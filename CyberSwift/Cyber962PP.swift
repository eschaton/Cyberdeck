//
//  Cyber962PP.swift
//  Cyber
//
//  Copyright © 2025 Christopher M. Hanson
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//


/// A Cyber 962 Peripheral Processor
///
/// The Cyber 962 does not do any I/O on its own; it uses a number of 16-bit Peripheral Processors to perform I/O on its behalf. These have either 4KW or 8KW of their own RAM and access to all of the Cyber 962 system's I/O channels, and can use those I/O channels on its behalf. They also have access to the entirety of the Cyber 962 systems' Central Memory, as a source or target for transfers.
///
/// - Note: Currently only the I0 processor model is emulated.
class Cyber962PP {

    // MARK: - System Interconnection
    
    /// The IOU this Peripheral Processor is a part of.
    var inputOutputUnit: Cyber962IOU
    
    /// The index of this Peripheral Procesor within the IOU.
    let index: Int

    /// The barrel this Peripheral Processor is part of.
    ///
    /// Within each IOU, each PP is organized by "barrel," with 5 PP per barrel. The barrels define which channels each PP gets access to, in addition to certain channels that are always accessible.
    var barrel: Int {
        return self.index % 5
    }

    /// The system this Central Processor is a part of.
    var system: Cyber962 {
        return inputOutputUnit.system
    }

    /// The different models of Peripheral Processor used in Cyber 962 systems.
    enum Model {
        case I0
        case I1
        case I2
        case I3
        case I4
    }

    /// The model of this peripheral processor.
    let model: Model = .I0

    // MARK: - Registers

    /// Arithmetic Register
    ///
    /// The Arithmetic Register (accumulator) is 18-bit.
    var regA: UInt32 {
        get { return self._regA }
        set { self._regA = newValue }
    }
    internal var _regA: UInt32 = 0

    /// Program Address Register
    ///
    /// The Program Address Register (program counter) is 16-bit.
    var regP: UInt16 {
        get { return self._regP }
        set { self._regP = newValue }
    }
    internal var _regP: UInt16

    /// Relocation Register
    ///
    /// The Relocation Register is used in conjunction with `A` to form an absolute Central Memory address.
    ///
    var regR: UInt32 {
        get { return self._regR }
        set { self._regR = newValue }
    }
    internal var _regR: UInt32 = 0


    // MARK: - Initialization

    /// Designated Intiailizer
    init(inputOutputUnit: Cyber962IOU, index: Int) {
        self.inputOutputUnit = inputOutputUnit
        self.index = index
        self._regA = inputOutputUnit.index == 0 ? 0o10000 : 0o20000
        self._regP = 0o1
    }


    // MARK: - PP Memory

    /// Raw memory of 16KW (since that's what the I0 model has).
    internal var _memory: [UInt16] = Array(repeating: 0, count: (16 * 1024))

    func read(from address: UInt16) -> UInt16 {
        return _memory[Int(address)]
    }

    func write(_ value: UInt16, to address: UInt16) {
        _memory[Int(address)] = value
    }


    // MARK: - Instruction Decoding & Execution

    /// Decode all possible instructions.
    func decode(at address: UInt16) -> (any Cyber962PPInstruction)? {
        let instructionWord: UInt16 = self.read(from: address)

        // Check whether an instruction is prima facie invalid
        guard (instructionWord & 0o070000) == 0 else {
            return nil
        }

        if let f16di  = Cyber962PPInstruction16d.decode(word: instructionWord, at: address, on: self)    { return f16di }
        if let f16sci = Cyber962PPInstruction16sc.decode(word: instructionWord, at: address, on: self)   { return f16sci }
        if let f32dmi = Cyber962PPInstruction32dm.decode(word: instructionWord, at: address, on: self)   { return f32dmi }
        if let f32scmi = Cyber962PPInstruction32scm.decode(word: instructionWord, at: address, on: self) { return f32scmi }

        return nil
    }

    /// Execute one instruction.
    func executeNextInstruction() {
        let address = self.regP
        guard let instruction = self.decode(at: address) else {
            fatalError("Could not decode instruction at \(address)")
        }

        let shouldAdjustP = instruction.execute(on: self)
        if shouldAdjustP {
            let newP = address + instruction.stride
            self.regP = newP
        }
    }
}


// MARK: - Address Modes

/// The Cyber 962 Peripheral Processor has a small number of fairly orthogonal addressing modes.
enum Cyber962PPAddressMode {

    /// "No-Address" mode is what most other processors refer to as "immediate" mode, and treats `d` as a 6-bit quantity.
    case noAddress(d: UInt8)

    /// "Constant" mode is what most other processors refer to as "extended immediate" mode, where it treats the least significant 6 bits of `d` as the most significant bits and the least significant 12 bits of `m` as the least significant bits as an 18-bit quanitty.
    case constant(d: UInt8, m: UInt16)

    /// Direct mode uses the least significant 6 bits of `d` as the address of a 12-bit or 16-bit word in memory.
    case direct(d: UInt8)

    /// Indirect mode uses the least significant 6 bits of `d` as the address of a word in memory that is used as the address of the 12-bit or 16-bit word in memory.
    case indirect(d: UInt8)

    /// "Memory" mode is what most other processors refer to as "indexed" mode, and uses the `d` and `m` fields to compose the address of a 12-bit or 16-bit word in memory, according to the following rules:
    ///
    /// 1. If `d` is `0`, `m` is the address to use.
    /// 2. If `d` is nonzero, `d` is the address of a 12-bit word that is added to `m` to generate an address.
    case memory(d: UInt8, m: UInt16)

    /// "Block I/O & Central Memory Access" mode is used to form addresses specifically for block I/O and Central Memory Access instructions.
    case io(d: UInt8, m: UInt16)

    /// The `d` value.
    var d: UInt8 {
        switch self {
        case let .noAddress(d: d):      return d
        case let .constant(d: d, m: _): return d
        case let .direct(d: d):         return d
        case let .indirect(d: d):       return d
        case let .memory(d: d, m: _):   return d
        case let .io(d: d, m: _):       return d
        }
    }

    /// The `m` value.
    var m: UInt16 {
        switch self {
        case let .constant(d: _, m: m): return m
        case let .memory(d: _, m: m):   return m
        case let .io(d: _, m: m):       return m
        default:                        return 0
        }
    }

    /// The combined `dm` value, an 18-bit quantity.
    var dm: UInt32 {
        let d32: UInt32 = UInt32(self.d & 0x3F)
        let m32: UInt32 = UInt32(self.m & 0x0FFF)
        return (d32 << 12) | m32
    }

    /// The `c` value, a 5-bit quantity derived from `d`.
    var c: UInt8 {
        return self.d & 0x1F
    }

    /// The `s` vaue, a boolean derived from `d`.
    var s: Bool {
        return (self.d & 0x20) == 0x20
    }

    /// Disassemble this effective address reference to the canonical format.
    func disassemble() -> String {
        switch self {
        case let .noAddress(d: d):      return "\(d)"
        case let .constant(d: d, m: m): return "\(m)+\(d)"
        case let .direct(d: d):         return "(\(d))"
        case let .indirect(d: d):       return "((\(d)))"
        case let .memory(d: d, m: m):   return "(\(m)+(\(d)))"
        case let .io(d: _, m: m):       return "\(self.c),\(m)"
        }
    }

