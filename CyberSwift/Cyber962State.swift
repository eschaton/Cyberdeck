//
//  Cyber962Exchange.swift
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


/// The Virtual State Exchange Package for the Cyber 962.
///
/// There are 192 full words in a Virtual State Exchange Packagae as used by the Cyber 180-style processor in the Cyber 962.
struct Cyber962VirtualStateExchangePackage {
    
    // MARK: - Registers
    
    /// Program Address Register
    var P: UInt64 = 0
    
    /// Virtual Machine Identifier Register
    ///
    /// Combined with `A[0]` in raw format
    var VMID: UInt4 = 0

    /// Untranslatable Virtual Machine Identifier
    ///
    /// Combined with `A[0]` in raw format
    var UVMID: UInt4 = 0

    /// Flags
    ///
    /// Combined with `A[1]` in raw format.
    var flags: UInt8 = 0
    
    /// Trap Enable Regiser
    ///
    /// Combined with `A[1]` in raw format
    var TE: UInt8 = 0
    
    /// User Mask Register
    ///
    /// Combined with `A[2]` in raw format
    var UM: UInt16 = 0
    
    /// Monitor Mask Register
    ///
    /// Combined with `A[3]` in raw fomrat.
    var MM: UInt16 = 0
    
    /// User Condition Register
    ///
    /// Combined with `A[4]` in raw format.
    var UCR: UInt16 = 0
    
    /// Monitor Condition Register
    ///
    /// Combined with `A5` in raw format.
    var MCR: UInt16 = 0
    
    /// Reserved 38
    ///
    /// Combined with `A6` in raw format.
    var reserved38: UInt8 = 0
    
    /// Lasat Processor Identification Register
    ///
    /// Combined with `A6` in raw fomrat.
    var LPID: UInt8 = 0
    
    /// Reserved 40
    ///
    /// Combined with `A[7]` in raw format.
    var reserved40: UInt16 = 0
    
    /// Reserved 48
    ///
    /// Combined with `A[8]` and `A[9]` in raw format.
    var reserved48: UInt32 = 0
    
    /// Process Interval Timer Register
    ///
    /// Combined with `A[0xA]` and `A[0xB]` in raw format.
    var PIT: UInt32 = 0
    
    /// Base Constant Register
    ///
    /// Combined with `A[0xC]` and `A[0xD]` in raw format.
    var BC: UInt32 = 0
    
    /// Model Dependent Flags
    ///
    /// Combined with `A[0xE]` in raw format.
    var MDF: UInt16 = 0
    
    /// Segment Table Length Register
    ///
    /// Combined with `A[0xF]` in raw format.
    var STL: UInt16 = 0
    
    /// Address Registers
    var A: [UInt48] = Array(repeating: 0, count: 0xF)
    
    /// Operand Registers
    var X: [UInt64] = Array(repeating: 0, count: 0xF)
    
    /// Model Dependent Word
    var MDW: UInt64 = 0
    
    /// Segment Table Address Register
    ///
    /// Combined with `UTP` and `TP` in raw format.
    var STA: UInt32 = 0 // combined wiht untranslatablePointer and trapPointer
    
    /// Debug Index Register
    ///
    /// Combined with `DLP` in raw format.
    var DI: UInt6 = 0
    
    /// Debug Mask Register
    ///
    /// Combined with `DLP` in raw format.
    var DM: UInt7 = 0
    
    /// Largest Ring Number Register
    ///
    /// Combined with `TOS[0]` in raw format.
    var LRN: UInt12 = 0
    
    /// Untranslatable Pointer Register
    var UTP: UInt48 = 0
    
    /// Trap Pointer Register
    var TP: UInt48 = 0
    
    /// Debug List Pointer Register
    var DLP: UInt48 = 0
    
    /// Top Of Stack Registers
    var TOS: [UInt48] = Array(repeating: 0, count: 15)
    
    
    // MARK: - Raw Value Packing/Unpacking
    
    var rawValues: [UInt64] {
        // TODO: Implement conversion to raw format.
        return Array<UInt64>(repeating: 0, count: 198)
    }
    
    init(rawValues: [UInt64]) {
        precondition(rawValues.count == 198)
        
        // TODO: Implement conversion from raw format.
    }
}


/// A Cyber 962 CP Stack Frame Save Area.
///
/// Tthe information here is derived from chapter 2 of the _Cyber 960 Virtual State Hardware Reference Manual Volume 2 Revision B_, part number 60000133B.
struct Cyber962StackFrameSaveArea {

