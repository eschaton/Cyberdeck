//
//  Cyber180PP.swift
//  Cyberdeck
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


/// A Cyber 180 Peripheral Processor
///
/// The Cyber 180 does not do any I/O on its own; it uses a number of 16-bit Peripheral Processors to perform I/O on its behalf. These have either 4KW or 8KW of their own RAM and access to all of the Cyber 180 system's I/O channels, and can use those I/O channels on its behalf. They also have access to the entirety of the Cyber 180 systems' Central Memory, as a source or target for transfers.
class Cyber180PP {

    /// The different models of Peripheral Processor used in Cyber 180 systems.
    enum Model {
        case I0
        case I1
        case I2
        case I3
        case I4
    }

    /// The model of this peripheral processor.
    let model: Model = .I4

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
    internal var _regP: UInt16 = 0

    /// Relocation Register
    ///
    /// The Relocation Register is used in conjunction with `A` to form an absolute Central Memory address.
    ///
    var regR: UInt32 {
        get { return self._regR }
        set { self._regR = newValue }
    }
    internal var _regR: UInt32 = 0


    // MARK: - PP Memory

    /// Raw memory of 8KW.
    internal var _memory: [UInt16] = Array(repeating: 0, count: (8 * 1024))

    func read(from address: UInt16) -> UInt16 {
        return _memory[Int(address)]
    }

    func write(_ value: UInt16, to address: UInt16) {
        _memory[Int(address)] = value
    }


    // MARK: - Instruction Decoding & Execution

    /// Decode all possible instructions.
    func decode(at address: UInt16) -> (any Cyber180PPInstruction)? {
        let instructionWord: UInt16 = self.read(from: address)

        // Check whether an instruction is prima facie invalid
        guard (instructionWord & 0o070000) == 0 else {
            return nil
        }

        if let f16di  = Cyber180PPInstruction16d.decode(word: instructionWord, at: address)   { return f16di }
        if let f16sci = Cyber180PPInstruction16sc.decode(word: instructionWord, at: address)  { return f16sci }
        if let f32dmi = Cyber180PPInstruction32dm.decode(word: instructionWord, at: address)  { return f32dmi }
        if let f32scmi = Cyber180PPInstruction32scm.decode(word: instructionWord, at: address) { return f32scmi }

        return nil
    }
}


protocol Cyber180PPInstruction {

    /// The adjustment to apply to `P` to get the following instruction.
    var stride: UInt16 { get }

    /// Decode an instruction.
    ///
    /// Tries to decode an instruction of this type from the given word, returning `nil` if one isn't present.
    static func decode(word: UInt16, at address: UInt16) -> Self?

    /// Disassemble the instruction.
    func disassemble() -> String

    /// Execute the instruction.
    ///
    /// Performs the operation corresponding to the instruction and returns whether to automatically update `P`.
    /// (Branch/jump instructions can update `P` themselves.)
    func execute(on processor: Cyber180PP) -> Bool
}

extension Cyber180PPInstruction {

    /// Extract the fields from an instruction word. Since `c` is the high bit of `d` we don't pass it separately.
    static func extract(from word: UInt16) -> (g: UInt8, f: UInt8, d: UInt8) {
        let g: UInt8 = UInt8((word & 0x8000) >> 15)
        let f: UInt8 = UInt8((word & 0x0FC0) >>  6)
        let d: UInt8 = UInt8((word & 0x003F) >>  0)
        return (g: g, f: f, d: d)
    }
}

/// A 16-bit Cyber 180 Peripheral Processor instruction.
protocol Cyber180PPInstruction16: Cyber180PPInstruction {
}

extension Cyber180PPInstruction16 {
    var stride: UInt16 { return 1 }
}

/// A 16-bit Cyber 180 Peripheral Processor `d`-format instruction.
enum Cyber180PPInstruction16d: Cyber180PPInstruction16 {
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

