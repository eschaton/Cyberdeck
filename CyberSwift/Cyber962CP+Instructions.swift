//
//  Cyber962CP+Instructions.swift
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


extension Cyber962CP {


    func executionLoop() {
        let p = self.regP

        guard let instruction = self.decode(at: p) else {
            // TODO: Handle illegal/unimplemented instruction.
            fatalError("Unimplemented instruction at \(p)")
        }

        if instruction.execute(on: self) {
            self.regP = p + instruction.stride
        }
    }

    func decode(at address: UInt64) -> (any Cyber962CPInstruction)? {
        let opcode: UInt8 = self.read(virtualAddress: address)
        switch opcode {
        case 0x00..<0x40,
            0x70..<0x80:
            // jk instructions are 16-bit
            let instruction: UInt16 = self.read(virtualAddress: address)
            return Cyber962CPInstruction_jk.decode(opcode: opcode, word: instruction)

        case 0x40..<0x70,
            0xA0..<0xB0,
            0xE0...0xFF:
            // jkiD instructions are 32-bit
            let instruction: UInt32 = self.read(virtualAddress: address)
            return Cyber962CPInstruction_jkiD.decode(opcode: opcode, word: instruction)

        case 0x80..<0xA0,
            0xB0..<0xC0:
            // jkQ instructions are 32-bit
            let instruction: UInt32 = self.read(virtualAddress: address)
            return Cyber962CPInstruction_jkQ.decode(opcode: opcode, word: instruction)

        case 0xC0..<0xE0:
            // SjkiD instructions are 32-bit
            let instruction: UInt32 = self.read(virtualAddress: address)
            return Cyber962CPInstruction_SjkiD.decode(opcode: opcode, word: instruction)

        default:
            fatalError("This should be impossible to reach.")
        }
    }

}


// MARK: - Instruction Formats

/// The protocol to which all Cyber 962 instructions conform, parameterized on the type used to represent the instruction word.
///
/// Instructions on the Cyber 962 have one of four possible layouts, which are represented by subprotocols:
///
/// ```
///      jkiD | Opcode: 8        | j: 4 | k: 4 | i: 4 | D: 12 |
///     SjkiD | Opcode: 5 | S: 3 | j: 4 | k: 4 | i: 4 | D: 12 |
///        jk | Opcode: 8        | j: 4 | k: 4 |
///       jkQ | Opcode: 8        | j: 4 | k: 4 | Q: 16        |
/// ```
///
/// Given the existence of 16-bit instructions, there may be two, three, or four instructions in a single 64-bit word.
protocol Cyber962CPInstruction<WordType> {
    associatedtype WordType: FixedWidthInteger

    /// The stride (number of bytes) of the instruction.
    var stride: UInt64 { get }

    /// The  4-bit `j` value for this instruction.
    var j: UInt8 { get }

    /// The 4-bit `k` value for this instruction.
    var k: UInt8 { get }

    /// Decode an instruction from the appropriate type of word, returninig `nil` if decoding was not possible.
    static func decode(opcode: UInt8, word: WordType) -> Self?

    /// Disassemble the instruction.
    func disassemble() -> String

    /// Execute the instruction on a processor,.
    ///
    /// Performs the operation specified by the instruction and returns whether to update `P`, since some instructions will update `P` themselves.
    func execute(on processor: Cyber962CP) -> Bool
}

extension Cyber962CPInstruction {

    /// Compute the stride of the instruction from the bit width of its underlying word type.
    var stride: UInt64 { UInt64(WordType.bitWidth / 8) }
}

/// A jkiD instruction is a 32-bit instruction that has an 8-bit opcode in its leftmost byte.
protocol Cyber962CPInstructionFormat_jkiD: Cyber962CPInstruction where WordType == UInt32 {

    /// The additional 4-bit `i` value for this type of instruction.
    var i: UInt8 { get }

    /// The additional 12-bit `D` value for this type of instruction.
    var D: UInt16 { get }
}

extension Cyber962CPInstructionFormat_jkiD {

