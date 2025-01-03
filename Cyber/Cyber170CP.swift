//
//  Cyber170CP.swift
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


/// A Cyber170CP emulate a Cyber 170 CP.
///
/// Each Cyber 960 CP (Central Processor) supports both a Cyber 170 "state" and a Cyber 180 "virtual state" for compatibility with both the older 60-bit product line and the more modern 64-bit product line, and the CP can switch between them using an "exchange jump."
class Cyber170CP {

    // MARK: - Baseline Types

    /// A 3-bit word.
    typealias Word3 = UInt8

    /// Whether a Word3 is valid (does not use more than the rightmost 3 bits).
    internal func isValid(word3: Word3) -> Bool {
        return word3 <= 0x07
    }

    /// A 6-bit word.
    typealias Word6 = UInt8

    /// Whether a Word6 is valid (does not use more than the rightmost 6 bits).
    internal func isValid(word6: Word6) -> Bool {
        return word6 <= 0x3F
    }

    /// An 18-bit word.
    typealias Word18 = UInt32

    /// Whether a Word18 is valid (does not use more than the rightmost 18 bits).
    internal func isValid(word18: Word18) -> Bool {
        return word18 <= 0x0003_FFFF
    }

    /// A 21-bit word.
    typealias Word21 = UInt32

    /// Whether a Word21 is valid (does not use more than the rightmost 21 bits).
    internal func isValid(word21: Word21) -> Bool {
        return word21 <= 0x001F_FFFF
    }

    /// A 60-bit word.
    typealias Word60 = UInt64

    /// Whether a Word60 is valid (does not use more than the rightmost 60 bits).
    internal func isValid(word60: Word60) -> Bool {
        return word60 <= 0x0FFF_FFFF_FFFF_FFFF
    }


    // MARK: - Registers

    /// Registers X0...X7 are actually 60-bit.
    internal var regX: [Word60] = Array(repeating: 0, count: 8)

    func get(X reg: Word3) -> Word60 {
        precondition((0..<8).contains(reg))

        return self.regX[Int(reg)]
    }

    func set(X reg: Word3, to value: Word60) {
        precondition((0..<8).contains(reg))
        precondition(isValid(word60: value))

        self.regX[Int(reg)] = value
    }

    /// Registers A0...A7 are actually 18-bit.
    internal var regA: [Word18] = Array(repeating: 0, count: 8)

    func get(A reg: Word3) -> Word18 {
        precondition((0..<8).contains(reg))

        return self.regA[Int(reg)]
    }

    func set(A reg: Word3, to value: Word18) {
        precondition((0..<8).contains(reg))
        precondition(isValid(word18: value))

        self.regA[Int(reg)] = value
    }

    /// Registers B0...B7 are actually 18-bit.
    internal var regB: [Word18] = Array(repeating: 0, count: 8)

    func get(B reg: Word3) -> Word18 {
        precondition((0..<8).contains(reg))

        return self.regB[Int(reg)]
    }

    func set(B reg: Word3, to value: Word18) {
        precondition((1..<8).contains(reg))
        precondition(isValid(word18: value))

        self.regB[Int(reg)] = value
    }

    /// The P register is the 18-bit program counter.
    internal var regP: Word18 = 0

    func getP() -> Word18 {
        return self.regP
    }

    func setP(to value: Word18) {
        precondition(isValid(word18: value))

        self.regP = value
    }

    /// The RAC register is the reference address for the user's central memory space is a 21-bit address value.
    internal var regRAC: Word21 = 0

    func getRAC() -> Word21 {
        return self.regRAC
    }

    func setRAC(to value: Word21) {
        precondition(isValid(word21: value))

        self.regRAC = value
    }

    /// The FLC register is the field length for the user's central memory space and is a 21-bit address value.
    internal var regFLC: Word21 = 0

    func getFLC() -> Word21 {
        return self.regFLC
    }

    func setFLC(to value: Word21) {
        precondition(isValid(word21: value))

        self.regFLC = value
    }

    /// The EM register describes exit modes (error conditions) and is a 6-bit value.
    internal var regEM: Word6 = 0

    func getEM() -> Word6 {
        return self.regEM
    }

    func setEM(to value: Word6) {
        precondition(isValid(word6: value))
    }

    var hardwareErrorExit: UInt8 {
        get {
            return (self.regEM  & 0b0011_1000) >> 3
        }

        set {
            precondition((newValue >= 0) && (newValue <= 3))

            self.regEM = (self.regEM & 0b0011_1000) | (newValue << 3)
        }
    }

    var indefiniteOperandExit: Bool {
        get {
            return (self.regEM & 0b0000_0100) != 0
        }
        set {
            if newValue {
                self.regEM |= 0b0000_0100
            } else {
                self.regEM &= 0b0011_1011
            }
        }
    }

    var infiniteOperandExit: Bool {
        get {
            return (self.regEM & 0b0000_0010) != 0
        }
        set {
            if newValue {
                self.regEM |= 0b0000_0010
            } else {
                self.regEM &= 0b0011_1101
            }
        }
    }

    var addressOutOfRangeExit: Bool {
        get {
            return (self.regEM & 0b0000_0001) != 0
        }
        set {
            if newValue {
                self.regEM |= 0b0000_0001
            } else {
                self.regEM &= 0b0011_1110
            }
        }
    }

