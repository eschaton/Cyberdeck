//
//  Cyber170PP+Instructions.swift
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


extension Cyber170PP {

    /// A protocol to which instructions conform.
    protocol Instruction {

        /// Attempt to decode one or two words as an instruction of this type, and return the decoded instruction or `nil`.
        static func decode(words: [Word]) -> Self?

        /// Execute the instruction.
        func execute(on processor: Cyber170PP)

        /// Disassemble the instruction.
        func disassemble() -> String
    }

    /// Load/Store Instructions (one-word)
    enum LoadStoreInstruction1: Instruction {
        case LDN(d: UInt8)
        case LCN(d: UInt8)
        case LRD(d: UInt8)
        case LDD(d: UInt8)
        case LDI(d: UInt8)
        case SRD(d: UInt8)
        case STD(d: UInt8)
        case STI(d: UInt8)

        static func decode(words: [Word]) -> Self? {
            let word0  = words[0].value
            let opcode = UInt8((word0 & 0x0FC0) >> 6)
            let d      = UInt8(word0 & 0x003F)

            switch opcode {
            case 0o14: return .LDN(d: d)
            case 0o15: return .LCN(d: d)
            case 0o24: return .LRD(d: d)
            case 0o30: return .LDD(d: d)
            case 0o40: return .LDI(d: d)
            case 0o25: return .SRD(d: d)
            case 0o34: return .STD(d: d)
            case 0o44: return .STI(d: d)
            default: return nil
            }
        }

        func execute(on processor: Cyber170PP) {
            switch self {
            case let .LDN(d: d): LDN(on: processor, d: d)
            case let .LCN(d: d): LCN(on: processor, d: d)
            case let .LRD(d: d): LRD(on: processor, d: d)
            case let .LDD(d: d): LDD(on: processor, d: d)
            case let .LDI(d: d): LDI(on: processor, d: d)
            case let .SRD(d: d): SRD(on: processor, d: d)
            case let .STD(d: d): STD(on: processor, d: d)
            case let .STI(d: d): STI(on: processor, d: d)
            }
        }

        func disassemble() -> String {
            switch self {
            case let .LDN(d: d): return "LDN \(d)"
            case let .LCN(d: d): return "LCN \(d)"
            case let .LRD(d: d): return "LRD \(d)"
            case let .LDD(d: d): return "LDD \(d)"
            case let .LDI(d: d): return "LDI \(d)"
            case let .SRD(d: d): return "SRD \(d)"
            case let .STD(d: d): return "STD \(d)"
            case let .STI(d: d): return "STI \(d)"
            }
        }

        internal func LDN(on processor: Cyber170PP, d: UInt8) {
            let av = UInt32(d)
            processor.regA = av
        }

        internal func LCN(on processor: Cyber170PP, d: UInt8) {
            let av = UInt32(d)
            let avc = ~av
            processor.regA = avc
        }

        internal func LRD(on processor: Cyber170PP, d: UInt8) {
            if d != 0 {
                let di = Int(d)
                let rvh = UInt32((processor.memory[di].value   & 0x03FF) << 18)
                let rvl = UInt32((processor.memory[di+1].value & 0x0FFF) <<  6)
                let rv = rvh | rvl
                processor.regR = rv
            } else {
                // Pass.
            }
        }

        internal func LDD(on processor: Cyber170PP, d: UInt8) {
            let di = Int(d)
            let av = processor.memory[di].value
            processor.regA = UInt32(av)
        }

        internal func LDI(on processor: Cyber170PP, d: UInt8) {
            // TODO: Implement LDI.
        }

        internal func SRD(on processor: Cyber170PP, d: UInt8) {
            if d != 0 {
                let di = Int(d)
                let rvh = UInt16((processor.regR >> 18) & 0x03FF)
                let rvl = UInt16((processor.regR >>  6) & 0x0FFF)
                processor.memory[di] = Word(rvh)
                processor.memory[di+1] = Word(rvl)
            } else {
                // Pass.
            }
        }

        internal func STD(on processor: Cyber170PP, d: UInt8) {
            let di = Int(d)
            let al: UInt16 = UInt16(processor.regA & 0x0FFF)
            processor.memory[di] = Word(al)
        }

        internal func STI(on processor: Cyber170PP, d: UInt8) {
            // TODO: Implement STI.
        }
    }

    /// Load/Store Instructions (two-word)
    enum LoadStoreInstruction2: Instruction {
        case LDC(d: UInt8, m: UInt16)
        case LDM(d: UInt8, m: UInt16)
        case STM(d: UInt8, m: UInt16)

        static func decode(words: [Word]) -> Self? {
            let word0  = words[0].value
            let opcode = UInt8((word0 & 0x0FC0) >> 6)
            let d      = UInt8(word0 & 0x003F)

            let word1  = words[1].value
            let m      = UInt16(word1 & 0x0FFF)

            switch opcode {
            case 0o20: return .LDC(d: d, m: m)
            case 0o50: return .LDM(d: d, m: m)
            case 0o54: return .STM(d: d, m: m)
            default: return nil
            }
        }