    /// Extract the fields `j`, `k`, `i`, `D` fields from the given instruction word.
    internal static func extract(from word: WordType) -> (j: UInt8, k: UInt8, i: UInt8, D: UInt16) {
        let j: UInt8  =  UInt8((word & 0x00F0_0000) >> 20)
        let k: UInt8  =  UInt8((word & 0x000F_0000) >> 16)
        let i: UInt8  =  UInt8((word & 0x0000_F000) >> 12)
        let D: UInt16 = UInt16((word & 0x0000_0FFF) >>  0)
        return (j: j, k: k, i: i, D: D)
    }
}

/// An SjkiD instruction is a 32-bit instruction that has a 5-bit opcode and 3 S bits in its leftmost byte.
protocol Cyber962CPInstructionFormat_SjkiD: Cyber962CPInstruction where WordType == UInt32 {

    /// The additional 3-bit S value for this type of instruction.
    var S: UInt8 { get }

    /// The additional 4-bit `i` value for this type of instruction.
    var i: UInt8 { get }

    /// The additional 12-bit `D` value for this type of instruction.
    var D: UInt16 { get }
}

extension Cyber962CPInstructionFormat_SjkiD {

    /// Extract the `S`, `j`, `k`, `i`, `D` fields from the given instruction word.
    internal static func extract(from word: WordType) -> (S: UInt8, j: UInt8, k: UInt8, i: UInt8, D: UInt16) {
        let S: UInt8  =  UInt8((word & 0x0700_0000) >> 24)
        let j: UInt8  =  UInt8((word & 0x00F0_0000) >> 20)
        let k: UInt8  =  UInt8((word & 0x000F_0000) >> 16)
        let i: UInt8  =  UInt8((word & 0x0000_F000) >> 12)
        let D: UInt16 = UInt16((word & 0x0000_0FFF) >>  0)
        return (S: S, j: j, k: k, i: i, D: D)
    }
}

/// A jk instruction is a 16-bit instruction that has an 8-bit opcode in its leftmost byte.
protocol Cyber962CPInstructionFormat_jk: Cyber962CPInstruction where WordType == UInt16 {
}

extension Cyber962CPInstructionFormat_jk {

    /// Extract the `j`, `k`, fields from the given instruction word.
    internal static func extract(from word: WordType) -> (j: UInt8, k: UInt8) {
        let j: UInt8  =  UInt8((word & 0x00F0) >> 4)
        let k: UInt8  =  UInt8((word & 0x000F) >> 0)
        return (j: j, k: k)
    }
}

/// A jkQ instruction is a 32-bit instruction that has an 8-bit opcode in its leftmost byte and a 16-bit `Q` in its rightmost two bytes.
protocol Cyber962CPInstructionFormat_jkQ: Cyber962CPInstruction where WordType == UInt32 {

    /// The additional 16-bit `Q` value for this type of instruction.
    var Q: UInt16 { get }
}

extension Cyber962CPInstructionFormat_jkQ {

    /// Extract the `j`, `k`, `Q`, fields from the given instruction word.
    internal static func extract(from word: WordType) -> (j: UInt8, k: UInt8, Q: UInt16) {
        let j: UInt8  =  UInt8((word & 0x00F0_0000) >> 20)
        let k: UInt8  =  UInt8((word & 0x000F_0000) >> 16)
        let Q: UInt16 = UInt16((word & 0x0000_FFFF) >>  0)
        return (j: j, k: k, Q: Q)
    }
}


// MARK: - Instruction Implementations