    /// Compute the effective address represented by this address mode on the given processor, or `nil` if one canot be computed (say for ``.noAddress`` and ``.constant(d:m:)`` modes.
    func effectiveAddress(on processor: Cyber962PP) -> UInt16? {
        switch self {
        case .noAddress(d: _), .constant(d: _, m: _):
            // These modes do not involve an address computation.
            return nil

        case let .direct(d: d):
            return UInt16(d)

        case let .indirect(d: d):
            return processor.read(from: UInt16(d))

        case let .memory(d: d, m: m):
            return (d == 0) ? m : (m + processor.read(from: UInt16(d)))

        case let .io(d: _, m: m):
            // The `d` value is unused by effective address calculation by block I/O & Central Memory Access instructions, the `m` value is just an address.
            return m
        }
    }
}


// MARK: - Instructions

protocol Cyber962PPInstruction {

    /// The adjustment to apply to `P` to get the following instruction.
    var stride: UInt16 { get }

    /// The addressing mode for this decoded instruction.
    ///
    /// While an instruction always has one of these, some specific instruction implementations may ignore it and use instruction fields directly.
    var addressMode: Cyber962PPAddressMode { get }

    /// The mnemonic representing this instruction in disassembly.
    ///
    /// For *most* instructions, their disassembly can be just the mnemonic, whitespace, and the disassembly of the address mode.
    var mnemonic: String { get }

    /// Decode an instruction.
    ///
    /// Tries to decode an instruction of this type from the given word, returning `nil` if one isn't present.
    ///
    /// Since fully decoding an instruction may require an additional memory access, the processor must also be passed.
    static func decode(word: UInt16, at address: UInt16, on processor: Cyber962PP) -> Self?

    /// Disassemble the instruction.
    func disassemble() -> String

    /// Execute the instruction.
    ///
    /// Performs the operation corresponding to the instruction and returns whether to automatically update `P`.
    /// (Branch/jump instructions can update `P` themselves.)
    func execute(on processor: Cyber962PP) -> Bool
}

extension Cyber962PPInstruction {

    /// Extract the fields from an instruction word. Since `c` is the high bit of `d` we don't pass it separately.
    static func extract(from word: UInt16) -> (g: UInt8, f: UInt8, d: UInt8) {
        let g: UInt8 = UInt8((word & 0x8000) >> 15)
        let f: UInt8 = UInt8((word & 0x0FC0) >>  6)
        let d: UInt8 = UInt8((word & 0x003F) >>  0)
        return (g: g, f: f, d: d)
    }

    /// Default helper implementation, so it can be called by implementors of the protocol to simplify their implementation.
    func defaultDisassemble() -> String {
        return self.mnemonic + " " + self.addressMode.disassemble()
    }

    /// Default implementation.
    func disassemble() -> String {
        return self.defaultDisassemble()
    }
}

/// A 16-bit Cyber 962 Peripheral Processor instruction.
protocol Cyber962PPInstruction16: Cyber962PPInstruction {
}

extension Cyber962PPInstruction16 {
    var stride: UInt16 { return 1 }
}

/// A 16-bit Cyber 962 Peripheral Processor `d`-format instruction.
enum Cyber962PPInstruction16d: Cyber962PPInstruction16 {
    case LDN(d: UInt8)
    case LCN(d: UInt8)
    case LDD(d: UInt8)
    case LDDL(d: UInt8)
    case STD(d: UInt8)
    case STDL(d: UInt8)
    case LDI(d: UInt8)
    case LDIL(d: UInt8)
    case STI(d: UInt8)
    case STIL(d: UInt8)
    case ADN(d: UInt8)
    case SBN(d: UInt8)
    case ADD(d: UInt8)
    case ADDL(d: UInt8)
    case SBD(d: UInt8)
    case SBDL(d: UInt8)
    case ADI(d: UInt8)
    case ADIL(d: UInt8)
    case SBI(d: UInt8)
    case SBIL(d: UInt8)
    case SHN(d: UInt8)
    case SHDL(d: UInt8)
    case LMN(d: UInt8)
    case LPN(d: UInt8)
    case SCN(d: UInt8)
    case LPDL(d: UInt8)
    case LPIL(d: UInt8)
    case LMD(d: UInt8)
    case LMDL(d: UInt8)
    case LMI(d: UInt8)
    case LMIL(d: UInt8)
    case RAD(d: UInt8)
    case RADL(d: UInt8)
    case AOD(d: UInt8)
    case AODL(d: UInt8)
    case SOD(d: UInt8)
    case SODL(d: UInt8)
    case RAI(d: UInt8)
    case RAIL(d: UInt8)
    case AOI(d: UInt8)
    case AOIL(d: UInt8)
    case SOI(d: UInt8)
    case SOIL(d: UInt8)
    case UNJ(d: UInt8)
    case ZJN(d: UInt8)
    case NJN(d: UInt8)
    case PJN(d: UInt8)
    case MJN(d: UInt8)
    case LRD(d: UInt8)
    case SRD(d: UInt8)
    case LRDL(d: UInt8)
    case SRDL(d: UInt8)
    case LRIL(d: UInt8)
    case SRIL(d: UInt8)
    case CRD(d: UInt8)
    case CRDL(d: UInt8)
    case CWD(d: UInt8)
    case CWDL(d: UInt8)
    case RDSL(d: UInt8)
    case RDCL(d: UInt8)
    case PSN(d: UInt8)
    case WAIT(d: UInt8)
    case KEYP(d: UInt8)
    case INPN(d: UInt8)
    case EXN
    case MXN
    case MAN

    var addressMode: Cyber962PPAddressMode {
        switch self {
        case let .LDN(d: d): return .noAddress(d: d)
        case let .LCN(d: d): return .noAddress(d: d)
        case let .LDD(d: d): return .direct(d: d)
        case let .LDDL(d: d): return .direct(d: d)
        case let .STD(d: d): return .direct(d: d)
        case let .STDL(d: d): return .direct(d: d)
        case let .LDI(d: d): return .indirect(d: d)
        case let .LDIL(d: d): return .indirect(d: d)
        case let .STI(d: d): return .indirect(d: d)
        case let .STIL(d: d): return .indirect(d: d)
        case let .ADN(d: d): return .noAddress(d: d)
        case let .SBN(d: d): return .noAddress(d: d)
        case let .ADD(d: d): return .direct(d: d)
        case let .ADDL(d: d): return .direct(d: d)
        case let .SBD(d: d): return .direct(d: d)
        case let .SBDL(d: d): return .direct(d: d)
        case let .ADI(d: d): return .indirect(d: d)
        case let .ADIL(d: d): return .indirect(d: d)
        case let .SBI(d: d): return .indirect(d: d)
        case let .SBIL(d: d): return .indirect(d: d)
        case let .SHN(d: d): return .noAddress(d: d)
        case let .SHDL(d: d): return .direct(d: d)
        case let .LMN(d: d): return .noAddress(d: d)
        case let .LPN(d: d): return .noAddress(d: d)
        case let .SCN(d: d): return .noAddress(d: d)
        case let .LPDL(d: d): return .direct(d: d)
        case let .LPIL(d: d): return .indirect(d: d)
        case let .LMD(d: d): return .direct(d: d)
        case let .LMDL(d: d): return .direct(d: d)
        case let .LMI(d: d): return .indirect(d: d)
        case let .LMIL(d: d): return .indirect(d: d)
        case let .RAD(d: d): return .direct(d: d)
        case let .RADL(d: d): return .direct(d: d)
        case let .AOD(d: d): return .direct(d: d)
        case let .AODL(d: d): return .direct(d: d)
        case let .SOD(d: d): return .direct(d: d)
        case let .SODL(d: d): return .direct(d: d)
        case let .RAI(d: d): return  .indirect(d: d)
        case let .RAIL(d: d): return .indirect(d: d)
        case let .AOI(d: d): return  .indirect(d: d)
        case let .AOIL(d: d): return .indirect(d: d)
        case let .SOI(d: d): return  .indirect(d: d)
        case let .SOIL(d: d): return .indirect(d: d)
        case let .UNJ(d: d): return  .noAddress(d: d)
        case let .ZJN(d: d): return  .noAddress(d: d)
        case let .NJN(d: d): return  .noAddress(d: d)
        case let .PJN(d: d): return  .noAddress(d: d)
        case let .MJN(d: d): return  .noAddress(d: d)
        case let .LRD(d: d): return  .direct(d: d)
        case let .SRD(d: d): return  .direct(d: d)
        case let .LRDL(d: d): return .direct(d: d)
        case let .SRDL(d: d): return .direct(d: d)
        case let .LRIL(d: d): return .indirect(d: d)
        case let .SRIL(d: d): return .indirect(d: d)
        case let .CRD(d: d): return  .direct(d: d)
        case let .CRDL(d: d): return .direct(d: d)
        case let .CWD(d: d): return  .direct(d: d)
        case let .CWDL(d: d): return .direct(d: d)
        case let .RDSL(d: d): return .direct(d: d)
        case let .RDCL(d: d): return .direct(d: d)
        case let .PSN(d: d): return  .noAddress(d: d)
        case let .WAIT(d: d): return .noAddress(d: d)
        case let .KEYP(d: d): return .noAddress(d: d)
        case let .INPN(d: d): return .noAddress(d: d)
        case .EXN: return .noAddress(d: 0)
        case .MXN: return .noAddress(d: 0)
        case .MAN: return .noAddress(d: 0)
        }
    }