        func execute(on processor: Cyber170PP) {
            switch self {
            case let .LDC(d: d, m: m): LDC(on: processor, d: d, m: m)
            case let .LDM(d: d, m: m): LDM(on: processor, d: d, m: m)
            case let .STM(d: d, m: m): STM(on: processor, d: d, m: m)
            }
        }

        func disassemble() -> String {
            switch self {
            case let .LDC(d: d, m: m): return "LDC \(m), \(d)"
            case let .LDM(d: d, m: m): return "LDM \(m), \(d)"
            case let .STM(d: d, m: m): return "STM \(m), \(d)"
            }
        }

        internal func LDC(on processor: Cyber170PP, d: UInt8, m: UInt16) {
            let avh: UInt32 = UInt32(d) << 12
            let avl: UInt32 = UInt32(m) << 0
            let av: UInt32 = avh | avl
            processor.regA = av
        }

        internal func LDM(on processor: Cyber170PP, d: UInt8, m: UInt16) {
            // TODO: Implement LDM
        }

        internal func STM(on processor: Cyber170PP, d: UInt8, m: UInt16) {
            // TODO: Implement STM
        }
    }

    /// Arithmetic Instructions (one-word)
    enum ArithmeticInstruction1: Instruction {
        case ADN(d: UInt8)
        case ADD(d: UInt8)
        case ADI(d: UInt8)
        case SBN(d: UInt8)
        case SBD(d: UInt8)
        case SBI(d: UInt8)

        static func decode(words: [Word]) -> Self? {
            let word0  = words[0].value
            let opcode = UInt8((word0 & 0x0FC0) >> 6)
            let d      = UInt8(word0 & 0x003F)

            switch opcode {
            case 0o16: return .ADN(d: d)
            case 0o31: return .ADD(d: d)
            case 0o41: return .ADI(d: d)
            case 0o17: return .SBN(d: d)
            case 0o32: return .SBD(d: d)
            case 0o42: return .SBI(d: d)
            default: return nil
            }
        }

        func execute(on processor: Cyber170PP) {
            switch self {
            case let .ADN(d: d): ADN(on: processor, d: d)
            case let .ADD(d: d): ADD(on: processor, d: d)
            case let .ADI(d: d): ADI(on: processor, d: d)
            case let .SBN(d: d): SBN(on: processor, d: d)
            case let .SBD(d: d): SBD(on: processor, d: d)
            case let .SBI(d: d): SBI(on: processor, d: d)
            }
        }

        func disassemble() -> String {
            switch self {
            case let .ADN(d: d): return "ADN \(d)"
            case let .ADD(d: d): return "ADD \(d)"
            case let .ADI(d: d): return "ADI \(d)"
            case let .SBN(d: d): return "SBN \(d)"
            case let .SBD(d: d): return "SBD \(d)"
            case let .SBI(d: d): return "SBI \(d)"
            }
        }

        func ADN(on processor: Cyber170PP, d: UInt8) {
            // TODO: Implement ADN.
        }

        func ADD(on processor: Cyber170PP, d: UInt8) {
            // TODO: Implement ADD.
        }

        func ADI(on processor: Cyber170PP, d: UInt8) {
            // TODO: Implement ADI.
        }

        func SBN(on processor: Cyber170PP, d: UInt8) {
            // TODO: Implement SBN.
        }

        func SBD(on processor: Cyber170PP, d: UInt8) {
            // TODO: Implement SBD.
        }

        func SBI(on processor: Cyber170PP, d: UInt8) {
            // TODO: Implement SBI.
        }
    }

    /// Arithmetic Instructions (two-word)
    enum ArithmeticInstruction2: Instruction {
        case ADC(d: UInt8, m: UInt16)
        case ADM(d: UInt8, m: UInt16)
        case SBM(d: UInt8, m: UInt16)

        static func decode(words: [Word]) -> Self? {
            let word0  = words[0].value
            let opcode = UInt8((word0 & 0x0FC0) >> 6)
            let d      = UInt8(word0 & 0x003F)

            let word1  = words[1].value
            let m      = UInt16(word1 & 0x0FFF)

            switch opcode {
            case 0o21: return .ADC(d: d, m: m)
            case 0o51: return .ADM(d: d, m: m)
            case 0o52: return .SBM(d: d, m: m)
            default: return nil
            }
        }

        func execute(on processor: Cyber170PP) {
            switch self {
            case let .ADC(d: d, m: m): ADC(on: processor, d: d, m: m)
            case let .ADM(d: d, m: m): ADM(on: processor, d: d, m: m)
            case let .SBM(d: d, m: m): SBM(on: processor, d: d, m: m)
            }
        }

        func disassemble() -> String {
            switch self {
            case let .ADC(d: d, m: m): return "ADC \(m), \(d)"
            case let .ADM(d: d, m: m): return "ADM \(m), \(d)"
            case let .SBM(d: d, m: m): return "SBM \(m), \(d)"
            }
        }