/// Cyber 962 `jkiD` instructions
enum Cyber962CPInstruction_jkiD: Cyber962CPInstructionFormat_jkiD {
    case ADDFV(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case SUBFV(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case MULFV(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case DIVFV(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case ADDXV(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case SUBXV(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case IORV(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case XORV(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case CNIFV(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case CNFIV(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case SHFV(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case COMPEQV(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case CMPLTV(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case CMPGEV(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case CMPNEV(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case MRGV(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case GTHV(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case SCTV(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case SUMFV(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case TPSFV(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case TPDFV(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case TSPFV(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case TDPFV(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case SUMPFV(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case GTHIV(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case SCTIV(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case LAI(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case SAI(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case LXI(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case SXI(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case LBYT(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case SBYT(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case ADDAD(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case SHFC(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case SHFX(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case SHFR(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case ISOM(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case ISOB(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case INSB(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case SCLN(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case SCLR(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case CMPC(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case TRANB(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case EDIT(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case SCNB(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case MOVI(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case CMPI(j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case ADDI(j: UInt8, k: UInt8, i: UInt8, D: UInt16)

    var j: UInt8 {
        return 0 // FIXME: Implement
    }

    var k: UInt8 {
        return 0 // FIXME: Implement
    }

    var i: UInt8 {
        return 0 // FIXME: Implement
    }

    var D: UInt16 {
        return 0 // FIXME: Implement
    }

    static func decode(opcode: UInt8, word: WordType) -> Self? {
        return nil // FIXME: Implemnet
    }

    func disassemble() -> String {
        return "jkiD" // FIXME: Implement
    }

    func execute(on processor: Cyber962CP) -> Bool {
        return true // FIXME: Implement
    }
}

/// Cyber 962 `SjkiD` instructions
enum Cyber962CPInstruction_SjkiD: Cyber962CPInstructionFormat_SjkiD {
    case EXECUTE(S: UInt8, j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case LBYTS(S: UInt8, j: UInt8, k: UInt8, i: UInt8, D: UInt16)
    case SBYTS(S: UInt8, j: UInt8, k: UInt8, i: UInt8, D: UInt16)

    var S: UInt8 {
        switch self {
        case let .EXECUTE(S: S, j: _, k: _, i: _, D: _): return S
        case let .LBYTS(S: S, j: _, k: _, i: _, D: _): return S
        case let .SBYTS(S: S, j: _, k: _, i: _, D: _): return S
        }
    }

    var j: UInt8 {
        switch self {
        case let .EXECUTE(S: _, j: j, k: _, i: _, D: _): return j
        case let .LBYTS(S: _, j: j, k: _, i: _, D: _): return j
        case let .SBYTS(S: _, j: j, k: _, i: _, D: _): return j
        }
    }

    var k: UInt8 {
        switch self {
        case let .EXECUTE(S: _, j: _, k: k, i: _, D: _): return k
        case let .LBYTS(S: _, j: _, k: k, i: _, D: _): return k
        case let .SBYTS(S: _, j: _, k: k, i: _, D: _): return k
        }
    }

    var i: UInt8 {
        switch self {
        case let .EXECUTE(S: _, j: _, k: _, i: i, D: _): return i
        case let .LBYTS(S: _, j: _, k: _, i: i, D: _): return i
        case let .SBYTS(S: _, j: _, k: _, i: i, D: _): return i
        }
    }

    var D: UInt16 {
        switch self {
        case let .EXECUTE(S: _, j: _, k: _, i: _, D: D): return D
        case let .LBYTS(S: _, j: _, k: _, i: _, D: D): return D
        case let .SBYTS(S: _, j: _, k: _, i: _, D: D): return D
        }
    }

    static func decode(opcode: UInt8, word: UInt32) -> Self? {
        let (S, j, k, i, D) = extract(from: word)

        switch (opcode & 0xF8) {
        case 0xC0: return .EXECUTE(S: S, j: j, k: k, i: i, D: D)
        case 0xD0: return .LBYTS(S: S, j: j, k: k, i: i, D: D)
        case 0xD8: return .SBYTS(S: S, j: j, k: k, i: i, D: D)
        default: return nil
        }
    }

    func disassemble() -> String {
        switch self {
        case let .EXECUTE(S: S, j: j, k: k, i: i, D: D): return "EXECUTE,\(S) \(j),\(k),\(i),\(D)"
        case let .LBYTS(S: S, j: j, k: k, i: i, D: D): return "LBYTS,\(S+1) X\(k),A\(j),X\(i),\(D)"
        case let .SBYTS(S: S, j: j, k: k, i: i, D: D): return "SBYTS,\(S+1) X\(k),A\(j),X\(i),\(D)"
        }
    }
    
    func execute(on processor: Cyber962CP) -> Bool {
        switch self {
        case let .EXECUTE(S: S, j: j, k: k, i: i, D: D): EXECUTE(on: processor, S: S, j: j, k: k, i: i, D: D)
        case let .LBYTS(S: S, j: j, k: k, i: i, D: D): LBYTS(on: processor, S: S, j: j, k: k, i: i, D: D)
        case let .SBYTS(S: S, j: j, k: k, i: i, D: D): SBYTS(on: processor, S: S, j: j, k: k, i: i, D: D)
        }
        return true
    }

    internal func EXECUTE(on processor: Cyber962CP, S: UInt8, j: UInt8, k: UInt8, i: UInt8, D: UInt16) {
        // TODO: Implement EXECUTE
    }

    internal func LBYTS(on processor: Cyber962CP, S: UInt8, j: UInt8, k: UInt8, i: UInt8, D: UInt16) {
        // TODO: Implement LBYTS
    }

    internal func SBYTS(on processor: Cyber962CP, S: UInt8, j: UInt8, k: UInt8, i: UInt8, D: UInt16) {
        // TODO: Implement SBYTS
    }
}

/// Cyber 962 `jk` instructions
enum Cyber962CPInstruction_jk: Cyber962CPInstructionFormat_jk {
    case HALT
    case SYNC
    case EXCHANGE
    case INTRUPT(k: UInt8)
    case RETURN
    case PURGE(j: UInt8, k: UInt8)
    case POP
    case PSFSA
    case CPYTX(j: UInt8, k: UInt8)
    case CPYAA(j: UInt8, k: UInt8)
    case CPYXA(j: UInt8, k: UInt8)
    case CPYAX(j: UInt8, k: UInt8)
    case CPYRR(j: UInt8, k: UInt8)
    case CPYXX(j: UInt8, k: UInt8)
    case CPYXS(j: UInt8, k: UInt8)

    case INCX(j: UInt8, k: UInt8)
    case DECX(j: UInt8, k: UInt8)
    case LBSET(j: UInt8, k: UInt8)
    case TPAGE(j: UInt8, k: UInt8)
    case LPAGE(j: UInt8, k: UInt8)
    case IORX(j: UInt8, k: UInt8)
    case XORX(j: UInt8, k: UInt8)
    case ANDX(j: UInt8, k: UInt8)
    case NOTX(j: UInt8, k: UInt8)
    case MARK(j: UInt8, k: UInt8)
    case ENTZOS(k: UInt8)

    case ADDR(j: UInt8, k: UInt8)
    case SUBR(j: UInt8, k: UInt8)
    case MULR(j: UInt8, k: UInt8)
    case DIVR(j: UInt8, k: UInt8)
    case ADDX(j: UInt8, k: UInt8)
    case SUBX(j: UInt8, k: UInt8)
    case MULX(j: UInt8, k: UInt8)
    case DIVX(j: UInt8, k: UInt8)
    case INCR(j: UInt8, k: UInt8)
    case DECR(j: UInt8, k: UInt8)
    case ADDAX(j: UInt8, k: UInt8)
    case CMPR(j: UInt8, k: UInt8)
    case CMPX(j: UInt8, k: UInt8)
    case BRREL(j: UInt8, k: UInt8)
    case BRDIR(j: UInt8, k: UInt8)

    case ADDF(j: UInt8, k: UInt8)
    case SUBF(j: UInt8, k: UInt8)
    case MULF(j: UInt8, k: UInt8)
    case DIVF(j: UInt8, k: UInt8)
    case ADDD(j: UInt8, k: UInt8)
    case SUBD(j: UInt8, k: UInt8)
    case MULD(j: UInt8, k: UInt8)
    case DIVD(j: UInt8, k: UInt8)
    case ENTX(j: UInt8, k: UInt8)
    case CNIF(j: UInt8, k: UInt8)
    case CNFI(j: UInt8, k: UInt8)
    case CMPF(j: UInt8, k: UInt8)
    case ENTP(j: UInt8, k: UInt8)
    case ENTN(j: UInt8, k: UInt8)
    case ENTL(j: UInt8, k: UInt8)

    case ADDN(j: UInt8, k: UInt8)
    case SUBN(j: UInt8, k: UInt8)
    case MULN(j: UInt8, k: UInt8)
    case DIVN(j: UInt8, k: UInt8)
    case CMPN(j: UInt8, k: UInt8)
    case MOVN(j: UInt8, k: UInt8)
    case MOVB(j: UInt8, k: UInt8)
    case CMPB(j: UInt8, k: UInt8)

    var j: UInt8 {
        return 0 // FIXME: Implement
    }

    var k: UInt8 {
        return 0 // FIXME: Implement
    }

    static func decode(opcode: UInt8, word: UInt16) -> Cyber962CPInstruction_jk? {
        return nil // FIXME: Implement
    }

    func disassemble() -> String {
        return "jk" // FIXME: Implement
    }

    func execute(on processor: Cyber962CP) -> Bool {
        return true // FIXME: Implement
    }
}


/// Cyber 962 `jkQ` instructions
enum Cyber962CPInstruction_jkQ: Cyber962CPInstructionFormat_jkQ {
    case LMULT(j: UInt8, k: UInt8, Q: UInt16)
    case SMULT(j: UInt8, k: UInt8, Q: UInt16)
    case LX(j: UInt8, k: UInt8, Q: UInt16)
    case SX(j: UInt8, k: UInt8, Q: UInt16)
    case LA(j: UInt8, k: UInt8, Q: UInt16)
    case SA(j: UInt8, k: UInt8, Q: UInt16)
    case LBYTP(j: UInt8, k: UInt8, Q: UInt16)
    case ENTC(j: UInt8, k: UInt8, Q: UInt16)
    case LBIT(j: UInt8, k: UInt8, Q: UInt16)
    case SBIT(j: UInt8, k: UInt8, Q: UInt16)
    case ADDRQ(j: UInt8, k: UInt8, Q: UInt16)
    case ADDXQ(j: UInt8, k: UInt8, Q: UInt16)
    case MULRQ(j: UInt8, k: UInt8, Q: UInt16)
    case ENTE(j: UInt8, k: UInt8, Q: UInt16)
    case ADDAQ(j: UInt8, k: UInt8, Q: UInt16)
    case ADDPXQ(j: UInt8, k: UInt8, Q: UInt16)
    case BRREQ(j: UInt8, k: UInt8, Q: UInt16)
    case BRRNE(j: UInt8, k: UInt8, Q: UInt16)
    case BRRGT(j: UInt8, k: UInt8, Q: UInt16)
    case BRRGE(j: UInt8, k: UInt8, Q: UInt16)
    case BRXEQ(j: UInt8, k: UInt8, Q: UInt16)
    case BRXNE(j: UInt8, k: UInt8, Q: UInt16)
    case BRXGT(j: UInt8, k: UInt8, Q: UInt16)
    case BRXGE(j: UInt8, k: UInt8, Q: UInt16)
    case BRFEQ(j: UInt8, k: UInt8, Q: UInt16)
    case BRFNE(j: UInt8, k: UInt8, Q: UInt16)
    case BRFGT(j: UInt8, k: UInt8, Q: UInt16)
    case BRFGE(j: UInt8, k: UInt8, Q: UInt16)
    case BRINC(j: UInt8, k: UInt8, Q: UInt16)
    case BRSEG(j: UInt8, k: UInt8, Q: UInt16)
    case BR___(j: UInt8, k: UInt8, Q: UInt16)
    case BRCR(j: UInt8, k: UInt8, Q: UInt16)
    case CALLREL(j: UInt8, k: UInt8, Q: UInt16)
    case KEYPOINT(j: UInt8, k: UInt8, Q: UInt16)
    case MULXQ(j: UInt8, k: UInt8, Q: UInt16)
    case ENTA(j: UInt8, k: UInt8, Q: UInt16)
    case CMPXA(j: UInt8, k: UInt8, Q: UInt16)
    case CALLSEG(j: UInt8, k: UInt8, Q: UInt16)

    var opcode: UInt8 {
        switch self {
        case .LMULT(j: _, k: _, Q: _): return 0x80

        default: return 0x0000 // TODO: Remove when done
        }
    }

    var j: UInt8 {
        switch self {
        case let .LMULT(j: j, k: _, Q: _): return j

        default: return 0x00 // TODO: Remove when done
        }
    }

    var k: UInt8 {
        switch self {
        case let .LMULT(j: _, k: k, Q: _): return k

        default: return 0x00 // TODO: Remove when done
        }
    }

    var Q: UInt16 {
        switch self {
        case let .LMULT(j: _, k: _, Q: Q): return Q

        default: return 0x0000 // TODO: Remove when done
        }
    }

    static func decode(opcode: UInt8, word: UInt32) -> Cyber962CPInstruction_jkQ? {
        let (j: j, k: k, Q: Q) = Self.extract(from: word)

        switch opcode {
        case 0x80: return .LMULT(j: j, k: k, Q: Q)

        default: return nil
        }
    }

    func disassemble() -> String {
        switch self {
        case let .LMULT(j: j, k: k, Q: Q): return "LMULT X\(k),A\(j),\(Q)"

        default: return "unknown" // TODO: Remove when done
        }
    }

    func execute(on processor: Cyber962CP) -> Bool {
        switch self {
        case let .LMULT(j: j, k: k, Q: Q): LMULT(on: processor, j: j, k: k, Q: Q)
        case let .SMULT(j: j, k: k, Q: Q): SMULT(on: processor, j: j, k: k, Q: Q)
        case let .LX(j: j, k: k, Q: Q): LX(on: processor, j: j, k: k, Q: Q)
        case let .SX(j: j, k: k, Q: Q): SX(on: processor, j: j, k: k, Q: Q)
        case let .LA(j: j, k: k, Q: Q): LA(on: processor, j: j, k: k, Q: Q)
        case let .SA(j: j, k: k, Q: Q): SA(on: processor, j: j, k: k, Q: Q)
        case let .LBYTP(j: j, k: k, Q: Q): LBYTP(on: processor, j: j, k: k, Q: Q)
        case let .ENTC(j: j, k: k, Q: Q): ENTC(on: processor, j: j, k: k, Q: Q)
        case let .LBIT(j: j, k: k, Q: Q): LBIT(on: processor, j: j, k: k, Q: Q)
        case let .SBIT(j: j, k: k, Q: Q): SBIT(on: processor, j: j, k: k, Q: Q)
        case let .ADDRQ(j: j, k: k, Q: Q): ADDRQ(on: processor, j: j, k: k, Q: Q)
        case let .ADDXQ(j: j, k: k, Q: Q): ADDXQ(on: processor, j: j, k: k, Q: Q)
        case let .MULRQ(j: j, k: k, Q: Q): MULRQ(on: processor, j: j, k: k, Q: Q)
        case let .ENTE(j: j, k: k, Q: Q): ENTE(on: processor, j: j, k: k, Q: Q)
        case let .ADDAQ(j: j, k: k, Q: Q): ADDAQ(on: processor, j: j, k: k, Q: Q)
        case let .ADDPXQ(j: j, k: k, Q: Q): ADDPXQ(on: processor, j: j, k: k, Q: Q)
        case let .BRREQ(j: j, k: k, Q: Q): BRREQ(on: processor, j: j, k: k, Q: Q)
        case let .BRRNE(j: j, k: k, Q: Q): BRRNE(on: processor, j: j, k: k, Q: Q)
        case let .BRRGT(j: j, k: k, Q: Q): BRRGT(on: processor, j: j, k: k, Q: Q)
        case let .BRRGE(j: j, k: k, Q: Q): BRRGE(on: processor, j: j, k: k, Q: Q)
        case let .BRXEQ(j: j, k: k, Q: Q): BRXEQ(on: processor, j: j, k: k, Q: Q)
        case let .BRXNE(j: j, k: k, Q: Q): BRXNE(on: processor, j: j, k: k, Q: Q)
        case let .BRXGT(j: j, k: k, Q: Q): BRXGT(on: processor, j: j, k: k, Q: Q)
        case let .BRXGE(j: j, k: k, Q: Q): BRXGE(on: processor, j: j, k: k, Q: Q)
        case let .BRFEQ(j: j, k: k, Q: Q): BRFEQ(on: processor, j: j, k: k, Q: Q)
        case let .BRFNE(j: j, k: k, Q: Q): BRFNE(on: processor, j: j, k: k, Q: Q)
        case let .BRFGT(j: j, k: k, Q: Q): BRFGT(on: processor, j: j, k: k, Q: Q)
        case let .BRFGE(j: j, k: k, Q: Q): BRFGE(on: processor, j: j, k: k, Q: Q)
        case let .BRINC(j: j, k: k, Q: Q): BRINC(on: processor, j: j, k: k, Q: Q)
        case let .BRSEG(j: j, k: k, Q: Q): BRSEG(on: processor, j: j, k: k, Q: Q)
        case let .BR___(j: j, k: k, Q: Q): BR___(on: processor, j: j, k: k, Q: Q)
        case let .BRCR(j: j, k: k, Q: Q): BRCR(on: processor, j: j, k: k, Q: Q)
        case let .CALLREL(j: j, k: k, Q: Q): CALLREL(on: processor, j: j, k: k, Q: Q)
        case let .KEYPOINT(j: j, k: k, Q: Q): KEYPOINT(on: processor, j: j, k: k, Q: Q)
        case let .MULXQ(j: j, k: k, Q: Q): MULXQ(on: processor, j: j, k: k, Q: Q)
        case let .ENTA(j: j, k: k, Q: Q): ENTA(on: processor, j: j, k: k, Q: Q)
        case let .CMPXA(j: j, k: k, Q: Q): CMPXA(on: processor, j: j, k: k, Q: Q)
        case let .CALLSEG(j: j, k: k, Q: Q): CALLSEG(on: processor, j: j, k: k, Q: Q)
        }

        switch self {
        case .CALLREL(j: _, k: _, Q: _),
                .CALLSEG(j: _, k: _, Q: _):
            // These instructions update P themselves.
            return false

        default:
            // All other instructions should get P updated automatically.
            return true
        }
    }

    internal func LMULT(on processor: Cyber962CP, j: UInt8, k: UInt8, Q: UInt16) {
        // TODO: Implement LMULT
    }

    internal func SMULT(on processor: Cyber962CP, j: UInt8, k: UInt8, Q: UInt16) {
        // TODO: Implement XXX.
    }

    internal func LX(on processor: Cyber962CP, j: UInt8, k: UInt8, Q: UInt16) {
        // TODO: Implement XXX.
    }

    internal func SX(on processor: Cyber962CP, j: UInt8, k: UInt8, Q: UInt16) {
        // TODO: Implement XXX.
    }

    internal func LA(on processor: Cyber962CP, j: UInt8, k: UInt8, Q: UInt16) {
        // TODO: Implement XXX.
    }

    internal func SA(on processor: Cyber962CP, j: UInt8, k: UInt8, Q: UInt16) {
        // TODO: Implement XXX.
    }

    internal func LBYTP(on processor: Cyber962CP, j: UInt8, k: UInt8, Q: UInt16) {
        // TODO: Implement XXX.
    }

    internal func ENTC(on processor: Cyber962CP, j: UInt8, k: UInt8, Q: UInt16) {
        // TODO: Implement XXX.
    }

    internal func LBIT(on processor: Cyber962CP, j: UInt8, k: UInt8, Q: UInt16) {
        // TODO: Implement XXX.
    }

    internal func SBIT(on processor: Cyber962CP, j: UInt8, k: UInt8, Q: UInt16) {
        // TODO: Implement XXX.
    }

    internal func ADDRQ(on processor: Cyber962CP, j: UInt8, k: UInt8, Q: UInt16) {
        // TODO: Implement XXX.
    }

    internal func ADDXQ(on processor: Cyber962CP, j: UInt8, k: UInt8, Q: UInt16) {
        // TODO: Implement XXX.
    }

    internal func MULRQ(on processor: Cyber962CP, j: UInt8, k: UInt8, Q: UInt16) {
        // TODO: Implement XXX.
    }

    internal func ENTE(on processor: Cyber962CP, j: UInt8, k: UInt8, Q: UInt16) {
        // TODO: Implement XXX.
    }

    internal func ADDAQ(on processor: Cyber962CP, j: UInt8, k: UInt8, Q: UInt16) {
        // TODO: Implement XXX.
    }

    internal func ADDPXQ(on processor: Cyber962CP, j: UInt8, k: UInt8, Q: UInt16) {
        // TODO: Implement XXX.
    }

    internal func BRREQ(on processor: Cyber962CP, j: UInt8, k: UInt8, Q: UInt16) {
        // TODO: Implement XXX.
    }

    internal func BRRNE(on processor: Cyber962CP, j: UInt8, k: UInt8, Q: UInt16) {
        // TODO: Implement XXX.
    }

    internal func BRRGT(on processor: Cyber962CP, j: UInt8, k: UInt8, Q: UInt16) {
        // TODO: Implement XXX.
    }

    internal func BRRGE(on processor: Cyber962CP, j: UInt8, k: UInt8, Q: UInt16) {
        // TODO: Implement XXX.
    }

    internal func BRXEQ(on processor: Cyber962CP, j: UInt8, k: UInt8, Q: UInt16) {
        // TODO: Implement XXX.
    }

    internal func BRXNE(on processor: Cyber962CP, j: UInt8, k: UInt8, Q: UInt16) {
        // TODO: Implement XXX.
    }

    internal func BRXGT(on processor: Cyber962CP, j: UInt8, k: UInt8, Q: UInt16) {
        // TODO: Implement XXX.
    }

    internal func BRXGE(on processor: Cyber962CP, j: UInt8, k: UInt8, Q: UInt16) {
        // TODO: Implement XXX.
    }

    internal func BRFEQ(on processor: Cyber962CP, j: UInt8, k: UInt8, Q: UInt16) {
        // TODO: Implement XXX.
    }

    internal func BRFNE(on processor: Cyber962CP, j: UInt8, k: UInt8, Q: UInt16) {
        // TODO: Implement XXX.
    }

    internal func BRFGT(on processor: Cyber962CP, j: UInt8, k: UInt8, Q: UInt16) {
        // TODO: Implement XXX.
    }

    internal func BRFGE(on processor: Cyber962CP, j: UInt8, k: UInt8, Q: UInt16) {
        // TODO: Implement XXX.
    }

    internal func BRINC(on processor: Cyber962CP, j: UInt8, k: UInt8, Q: UInt16) {
        // TODO: Implement XXX.
    }

    internal func BRSEG(on processor: Cyber962CP, j: UInt8, k: UInt8, Q: UInt16) {
        // TODO: Implement XXX.
    }

    internal func BR___(on processor: Cyber962CP, j: UInt8, k: UInt8, Q: UInt16) {
        // TODO: Implement XXX.
    }

    internal func BRCR(on processor: Cyber962CP, j: UInt8, k: UInt8, Q: UInt16) {
        // TODO: Implement XXX.
    }

    internal func CALLREL(on processor: Cyber962CP, j: UInt8, k: UInt8, Q: UInt16) {
        // TODO: Implement XXX.
    }

    internal func KEYPOINT(on processor: Cyber962CP, j: UInt8, k: UInt8, Q: UInt16) {
        // TODO: Implement XXX.
    }

    internal func MULXQ(on processor: Cyber962CP, j: UInt8, k: UInt8, Q: UInt16) {
        // TODO: Implement XXX.
    }

    internal func ENTA(on processor: Cyber962CP, j: UInt8, k: UInt8, Q: UInt16) {
        // TODO: Implement XXX.
    }

    internal func CMPXA(on processor: Cyber962CP, j: UInt8, k: UInt8, Q: UInt16) {
        // TODO: Implement XXX.
    }

    internal func CALLSEG(on processor: Cyber962CP, j: UInt8, k: UInt8, Q: UInt16) {
        // TODO: Implement XXX.
    }
}
