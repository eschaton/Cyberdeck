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
    var system: Cyber962
    
    /// The index of this Peripheral Procesor within the IOU.
    var index: Int
    
    
    // MARK: - Facilities
    
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