        func ADC(on processor: Cyber170PP, d: UInt8, m: UInt16) {
            // TODO: Implement ADC.
        }

        func ADM(on processor: Cyber170PP, d: UInt8, m: UInt16) {
            // TODO: Implement ADM.
        }

        func SBM(on processor: Cyber170PP, d: UInt8, m: UInt16) {
            // TODO: Implement SBM.
        }
    }

    /// Logical Instructions (one-word)
    enum LogicalInstruction1: Instruction {
        case SHN(d: UInt8)
        case SCN(d: UInt8)
        case LMN(d: UInt8)
        case LMD(d: UInt8)
        case LMI(d: UInt8)
        case LPN(d: UInt8)

        static func decode(words: [Word]) -> Self? {
            let word0  = words[0].value
            let opcode = UInt8((word0 & 0x0FC0) >> 6)
            let d      = UInt8(word0 & 0x003F)

            switch opcode {
            case 0o10: return .SHN(d: d)
            case 0o13: return .SCN(d: d)
            case 0o11: return .LMN(d: d)
            case 0o33: return .LMD(d: d)
            case 0o43: return .LMI(d: d)
            case 0o12: return .LPN(d: d)
            default: return nil
            }
        }

        func execute(on processor: Cyber170PP) {
            switch self {
            case let .SHN(d: d): SHN(on: processor, d: d)
            case let .SCN(d: d): SCN(on: processor, d: d)
            case let .LMN(d: d): LMN(on: processor, d: d)
            case let .LMD(d: d): LMD(on: processor, d: d)
            case let .LMI(d: d): LMI(on: processor, d: d)
            case let .LPN(d: d): LPN(on: processor, d: d)
            }
        }

        func disassemble() -> String {
            switch self {
            case let .SHN(d: d): "SHN \(d)"
            case let .SCN(d: d): "SCN \(d)"
            case let .LMN(d: d): "LMN \(d)"
            case let .LMD(d: d): "LMD \(d)"
            case let .LMI(d: d): "LMI \(d)"
            case let .LPN(d: d): "LPN \(d)"
            }
        }

        /// Shift `d`
        ///
        /// This instruction shifts the content of the `A` register right or left `d` places.
        /// If `d` is positive (`0o00` through `0o37`), the shift is left circular.
        /// If `d` is negative (`0o40` through `0o77`), the shift is right circular (end-off with no sign extension).
        /// Thus `d` equal to `0o06` requires a left-shift of six places; `d` equal to `0o71` requires a right-shift of six places.
        internal func SHN(on processor: Cyber170PP, d: UInt8) {
            let a = processor.regA
            let ds = signExtend6(d)
            let av = (ds > 0) ? (a << ds) : (a >> -ds)
            processor.regA = av
        }

        /// Selective Clear `d`
        ///
        /// This instruction clears the lower bits of the `A` register where corresponding bits of `d` are one.
        /// The upper 12 bits of `A` are not altered.
        internal func SCN(on processor: Cyber170PP, d: UInt8) {
            let a: UInt32 = processor.regA
            let m: UInt32 = 0x3FFC0 | ~UInt32(d)
            let av: UInt32 = a & m
            processor.regA = av
        }

        /// Logical Difference `d`
        ///
        /// This instruction forms the bit-by-bit logical difference of `d` and the lower 6 bits of the `A` register.
        /// This is equivalent to complementing individual bits of `A` that correspond to bits of `d` that are one.
        /// The upper 12 bits of `A` are not altered.
        internal func LMN(on processor: Cyber170PP, d: UInt8) {
            // TODO: Implement LMN.
        }

        /// Logical Difference `(d)`
        ///
        /// This instruction forms in the `A` register the bit-by-bit logical difference of the lower 12 bits of the `A` register and the content at location `d`.
        /// This is equivalent to complementing individual bits of `A` that correspond to bits in location `d` that are ones.
        /// The upper 6 bits are not altered.
        internal func LMD(on processor: Cyber170PP, d: UInt8) {
            // TODO: Implement LMD.
        }

        /// Logical Difference `((d))`
        ///
        /// This instruction forms in the `A` register the bit-by-bit logical difference of the lower 12 bits of the `A` register and the 12-bit operand read by indirect addressing.
        /// Location `d` is read from PPM, and the word read is used as the operand address.
        /// The upper 6 bits of `A` are not altered.
        internal func LMI(on processor: Cyber170PP, d: UInt8) {
            // TODO: Implement LMI.
        }

        /// Logical Product `d`
        ///
        /// This instruction forms the bit-by-bit logical product of `d` and the lower 6 bits of the `A` register and leaves this quantity in the lower 6 bits of `A`.
        /// The upper 12 bits of `A` are zero.
        internal func LPN(on processor: Cyber170PP, d: UInt8) {
            // TODO: Implement LPN.
        }

    }

    /// Logical Instructions (ttwo-word)
    enum LogicalInstruction2: Instruction {
        case LMC(d: UInt8, m: UInt16)
        case LMM(d: UInt8, m: UInt16)
        case LPC(d: UInt8, m: UInt16)