    static func decode(word: UInt16, at address: UInt16) -> Self? {
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
        case let .LDN(d: d): return "LDN \(d)"
        case let .LCN(d: d): return "LCN \(d)"
        case let .LDD(d: d): return "LDD \(d)"
        case let .LDDL(d: d): return "LDDL \(d)"
        case let .STD(d: d): return "STD \(d)"
        case let .STDL(d: d): return "STDL \(d)"
        case let .LDI(d: d): return "LDI \(d)"
        case let .LDIL(d: d): return "LDIL \(d)"
        case let .STI(d: d): return "STI \(d)"
        case let .STIL(d: d): return "STIL \(d)"
        case let .ADN(d: d): return "ADN \(d)"
        case let .SBN(d: d): return "SBN \(d)"
        case let .ADD(d: d): return "ADD \(d)"
        case let .ADDL(d: d): return "ADDL \(d)"
        case let .SBD(d: d): return "SBD \(d)"
        case let .SBDL(d: d): return "SBDL \(d)"
        case let .ADI(d: d): return "ADI \(d)"
        case let .ADIL(d: d): return "ADIL \(d)"
        case let .SBI(d: d): return "SBI \(d)"
        case let .SBIL(d: d): return "SBIL \(d)"
        case let .SHN(d: d): return "SHN \(d)"
        case let .SHDL(d: d): return "SHDL \(d)"
        case let .LMN(d: d): return "LMN \(d)"
        case let .LPN(d: d): return "LPN \(d)"
        case let .SCN(d: d): return "SCN \(d)"
        case let .LPDL(d: d): return "LPDL \(d)"
        case let .LPIL(d: d): return "LPIL \(d)"
        case let .LMD(d: d): return "LMD \(d)"
        case let .LMDL(d: d): return "LMDL \(d)"
        case let .LMI(d: d): return "LMI \(d)"
        case let .LMIL(d: d): return "LMIL \(d)"
        case let .RAD(d: d): return "RAD \(d)"
        case let .RADL(d: d): return "RADL \(d)"
        case let .AOD(d: d): return "AOD \(d)"
        case let .AODL(d: d): return "AODL \(d)"
        case let .SOD(d: d): return "SOD \(d)"
        case let .SODL(d: d): return "SODL \(d)"
        case let .RAI(d: d): return "RAI \(d)"
        case let .RAIL(d: d): return "RAIL \(d)"
        case let .AOI(d: d): return "AOI \(d)"
        case let .AOIL(d: d): return "AOIL \(d)"
        case let .SOI(d: d): return "SOI \(d)"
        case let .SOIL(d: d): return "SOIL \(d)"
        case let .UNJ(d: d): return "UNJ \(d)"
        case let .ZJN(d: d): return "ZJN \(d)"
        case let .NJN(d: d): return "NJN \(d)"
        case let .PJN(d: d): return "PJN \(d)"
        case let .MJN(d: d): return "MJN \(d)"
        case let .LRD(d: d): return "LRD \(d)"
        case let .SRD(d: d): return "SRD \(d)"
        case let .LRDL(d: d): return "LRDL \(d)"
        case let .SRDL(d: d): return "SRDL \(d)"
        case let .LRIL(d: d): return "LRIL \(d)"
        case let .SRIL(d: d): return "SRIL \(d)"
        case let .CRD(d: d): return "CRD \(d)"
        case let .CRDL(d: d): return "CRDL \(d)"
        case let .CWD(d: d): return "CWD \(d)"
        case let .CWDL(d: d): return "CWDL \(d)"
        case let .RDSL(d: d): return "RDSL \(d)"
        case let .RDCL(d: d): return "RDCL \(d)"
        case let .PSN(d: d): return "PSN \(d)"
        case let .WAIT(d: d): return "WAIT \(d)"
        case let .KEYP(d: d): return "KEYP \(d)"
        case let .INPN(d: d): return "INPN \(d)"
        case .EXN: return "EXN"
        case .MXN: return "MXN"
        case .MAN: return "MAN"
        }
    }

    func execute(on processor: Cyber180PP) -> Bool {
        switch self {
        case let .LDN(d: d): LDN(on: processor, d: d)
        case let .LCN(d: d): LCN(on: processor, d: d)
        case let .LDD(d: d): LDD(on: processor, d: d)
        case let .LDDL(d: d): LDDL(on: processor, d: d)
        case let .STD(d: d): STD(on: processor, d: d)
        case let .STDL(d: d): STDL(on: processor, d: d)
        case let .LDI(d: d): LDI(on: processor, d: d)
        case let .LDIL(d: d): LDIL(on: processor, d: d)
        case let .STI(d: d): STI(on: processor, d: d)
        case let .STIL(d: d): STIL(on: processor, d: d)
        case let .ADN(d: d): ADN(on: processor, d: d)
        case let .SBN(d: d): SBN(on: processor, d: d)
        case let .ADD(d: d): ADD(on: processor, d: d)
        case let .ADDL(d: d): ADDL(on: processor, d: d)
        case let .SBD(d: d): SBD(on: processor, d: d)
        case let .SBDL(d: d): SBDL(on: processor, d: d)
        case let .ADI(d: d): ADI(on: processor, d: d)
        case let .ADIL(d: d): ADIL(on: processor, d: d)
        case let .SBI(d: d): SBI(on: processor, d: d)
        case let .SBIL(d: d): SBIL(on: processor, d: d)
        case let .SHN(d: d): SHN(on: processor, d: d)
        case let .SHDL(d: d): SHDL(on: processor, d: d)
        case let .LMN(d: d): LMN(on: processor, d: d)
        case let .LPN(d: d): LPN(on: processor, d: d)
        case let .SCN(d: d): SCN(on: processor, d: d)
        case let .LPDL(d: d): LPDL(on: processor, d: d)
        case let .LPIL(d: d): LPIL(on: processor, d: d)
        case let .LMD(d: d): LMD(on: processor, d: d)
        case let .LMDL(d: d): LMDL(on: processor, d: d)
        case let .LMI(d: d): LMI(on: processor, d: d)
        case let .LMIL(d: d): LMIL(on: processor, d: d)
        case let .RAD(d: d): RAD(on: processor, d: d)
        case let .RADL(d: d): RADL(on: processor, d: d)
        case let .AOD(d: d): AOD(on: processor, d: d)
        case let .AODL(d: d): AODL(on: processor, d: d)
        case let .SOD(d: d): SOD(on: processor, d: d)
        case let .SODL(d: d): SODL(on: processor, d: d)
        case let .RAI(d: d): RAI(on: processor, d: d)
        case let .RAIL(d: d): RAIL(on: processor, d: d)
        case let .AOI(d: d): AOI(on: processor, d: d)
        case let .AOIL(d: d): AOIL(on: processor, d: d)
        case let .SOI(d: d): SOI(on: processor, d: d)
        case let .SOIL(d: d): SOIL(on: processor, d: d)
        case let .UNJ(d: d): UNJ(on: processor, d: d)
        case let .ZJN(d: d): ZJN(on: processor, d: d)
        case let .NJN(d: d): NJN(on: processor, d: d)
        case let .PJN(d: d): PJN(on: processor, d: d)
        case let .MJN(d: d): MJN(on: processor, d: d)
        case let .LRD(d: d): LRD(on: processor, d: d)
        case let .SRD(d: d): SRD(on: processor, d: d)
        case let .LRDL(d: d): LRDL(on: processor, d: d)
        case let .SRDL(d: d): SRDL(on: processor, d: d)
        case let .LRIL(d: d): LRIL(on: processor, d: d)
        case let .SRIL(d: d): SRIL(on: processor, d: d)
        case let .CRD(d: d): CRD(on: processor, d: d)
        case let .CRDL(d: d): CRDL(on: processor, d: d)
        case let .CWD(d: d): CWD(on: processor, d: d)
        case let .CWDL(d: d): CWDL(on: processor, d: d)
        case let .RDSL(d: d): RDSL(on: processor, d: d)
        case let .RDCL(d: d): RDCL(on: processor, d: d)
        case let .PSN(d: d): PSN(on: processor, d: d)
        case let .WAIT(d: d): WAIT(on: processor, d: d)
        case let .KEYP(d: d): KEYP(on: processor, d: d)
        case let .INPN(d: d): INPN(on: processor, d: d)
        case .EXN: EXN(on: processor)
        case .MXN: MXN(on: processor)
        case .MAN: MAN(on: processor)
        }
        return true
    }

    internal func LDN(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement LDN
    }

    internal func LCN(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement LCN
    }

    internal func LDD(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement LDD
    }

    internal func LDDL(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement LDDL
    }

    internal func STD(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement STD
    }

    internal func STDL(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement STDL
    }

    internal func LDI(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement LDI
    }

    internal func LDIL(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement LDIL
    }

    internal func STI(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement STI
    }

    internal func STIL(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement STIL
    }

    internal func ADN(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement ADN
    }

    internal func SBN(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement SBN
    }

    internal func ADD(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement ADD
    }

    internal func ADDL(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement ADDL
    }

    internal func SBD(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement SBD
    }

    internal func SBDL(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement SBDL
    }

    internal func ADI(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement ADI
    }

    internal func ADIL(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement ADIL
    }

    internal func SBI(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement SBI
    }

    internal func SBIL(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement SBIL
    }

    internal func SHN(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement SHN
    }

    internal func SHDL(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement SHDL
    }

    internal func LMN(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement LMN
    }

    internal func LPN(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement LPN
    }

    internal func SCN(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement SCN
    }

    internal func LPDL(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement LPDL
    }

    internal func LPIL(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement LPIL
    }

    internal func LMD(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement LMD
    }

    internal func LMDL(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement LMDL
    }

    internal func LMI(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement LMI
    }

    internal func LMIL(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement LMIL
    }

    internal func RAD(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement RAD
    }

    internal func RADL(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement RADL
    }

    internal func AOD(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement AOD
    }

    internal func AODL(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement AODL
    }

    internal func SOD(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement SOD
    }

    internal func SODL(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement SODL
    }

    internal func RAI(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement RAI
    }

    internal func RAIL(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement RAIL
    }

    internal func AOI(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement AOI
    }

    internal func AOIL(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement AOIL
    }

    internal func SOI(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement SOI
    }

    internal func SOIL(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement SOIL
    }

    internal func UNJ(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement UNJ
    }

    internal func ZJN(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement ZJN
    }

    internal func NJN(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement NJN
    }

    internal func PJN(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement PJN
    }

    internal func MJN(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement MJN
    }

    internal func LRD(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement LRD
    }

    internal func SRD(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement SRD
    }

    internal func LRDL(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement LRDL
    }

    internal func SRDL(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement SRDL
    }

    internal func LRIL(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement LRIL
    }

    internal func SRIL(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement SRIL
    }

    internal func CRD(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement CRD
    }

    internal func CRDL(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement CRDL
    }

    internal func CWD(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement CWD
    }

    internal func CWDL(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement CWDL
    }

    internal func RDSL(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement RDSL
    }

    internal func RDCL(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement RDCL
    }

    internal func PSN(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement PSN
    }

    internal func WAIT(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement WAIT
    }

    internal func KEYP(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement KEYP
    }

    internal func INPN(on processor: Cyber180PP, d: UInt8) {
        // TODO: Implement INPN
    }

    internal func EXN(on processor: Cyber180PP) {
        // TODO: Implement EXN
    }

    internal func MXN(on processor: Cyber180PP) {
        // TODO: Implement MXN
    }

    internal func MAN(on processor: Cyber180PP) {
        // TODO: Implement MAN
    }
}

