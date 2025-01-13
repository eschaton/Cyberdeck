//
//  Cyber962IOU.swift
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


/// A Cyber962IOU emulates a Cyber 962 I/O Unit.
class Cyber962IOU {


    // MARK: - System Interconnection

    /// The system to which this IOU belongs
    let system: Cyber962
    
    /// The index of this Peripheral Procesor within the IOU.
    let index: Int

    /// The Peripheral Processors (PPs) that are part of this I/O Unit.
    var peripheralProcessors: [Cyber962PP] = []
    
    /// The I/O Channels that are part of this I/O Unit.
    var channels: [Cyber962IOChannel] = []

    /// The number of time-multiplexed "barrels" in this I/O Unit.
    ///
    /// Each "barrel" has 5 I/O channels and 5 associated PPs.
    var barrels: Int {
        return self.peripheralProcessors.count / 5
    }


    // MARK: - Maintenance Registers

    struct MaintenanceRegisterAddress {
        static let EID = 0x10
        static let EC = 0x30
        static let FS1 = 0x80
        static let FS2 = 0x81
        static let FSM = 0x18
        static let OI = 0x12
        static let OSB = 0x21
        static let SS = 0x00
        static let TM = 0xA0
    }

    /// Element Identifier Register
    var regEID: UInt32 = 0

    /// Environment Control Register
    var regEC: UInt32 = 0

    /// Fault Status Register 1
    var regFS1: UInt64 = 0

    /// Fault Status Register 2
    var regFS2: UInt64 = 0

    /// Fault Status Mask Register
    var regFSM: UInt64 = 0

    /// Options Installed Register
    var regOI: UInt64 = 0

    /// OS Bounds Register
    var regOSB: UInt64 = 0

    /// Status Summary Register
    var regSS: UInt6 = 0

    /// Test Mode Register
    var regTM: UInt16 = 0


    // MARK: - Initialization
    
    /// Designated initializer.
    ///
    /// Configures the default type of IOU included with a Cyber 962-11 system when no arguments are overridden, that is one with 10 PPs and 10 channels.
    init(system: Cyber962, index: Int, peripheralProcessors: Int = 10, channels: Int = 10) {
        precondition((5...20).contains(peripheralProcessors))
        precondition((peripheralProcessors % 5) == 0)
        precondition((5...20).contains(channels))
        precondition((channels % 5) == 0)
        precondition(peripheralProcessors == channels)

        self.system = system
        self.index = index
        
        for pp in 0..<peripheralProcessors {
            let peripheralProcessor = Cyber962PP(inputOutputUnit: self, index: pp)
            self.peripheralProcessors.append(peripheralProcessor)
        }
         
        for ch in 0..<channels {
            let channel = Cyber962IOChannel(inputOutputUnit: self, index: ch)
            self.channels.append(channel)
        }
    }
}