        static func decode(words: [Word]) -> Self? {
            let word0  = words[0].value
            let opcode = UInt8((word0 & 0x0FC0) >> 6)
            let d      = UInt8(word0 & 0x003F)

            let word1  = words[1].value
            let m      = UInt16(word1 & 0x0FFF)

            switch opcode {
            case 0o23: return .LMC(d: d, m: m)
            case 0o53: return .LMM(d: d, m: m)
            case 0o22: return .LPC(d: d, m: m)
            default: return nil
            }
        }

        func execute(on processor: Cyber170PP) {
            switch self {
            case let .LMC(d: d, m: m): LMC(on: processor, d: d, m: m)
            case let .LMM(d: d, m: m): LMM(on: processor, d: d, m: m)
            case let .LPC(d: d, m: m): LPC(on: processor, d: d, m: m)
            }
        }

        func disassemble() -> String {
            switch self {
            case let .LMC(d: d, m: m): return "LMC \(m), \(d)"
            case let .LMM(d: d, m: m): return "LMM \(m), \(d)"
            case let .LPC(d: d, m: m): return "LPC \(m), \(d)"
            }
        }

        internal func LMC(on processor: Cyber170PP, d: UInt8, m: UInt16) {
            // TODO: Implement LMC
        }

        internal func LMM(on processor: Cyber170PP, d: UInt8, m: UInt16) {
            // TODO: Implement LMM
        }

        internal func LPC(on processor: Cyber170PP, d: UInt8, m: UInt16) {
            // TODO: Implement LPC
        }
    }

    /// Replace Instructions (one-word)
    enum ReplaceInstruction1: Instruction {
        case RAD(d: UInt8)
        case AOD(d: UInt8)
        case RAI(d: UInt8)
        case AOI(d: UInt8)
        case SOD(d: UInt8)
        case SOI(d: UInt8)

        static func decode(words: [Word]) -> Self? {
            let word0  = words[0].value
            let opcode = UInt8((word0 & 0x0FC0) >> 6)
            let d      = UInt8(word0 & 0x003F)

            switch opcode {
            case 0o35: return .RAD(d: d)
            case 0o36: return .AOD(d: d)
            case 0o45: return .RAI(d: d)
            case 0o46: return .AOI(d: d)
            case 0o37: return .SOD(d: d)
            case 0o47: return .SOI(d: d)
            default: return nil
            }
        }

        func execute(on processor: Cyber170PP) {
            switch self {
            case let .RAD(d: d): RAD(on: processor, d: d)
            case let .AOD(d: d): AOD(on: processor, d: d)
            case let .RAI(d: d): RAI(on: processor, d: d)
            case let .AOI(d: d): AOI(on: processor, d: d)
            case let .SOD(d: d): SOD(on: processor, d: d)
            case let .SOI(d: d): SOI(on: processor, d: d)
            }
        }

        func disassemble() -> String {
            switch self {
            case let .RAD(d: d): "RAD \(d)"
            case let .AOD(d: d): "AOD \(d)"
            case let .RAI(d: d): "RAI \(d)"
            case let .AOI(d: d): "AOI \(d)"
            case let .SOD(d: d): "SOD \(d)"
            case let .SOI(d: d): "SOI \(d)"
            }
        }

        /// Replace add `(d)`
        internal func RAD(on processor: Cyber170PP, d: UInt8) {
            // TODO: Implement XXX.
        }

        /// Replace add `1` `(d)`
        internal func AOD(on processor: Cyber170PP, d: UInt8) {
            // TODO: Implement XXX.
        }

        /// Replace add `((d))`
        internal func RAI(on processor: Cyber170PP, d: UInt8) {
            // TODO: Implement XXX.
        }

        /// Replace add `1` `((d))`
        internal func AOI(on processor: Cyber170PP, d: UInt8) {
            // TODO: Implement XXX.
        }

        /// Replace subtract `1` `(d)`
        internal func SOD(on processor: Cyber170PP, d: UInt8) {
            // TODO: Implement XXX.
        }

        /// Replace subtract `1` `((d))`
        internal func SOI(on processor: Cyber170PP, d: UInt8) {
            // TODO: Implement XXX.
        }
    }

    /// Replace Instructions (two-word)
    enum ReplaceInstruction2: Instruction {
        case RAM(d: UInt8, m: UInt16)
        case AOM(d: UInt8, m: UInt16)
        case SOM(d: UInt8, m: UInt16)

        static func decode(words: [Word]) -> Self? {
            let word0  = words[0].value
            let opcode = UInt8((word0 & 0x0FC0) >> 6)
            let d      = UInt8(word0 & 0x003F)

            let word1  = words[1].value
            let m      = UInt16(word1 & 0x0FFF)

            switch opcode {
            case 0o55: return .RAM(d: d, m: m)
            case 0o56: return .AOM(d: d, m: m)
            case 0o57: return .SOM(d: d, m: m)
            default: return nil
            }
        }