/// A 16-bit Cyber 180 Peripheral Processor `c`-format instruction.
///
/// A 16sc instruction has the format:
///
///     | 48 | 49 | 50 | 51 | 52 | 53 | 54 | 55 | 56 | 57 | 58 | 59 | 60 | 61 | 62 | 63 |
///     | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- |
///     |  g |  0    0    0 |              f              |  s |           c            |
///
/// For instructions that support it, the `s` bit means "wait until active" when set and "skip if inactive" when clear.
enum Cyber180PPInstruction16sc: Cyber180PPInstruction16 {
    case IAN(s: Bool, c: UInt8) // 0070sc
    case OAN(s: Bool, c: UInt8) // 0072sc
    case ACN(s: Bool, c: UInt8) // 0074sc
    case DCN(s: Bool, c: UInt8) // 0075sc
    case FAN(s: Bool, c: UInt8) // 0076sc
    case MCLR(c: UInt8) // 1074xc

    static func decode(word: UInt16, at address: UInt16) -> Self? {
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
        func ss(_ s: Bool) -> String {
            return s ? "W" : "I"
        }

        switch self {
        case let .IAN(s: s, c: c): return "IAN\(ss(s)) \(c)"
        case let .OAN(s: s, c: c): return "OAN\(ss(s)) \(c)"
        case let .ACN(s: s, c: c): return "ACN\(ss(s)) \(c)"
        case let .DCN(s: s, c: c): return "DCN\(ss(s)) \(c)"
        case let .FAN(s: s, c: c): return "FAN\(ss(s)) \(c)"
        case let .MCLR(c: c):      return "MCLR \(c)"
        }
    }

