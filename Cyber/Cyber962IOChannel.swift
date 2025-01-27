//
//  Cyber962Channel.swift
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


/// An I/O Channel on the Cyber 962.
open class Cyber962IOChannel {


    /// Cross-barrel IOU channel 0.
    static let crossBarrelIOU0 = 0o00

    /// Cross-barrel IOU channel 1.
    static let crossBarrelIOU1 = 0o01

    /// Cross-barrel IOU channel 2.
    static let crossBarrelIOU2 = 0o12

    /// Cross-barrel IOU channel 3.
    static let crossBarrelIOU3 = 0o13

    /// Real-time clock.
    static let realTimeClock = 0o14

    /// Two-port multiplexer.
    static let twoPortMulitplexer = 0o15

    /// Maintenance Channel
    static let maintenance = 0o17

    /// Deadstart Load (DLD) SCSI channel 0.
    static let scsi0 = 0o32

    /// Deadstart Load (DLD) SCSI channel 1.
    static let scsi1 = 0o33

    

    // MARK: - System Interconnection
    
    /// The IOU this channel is a part of.
    let inputOutputUnit: Cyber962IOU
    
    /// The index of this channel within its IOU.
    let index: Int

    /// The system this Central Processor is a part of.
    var system: Cyber962 {
        return self.inputOutputUnit.system
    }
    

    // MARK: - Initialization
    
    /// Designated Initializer
    init(inputOutputUnit: Cyber962IOU, index: Int, width: Width = .channel16) {
        self.inputOutputUnit = inputOutputUnit
        self.index = index
        self.width = width
    }


    // MARK: - I/O State

    /// The i/O channel widths supported by the Cyber 962.
    enum Width: Int {
        /// The channel is a 12-bit channel.
        case channel12 = 12

        /// The channel is a 16-bit channel.
        case channel16 = 16

        /// The mask to use against a ``UInt16`` to create a value appropriate for a channel of this type.
        var mask: UInt16 {
            switch self {
            case .channel12: return 0x0FFF
            case .channel16: return 0xFFFF
            }
        }
    }

    /// The width of the channel, defaults to 12-bit.
    let width: Width

    /// Whether the channel is full, starts non-full.
    var full: Bool = false

    /// The channel flag, starts false.
    var flag: Bool = false

    /// The channel error flag, starts false.
    var error: Bool = false

    /// Whether the channel is active or inactive, starts active.
    var active: Bool = true


    // MARK: - I/O Behavior

    // FIXME: Make channels asynchronous
    // Ideally the API used by the Peripheral Processor will handle the asynchronous
    // state management, while the API available for subclasses to override will be
    // synchronous and just concerned with write/read/function.

    /// Indicate whether the given PP is allowed access to this channel.
    ///
    /// Some channels may only be accessed from certain barrels.
    func accessAllowed(from processor: Cyber962PP) -> Bool {
        let sharedChannelIndexes: Set<Int> = [ Self.crossBarrelIOU0,
                                               Self.crossBarrelIOU1,
                                               Self.crossBarrelIOU2,
                                               Self.crossBarrelIOU3,
                                               Self.twoPortMulitplexer,
                                               Self.maintenance,
                                               Self.scsi0,
                                               Self.scsi1 ]
        
        let perBarrelRanges: [Int: ClosedRange<Int>] = [ 0: 0o02...0o04,
                                                         1: 0o05...0o11,
                                                         2: 0o20...0o24,
                                                         3: 0o25...0o31 ]

        let index = self.index

        return sharedChannelIndexes.contains(index) || perBarrelRanges[processor.barrel]!.contains(index)
    }

    /// Receive input from the channel.
    ///
    /// Transfer one or more words from the I/O channel to the PP or CM.
    ///
    /// - Parameters:
    ///   - count: The number of words to input, only using 18 bits.
    ///   - skipIfNotActiveAndFull: If `true`, if the channel is or becomes inactive before becoming full, causes the call to return `0`.
    ///                             If false, waits for the channel to become both active and full before returning.
    ///
    /// - Returns: An array of words whose width matches this channel's ``width``.
    func input(count: UInt32, skipIfNotActiveAndFull: Bool = false) -> [UInt16] {
        // TODO: Implement asynchrony.
        self.read(count: count)
    }

    /// Send output from the PP or CM to the channel.
    ///
    /// Transfer one or more words from the PP or CM to the  I/O channel.
    ///
    /// - Parameters:
    ///   - words: The words to transfer.
    func output(words: [UInt16], skipIfNotActive: Bool = false) {
        // TODO: Implement asynchrony.
        self.write(values: words)
    }

    /// Activate the channel either once it's inactive or unconditionally.
    func activate(onceInactive: Bool = false) {
        // TODO: Implement asynchrony.
        self.active = true
    }

    /// Deactivate the channel once it's active or unconditionally.
    func deactivate(onceActive: Bool = false) {
        // TODO: Implement asynchrony.
        self.active = false
    }

    /// "Master Clear" the channel, fully resetting its state.
    func masterClear() {
        self.error = false
        self.flag = false
        self.full = false
        self.active = true
    }

    /// Send the given function to the channel, either waiting until it's inactive or skipping the send.
    func function(_ value: UInt16, skipIfActive: Bool = false) {
        // TODO: Implement asynchrony.
        function(value: value)
    }


    // MARK: - Subclassing Interface

    open func read(count: UInt32) -> [UInt16] {
        fatalError("Subclass must override read(count:)")
    }

    open func write(values: [UInt16]) {
        fatalError("Subclass must override write(values:)")
    }

    open func function(value: UInt16) {
        fatalError("Subclass must override function(value:)")
    }
}