        func execute(on processor: Cyber170PP) {
            switch self {
            case let .RAM(d: d, m: m): RAM(on: processor, d: d, m: m)
            case let .AOM(d: d, m: m): AOM(on: processor, d: d, m: m)
            case let .SOM(d: d, m: m): SOM(on: processor, d: d, m: m)
            }
        }

        func disassemble() -> String {
            switch self {
            case let .RAM(d: d, m: m): "RAM \(m),\(d)"
            case let .AOM(d: d, m: m): "AOM \(m),\(d)"
            case let .SOM(d: d, m: m): "SOM \(m),\(d)"
            }
        }

        /// Replace add `(m + (d))`
        internal func RAM(on processor: Cyber170PP, d: UInt8, m: UInt16) {
            // TODO: Implement RAM.
        }

        /// Replace add `1` `(m + (d))`
        internal func AOM(on processor: Cyber170PP, d: UInt8, m: UInt16) {
            // TODO: Implement AOM.
        }

        /// Replace subtract `1` `(m + (d))`
        internal func SOM(on processor: Cyber170PP, d: UInt8, m: UInt16) {
            // TODO: Implement SOM.
        }
    }

    /// Branch Instructions (one-word)
    enum BranchInstruction1: Instruction {
        case UJN(d: UInt8)
        case ZJN(d: UInt8)
        case NJN(d: UInt8)
        case PJN(d: UInt8)
        case MJN(d: UInt8)

        static func decode(words: [Word]) -> Self? {
            let word0  = words[0].value
            let opcode = UInt8((word0 & 0x0FC0) >> 6)
            let d      = UInt8(word0 & 0x003F)

            switch opcode {
            case 0o03: return .UJN(d: d)
            case 0o04: return .ZJN(d: d)
            case 0o05: return .NJN(d: d)
            case 0o06: return .PJN(d: d)
            case 0o07: return .MJN(d: d)
            default: return nil
            }
        }

        func execute(on processor: Cyber170PP) {
            switch self {
            case let .UJN(d: d): UJN(on: processor, d: d)
            case let .ZJN(d: d): ZJN(on: processor, d: d)
            case let .NJN(d: d): NJN(on: processor, d: d)
            case let .PJN(d: d): PJN(on: processor, d: d)
            case let .MJN(d: d): MJN(on: processor, d: d)
            }
        }

        func disassemble() -> String {
            switch self {
            case let .UJN(d: d): "UJN \(d)"
            case let .ZJN(d: d): "ZJN \(d)"
            case let .NJN(d: d): "NJN \(d)"
            case let .PJN(d: d): "PJN \(d)"
            case let .MJN(d: d): "MJN \(d)"
            }
        }

        /// Unconditional jump `d`
        internal func UJN(on processor: Cyber170PP, d: UInt8) {
            let p = processor.regP
            let ds = signExtend6(d)
            let pv = UInt16(Int(p) + Int(ds))
            processor.regP = pv
        }

        /// Zero jump `d`
        internal func ZJN(on processor: Cyber170PP, d: UInt8) {
            let a = processor.regA
            if a == 0 {
                let p = processor.regP
                let ds = signExtend6(d)
                let pv = UInt16(Int(p) + Int(ds))
                processor.regP = pv
            }
        }

        /// Nonzero jump `d`
        internal func NJN(on processor: Cyber170PP, d: UInt8) {
            let a = processor.regA
            if a != 0 {
                let p = processor.regP
                let ds = signExtend6(d)
                let pv = UInt16(Int(p) + Int(ds))
                processor.regP = pv
            }
        }

        /// Plus jump `d`
        internal func PJN(on processor: Cyber170PP, d: UInt8) {
            let a = processor.regA
            if (a & 0o400000) == 0 {
                let p = processor.regP
                let ds = signExtend6(d)
                let pv = UInt16(Int(p) + Int(ds))
                processor.regP = pv
            }
        }

        /// Minus jump `d`
        internal func MJN(on processor: Cyber170PP, d: UInt8) {
            let a = processor.regA
            if (a & 0o400000) != 0 {
                let p = processor.regP
                let ds = signExtend6(d)
                let pv = UInt16(Int(p) + Int(ds))
                processor.regP = pv
            }
        }
    }

    /// Branch Instructions (two-word)
    enum BranchInstruction2: Instruction {
        case LJM(d: UInt8, m: UInt16)
        case RJM(d: UInt8, m: UInt16)
        case AJM(c: UInt8, m: UInt16)
        case IJM(c: UInt8, m: UInt16)
        case FJM(c: UInt8, m: UInt16)
        case SFM(c: UInt8, m: UInt16)
        case EJM(c: UInt8, m: UInt16)
        case CFM(c: UInt8, m: UInt16)

