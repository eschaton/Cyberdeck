//
//  Cyber170PP.swift
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


/// A Cyber170PP represents a Cyber 170 Peripheral Processor.
class Cyber170PP {

    /// The R register is used in conjunction with the A register to form a CM address.
    ///
    /// - Note: The R register actually 28 bits, with the lower 6 bits always set to 0.
    var regR: UInt32 {
        get { return self._regR }
        set { self._regR = newValue & 0x0FFF_FFC0 }
    }
    var _regR: UInt32 = 0x000_0000

    /// The A register is used in conjunction with the R register to form a CM address.
    ///
    /// - Note: The A register is actually 18 bits.
    var regA: UInt32 {
        get { return self._regA }
        set { self._regA = newValue & 0o777777 }
    }
    var _regA: UInt32 = 0o010000

    /// The P register is a PP's program counter,
    ///
    /// - Note: The P register is actually 12 bits wide.
    var regP: UInt16 {
        get { return self._regP }
        set { self._regP = newValue & 0x0FFF }
    }
    var _regP: UInt16 = 0

    /// The Q register.
    ///
    /// - Note: The Q register is actually 12 bits wide.
    var regQ: UInt16 {
        get { return self._regQ }
        set { self._regQ = newValue & 0x0FFF }
    }
    var _regQ: UInt16 = 0

    /// The K register.
    ///
    /// - Note: The K register is actually 12 bits wide.
    var regK: UInt16 {
        get { return self._regK }
        set { self._regK = newValue & 0x0FFF }
    }
    var _regK: UInt16 = 0

    /// When needed, a CM address formed by either the A register alone, or the A register plus the R register.
    var centralMemoryAddress: UInt32 {
        let incorporateR: Bool = self.regA & 0o400000 != 0
        return self.regA + (incorporateR ? self.regR : 0)
    }

    /// The rank with which this PP was created.
    ///
    /// - Note: The rank is actually 6 bits max.
    var rank: UInt8 {
        get { return self._rank }
        set { self._rank = newValue & 0x003F }
    }
    var _rank: UInt8

    /// The barrel with which this PP is associated.
    ///
    /// - Note: The barrel is derived from the rank, and is in the range `0...3`.
    var barrel: UInt8 {
        get {
            let rank = self.rank
            switch rank {
            case 0o00...0o04: return 0
            case 0o05...0o11: return 1
            case 0o20...0o24: return 2
            case 0o25...0o31: return 3
            default: fatalError("Unexpected rank \(rank)")
            }
        }
    }

    /// The structure of a PP word: 16 bits plus parity.
    struct Word: ExpressibleByIntegerLiteral {
        typealias IntegerLiteralType = UInt16

        var value: UInt16
        var parity: Bool

        static func parity(_ value: UInt16) -> Bool {
            // FIXME: Compute parity.
            return false
        }

        init(_ value: UInt16) {
            self.value = value
            self.parity = Self.parity(value)
        }

        init(integerLiteral value: UInt16) {
            self.init(value)
        }
    }

    /// Each PP has 4KW of memory.
    var memory: [Word] = Array(repeating: 0, count: 4096)

    func reset() {
        self.regR = 0x000_0000
        self.regA = 0o010000
        self.regP = 0
        self.regQ = UInt16(self.rank)
        self.regK = 0xFFF
        self.memory = Array(repeating: 0, count: 4096)
    }

    init(rank: UInt8) {
        self._rank = rank
    }

    func decode(words: [Word]) -> Instruction? {
        if let lsi1 = LoadStoreInstruction1.decode(words: words) { return lsi1 }
        if let ai1 = ArithmeticInstruction1.decode(words: words) { return ai1 }
        if let li1 = LogicalInstruction1.decode(words: words) { return li1 }
        if let ri1 = ReplaceInstruction1.decode(words: words) { return ri1 }
        if let bi1 = BranchInstruction1.decode(words: words) { return bi1 }
        if let cmai1 = CentralMemoryAccessInstruction1.decode(words: words) { return cmai1 }
        if let ioi1 = InputOutputInstruction1.decode(words: words) { return ioi1 }
        if let oi = OtherInstruction.decode(words: words) { return oi }

        if let lsi2 = LoadStoreInstruction2.decode(words: words) { return lsi2 }
        if let ai2 = ArithmeticInstruction2.decode(words: words) { return ai2 }
        if let li2 = LogicalInstruction2.decode(words: words) { return li2 }
        if let ri2 = ReplaceInstruction2.decode(words: words) { return ri2 }
        if let bi2 = BranchInstruction2.decode(words: words) { return bi2 }
        if let cmai2 = CentralMemoryAccessInstruction2.decode(words: words) { return cmai2 }
        if let ioi2 = InputOutputInstruction2.decode(words: words) { return ioi2 }

        return nil
    }
}

/// Sign-extend a six-bit word in to an 8-bit signed integer.
func signExtend6(_ word6: UInt8) -> Int8 {
    let word6ext: UInt8
    if (word6 & 0b0010_0000) != 0 {
        word6ext = word6 | 0b1110_0000
    } else {
        word6ext = word6
    }
    return Int8(bitPattern: word6ext)
}
