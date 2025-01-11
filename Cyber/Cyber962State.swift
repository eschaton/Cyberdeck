//
//  Cyber962Exchange.swift
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


/// The Virtual State Exchange Package for the Cyber 962.
///
/// There are 192 full words in a Virtual State Exchange Packagae as used by the Cyber 180-style processor in the Cyber 962.
struct Cyber962VirtualStateExchangePackage {
    
    // MARK: - Registers
    
    /// Program Address Register
    var P: UInt64 = 0
    
    /// Virtual Machine Identifier Register
    ///
    /// Combined with `A[0]` in raw format
    var VMID: UInt8 = 0
    
    /// Untranslatable Virtual Machine Identifier
    ///
    /// Combined with `A[0]` in raw format
    var UVMID: UInt8 = 0
    
    /// Flags
    ///
    /// Combined with `A[1]` in raw format.
    var flags: UInt8 = 0
    
    /// Trap Enable Regiser
    ///
    /// Combined with `A[1]` in raw format
    var TE: UInt8 = 0
    
    /// User Mask Register
    ///
    /// Combined with `A[2]` in raw format
    var UM: UInt16 = 0
    
    /// Monitor Mask Register
    ///
    /// Combined with `A[3]` in raw fomrat.
    var MM: UInt16 = 0
    
    /// User Condition Register
    ///
    /// Combined with `A[4]` in raw format.
    var UCR: UInt16 = 0
    
    /// Monitor Condition Register
    ///
    /// Combined with `A5` in raw format.
    var MCR: UInt16 = 0
    
    /// Reserved 38
    ///
    /// Combined with `A6` in raw format.
    var reserved38: UInt8 = 0
    
    /// Lasat Processor Identification Register
    ///
    /// Combined with `A6` in raw fomrat.
    var LPID: UInt8 = 0
    
    /// Reserved 40
    ///
    /// Combined with `A[7]` in raw format.
    var reserved40: UInt16 = 0
    
    /// Reserved 48
    ///
    /// Combined with `A[8]` and `A[9]` in raw format.
    var reserved48: UInt32 = 0
    
    /// Process Interval Timer Register
    ///
    /// Combined with `A[0xA]` and `A[0xB]` in raw format.
    var PIT: UInt32 = 0
    
    /// Base Constant Register
    ///
    /// Combined with `A[0xC]` and `A[0xD]` in raw format.
    var BC: UInt32 = 0
    
    /// Model Dependent Flags
    ///
    /// Combined with `A[0xE]` in raw format.
    var MDF: UInt16 = 0
    
    /// Segment Table Length Register
    ///
    /// Combined with `A[0xF]` in raw format.
    var STL: UInt16 = 0
    
    /// Address Registers
    var A: [UInt48] = Array(repeating: 0, count: 0xF)
    
    /// Operand Registers
    var X: [UInt64] = Array(repeating: 0, count: 0xF)
    
    /// Model Dependent Word
    var MDW: UInt64 = 0
    
    /// Segment Table Address Register
    ///
    /// Combined with `UTP` and `TP` in raw format.
    var STA: UInt32 = 0 // combined wiht untranslatablePointer and trapPointer
    
    /// Debug Index Register
    ///
    /// Combined with `DLP` in raw format.
    var DI: UInt6 = 0
    
    /// Debug Mask Register
    ///
    /// Combined with `DLP` in raw format.
    var DM: UInt7 = 0
    
    /// Largest Ring Number Register
    ///
    /// Combined with `TOS[0]` in raw format.
    var LRN: UInt12 = 0
    
    /// Untranslatable Pointer Register
    var UTP: UInt48 = 0
    
    /// Trap Pointer Register
    var TP: UInt48 = 0
    
    /// Debug List Pointer Register
    var DLP: UInt48 = 0
    
    /// Top Of Stack Registers
    var TOS: [UInt48] = Array(repeating: 0, count: 15)
    
    
    // MARK: - Raw Value Packing/Unpacking
    
    var rawValues: [UInt64] {
        // TODO: Implement conversion to raw format.
        return Array<UInt64>(repeating: 0, count: 198)
    }
    
    init(rawValues: [UInt64]) {
        precondition(rawValues.count == 198)
        
        // TODO: Implement conversion from raw format.
    }
}
