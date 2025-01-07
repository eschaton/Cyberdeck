//
//  Cyber180Channel.swift
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


/// The protocol to which all I/O channels conform.
protocol Cyber180IOChannel {

    /// The width of the channel.
    var width: Cyber180IOChannelWidth { get }

    /// Whether the channel is active or inactive.
    var active: Bool { get set }

    /// Whether the channel is full.
    var full: Bool { get set }

    /// The channel flag.
    var flag: Bool { get set }

    /// The channel error flag.
    var error: Bool { get set }

    /// Receive input from the channe.
    ///
    /// Transfer one or more words from the I/O channel to the PP or CM.
    ///
    /// - Parameters:
    ///   - count: The number of words to input, only using 18 bits.
    ///
    /// - Returns: An array of words whose width matches this channel's ``width``.
    ///
    func input(count: UInt32) -> [UInt16]

    /// Send output from the PP or CM to the channel.
    ///
    /// Transfer one or more words from the PP or CM to the  I/O channel.
    ///
    /// - Parameters:
    ///   - words: The words to transfer.
    func output(words: [UInt16])

    /// Send the given function to the channel.
    func function(_ value: UInt16)
}


/// The i/O channel widths supported by the Cyber 180.
enum Cyber180IOChannelWidth: Int {
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
