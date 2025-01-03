//
//  Cyber170CP+Parcels.swift
//  Cyber
//
//  Copyright © 2024-2025 Christopher M. Hanson
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


extension Cyber170CP {

    /// An instruction parcel.
    protocol Parcel {

        /// The number of bits taken by the parcel.
        var bits: Int { get }

        /// The opcode for the parcel.
        var opcode: Word6 { get }

        /// The primary initializer.
        init?(from word60: Word60, at index: Int)

        /// The decoded instruction to which the parcel corresponds.
        func decode() -> Instruction?
    }

    /// A 15-bit instruction parcel.
    struct Parcel15: Parcel {
        let bits = 15

        var opcode: Word6
        var i: Word3
        var j: Word3
        var k: Word3

        /// Create a 15-bit parcel from the given values.
        init(opcode: Word6, i: Word3, j: Word3, k: Word3) {
            self.opcode = opcode
            self.i = i
            self.j = j
            self.k = k
        }

        /// Create a 15-bit parcel from the given raw value.
        init(raw: UInt16) {
            precondition(raw <= 0x7FFF)

            let opcode = Word6((raw & 0b0111_1110_0000_0000) >> 9)
            let i      = Word3((raw & 0b0000_0001_1100_0000) >> 5)
            let j      = Word3((raw & 0b0000_0000_0011_1000) >> 3)
            let k      = Word3((raw & 0b0000_0000_0000_0111) >> 0)

            self.init(opcode: opcode, i: i, j: j, k: k)
        }

        /// Get the requested 15-bit parcel from a 60-bit word.
        ///
        /// The 15-bit parcels in a word are indexed as:
        /// - 0: Bits 59...45
        /// - 1: Bits 44...30
        /// - 2: Bits 29...15
        /// - 3: Bits 14...0
        init?(from word60: Word60, at index: Int) {
            precondition((index >= 0) && (index <= 3))

            let shifts: [Word60] = [45, 30, 15, 0]
            let value = UInt16((word60 >> shifts[index]) & 0x7FFF)

            self.init(raw: value)
        }

        /// Decode the instruction to which the parcel corresponds, if any.
        func decode() -> Instruction? {
            if let iai = IntegerArithmeticInstruction(from: self) { return iai }
            if let si = ShiftInstruction(from: self) { return si }
            if let li = LogicalInstruction(from: self) { return li }
            if let fpai = FPArithmeticInstruction(from: self) { return fpai }
            if let ti = TransmitInstruction(from: self) { return ti }
            return nil
        }
    }

    /// A 30-bit instruction parcel.
    struct Parcel30: Parcel {
        let bits = 30

        var opcode: Word6
        var i: Word3
        var j: Word3
        var K: Word18

        /// Create a 30-bit parcel from the given values.
        init(opcode: Word6, i: Word3, j: Word3, K: Word18) {
            self.opcode = opcode
            self.i = i
            self.j = j
            self.K = K
        }

        init(raw: UInt32) {
            precondition(raw <= 0x3FFF_FFFF)

            let opcode =  Word6((raw & 0b0011_1111_0000_0000_0000_0000_0000_0000) >> 24)
            let i      =  Word3((raw & 0b0000_0000_1110_0000_0000_0000_0000_0000) >> 21)
            let j      =  Word3((raw & 0b0000_0000_0001_1100_0000_0000_0000_0000) >> 18)
            let K      = Word18((raw & 0b0000_0000_0000_0011_1111_1111_1111_1111) >> 0)

            self.init(opcode: opcode, i: i, j: j, K: K)
        }

        /// Get the given 30-bit parcel from a 60-bit word.
        ///
        /// The 30-bit parcels in a word are mapped as:
        /// - 0: Bits 59...30
        /// - 1: Bits 44...15
        /// - 2: Bits 14...0
        init?(from word60: Word60, at index: Int) {
            precondition((index >= 0) && (index <= 2))

            let shifts: [Word60] = [30, 15, 0]
            let value = UInt32((word60 >> shifts[index]) & 0x3FFF_FFFF)

            self.init(raw: value)
        }

        /// Decode the instruction to which the parcel corresponds, if any.
        func decode() -> Instruction? {
            if let bi = BranchInstruction(from: self) { return bi }
            if let bci = BlockCopyInstruction(from: self) { return bci }
            if let ji = JumpInstruction(from: self) { return ji }
            return nil
        }
    }

    /// A 60-bit instruction parcel.
    struct Parcel60: Parcel {
        let bits = 60

        var opcode: Word6
        var i: Word3
        var j: Word3
        var K: Word18
        var other: UInt32 // actually 30 bits

        var rawValue: Word60 {
            var value: Word60 = 0
            value |= Word60(self.opcode << 54)
            value |= Word60(self.i      << 51)
            value |= Word60(self.j      << 48)
            value |= Word60(self.K      << 30)
            value |= Word60(self.other  << 0)
            return value
        }

        init(opcode: Word6, i: Word3, j: Word3, K: Word18, other: UInt32) {
            self.opcode = opcode
            self.i = i
            self.j = j
            self.K = K
            self.other = other
        }

        init(raw: UInt64) {
            precondition(raw <= 0x0FFF_FFFF_FFFF_FFFF)

            let opcode =  Word6((raw >> 54) & 0b111_111)
            let i      =  Word3((raw >> 51) & 0b111)
            let j      =  Word3((raw >> 48) & 0b111)
            let K      = Word18((raw >> 30) & 0x0003_FFFF)
            let other  = UInt32((raw >>  0) & 0x3FFF_FFFF)

            self.init(opcode: opcode, i: i, j: j, K: K, other: other)
        }

        init?(from word60: Word60, at index: Int) {
            precondition(index == 0)

            self.init(raw: word60)
        }

        /// Decode the instruction to which the parcel corresponds, if any.
        func decode() -> Instruction? {
            if let eji = ExchangeJumpInstruction(from: self) { return eji }
            if let cmi = CompareMoveInstruction(from: self) { return cmi }
            return nil
        }
    }
}