    var mnemonic: String {
        switch self {
        case .LDN(d: _):  return "LDN"
        case .LCN(d: _):  return "LCN"
        case .LDD(d: _):  return "LDD"
        case .LDDL(d: _): return "LDDL"
        case .STD(d: _):  return "STD"
        case .STDL(d: _): return "STDL"
        case .LDI(d: _):  return "LDI"
        case .LDIL(d: _): return "LDIL"
        case .STI(d: _):  return "STI"
        case .STIL(d: _): return "STIL"
        case .ADN(d: _):  return "ADN"
        case .SBN(d: _):  return "SBN"
        case .ADD(d: _):  return "ADD"
        case .ADDL(d: _): return "ADDL"
        case .SBD(d: _):  return "SBD"
        case .SBDL(d: _): return "SBDL"
        case .ADI(d: _):  return "ADI"
        case .ADIL(d: _): return "ADIL"
        case .SBI(d: _):  return "SBI"
        case .SBIL(d: _): return "SBIL"
        case .SHN(d: _):  return "SHN"
        case .SHDL(d: _): return "SHDL"
        case .LMN(d: _):  return "LMN"
        case .LPN(d: _):  return "LPN"
        case .SCN(d: _):  return "SCN"
        case .LPDL(d: _): return "LPDL"
        case .LPIL(d: _): return "LPIL"
        case .LMD(d: _):  return "LMD"
        case .LMDL(d: _): return "LMDL"
        case .LMI(d: _):  return "LMI"
        case .LMIL(d: _): return "LMIL"
        case .RAD(d: _):  return "RAD"
        case .RADL(d: _): return "RADL"
        case .AOD(d: _):  return "AOD"
        case .AODL(d: _): return "AODL"
        case .SOD(d: _):  return "SOD"
        case .SODL(d: _): return "SODL"
        case .RAI(d: _):  return "RAI"
        case .RAIL(d: _): return "RAIL"
        case .AOI(d: _):  return "AOI"
        case .AOIL(d: _): return "AOIL"
        case .SOI(d: _):  return "SOI"
        case .SOIL(d: _): return "SOIL"
        case .UNJ(d: _):  return "UNJ"
        case .ZJN(d: _):  return "ZJN"
        case .NJN(d: _):  return "NJN"
        case .PJN(d: _):  return "PJN"
        case .MJN(d: _):  return "MJN"
        case .LRD(d: _):  return "LRD"
        case .SRD(d: _):  return "SRD"
        case .LRDL(d: _): return "LRDL"
        case .SRDL(d: _): return "SRDL"
        case .LRIL(d: _): return "LRIL"
        case .SRIL(d: _): return "SRIL"
        case .CRD(d: _):  return "CRD"
        case .CRDL(d: _): return "CRDL"
        case .CWD(d: _):  return "CWD"
        case .CWDL(d: _): return "CWDL"
        case .RDSL(d: _): return "RDSL"
        case .RDCL(d: _): return "RDCL"
        case .PSN(d: _):  return "PSN"
        case .WAIT(d: _): return "WAIT"
        case .KEYP(d: _): return "KEYP"
        case .INPN(d: _): return "INPN"
        case .EXN:        return "EXN"
        case .MXN:        return "MXN"
        case .MAN:        return "MAN"
        }
    }

    static func decode(word: UInt16, at address: UInt16, on processor: Cyber962PP) -> Self? {
        let (g, f, d) = Self.extract(from: word)

        switch f {
        case 0o00: if g == 0 { return .PSN(d: d)  } else { return .RDSL(d: d) }
        case 0o01: if g == 0 { return nil         } else { return .RDCL(d: d) }
            // 0o02
        case 0o03: if g == 0 { return .UNJ(d: d)  } else { return nil         }
        case 0o04: if g == 0 { return .ZJN(d: d)  } else { return nil         }
        case 0o05: if g == 0 { return .NJN(d: d)  } else { return nil         }
        case 0o06: if g == 0 { return .PJN(d: d)  } else { return nil         }
        case 0o07: if g == 0 { return .MJN(d: d)  } else { return nil         }
        case 0o10: if g == 0 { return .SHN(d: d)  } else { return .SHDL(d: d) }
        case 0o11: if g == 0 { return .LMN(d: d)  } else { return .LRDL(d: d) }
        case 0o12: if g == 0 { return .LPN(d: d)  } else { return .LRIL(d: d) }
        case 0o13: if g == 0 { return .SCN(d: d)  } else { return nil         }
        case 0o14: if g == 0 { return .LDN(d: d)  } else { return .SRD(d: d)  }
        case 0o15: if g == 0 { return .LCN(d: d)  } else { return .SRIL(d: d) }
        case 0o16: if g == 0 { return .ADN(d: d)  } else { return nil         }
        case 0o17: if g == 0 { return .SBN(d: d)  } else { return .WAIT(d: d) }
            // 0o20...0o21
        case 0o22: if g == 0 { return nil         } else { return .LPDL(d: d) }
        case 0o23: if g == 0 { return nil         } else { return .LPIL(d: d) }
        case 0o24: if g == 0 { return .LRD(d: d)  } else { return nil         }
        case 0o25: if g == 0 { return .SRD(d: d)  } else { return nil         }
        case 0o26: if g == 0 {
            switch (d & 0o70) {
            case 0o00:         return .EXN
            case 0o10:         return .MXN
            case 0o20, 0o30:   return .MAN
            default:           return nil
            }
        } else { return .INPN(d: d) }
        case 0o27: if g == 0 { return .KEYP(d: d) } else { return nil         }
        case 0o30: if g == 0 { return .LDD(d: d)  } else { return .LDDL(d: d) }
        case 0o31: if g == 0 { return .ADD(d: d)  } else { return .ADDL(d: d) }
        case 0o32: if g == 0 { return .SBD(d: d)  } else { return .SBDL(d: d) }
        case 0o33: if g == 0 { return .LMD(d: d)  } else { return .LMDL(d: d) }
        case 0o34: if g == 0 { return .STD(d: d)  } else { return .STDL(d: d) }
        case 0o35: if g == 0 { return .RAD(d: d)  } else { return .RADL(d: d) }
        case 0o36: if g == 0 { return .AOD(d: d)  } else { return .AODL(d: d) }
        case 0o37: if g == 0 { return .SOD(d: d)  } else { return .SODL(d: d) }
        case 0o40: if g == 0 { return .LDI(d: d)  } else { return .LDIL(d: d) }
        case 0o41: if g == 0 { return .ADI(d: d)  } else { return .ADIL(d: d) }
        case 0o42: if g == 0 { return .SBI(d: d)  } else { return .SBIL(d: d) }
        case 0o43: if g == 0 { return .LMI(d: d)  } else { return .LMIL(d: d) }
        case 0o44: if g == 0 { return .STI(d: d)  } else { return .STIL(d: d) }
        case 0o45: if g == 0 { return .RAI(d: d)  } else { return .RAIL(d: d) }
        case 0o46: if g == 0 { return .AOI(d: d)  } else { return .AOIL(d: d) }
        case 0o47: if g == 0 { return .SOI(d: d)  } else { return .SOIL(d: d) }
            // 0o50...0o57
        case 0o60: if g == 0 { return .CRD(d: d)  } else { return .CRDL(d: d) }
            // 0o61
        case 0o62: if g == 0 { return .CWD(d: d)  } else { return .CWDL(d: d) }
            // 0o63...0o77

        default: return nil
        }
    }