        static func decode(words: [Word]) -> Self? {
            let word0  = words[0].value
            let opcode = UInt8((word0 & 0x0FC0) >> 6)
            let d      = UInt8(word0 & 0x003F)
            let dhi    = (d & 0b100_000) != 0
            let c      = d & 0b011_111

            let word1  = words[1].value
            let m      = UInt16(word1 & 0x0FFF)

            switch opcode {
            case 0o01: return .LJM(d: d, m: m)
            case 0o02: return .RJM(d: d, m: m)
            case 0o64: if !dhi { return .AJM(c: c, m: m) } else { return nil }
            case 0o65: if !dhi { return .IJM(c: c, m: m) } else { return nil }
            case 0o66: if !dhi { return .FJM(c: c, m: m) } else { return .SFM(c: c, m: m) }
            case 0o67: if !dhi { return .EJM(c: c, m: m) } else { return .CFM(c: c, m: m) }
            default: return nil
            }
        }

        func execute(on processor: Cyber170PP) {
            switch self {
            case let .LJM(d: d, m: m): LJM(on: processor, d: d, m: m)
            case let .RJM(d: d, m: m): RJM(on: processor, d: d, m: m)
            case let .AJM(c: c, m: m): AJM(on: processor, c: c, m: m)
            case let .IJM(c: c, m: m): IJM(on: processor, c: c, m: m)
            case let .FJM(c: c, m: m): FJM(on: processor, c: c, m: m)
            case let .SFM(c: c, m: m): SFM(on: processor, c: c, m: m)
            case let .EJM(c: c, m: m): EJM(on: processor, c: c, m: m)
            case let .CFM(c: c, m: m): CFM(on: processor, c: c, m: m)
            }
        }

        func disassemble() -> String {
            switch self {
            case let .LJM(d: d, m: m): "LJM \(m),\(d)"
            case let .RJM(d: d, m: m): "RJM \(m),\(d)"
            case let .AJM(c: c, m: m): "AJM \(m),\(c)"
            case let .IJM(c: c, m: m): "IJM \(m),\(c)"
            case let .FJM(c: c, m: m): "FJM \(m),\(c)"
            case let .SFM(c: c, m: m): "SFM \(m),\(c)"
            case let .EJM(c: c, m: m): "EJM \(m),\(c)"
            case let .CFM(c: c, m: m): "CFM \(m),\(c)"
            }
        }

        /// Long jump to `m + (d)`
        internal func LJM(on processor: Cyber170PP, d: UInt8, m: UInt16) {
            // TODO: Implement LJM.
        }

        /// Return jump to `m + (d)`
        internal func RJM(on processor: Cyber170PP, d: UInt8, m: UInt16) {
            // TODO: Implement RJM.
        }

        /// Jump to `m` if channel `c` active
        internal func AJM(on processor: Cyber170PP, c: UInt8, m: UInt16) {
            // TODO: Implement AJM.
        }

        /// Jump to `m` if channel `c` inactive
        internal func IJM(on processor: Cyber170PP, c: UInt8, m: UInt16) {
            // TODO: Implement IJM.
        }

        /// Jump to `m` if channel `c` full
        internal func FJM(on processor: Cyber170PP, c: UInt8, m: UInt16) {
            // TODO: Implement FJM.
        }

        /// Jump to `m` if channel `c` error flag set
        internal func SFM(on processor: Cyber170PP, c: UInt8, m: UInt16) {
            // TODO: Implement SFM.
        }

        /// Jump to `m` if channel `c` empty
        internal func EJM(on processor: Cyber170PP, c: UInt8, m: UInt16) {
            // TODO: Implement EJM.
        }

        /// Jump to `m` if channel `c` error flag clear
        internal func CFM(on processor: Cyber170PP, c: UInt8, m: UInt16) {
            // TODO: Implement CFM.
        }
    }

    /// Central Memory Access Instructions (one-word)
    enum CentralMemoryAccessInstruction1: Instruction {
        case CRD(d: UInt8)
        case CWD(d: UInt8)

        static func decode(words: [Word]) -> Self? {
            let word0  = words[0].value
            let opcode = UInt8((word0 & 0x0FC0) >> 6)
            let d      = UInt8(word0 & 0x003F)

            switch opcode {
            case 0o60: return .CRD(d: d)
            case 0o62: return .CWD(d: d)
            default: return nil
            }
        }

        func execute(on processor: Cyber170PP) {
            switch self {
            case let .CRD(d: d): CRD(on: processor, d: d)
            case let .CWD(d: d): CWD(on: processor, d: d)
            }
        }

        func disassemble() -> String {
            switch self {
            case let .CRD(d: d): "CRD \(d)"
            case let .CWD(d: d): "CWD \(d)"
            }
        }

        /// Central Read from `(A)` to `d`
        ///
        /// This instruction disassembles one 60-bit word from central memory into five 12-bit words and stores these in five consecutive PP memory locations, beginning with the leftmost 12 bits of the 60-bit word.
        ///
        /// The parameters of the transfer are as follows: If bit 17 of `A` is zero, `A` bits 0 through 16 contain the absolute address of the 60-bit word transferred.
        /// If bit 17 of `A` is one, hardware adds relocation register `R` to zero-etended `A` bits 0 through 16 to obtani the absolute address of the 60-bit word transferred.
        /// Field `d` gives the PP location that receives the first 12-bit word transfered. PP memory addressing is cyclic, and location `0o0000` follows location `0o7777`.
        internal func CRD(on processor: Cyber170PP, d: UInt8) {
            // TODO: Implement CRD.
        }