    func execute(on processor: Cyber180PP) -> Bool {
        switch self {
        case let .IAN(s: s, c: c): IAN(on: processor, s: s, c: c)
        case let .OAN(s: s, c: c): OAN(on: processor, s: s, c: c)
        case let .ACN(s: s, c: c): ACN(on: processor, s: s, c: c)
        case let .DCN(s: s, c: c): DCN(on: processor, s: s, c: c)
        case let .FAN(s: s, c: c): FAN(on: processor, s: s, c: c)
        case let .MCLR(c: c):      MCLR (on: processor, c: c)
        }
        return true
    }

    internal func IAN(on processor: Cyber180PP, s: Bool, c: UInt8) {
        // TODO: Implement IAN.
    }

    internal func OAN(on processor: Cyber180PP, s: Bool, c: UInt8) {
        // TODO: Implement OAN.
    }

    internal func ACN(on processor: Cyber180PP, s: Bool, c: UInt8) {
        // TODO: Implement ACN.
    }

    internal func DCN(on processor: Cyber180PP, s: Bool, c: UInt8) {
        // TODO: Implement DCN.
    }

    internal func FAN(on processor: Cyber180PP, s: Bool, c: UInt8) {
        // TODO: Implement FAN.
    }

    internal func MCLR(on processor: Cyber180PP, c: UInt8) {
        // TODO: Implement MCLR.
    }
}

