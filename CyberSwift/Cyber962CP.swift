//
//  Cyber962CP.swift
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


/// A Cyber962CP implements the Cyber 962 Central Processor.
///
/// The Cyber 962 Central Processor is a 64-bit processor with:
///
/// - Byte rather than word addressing
/// - Two's complement rather than one's complement representation
/// - 16 X registers of 64 bits each
/// - 16 A registers of 48 bits each
/// - A "4096 times 2^31" byte user address space
///
/// The Cyber 962 also uses IBM-style bit numbering; that is, bit 0 is the "leftmost" (most significant) bit in a word.
class Cyber962CP {

    // MARK: - System Interconnection

    /// The system this Central Processor is a part of.
    let system: Cyber962
    
    /// The index of the CP in the system.
    let index: Int

    // MARK: - General Registers

    /// Program Address register
    ///
    /// The program counter.
    var regP: UInt64 {
        get { return self._regP }
        set { self._regP = newValue }
    }
    internal var _regP: UInt64 = 0

    /// Address registers.
    internal var _regAi: [UInt64] = Array(repeating: 0, count: 16)

    /// Get an address register value.
    func get(regA i: Int) -> UInt64 {
        precondition((i >= 0) && (i <= 0xF))
        return self._regAi[i]
    }

    /// Set an address register value.
    func set(regA i: Int, to value: UInt64) {
        precondition((i >= 0) && (i <= 0xF))
        precondition((value & 0xFFFF_0000_0000_0000) == 0)
        self._regAi[i] = value
    }

    /// Data registers.
    internal var _regXi: [UInt64] = Array(repeating: 0, count: 16)

    /// Get a data register value.
    func get(regX i: Int) -> UInt64 {
        precondition((i >= 0) && (i <= 0xF))
        return self._regXi[i]
    }

    /// Set a data register value.
    func set(regX i: Int, to value: UInt64) {
        precondition((i >= 0) && (i <= 0xF))
        self._regXi[i] = value
    }

    // MARK: - Other Registers

    /// Monitor Process State register
    ///
    /// Contains the physical address of the monitor process state exchange packgae.
    ///
    /// - Note: Bits 0 and 28...31 are irrelevant.
    var regMPS: UInt32 {
        get { return self._regMPS & 0x7FFF_FFF0 }
        set { self._regMPS = newValue }
    }
    internal var _regMPS: UInt32 = 0

    /// Job Process State register
    ///
    /// Contains the physical address of the job process state exchange packgae.
    ///
    /// - Note: Bits 0 and 28...31 are irrelevant.
    var regJPS: UInt32 {
        get { return self._regJPS  & 0x7FFF_FFF0 }
        set { self._regJPS = newValue }
    }
    internal var _regJPS: UInt32 = 0

    /// Page Table Address register
    ///
    /// Contains the address of the page table.
    var regPTA: UInt32 {
        get { return self._regPTA }
        set { self._regPTA = newValue }
    }
    internal var _regPTA: UInt32 = 0

    /// Page Table Length register
    ///
    /// Contains the length of the page table.
    var regPTL: UInt32 {
        get { return self._regPTL }
        set { self._regPTL = newValue }
    }
    internal var _regPTL: UInt32 = 0

    /// Page Size Mask register
    var regPSM: UInt32 {
        get { return self._regPSM }
        set { self._regPSM = newValue }
    }
    internal var _regPSM: UInt32 = 0

    /// Element ID register
    var regEID: UInt32 {
        get { return self._regEID }
        set { self._regEID = newValue }
    }
    internal var _regEID: UInt32 = 0

    /// Processor ID register
    var regPID: UInt32 {
        get { return self._regPID }
        set { self._regPID = newValue }
    }
    internal var _regPID: UInt32 = 0

    /// Options Installed register
    var regOI: UInt64 {
        get { return self._regOI }
        set { self._regOI = newValue }
    }
    internal var _regOI: UInt64 = 0

    /// System Interval Timer register
    ///
    /// A microsecond countdown timer.
    var regSIT: UInt32 {
        get { return self._regSIT }
    }
    internal var _regSIT: UInt32 = 0

    /// Virtual Machine Capability List register
    var regVMCL: UInt16 {
        get { return self._regVMCL }
        set { self._regVMCL = newValue }
    }
    internal var _regVMCL: UInt16 = 0

    
    // MARK: - Initialization

    /// Designated Intiailizer
    init(system: Cyber962, index: Int) {
        self.system = system
        self.index = index
    }

    // MARK: - Memory

    /// Raw memory, 8MW of 64-bit words (64MB).
    var _memory: [UInt64] = Array(repeating: 0, count: (8 * 1024 * 1024))

    internal func isValid(physicalAddress: UInt64) -> Bool {
        return (physicalAddress & 0xFFFF_0000_0000_0000) == 0
    }

    func read<T: FixedWidthInteger>(physicalAddress: UInt64) -> T {
        precondition(self.isValid(physicalAddress: physicalAddress))

        let wordAddress = physicalAddress >> 3
        let existingWord = _memory[Int(wordAddress)]

        switch (T.bitWidth) {
        case 64:
            return T(existingWord)

        case 32:
            let index = 0x1 - (physicalAddress & 0x1)
            let shift = index * 32
            let value = existingWord >> shift
            return T(value)

        case 16:
            let index = 0x3 - (physicalAddress & 0x3)
            let shift = index * 16
            let value = existingWord >> shift
            return T(value)

        case 8:
            let index = 0x7 - (physicalAddress & 0x7)
            let shift = index * 8
            let value = existingWord >> shift
            return T(value)

        default:
            fatalError("Only 8/16/32/64-bit reads are supported.")
        }
    }

    func write<T: FixedWidthInteger>(value: T, physicalAddress: UInt64) {
        precondition(self.isValid(physicalAddress: physicalAddress))

        let wordAddress = physicalAddress >> 3
        let existingWord = _memory[Int(wordAddress)]

        switch (T.bitWidth) {
        case 64:
            _memory[Int(wordAddress)] = UInt64(value)

        case 32:
            let index = 0x1 - (physicalAddress & 0x1)
            let shift = index * 32
            let mask: UInt64 = ~(UInt64(UInt32.max) << shift)
            let updateValue: UInt64 = UInt64(value) << shift
            let newValue: UInt64 = (existingWord & mask) | (updateValue << shift)
            _memory[Int(wordAddress)] = newValue

        case 16:
            let index = 0x3 - (physicalAddress & 0x3)
            let shift = index * 16
            let mask: UInt64 = ~(UInt64(UInt16.max) << shift)
            let updateValue: UInt64 = UInt64(value) << shift
            let newValue: UInt64 = (existingWord & mask) | (updateValue << shift)
            _memory[Int(wordAddress)] = newValue

        case 8:
            let index = 0x7 - (physicalAddress & 0x7)
            let shift = index * 8
            let mask: UInt64 = ~(UInt64(UInt8.max) << shift)
            let updateValue: UInt64 = UInt64(value) << shift
            let newValue: UInt64 = (existingWord & mask) | (updateValue << shift)
            _memory[Int(wordAddress)] = newValue

        default:
            fatalError("Only 8/16/32/64-bit writes are supported.")
        }
    }

    func read<T: FixedWidthInteger>(virtualAddress: UInt64) -> T {
        // TODO: Implement read from VA
        return self.read(physicalAddress: virtualAddress)
    }

    func write<T: FixedWidthInteger>(value: T, virtualAddress: UInt64) {
        // TODO: Implement write to VA
        self.write(value: value, physicalAddress: virtualAddress)
    }
}