        /// Central Write to `(A)` from `d`
        ///
        /// This instruction assembles five 12-bit words from consecutive PP memory locations into one 60-bit word and stores the 60-bit word in central memory. The first 12-bit word is stored in the leftmost 12 bits of the 60-bit word. (PP memory addressing is cyclic, and location `0o0000` follows location `0o7777`.)
        ///
        /// The parameters of the transfer are as follows: If bit 17 of `A` is zeo, `A` bits 0 through 16 contain the absolute address of the 60-bit word stored. If bit 17 of `A` is one, hardware adds relocation register `R` to zero-extended `A` bits 0 through 16 to obtain the absolute address of the 60-bit word stored.
        /// Field `d` gives the PP location of the first 12-bit word transferred. The trnsfer is subject to the CM bounds test.
        internal func CWD(on processor: Cyber170PP, d: UInt8) {
            // TODO: Implement CWD.
        }
    }

    //// Central Memory Access Instructions (two-word)
    enum CentralMemoryAccessInstruction2: Instruction {
        case CRM(d: UInt8, m: UInt16)
        case CWM(d: UInt8, m: UInt16)

        static func decode(words: [Word]) -> Self? {
            let word0  = words[0].value
            let opcode = UInt8((word0 & 0x0FC0) >> 6)
            let d      = UInt8(word0 & 0x003F)

            let word1  = words[1].value
            let m      = UInt16(word1 & 0x0FFF)

            switch opcode {
            case 0o61: return .CRM(d: d, m: m)
            case 0o63: return .CWM(d: d, m: m)
            default: return nil
            }
        }

        func execute(on processor: Cyber170PP) {
            switch self {
            case let .CRM(d: d, m: m): CRM(on: processor, d: d, m: m)
            case let .CWM(d: d, m: m): CWM(on: processor, d: d, m: m)
            }
        }

        func disassemble() -> String {
            switch self {
            case let .CRM(d: d, m: m): return "CRM \(m), \(d)"
            case let .CWM(d: d, m: m): return "CWM \(m), \(d)"
            }
        }

        /// Central Read `(d)` words from `(A)` to `m`
        internal func CRM(on processor: Cyber170PP, d: UInt8, m: UInt16) {
            // TODO: Implement XXX.
        }

        /// Central Wirte `(d)` words to `(A)` from `m`.
        internal func CWM(on processor: Cyber170PP, d: UInt8, m: UInt16) {
            // TODO: Implement XXX.
        }
    }

    /// Input/Output Instructions (one-word)
    enum InputOutputInstruction1: Instruction {
        case IAN(d: UInt8)
        case OAN(d: UInt8)
        case ACN(d: UInt8)
        case DCN(d: UInt8)
        case FAN(d: UInt8)

        static func decode(words: [Word]) -> Self? {
            let word0  = words[0].value
            let opcode = UInt8((word0 & 0x0FC0) >> 6)
            let d      = UInt8(word0 & 0x003F)

            switch opcode {
            case 0o70: return .IAN(d: d)
            case 0o72: return .OAN(d: d)
            case 0o74: return .ACN(d: d)
            case 0o75: return .DCN(d: d)
            case 0o76: return .FAN(d: d)
            default: return nil
            }
        }

        func execute(on processor: Cyber170PP) {
            switch self {
            case let .IAN(d: d): IAN(on: processor, d: d)
            case let .OAN(d: d): OAN(on: processor, d: d)
            case let .ACN(d: d): ACN(on: processor, d: d)
            case let .DCN(d: d): DCN(on: processor, d: d)
            case let .FAN(d: d): FAN(on: processor, d: d)
            }
        }

        func disassemble() -> String {
            switch self {
            case let .IAN(d: d): return "IAN \(d)"
            case let .OAN(d: d): return "OAN \(d)"
            case let .ACN(d: d): return "ACN \(d)"
            case let .DCN(d: d): return "DCN \(d)"
            case let .FAN(d: d): return "FAN \(d)"
            }
        }

        /// Input to `A` form channel `d`
        internal func IAN(on processor: Cyber170PP, d: UInt8) {
            // TODO: Implement IAN.
        }

        /// Output from `A` on channel `d`
        internal func OAN(on processor: Cyber170PP, d: UInt8) {
            // TODO: Implement OAN.
        }

        /// Activate channel `d`
        internal func ACN(on processor: Cyber170PP, d: UInt8) {
            // TODO: Implement ACN.
        }

        /// Deactivate channel `d`
        internal func DCN(on processor: Cyber170PP, d: UInt8) {
            // TODO: Implement DCN.
        }

        /// Function `A` on on channel `d`
        internal func FAN(on processor: Cyber170PP, d: UInt8) {
            // TODO: Implement FAN.
        }
    }

