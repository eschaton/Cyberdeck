//
//  Cyber962.swift
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


/// A Cyber 962 system.
///
/// A Cyber 962 system always consists of:
/// - One or two Central Processor (CP)
/// - One Central Memory (CM) containing:
///   - 32MB (4MW) RAM
/// - One I/O Unit (IOU) containing:
///   - 10 CIO (Concurrent I/O) Peripheral Processors
///   - 8 DMA channels
///
/// One or two adaditional IOU can be added with:
/// - 10-20 CIO PP
/// - 10-20 DMA channels
///
/// The CM can be expanded to the following sizes:
/// - 64MB (8MW)
/// - 128MB (16MW)
/// - 192MB (24MW)
/// - 256MB (32MW)
class Cyber962 {

    /// The Central Memory subsystem.
    var centralMemory: Cyber962CM

    /// The Central Processors.
    var centralProcessors: [Cyber962CP] = []

    /// The I/O Units.
    var inputOutputUnits: [Cyber962IOU] = []

    init(memorySize: Int, channels: Int = 12, centralProcessors: Int = 1, inputOutputUnits: Int = 1) {
        precondition([32,64,128,192,256].contains(memorySize / 1048576))
        precondition((1...2).contains(centralProcessors))
        precondition((1...3).contains(inputOutputUnits))
        
        self.centralMemory = Cyber962CM()
        
        for cp in 0..<centralProcessors {
            let centralProcessor = Cyber962CP(system: self, index: cp)
            self.centralProcessors.append(centralProcessor)
        }
        
        for iou in 0..<inputOutputUnits {
            let inputOutputUnit = Cyber962IOU(system: self, index: iou)
            self.inputOutputUnits.append(inputOutputUnit)
        }
        
        // TODO: Connect the subsystems together.

        // TODO: Set up standard I/O channels
    }
}
