//
//  CyberMemory.swift
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


/// A CyberMemory emulates RAM in the Cyber 960.
///
/// RAM in the Cyber 960 is ultimately word-addressed and 72 bits wide, with 64 bits of data and 8 bits of ECC.
///
/// In Cyber 170 mode, the top 4 bits are unused, while in Cyber 180 mode the top 4 bits are used. And in both modes, the 8 bits of ECC are maintained by the system.
class CyberMemory {

    /// An address in the Cyber 960 is actually 25-bit word-addressed.
    struct Address {
        /// A mask of the low 25 bits.
        static let mask: UInt32 = 0x01FF_FFFF

        /// Internal storage for the value of an address.
        internal var _value: UInt32

        /// The raw value of an address is 25 bits.
        var value: UInt32 {
            get { return (_value & Self.mask) }
            set { _value = (newValue & Self.mask) }
        }

        init(value: UInt32) {
            self._value = (value & Self.mask)
        }

        static func <(a: Address, b: Address) -> Bool {
            return a._value < b._value
        }

        static func &(a: Address, b: Address) -> Address {
            return Address(value: a._value & b._value)
        }

        var intValue: Int {
            get { return Int(_value & Self.mask) }
            set { _value = (UInt32(newValue) & Self.mask) }
        }
    }

    /// A memory word is itself 72 bits: 64 bits of storage, 8 bits of ECC.
    struct Word {
        /// Internal storage for the value of a word.
        internal var _value: UInt64

        /// Internal storage for the error correction of a word.
        internal var _errorCorrection: UInt8

        /// The value of a memory word is either 60 or 64 bits.
        var value: UInt64 {
            // TODO: Consider updating errorCorrection
            get { return _value }
            set { _value = newValue }
        }

        /// Each memory word has 8 bits of ECC.
        var errorCorrection: UInt8 {
            get { return _errorCorrection }
            set { _errorCorrection = newValue }
        }

        /// Designated initializer.
        init(value: UInt64, errorCorrection: UInt8) {
            self._value = value
            self._errorCorrection = errorCorrection
        }

        /// Convenience initializer.
        init(value: UInt64) {
            self._value = value
            self._errorCorrection = 0
            // FIXME: Set proepr ECC.
        }
    }

    /// The default capacity of the memory in words (1MW = 8MB plus ECC))
    static let defaultCapacity: Address = Address(value: 1 * 1024 * 1024)

    /// The capacity of the memory in words.
    var capacity: Address {
        get { return Address(value: UInt32(storage.capacity)) }
    }

    /// The storage of the memory words.
    var storage: [Word] = []

    /// Reads a word from the memory.
    func read(from address: Address) -> Word {
        precondition(address < self.capacity)

        return self.storage[address.intValue]
    }

    /// Writes a word to the memory.
    func write(word: Word, to address: Address) {
        precondition(address < self.capacity)

        self.storage[address.intValue] = word
    }

    /// Resets the entire memory.
    func reset() {
        self.storage = Array(repeating: 0, count: self.capacity.intValue)
    }

    init(with capacity: Address = defaultCapacity) {
        self.storage = Array(repeating: 0, count: capacity.intValue)
    }
}


extension CyberMemory.Address: ExpressibleByIntegerLiteral {
    typealias IntegerLiteralType = UInt32

    init(integerLiteral value: UInt32) {
        self.init(value: value)
    }
}


extension CyberMemory.Word: ExpressibleByIntegerLiteral {
    typealias IntegerLiteralType = UInt64

    init(integerLiteral value: UInt64) {
        self.init(value: value)
    }
}