protocol Cyber180PPInstruction32: Cyber180PPInstruction {
}

extension Cyber180PPInstruction32 {
    var stride: UInt16 { return 2 }
}

enum Cyber180PPInstruction32dm: Cyber180PPInstruction32 {

    static func decode(word: UInt16, at address: UInt16) -> Self? {
        // TODO: Implement f32dm instruction decoding
        return nil
    }

    func disassemble() -> String {
        // TODO: Implement f32dm instruction disassembly
        return "f32dm"
    }

    func execute(on processor: Cyber180PP) -> Bool {
        // TODO: Implement f32dm instruction execution
        return true
    }
}

enum Cyber180PPInstruction32scm: Cyber180PPInstruction32 {
    case CHCM(c: UInt8) // 1070X
    case IAM(c: UInt8) // 0071X
    case IAPM(c: UInt8) // 1071X
    case CMCH(c: UInt8) // 1072X
    case OAM(c: UInt8) // 0073X
    case OAPM(c: UInt8) // 1073X
    case FNC(s: Bool, c: UInt8) // 00770

    static func decode(word: UInt16, at address: UInt16) -> Self? {
        let (g, f, d) = Self.extract(from: word)
        let s = (d & 0o40) == 0o40
        let c = (d & 0o37)
        // m is retrieved at execution time

        switch f {
        case 0o70: if g == 0 { return .FNC(s: s, c: c) }  else { return .CHCM(c: c) }
        case 0o71: if g == 0 { return .IAM(c: c) }        else { return .IAPM(c: c) }
        case 0o72: if g == 0 { return nil }               else { return .CMCH(c: c) }
        case 0o73: if g == 0 { return .OAM(c: c) }        else { return .OAPM(c: c) }
        default: return nil
        }
    }

    func disassemble() -> String {
        func ss(_ s: Bool) -> String {
            return s ? "W" : "I"
        }

        switch self {
        case let .CHCM(c: c):      return "CHCM \(c)"
        case let .IAM(c: c):       return "IAM \(c)"
        case let .IAPM(c: c):      return "IAPM \(c)"
        case let .CMCH(c: c):      return "CMCH \(c)"
        case let .OAM(c: c):       return "OAM \(c)"
        case let .OAPM(c: c):      return "OAPM \(c)"
        case let .FNC(s: s, c: c): return "FNC\(ss(s)) \(c)"
        }
    }

    func execute(on processor: Cyber180PP) -> Bool {
        switch self {
        case let .CHCM(c: c):      CHCM(on: processor, c: c)
        case let .IAM(c: c):       IAM(on: processor, c: c)
        case let .IAPM(c: c):      IAPM(on: processor, c: c)
        case let .CMCH(c: c):      CMCH(on: processor, c: c)
        case let .OAM(c: c):       OAM(on: processor, c: c)
        case let .OAPM(c: c):      OAPM(on: processor, c: c)
        case let .FNC(s: s, c: c): FNC(on: processor, s: s, c: c)
        }

        return true
    }

    internal func CHCM(on processor: Cyber180PP, c: UInt8) {
        // TODO: Implement CHCM.
    }

    internal func IAM(on processor: Cyber180PP, c: UInt8) {
        // TODO: Implement IAM.
    }

    internal func IAPM(on processor: Cyber180PP, c: UInt8) {
        // TODO: Implement IAPM.
    }

    internal func CMCH(on processor: Cyber180PP, c: UInt8) {
        // TODO: Implement CMCH.
    }

    internal func OAM(on processor: Cyber180PP, c: UInt8) {
        // TODO: Implement OAM.
    }

    internal func OAPM(on processor: Cyber180PP, c: UInt8) {
        // TODO: Implement OAPM.
    }

    internal func FNC(on processor: Cyber180PP, s: Bool, c: UInt8) {
        // TODO: Implement FNC.
    }
}