    func disassemble() -> String {
        switch self {
        case .EXN, .MXN, .MAN: return mnemonic
        default: return self.defaultDisassemble()
        }
    }

    func execute(on processor: Cyber962PP) -> Bool {
        switch self {
        case .LDN(d: _): LDN(on: processor)
        case .LCN(d: _): LCN(on: processor)
        case .LDD(d: _): LDD(on: processor)
        case .LDDL(d: _): LDDL(on: processor)
        case .STD(d: _): STD(on: processor)
        case .STDL(d: _): STDL(on: processor)
        case .LDI(d: _): LDI(on: processor)
        case .LDIL(d: _): LDIL(on: processor)
        case .STI(d: _): STI(on: processor)
        case .STIL(d: _): STIL(on: processor)
        case .ADN(d: _): ADN(on: processor)
        case .SBN(d: _): SBN(on: processor)
        case .ADD(d: _): ADD(on: processor)
        case .ADDL(d: _): ADDL(on: processor)
        case .SBD(d: _): SBD(on: processor)
        case .SBDL(d: _): SBDL(on: processor)
        case .ADI(d: _): ADI(on: processor)
        case .ADIL(d: _): ADIL(on: processor)
        case .SBI(d: _): SBI(on: processor)
        case .SBIL(d: _): SBIL(on: processor)
        case .SHN(d: _): SHN(on: processor)
        case .SHDL(d: _): SHDL(on: processor)
        case .LMN(d: _): LMN(on: processor)
        case .LPN(d: _): LPN(on: processor)
        case .SCN(d: _): SCN(on: processor)
        case .LPDL(d: _): LPDL(on: processor)
        case .LPIL(d: _): LPIL(on: processor)
        case .LMD(d: _): LMD(on: processor)
        case .LMDL(d: _): LMDL(on: processor)
        case .LMI(d: _): LMI(on: processor)
        case .LMIL(d: _): LMIL(on: processor)
        case .RAD(d: _): RAD(on: processor)
        case .RADL(d: _): RADL(on: processor)
        case .AOD(d: _): AOD(on: processor)
        case .AODL(d: _): AODL(on: processor)
        case .SOD(d: _): SOD(on: processor)
        case .SODL(d: _): SODL(on: processor)
        case .RAI(d: _): RAI(on: processor)
        case .RAIL(d: _): RAIL(on: processor)
        case .AOI(d: _): AOI(on: processor)
        case .AOIL(d: _): AOIL(on: processor)
        case .SOI(d: _): SOI(on: processor)
        case .SOIL(d: _): SOIL(on: processor)
        case .UNJ(d: _): UNJ(on: processor)
        case .ZJN(d: _): ZJN(on: processor)
        case .NJN(d: _): NJN(on: processor)
        case .PJN(d: _): PJN(on: processor)
        case .MJN(d: _): MJN(on: processor)
        case .LRD(d: _): LRD(on: processor)
        case .SRD(d: _): SRD(on: processor)
        case .LRDL(d: _): LRDL(on: processor)
        case .SRDL(d: _): SRDL(on: processor)
        case .LRIL(d: _): LRIL(on: processor)
        case .SRIL(d: _): SRIL(on: processor)
        case .CRD(d: _): CRD(on: processor)
        case .CRDL(d: _): CRDL(on: processor)
        case .CWD(d: _): CWD(on: processor)
        case .CWDL(d: _): CWDL(on: processor)
        case .RDSL(d: _): RDSL(on: processor)
        case .RDCL(d: _): RDCL(on: processor)
        case .PSN(d: _): PSN(on: processor)
        case .WAIT(d: _): WAIT(on: processor)
        case .KEYP(d: _): KEYP(on: processor)
        case .INPN(d: _): INPN(on: processor)
        case .EXN: EXN(on: processor)
        case .MXN: MXN(on: processor)
        case .MAN: MAN(on: processor)
        }
        return true
    }

    internal func load(on processor: Cyber962PP, long: Bool = false) {
        let mode = self.addressMode
        let value: UInt32
        if let address = mode.effectiveAddress(on: processor) {
            let mask: UInt16 = long ? 0xFFFF : 0x0FFF
            value = UInt32(processor.read(from: address) & mask)
        } else {
            value = mode.dm
        }
        processor.regA = value
    }

    internal func loadComplement(on processor: Cyber962PP) {
        let dc: UInt32 = UInt32(~self.addressMode.d & 0x3F)
        let newA: UInt32 = 0x0003_FFC0 | dc
        processor.regA = newA
    }

    internal func store(on processor: Cyber962PP, long: Bool = false) {
        let mode = self.addressMode
        let mask: UInt32 = long ? 0x0000_FFFF : 0x0000_0FFF
        let value: UInt16 = UInt16(processor.regA & mask)
        if let address = mode.effectiveAddress(on: processor) {
            processor.write(value, to: address)
        } else {
            fatalError("store only operates on memory")
        }
    }

    internal func LDN(on processor: Cyber962PP) {
        self.load(on: processor)
    }

    internal func LCN(on processor: Cyber962PP) {
        self.loadComplement(on: processor)
    }

    internal func LDD(on processor: Cyber962PP) {
        self.load(on: processor)
    }

    internal func LDDL(on processor: Cyber962PP) {
        self.load(on: processor, long: true)
    }

    internal func STD(on processor: Cyber962PP) {
        self.store(on: processor)
    }

    internal func STDL(on processor: Cyber962PP) {
        self.store(on: processor, long: true)
    }

    internal func LDI(on processor: Cyber962PP) {
        self.load(on: processor)
    }

    internal func LDIL(on processor: Cyber962PP) {
        self.load(on: processor, long: true)
    }

    internal func STI(on processor: Cyber962PP) {
        self.store(on: processor)
    }

    internal func STIL(on processor: Cyber962PP) {
        self.store(on: processor, long: true)
    }

    internal func ADN(on processor: Cyber962PP) {
    }

    internal func SBN(on processor: Cyber962PP) {
    }