    // FIXME: Support CFF/OCF/PND
    // See Figure 2-9 on page 2-44 (238).

    /// P register.
    var P: UInt64

    /// VMID register.
    ///
    /// Combined with `A[0x0]` in raw format.
    var VMID: UInt4

    /// Frame description.
    ///
    /// Combined with `A[0x1]` in raw format.
    var frameDescription: UInt16

    /// User Mask Register
    ///
    /// Combined with `A[0x2]` in raw format.
    var UM: UInt16

    /// User Condition Register
    ///
    /// Combined with `A[0x4]` in raw format.
    var UCR: UInt16

    /// Monitor Condition Register
    ///
    /// Combined with `A[0x5]` in raw format.
    var MCR: UInt16

    /// A registers.
    var A: [UInt48]

    /// X registers
    var X: [UInt64]

    // MARK: - Raw Value Packing/Unpacking

    /// Pack a Stack Frame Save Area descriptor.
    static func pack(Xs: UInt4, At: UInt4, Xt: UInt4) -> UInt12 {
        var descriptor: UInt12 = 0
        descriptor |= UInt12(Xs) << 8
        descriptor |= UInt12(At) << 4
        descriptor |= UInt12(Xt) << 0
        return descriptor
    }

    /// Unpack a Stack Frame Save Area descriptor.
    static func unpack(descriptor: UInt12) -> (Xs: UInt4, At: UInt4, Xt: UInt4) {
        let Xs: UInt4 = UInt4((descriptor & 0xF00) >> 8)
        let At: UInt4 = UInt4((descriptor & 0x0F0) >> 4)
        let Xt: UInt4 = UInt4((descriptor & 0x00F) >> 0)
        return (Xs: Xs, At: At, Xt: Xt)
    }

    /// Get a sequence of words to form a raw Stack Frame Save Area package.
    func rawValues(for descriptor: UInt12) -> [UInt64] {
        let (Xs, At, Xt) = Self.unpack(descriptor: descriptor)
        let countX: Int = Int(Xt - Xs + 1)
        let countA: Int = Int((At > 2) ? (At + 1) : 3)
        let count = 1 + countA + countX
        var values: [UInt64] = Array(repeating: 0, count: count)

        values[0] = self.P

        for a in 0...Int(At + 1) {
            values[1 + a] = self.A[a]

            switch a {
            case 1: values[1 + a] = values[1 + a] | UInt64(self.VMID) << 56
            case 2: values[1 + a] = values[1 + a] | UInt64(descriptor) << 48
            case 3: values[1 + a] = values[1 + a] | UInt64(self.UM) << 48
            case 5: values[1 + a] = values[1 + a] | UInt64(self.UCR) << 48
            case 6: values[1 + a] = values[1 + a] | UInt64(self.MCR) << 48
            default: break // do nothing
            }
        }

        for x in Int(Xs)...Int(Xt) {
            values[1 + countA + (x - Int(Xs))] = self.X[x]
        }

        return values
    }

    /// Initialize a Stack Frame Save Area from raw memory words.
    init(rawValues values: [UInt64]) {
        precondition(values.count >= 4)

        let descriptor: UInt12 = UInt12(values[2] >> 48)
        let (Xs, At, Xt) = Self.unpack(descriptor: descriptor)
        let countX: Int = Int(Xt - Xs + 1)
        let countA: Int = Int((At > 2) ? (At + 1) : 3)

        self.P = values[0]
        self.VMID = 0
        self.frameDescription = descriptor
        self.UM = 0
        self.UCR = 0
        self.MCR = 0
        self.A = Array(repeating: 0, count: countA)
        self.X = Array(repeating: 0, count: countX)

        for a in 0...Int(At) {
            self.A[a] = values[1 + a]

            switch a {
            case 1: self.VMID =  UInt4(values[1 + a] >> 56) & 0xF
            case 3: self.UM   = UInt16(values[1 + a] >> 48)
            case 5: self.UCR  = UInt16(values[1 + a] >> 48)
            case 6: self.MCR  = UInt16(values[1 + a] >> 48)
            default: break // do nothing
            }
        }

        for x in Int(Xs)...Int(Xt) {
            self.X[x] = values[1 + countA + (x - Int(Xs))]
        }
    }
}