    /// Input/Output Instructions (two-word)
    enum InputOutputInstruction2: Instruction {
        case SCF(c: UInt8, m: UInt16)
        case CCF(c: UInt8, m: UInt16)
        case IAM(d: UInt8, m: UInt16)
        case OAM(d: UInt8, m: UInt16)
        case FNC(d: UInt8, m: UInt16)

        static func decode(words: [Word]) -> Self? {
            let word0  = words[0].value
            let opcode = UInt8((word0 & 0x0FC0) >> 6)
            let d      = UInt8(word0 & 0x003F)
            let dhi    = (d & 0b100_000) != 0
            let c      = d & 0b011_111

            let word1  = words[1].value
            let m      = UInt16(word1 & 0x0FFF)

            switch opcode {
            case 0o64: if dhi { return .SCF(c: c, m: m) } else { return nil }
            case 0o65: if dhi { return .CCF(c: c, m: m) } else { return nil }
            case 0o71: return .IAM(d: d, m: m)
            case 0o73: return .OAM(d: d, m: m)
            case 0o77: return .FNC(d: d, m: m)
            default: return nil
            }
        }

        func execute(on processor: Cyber170PP) {
            switch self {
            case let .SCF(c: c, m: m): SCF(on: processor, c: c, m: m)
            case let .CCF(c: c, m: m): CCF(on: processor, c: c, m: m)
            case let .IAM(d: d, m: m): IAM(on: processor, d: d, m: m)
            case let .OAM(d: d, m: m): OAM(on: processor, d: d, m: m)
            case let .FNC(d: d, m: m): FNC(on: processor, d: d, m: m)
            }
        }

        func disassemble() -> String {
            switch self {
            case let .SCF(c: c, m: m): "SCF \(m),\(c)"
            case let .CCF(c: c, m: m): "CCF \(m),\(c)"
            case let .IAM(d: d, m: m): "IAM \(m),\(d)"
            case let .OAM(d: d, m: m): "OAM \(m),\(d)"
            case let .FNC(d: d, m: m): "FNC \(m),\(d)"
            }
        }

        /// Test and set channel `c` flag.
        internal func SCF(on processor: Cyber170PP, c: UInt8, m: UInt16) {
            // TODO: Implement SCF.
        }

        /// Clear channel `c` flag.
        internal func CCF(on processor: Cyber170PP, c: UInt8, m: UInt16) {
            // TODO: Implement CCF.
        }

        /// Input `A` words to `m` from channel `d`.
        internal func IAM(on processor: Cyber170PP, d: UInt8, m: UInt16) {
            // TODO: Implement IAM.
        }

        /// Output `A` words from `m` to channel `d`.
        internal func OAM(on processor: Cyber170PP, d: UInt8, m: UInt16) {
            // TODO: Implement OAM.
        }

        /// Function `m` on channel `d`
        internal func FNC(on processor: Cyber170PP, d: UInt8, m: UInt16) {
            // TODO: Implement FNC.
        }
    }

    /// Other Instructions
    enum OtherInstruction: Instruction {
        case PSN(d: UInt8)
        case KPT(d: UInt8)
        case EXN
        case MXN
        case MAN

        static func decode(words: [Word]) -> Self? {
            let word0  = words[0].value
            let opcode = UInt8((word0 & 0x0FC0) >> 6)
            let d      = UInt8(word0 & 0x003F)

            switch opcode {
            case 0o00: return .PSN(d: d)
            case 0o27: return .KPT(d: d)
            case 0o26:
                switch d {
                case 0o00: return .EXN
                case 0o10: return .MXN
                case 0o20: return .MAN
                default: return nil
                }
            default: return nil
            }
        }

        func execute(on processor: Cyber170PP) {
            switch self {
            case let .PSN(d: d): PSN(on: processor, d: d)
            case let .KPT(d: d): KPT(on: processor, d: d)
            case .EXN: EXN(on: processor)
            case .MXN: MXN(on: processor)
            case .MAN: MAN(on: processor)
            }
        }

        func disassemble() -> String {
            switch self {
            case let .PSN(d: d): return "PSN \(d)"
            case let .KPT(d: d): return "KPT \(d)"
            case .EXN: return "EXN"
            case .MXN: return "MXN"
            case .MAN: return "MAN"
            }
        }

        /// Pass
        internal func PSN(on processor: Cyber170PP, d: UInt8) {
            // TODO: Implement PSN.
        }

        /// Pass pulsing test point
        internal func KPT(on processor: Cyber170PP, d: UInt8) {
            // TODO: Implement KPT.
        }

        /// Exchange jump
        internal func EXN(on processor: Cyber170PP) {
            // TODO: Implement EXN.
        }

        /// Monitor exchange jump
        internal func MXN(on processor: Cyber170PP) {
            // TODO: Implement MXN.
        }

        /// Monitor exchange jump to MA
        internal func MAN(on processor: Cyber170PP) {
            // TODO: Implement MAN.
        }
    }
}