    internal func ADD(on processor: Cyber962PP) {
    }

    internal func ADDL(on processor: Cyber962PP) {
    }

    internal func SBD(on processor: Cyber962PP) {
    }

    internal func SBDL(on processor: Cyber962PP) {
    }

    internal func ADI(on processor: Cyber962PP) {
    }

    internal func ADIL(on processor: Cyber962PP) {
    }

    internal func SBI(on processor: Cyber962PP) {
    }

    internal func SBIL(on processor: Cyber962PP) {
    }

    internal func SHN(on processor: Cyber962PP) {
    }

    internal func SHDL(on processor: Cyber962PP) {
    }

    internal func LMN(on processor: Cyber962PP) {
    }

    internal func LPN(on processor: Cyber962PP) {
    }

    internal func SCN(on processor: Cyber962PP) {
    }

    internal func LPDL(on processor: Cyber962PP) {
    }

    internal func LPIL(on processor: Cyber962PP) {
    }

    internal func LMD(on processor: Cyber962PP) {
    }

    internal func LMDL(on processor: Cyber962PP) {
    }

    internal func LMI(on processor: Cyber962PP) {
    }

    internal func LMIL(on processor: Cyber962PP) {
    }

    internal func RAD(on processor: Cyber962PP) {
    }

    internal func RADL(on processor: Cyber962PP) {
    }

    internal func AOD(on processor: Cyber962PP) {
    }

    internal func AODL(on processor: Cyber962PP) {
    }

    internal func SOD(on processor: Cyber962PP) {
    }

    internal func SODL(on processor: Cyber962PP) {
    }

    internal func RAI(on processor: Cyber962PP) {
    }

    internal func RAIL(on processor: Cyber962PP) {
    }

    internal func AOI(on processor: Cyber962PP) {
    }

    internal func AOIL(on processor: Cyber962PP) {
    }

    internal func SOI(on processor: Cyber962PP) {
    }

    internal func SOIL(on processor: Cyber962PP) {
    }

    internal func UNJ(on processor: Cyber962PP) {
    }

    internal func ZJN(on processor: Cyber962PP) {
    }

    internal func NJN(on processor: Cyber962PP) {
    }

    internal func PJN(on processor: Cyber962PP) {
    }

    internal func MJN(on processor: Cyber962PP) {
    }

    internal func LRD(on processor: Cyber962PP) {
    }

    internal func SRD(on processor: Cyber962PP) {
    }

    internal func LRDL(on processor: Cyber962PP) {
    }

    internal func SRDL(on processor: Cyber962PP) {
    }

    internal func LRIL(on processor: Cyber962PP) {
    }

    internal func SRIL(on processor: Cyber962PP) {
    }

    internal func CRD(on processor: Cyber962PP) {
    }

    internal func CRDL(on processor: Cyber962PP) {
    }

    internal func CWD(on processor: Cyber962PP) {
    }

    internal func CWDL(on processor: Cyber962PP) {
    }

    internal func RDSL(on processor: Cyber962PP) {
    }

    internal func RDCL(on processor: Cyber962PP) {
    }

    internal func PSN(on processor: Cyber962PP) {
    }

    internal func WAIT(on processor: Cyber962PP) {
    }

    internal func KEYP(on processor: Cyber962PP) {
    }

    internal func INPN(on processor: Cyber962PP) {
    }

    internal func EXN(on processor: Cyber962PP) {
    }

    internal func MXN(on processor: Cyber962PP) {
    }

    internal func MAN(on processor: Cyber962PP) {
    }
}

/// A 16-bit Cyber 962 Peripheral Processor `sc`-format instruction.
///
/// A 16sc instruction has the format:
///
///     | 48 | 49 | 50 | 51 | 52 | 53 | 54 | 55 | 56 | 57 | 58 | 59 | 60 | 61 | 62 | 63 |
///     | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- |
///     |  g |  0    0    0 |              f              |  s |           c            |
///
/// For instructions that support it, the `s` bit means "wait until active" when set and "skip if inactive" when clear.
enum Cyber962PPInstruction16sc: Cyber962PPInstruction16 {
    case IAN(s: Bool, c: UInt8) // 0070sc
    case OAN(s: Bool, c: UInt8) // 0072sc
    case ACN(s: Bool, c: UInt8) // 0074sc
    case DCN(s: Bool, c: UInt8) // 0075sc
    case FAN(s: Bool, c: UInt8) // 0076sc
    case MCLR(c: UInt8) // 1074xc

    var addressMode: Cyber962PPAddressMode {
        switch self {
        case let .IAN(s: s, c: c): return .noAddress(d: ((s ? 0 : 1) << 6) | c)
        case let .OAN(s: s, c: c): return .noAddress(d: ((s ? 0 : 1) << 6) | c)
        case let .ACN(s: s, c: c): return .noAddress(d: ((s ? 0 : 1) << 6) | c)
        case let .DCN(s: s, c: c): return .noAddress(d: ((s ? 0 : 1) << 6) | c)
        case let .FAN(s: s, c: c): return .noAddress(d: ((s ? 0 : 1) << 6) | c)
        case let .MCLR(c: c):      return .noAddress(d: c)
        }
    }

    var mnemonic: String {
        func ss(_ s: Bool) -> String {
            return s ? ".W" : ".I"
        }

        switch self {
        case let .IAN(s: s, c: _): return "IAN\(ss(s))"
        case let .OAN(s: s, c: _): return "OAN\(ss(s))"
        case let .ACN(s: s, c: _): return "ACN\(ss(s))"
        case let .DCN(s: s, c: _): return "DCN\(ss(s))"
        case let .FAN(s: s, c: _): return "FAN\(ss(s))"
        case     .MCLR(c: _):      return "MCLR"
        }
    }

    var c: UInt8 {
        switch self {
        case let .IAN(s: _, c: c): return c
        case let .OAN(s: _, c: c): return c
        case let .ACN(s: _, c: c): return c
        case let .DCN(s: _, c: c): return c
        case let .FAN(s: _, c: c): return c
        case let .MCLR(c: c):      return c
        }
    }

    static func decode(word: UInt16, at address: UInt16, on processor: Cyber962PP) -> Self? {
        let (g, f, d) = Self.extract(from: word)
        let s = (d & 0o40) == 0o40
        let c = (d & 0o37)

        switch f {
        case 0o70: return .IAN(s: s, c: c)
        case 0o72: return .OAN(s: s, c: c)
        case 0o74:
            if (g == 0) {
                return    .ACN(s: s, c: c)
            } else {
                return    .MCLR(c: c)
            }
        case 0o75: return .DCN(s: s, c: c)
        case 0o76: return .FAN(s: s, c: c)

        default: return nil
        }
    }

    func disassemble() -> String {
        return self.mnemonic + " " + "\(self.c)"
    }

    func execute(on processor: Cyber962PP) -> Bool {
        switch self {
        case .IAN(s: _, c: _): IAN(on: processor)
        case .OAN(s: _, c: _): OAN(on: processor)
        case .ACN(s: _, c: _): ACN(on: processor)
        case .DCN(s: _, c: _): DCN(on: processor)
        case .FAN(s: _, c: _): FAN(on: processor)
        case .MCLR(c: _):      MCLR(on: processor)
        }
        return true
    }

    /// Input to `A` from channel `c` when or if active, depending on whether `s` is `0` or `1`.
    internal func IAN(on processor: Cyber962PP) {
        let mode = self.addressMode
        let channel = processor.inputOutputUnit.channels[Int(mode.c)]
        let values = channel.input(count: 1, skipIfNotActiveAndFull: mode.s)
        processor.regA = UInt32(values[0])
    }