    /// The Flags register contains control flags and is 6 bits.
    internal var regFlags: Word6 = 0

    func getFlags() -> Word6 {
        return self.regFlags
    }

    func setFlags(to value: Word6) {
        precondition(isValid(word6: value))

        self.regFlags = value
    }

    var uemEnableFlag: Bool {
        get {
            return (self.regFlags & 0b0010_0000) != 0
        }
        set {
            if newValue {
                self.regFlags |= 0b0010_0000
            } else {
                self.regFlags &= 0b0001_1111
            }
        }
    }

    var expandedAddressingFlag: Bool {
        get {
            return (self.regFlags & 0b0001_0000) != 0
        }
        set {
            if newValue {
                self.regFlags |= 0b0001_0000
            } else {
                self.regFlags &= 0b0010_1111
            }
        }
    }

    var blockCopyFlag: Bool {
        get {
            return (self.regFlags & 0b0000_1000) != 0
        }
        set {
            if newValue {
                self.regFlags |= 0b0000_1000
            } else {
                self.regFlags &= 0b0011_0111
            }
        }
    }

    var compareMoveInterruptedFlag: Bool {
        get {
            return (self.regFlags & 0b0000_0100) != 0
        }
        set {
            if newValue {
                self.regFlags |= 0b0000_0100
            } else {
                self.regFlags &= 0b0011_1011
            }
        }
    }

    var lookaheadPurgeFlag: Bool {
        get {
            return (self.regFlags & 0b0000_0010) != 0
        }
        set {
            if newValue {
                self.regFlags |= 0b0000_0010
            } else {
                self.regFlags &= 0b0011_1101
            }
        }
    }

    var hardwareErrorFlag: Bool {
        get {
            return (self.regFlags & 0b0000_0001) != 0
        }
        set {
            if newValue {
                self.regFlags |= 0b0000_0001
            } else {
                self.regFlags &= 0b0011_1110
            }
        }
    }

    /// The RAE register is the address for the user's extended memory space and is 21 bits.
    internal var regRAE: Word21 = 0

    func getRAE() -> Word21 {
        return self.regRAE
    }

    func setRAE(to value: Word21) {
        precondition(isValid(word21: value))

        self.regRAE = value
    }

    /// The FLE register is the field length for the user's extended memory space and is 21 bits.
    internal var regFLE: Word21 = 0

    func getFLE() -> Word21 {
        return self.regFLE
    }

    func setFLE(to value: Word21) {
        precondition(isValid(word21: value))

        self.regFLE = value
    }

    /// The MA register holds the 18-bit monitor address.
    internal var regMA: Word18 = 0

    func getMA() -> Word21 {
        return self.regMA
    }

    func setMA(to value: Word21) {
        precondition(isValid(word21: value))

        self.regMA = value
    }


    // MARK: - Behaviors

    func reset() {
        self.regX = Array(repeating: 0, count: 8)
        self.regA = Array(repeating: 0, count: 8)
        self.regB = Array(repeating: 0, count: 8)
        self.regP = 0
        self.regRAC = 0
        self.regFLC = 0
        self.regEM = 0
        self.regFlags = 0
        self.regRAE = 0
        self.regFLE = 0
        self.regMA = 0
    }


    // MARK: - Instruction Decoding

    /// Decode an instruction from the next instruction parcel in the word, according to the number of bits remaining.
    ///
    /// An instruction is divided into parcels which may be 15, 30, or 60 bits.
    /// We need to accommodate all possible layouts in decoding instructions:
    /// - (15,15,15,15)
    /// - (15,30,15)
    /// - (15,15,30)
    /// - (30,15,15)
    /// - (30,30)
    /// - (60)
    internal func decodeNextParcel(from word60: Word60, bitsLeft: Int) -> Instruction? {
        let bitsToAt15: [Int: Int] = [60: 0, 45: 1, 30: 2, 15: 3]
        let bitsToAt30: [Int: Int] = [60: 0, 45: 1, 30: 2]
        let bitsToAt60: [Int: Int] = [60: 0]

        if let at15 = bitsToAt15[bitsLeft],
           let parcel15 = Parcel15(from: word60, at: at15),
           let instruction15 = parcel15.decode()
        {
            return instruction15
        }

        if let at30 = bitsToAt30[bitsLeft],
           let parcel30 = Parcel30(from: word60, at: at30),
           let instruction30 = parcel30.decode()
        {
            return instruction30
        }

        if let at60 = bitsToAt60[bitsLeft],
           let parcel60 = Parcel60(from: word60, at: at60),
           let instruction60 = parcel60.decode()
        {
            return instruction60
        }

        return nil
    }

    /// Decode one or more instructions from the given word.
    ///
    /// Decodes one to four instructions from the parcels in the given word, or returns `nil` if no instructions can be decoded.
    func decode(word60: Word60) -> [Instruction]? {

        var instructions: [Instruction] = []
        var bitsLeft: Int = 60

        while bitsLeft > 0 {
            if let instruction = decodeNextParcel(from: word60, bitsLeft: bitsLeft) {
                instructions.append(instruction)
                bitsLeft -= instruction.parcel.bits
            } else {
                bitsLeft = 0
                fatalError("Could not decode the next parcel.")
            }
        }

        return (instructions.count > 0) ? instructions : nil
    }
}
