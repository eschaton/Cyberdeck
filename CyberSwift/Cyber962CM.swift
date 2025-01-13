//
//  Cyber962CM.swift
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


/// A Cyber962CM emulates the Central Memory in the Cyber 962.
///
/// The Central Memory in the Cyber 962 has eight banks of 8KW to 32MW each, and is interacted with via multiple ports that allow simultaneous CP and PP access. The CM also has a bounds register that limits writes from any or all ports. Finally, there is also a maintenance chaannel interface that provides access to the maintenance registers via a PP for initialization, diagnostics, error reporting and correction, and for manipulating the bounds register.
class Cyber962CM {
    
    /// The capacity of the memory in words.
    var capacity: UInt32 {
        get { return UInt32(storage.capacity) }
    }

    /// The storage for the memory words.
    var storage: [UInt64] = Array(repeating: 0, count: 4 * 1024 * 1024)
    
    /// Bounds Register
    var BR: UInt64 = 0
    
    /// Corrected Error Log Register
    var CEL: UInt64 = 0
    
    /// Element Identification Register
    var EID: UInt32 = 0
    
    /// Environment Control Register
    var EC: UInt64 = 0
    
    /// Free-Running Counter Register
    var FRC: UInt48 = 0
    
    /// Options Installed Register
    var OI: UInt32 = 0
    
    /// Status Summary Register
    var SS: UInt6 = 0
    
    /// Uncorrected Error Log Registers
    var UEL: [UInt64] = [0, 0]

    /// Low-level read of a word from the memory.
    ///
    /// The actual access should happen via a port.
    func read(from address: UInt32) -> UInt64 {
        precondition(address < self.capacity)

        return self.storage[Int(address)]
    }

    /// Low-level write of a word to the memory.
    ///
    /// The actual access should happen via a port.
    func write(word: UInt64, to address: UInt32) {
        precondition(address < self.capacity)

        self.storage[Int(address)] = word
    }

    /// Resets the entire memory.
    func reset() {
        self.storage = Array(repeating: 0, count: Int(self.capacity))
    }
    
    // MARK: - Initialization

    /// Designated Initializer
    init(capacity: UInt32 = 4 * 1024 * 1024) {
        self.storage = Array(repeating: 0, count: Int(capacity))
    }
}