    /// Output from `A` to channel `c` when or if active, depending on whether `s` is `0` or `1`.
    internal func OAN(on processor: Cyber962PP) {
        let mode = self.addressMode
        let channel = processor.inputOutputUnit.channels[Int(mode.c)]
        let lowA = UInt16(processor.regA)
        channel.output(words: [lowA], skipIfNotActive: mode.s)
    }

    /// Activate channel `c` when inactive or unconditionally, depending on `s`.
    internal func ACN(on processor: Cyber962PP) {
        let mode = self.addressMode
        let channel = processor.inputOutputUnit.channels[Int(mode.c)]
        let waitForInactive = !mode.s
        channel.activate(onceInactive: waitForInactive)
    }

    internal func DCN(on processor: Cyber962PP) {
        let mode = self.addressMode
        let channel = processor.inputOutputUnit.channels[Int(mode.c)]
        let waitForActive = !mode.s
        channel.deactivate(onceActive: waitForActive)
    }

    internal func FAN(on processor: Cyber962PP) {
        let mode = self.addressMode
        let channel = processor.inputOutputUnit.channels[Int(mode.c)]
        let skipIfActive = mode.s
        let lowA: UInt16 = UInt16(processor.regA) // we'll only use the lower 12 or 16 bits
        channel.function(lowA, skipIfActive: skipIfActive)
    }

    /// Master Clear I/O channel `c` marking it active and empty.
    ///
    /// - Note: Only supported on model I0.
    internal func MCLR(on processor: Cyber962PP) {
        guard processor.model == .I0 else {
            fatalError("Only supported on I0")
        }

        let c = self.addressMode.c
        let channel = processor.inputOutputUnit.channels[Int(c)]
        channel.masterClear()
    }
}

protocol Cyber962PPInstruction32: Cyber962PPInstruction {
}

extension Cyber962PPInstruction32 {
    var stride: UInt16 { return 2 }
}

enum Cyber962PPInstruction32dm: Cyber962PPInstruction32 {
    case LDC(d: UInt8, m: UInt16)  // 0o0020
    case LDM(d: UInt8, m: UInt16)  // 0o0050
    case LDML(d: UInt8, m: UInt16) // 0o1050
    case STM(d: UInt8, m: UInt16)  // 0o0054
    case STML(d: UInt8, m: UInt16) // 0o1054
    case ADC(d: UInt8, m: UInt16)  // 0o0021
    case ADM(d: UInt8, m: UInt16)  // 0o0051
    case ADML(d: UInt8, m: UInt16) // 0o1051
    case SBM(d: UInt8, m: UInt16)  // 0o0052
    case SBML(d: UInt8, m: UInt16) // 0o1052
    case LPC(d: UInt8, m: UInt16)  // 0o0022
    case LPML(d: UInt8, m: UInt16) // 0o1024
    case LMC(d: UInt8, m: UInt16)  // 0o0023
    case LMM(d: UInt8, m: UInt16)  // 0o0053
    case LMML(d: UInt8, m: UInt16) // 0o1053
    case RAM(d: UInt8, m: UInt16)  // 0o0055
    case RAML(d: UInt8, m: UInt16) // 0o1055
    case AOM(d: UInt8, m: UInt16)  // 0o0056
    case AOML(d: UInt8, m: UInt16) // 0o1056
    case SOM(d: UInt8, m: UInt16)  // 0o0057
    case SOML(d: UInt8, m: UInt16) // 0o1057
    case LJM(d: UInt8, m: UInt16)  // 0o0001
    case RJM(d: UInt8, m: UInt16)  // 0o0002
    case LRML(d: UInt8, m: UInt16) // 0o1013
    case SRML(d: UInt8, m: UInt16) // 0o1016
    case CRM(d: UInt8, m: UInt16)  // 0o0061
    case CRML(d: UInt8, m: UInt16) // 0o1061
    case CWM(d: UInt8, m: UInt16)  // 0o0063
    case CWML(d: UInt8, m: UInt16) // 0o1063

    var addressMode: Cyber962PPAddressMode {
        switch self {
        case let .LDC(d: d, m: m):  return .memory(d: d, m: m)
        case let .LDM(d: d, m: m):  return .memory(d: d, m: m)
        case let .LDML(d: d, m: m): return .memory(d: d, m: m)
        case let .STM(d: d, m: m):  return .memory(d: d, m: m)
        case let .STML(d: d, m: m): return .memory(d: d, m: m)
        case let .ADC(d: d, m: m):  return .memory(d: d, m: m)
        case let .ADM(d: d, m: m):  return .memory(d: d, m: m)
        case let .ADML(d: d, m: m): return .memory(d: d, m: m)
        case let .SBM(d: d, m: m):  return .memory(d: d, m: m)
        case let .SBML(d: d, m: m): return .memory(d: d, m: m)
        case let .LPC(d: d, m: m):  return .memory(d: d, m: m)
        case let .LPML(d: d, m: m): return .memory(d: d, m: m)
        case let .LMC(d: d, m: m):  return .memory(d: d, m: m)
        case let .LMM(d: d, m: m):  return .memory(d: d, m: m)
        case let .LMML(d: d, m: m): return .memory(d: d, m: m)
        case let .RAM(d: d, m: m):  return .memory(d: d, m: m)
        case let .RAML(d: d, m: m): return .memory(d: d, m: m)
        case let .AOM(d: d, m: m):  return .memory(d: d, m: m)
        case let .AOML(d: d, m: m): return .memory(d: d, m: m)
        case let .SOM(d: d, m: m):  return .memory(d: d, m: m)
        case let .SOML(d: d, m: m): return .memory(d: d, m: m)
        case let .LJM(d: d, m: m):  return .memory(d: d, m: m)
        case let .RJM(d: d, m: m):  return .memory(d: d, m: m)
        case let .LRML(d: d, m: m): return .memory(d: d, m: m)
        case let .SRML(d: d, m: m): return .memory(d: d, m: m)
        case let .CRM(d: d, m: m):  return .memory(d: d, m: m)
        case let .CRML(d: d, m: m): return .memory(d: d, m: m)
        case let .CWM(d: d, m: m):  return .memory(d: d, m: m)
        case let .CWML(d: d, m: m): return .memory(d: d, m: m)
        }
    }

    var mnemonic: String {
        switch self {
        case .LDC(d: _, m: _):  return "LDC"
        case .LDM(d: _, m: _):  return "LDM"
        case .LDML(d: _, m: _): return "LDML"
        case .STM(d: _, m: _):  return "STM"
        case .STML(d: _, m: _): return "STML"
        case .ADC(d: _, m: _):  return "ADC"
        case .ADM(d: _, m: _):  return "ADM"
        case .ADML(d: _, m: _): return "ADML"
        case .SBM(d: _, m: _):  return "SBM"
        case .SBML(d: _, m: _): return "SBML"
        case .LPC(d: _, m: _):  return "LPC"
        case .LPML(d: _, m: _): return "LPML"
        case .LMC(d: _, m: _):  return "LMC"
        case .LMM(d: _, m: _):  return "LMM"
        case .LMML(d: _, m: _): return "LMML"
        case .RAM(d: _, m: _):  return "RAM"
        case .RAML(d: _, m: _): return "RAML"
        case .AOM(d: _, m: _):  return "AOM"
        case .AOML(d: _, m: _): return "AOML"
        case .SOM(d: _, m: _):  return "SOM"
        case .SOML(d: _, m: _): return "SOML"
        case .LJM(d: _, m: _):  return "LJM"
        case .RJM(d: _, m: _):  return "RJM"
        case .LRML(d: _, m: _): return "LRML"
        case .SRML(d: _, m: _): return "SRML"
        case .CRM(d: _, m: _):  return "CRM"
        case .CRML(d: _, m: _): return "CRML"
        case .CWM(d: _, m: _):  return "CWM"
        case .CWML(d: _, m: _): return "CWML"
        }
    }

    static func decode(word: UInt16, at address: UInt16, on processor: Cyber962PP) -> Self? {
        let (g, f, d) = Self.extract(from: word)
        let m = processor.read(from: address + 1)

        switch f {
        case 0o20: if g == 0 { return .LDC(d: d, m: m) } else { return nil }
        case 0o50: if g == 0 { return .LDM(d: d, m: m) } else { return .LDML(d: d, m: m) }
        case 0o54: if g == 0 { return .STM(d: d, m: m) } else { return .STML(d: d, m: m) }
        case 0o21: if g == 0 { return .ADC(d: d, m: m) } else { return nil }
        case 0o51: if g == 0 { return .ADM(d: d, m: m) } else { return .ADML(d: d, m: m) }
        case 0o52: if g == 0 { return .SBM(d: d, m: m) } else { return .SBML(d: d, m: m) }
        case 0o22: if g == 0 { return .LPC(d: d, m: m) } else { return nil }
        case 0o24: if g == 0 { return nil }              else { return .LPML(d: d, m: m) }
        case 0o23: if g == 0 { return .LMC(d: d, m: m) } else { return nil }
        case 0o53: if g == 0 { return .LMM(d: d, m: m) } else { return .LMML(d: d, m: m) }
        case 0o55: if g == 0 { return .RAM(d: d, m: m) } else { return .RAML(d: d, m: m) }
        case 0o56: if g == 0 { return .AOM(d: d, m: m) } else { return .AOML(d: d, m: m) }
        case 0o57: if g == 0 { return .SOM(d: d, m: m) } else { return .SOML(d: d, m: m) }
        case 0o01: if g == 0 { return .LJM(d: d, m: m) } else { return nil }
        case 0o02: if g == 0 { return .RJM(d: d, m: m) } else { return nil }
        case 0o13: if g == 0 { return nil }              else { return .LRML(d: d, m: m) }
        case 0o16: if g == 0 { return nil }              else { return .SRML(d: d, m: m) }
        case 0o61: if g == 0 { return .CRM(d: d, m: m) } else { return .CRML(d: d, m: m) }
        case 0o63: if g == 0 { return .CWM(d: d, m: m) } else { return .CWML(d: d, m: m) }
        default: return nil
        }
    }

    func execute(on processor: Cyber962PP) -> Bool {
        switch self {
        case .LDC(d: _, m: _):  LDC(on: processor)
        case .LDM(d: _, m: _):  LDM(on: processor)
        case .LDML(d: _, m: _): LDML(on: processor)
        case .STM(d: _, m: _):  STM(on: processor)
        case .STML(d: _, m: _): STML(on: processor)
        case .ADC(d: _, m: _):  ADC(on: processor)
        case .ADM(d: _, m: _):  ADM(on: processor)
        case .ADML(d: _, m: _): ADML(on: processor)
        case .SBM(d: _, m: _):  SBM(on: processor)
        case .SBML(d: _, m: _): SBML(on: processor)
        case .LPC(d: _, m: _):  LPC(on: processor)
        case .LPML(d: _, m: _): LPML(on: processor)
        case .LMC(d: _, m: _):  LMC(on: processor)
        case .LMM(d: _, m: _):  LMM(on: processor)
        case .LMML(d: _, m: _): LMML(on: processor)
        case .RAM(d: _, m: _):  RAM(on: processor)
        case .RAML(d: _, m: _): RAML(on: processor)
        case .AOM(d: _, m: _):  AOM(on: processor)
        case .AOML(d: _, m: _): AOML(on: processor)
        case .SOM(d: _, m: _):  SOM(on: processor)
        case .SOML(d: _, m: _): SOML(on: processor)
        case .LJM(d: _, m: _):  LJM(on: processor)
        case .RJM(d: _, m: _):  RJM(on: processor)
        case .LRML(d: _, m: _): LRML(on: processor)
        case .SRML(d: _, m: _): SRML(on: processor)
        case .CRM(d: _, m: _):  CRM(on: processor)
        case .CRML(d: _, m: _): CRML(on: processor)
        case .CWM(d: _, m: _):  CWM(on: processor)
        case .CWML(d: _, m: _): CWML(on: processor)
        }
        return true
    }

    internal func LDC(on processor: Cyber962PP) {
    }

    internal func LDM(on processor: Cyber962PP) {
    }

    internal func LDML(on processor: Cyber962PP) {
    }

    internal func STM(on processor: Cyber962PP) {
    }

    internal func STML(on processor: Cyber962PP) {
    }

    internal func ADC(on processor: Cyber962PP) {
    }

    internal func ADM(on processor: Cyber962PP) {
    }

    internal func ADML(on processor: Cyber962PP) {
    }

    internal func SBM(on processor: Cyber962PP) {
    }

    internal func SBML(on processor: Cyber962PP) {
    }

    internal func LPC(on processor: Cyber962PP) {
    }

    internal func LPML(on processor: Cyber962PP) {
    }

    internal func LMC(on processor: Cyber962PP) {
    }

    internal func LMM(on processor: Cyber962PP) {
    }

    internal func LMML(on processor: Cyber962PP) {
    }

    internal func RAM(on processor: Cyber962PP) {
    }

    internal func RAML(on processor: Cyber962PP) {
    }

    internal func AOM(on processor: Cyber962PP) {
    }

    internal func AOML(on processor: Cyber962PP) {
    }

    internal func SOM(on processor: Cyber962PP) {
    }

    internal func SOML(on processor: Cyber962PP) {
    }

    internal func LJM(on processor: Cyber962PP) {
    }

    internal func RJM(on processor: Cyber962PP) {
    }

    internal func LRML(on processor: Cyber962PP) {
    }

    internal func SRML(on processor: Cyber962PP) {
    }

    internal func CRM(on processor: Cyber962PP) {
    }

    internal func CRML(on processor: Cyber962PP) {
    }

    internal func CWM(on processor: Cyber962PP) {
    }

    internal func CWML(on processor: Cyber962PP) {
    }
}

enum Cyber962PPInstruction32scm: Cyber962PPInstruction32 {
    case AJM(c: UInt8, m: UInt16) // 00640
    case SCF(c: UInt8, m: UInt16) // 00641
    case FSJM(c: UInt8, m: UInt16) // 1064X
    case IJM(c: UInt8, m: UInt16) // 00650
    case CCF(c: UInt8, m: UInt16) // 00651
    case FCJM(c: UInt8, m: UInt16) // 1065X
    case FJM(c: UInt8, m: UInt16) // 00660
    case SFM(c: UInt8, m: UInt16) // 00661
    case EJM(c: UInt8, m: UInt16) // 00670
    case CFM(c: UInt8, m: UInt16) // 00671
    case CHCM(c: UInt8, m: UInt16) // 1070X
    case IAM(c: UInt8, m: UInt16) // 0071X
    case IAPM(c: UInt8, m: UInt16) // 1071X
    case CMCH(c: UInt8, m: UInt16) // 1072X
    case OAM(c: UInt8, m: UInt16) // 0073X
    case OAPM(c: UInt8, m: UInt16) // 1073X
    case FNC(s: Bool, c: UInt8, m: UInt16) // 00770

    var addressMode: Cyber962PPAddressMode {
        func computeD(for s: Bool, using c: UInt8) -> UInt8 {
            return (((s ? 0 : 1) << 6) | c)
        }

        switch self {
        case let .AJM(c: c, m: m):       return .io(d: c, m: m)
        case let .SCF(c: c, m: m):       return .io(d: c, m: m)
        case let .FSJM(c: c, m: m):      return .io(d: c, m: m)
        case let .IJM(c: c, m: m):       return .io(d: c, m: m)
        case let .CCF(c: c, m: m):       return .io(d: c, m: m)
        case let .FCJM(c: c, m: m):      return .io(d: c, m: m)
        case let .FJM(c: c, m: m):       return .io(d: c, m: m)
        case let .SFM(c: c, m: m):       return .io(d: c, m: m)
        case let .EJM(c: c, m: m):       return .io(d: c, m: m)
        case let .CFM(c: c, m: m):       return .io(d: c, m: m)
        case let .CHCM(c: c, m: m):      return .io(d: c, m: m)
        case let .IAM(c: c, m: m):       return .io(d: c, m: m)
        case let .IAPM(c: c, m: m):      return .io(d: c, m: m)
        case let .CMCH(c: c, m: m):      return .io(d: c, m: m)
        case let .OAM(c: c, m: m):       return .io(d: c, m: m)
        case let .OAPM(c: c, m: m):      return .io(d: c, m: m)
        case let .FNC(s: s, c: c, m: m): return .io(d: computeD(for: s, using: c), m: m)
        }
    }

    var mnemonic: String {
        func ss(_ s: Bool) -> String {
            return s ? "W" : "I"
        }

        switch self {
        case .AJM(c: _, m: _):           return "AJM"
        case .SCF(c: _, m: _):           return "SCF"
        case .FSJM(c: _, m: _):          return "FSJM"
        case .IJM(c: _, m: _):           return "IJM"
        case .CCF(c: _, m: _):           return "CCF"
        case .FCJM(c: _, m: _):          return "FCJM"
        case .FJM(c: _, m: _):           return "FJM"
        case .SFM(c: _, m: _):           return "SFM"
        case .EJM(c: _, m: _):           return "EJM"
        case .CFM(c: _, m: _):           return "CFM"
        case .CHCM(c: _, m: _):          return "CHCM"
        case .IAM(c: _, m: _):           return "IAM"
        case .IAPM(c: _, m: _):          return "IAPM"
        case .CMCH(c: _, m: _):          return "CMCH"
        case .OAM(c: _, m: _):           return "OAM"
        case .OAPM(c: _, m: _):          return "OAPM"
        case let .FNC(s: s, c: _, m: _): return "FNC\(ss(s))"
        }
    }

    var s: Bool {
        switch self {
        case let .FNC(s: s, c: _, m: _): return s
        default:                         return false
        }
    }

    var c: UInt8 {
        switch self {
        case let .AJM(c: c, m: _):       return c
        case let .SCF(c: c, m: _):       return c
        case let .FSJM(c: c, m: _):      return c
        case let .IJM(c: c, m: _):       return c
        case let .CCF(c: c, m: _):       return c
        case let .FCJM(c: c, m: _):      return c
        case let .FJM(c: c, m: _):       return c
        case let .SFM(c: c, m: _):       return c
        case let .EJM(c: c, m: _):       return c
        case let .CFM(c: c, m: _):       return c
        case let .CHCM(c: c, m: _):      return c
        case let .IAM(c: c, m: _):       return c
        case let .IAPM(c: c, m: _):      return c
        case let .CMCH(c: c, m: _):      return c
        case let .OAM(c: c, m: _):       return c
        case let .OAPM(c: c, m: _):      return c
        case let .FNC(s: _, c: c, m: _): return c
        }
    }

    static func decode(word: UInt16, at address: UInt16, on processor: Cyber962PP) -> Self? {
        let (g, f, d) = Self.extract(from: word)
        let s = (d & 0o40) == 0o40
        let c = (d & 0o37)
        let m = processor.read(from: address + 1)

        switch f {
        case 0o64: if g == 0 {
            if !s            { return .AJM(c: c, m: m) }       else { return .SCF(c: c, m: m) }
        } else               { return .FSJM(c: c, m: m) }
        case 0o65: if g == 0 {
            if !s            { return .IJM(c: c, m: m) }       else { return .CCF(c: c, m: m) }
        } else               { return .FCJM(c: c, m: m) }
        case 0o66: if !s     { return .FJM(c: c, m: m) }       else { return .SFM(c: c, m: m) }
        case 0o67: if !s     { return .EJM(c: c, m: m) }       else { return .CFM(c: c, m: m) }
        case 0o70: if g == 0 { return .FNC(s: s, c: c, m: m) } else { return .CHCM(c: c, m: m) }
        case 0o71: if g == 0 { return .IAM(c: c, m: m) }       else { return .IAPM(c: c, m: m) }
        case 0o72: if g == 0 { return nil }                    else { return .CMCH(c: c, m: m) }
        case 0o73: if g == 0 { return .OAM(c: c, m: m) }       else { return .OAPM(c: c, m: m) }
        default: return nil
        }
    }

    func disassemble() -> String {
        return self.mnemonic + " " + "\(self.c)"
    }

    func execute(on processor: Cyber962PP) -> Bool {
        switch self {
        case .AJM(c: _, m: _):       AJM(on: processor)
        case .SCF(c: _, m: _):       SCF(on: processor)
        case .FSJM(c: _, m: _):      FSJM(on: processor)
        case .IJM(c: _, m: _):       IJM(on: processor)
        case .CCF(c: _, m: _):       CCF(on: processor)
        case .FCJM(c: _, m: _):      FCJM(on: processor)
        case .FJM(c: _, m: _):       FJM(on: processor)
        case .SFM(c: _, m: _):       SFM(on: processor)
        case .EJM(c: _, m: _):       EJM(on: processor)
        case .CFM(c: _, m: _):       CFM(on: processor)
        case .CHCM(c: _, m: _):      CHCM(on: processor)
        case .IAM(c: _, m: _):       IAM(on: processor)
        case .IAPM(c: _, m: _):      IAPM(on: processor)
        case .CMCH(c: _, m: _):      CMCH(on: processor)
        case .OAM(c: _, m: _):       OAM(on: processor)
        case .OAPM(c: _, m: _):      OAPM(on: processor)
        case .FNC(s: _, c: _, m: _): FNC(on: processor)
        }

        return true
    }

    internal func AJM(on processor: Cyber962PP) {
    }

    internal func SCF(on processor: Cyber962PP) {
    }

    internal func FSJM(on processor: Cyber962PP) {
    }

    internal func IJM(on processor: Cyber962PP) {
    }

    internal func CCF(on processor: Cyber962PP) {
    }

    internal func FCJM(on processor: Cyber962PP) {
    }

    internal func FJM(on processor: Cyber962PP) {
    }

    internal func SFM(on processor: Cyber962PP) {
    }

    internal func EJM(on processor: Cyber962PP) {
    }

    internal func CFM(on processor: Cyber962PP) {
    }

    internal func CHCM(on processor: Cyber962PP) {
    }

    internal func IAM(on processor: Cyber962PP) {
    }

    internal func IAPM(on processor: Cyber962PP) {
    }

    internal func CMCH(on processor: Cyber962PP) {
    }

    internal func OAM(on processor: Cyber962PP) {
    }

    internal func OAPM(on processor: Cyber962PP) {
    }

    internal func FNC(on processor: Cyber962PP) {
    }
}
