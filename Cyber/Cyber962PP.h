//
//  Cyber962PP.h
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

#include <Cyber/CyberTypes.h>

#ifndef __CYBER_CYBER962PP_H__
#define __CYBER_CYBER962PP_H__

CYBER_HEADER_BEGIN


struct Cyber962IOU;
struct Cyber962PP;


/// Create a Cyber 962 Peripheral Processor connected to an Input/Output Unit.
///
/// - Parameters:
///   - inputOutputUnit: The Input/Output Unit to which this Peripheral Processor is attached.
///   - index: The index of this Peripheral Processor in the Input/Output Unit.
///
/// - Returns: A Peripheral Processor connected to the Input/Output Unit, or `NULL` on failure.
CYBER_EXPORT struct Cyber962PP * _Nullable Cyber962PPCreate(struct Cyber962IOU *inputOutputUnit, int index);


/// Dispose of a Cyber 962 Peripheral Processor.
CYBER_EXPORT void Cyber962PPDispose(struct Cyber962PP * _Nullable pp);


/// Reset the given Cyber 962 Peripheral Processor.
CYBER_EXPORT void Cyber962PPReset(struct Cyber962PP *pp);


/// Get the "barrel" that a PP is part of. This determines which I/O channels it's allowed to access.
CYBER_EXPORT int Cyber962PPGetBarrel(struct Cyber962PP *processor);


/// Read a single word from PP memory.
CYBER_EXPORT CyberWord16 Cyber962PPReadSingle(struct Cyber962PP *processor, CyberWord16 address);

/// Read multiple words from PP memory.
///
/// - Parameters:
///   - processor: The PP from whose memory to read.
///   - address: The address in the PP memory from which to read.
///   - buffer: The location in which to store the read words.
///   - count: The number of words to read.
CYBER_EXPORT void Cyber962PPReadMultiple(struct Cyber962PP *processor, CyberWord16 address, CyberWord16 *buffer, CyberWord16 count);

/// Write a single word to PP memory.
CYBER_EXPORT void Cyber962PPWriteSingle(struct Cyber962PP *processor, CyberWord16 address, CyberWord16 value);

/// Write multiple words to PP memory.
///
/// - Parameters:
///   - processor: The PP to whose memory to write.
///   - address: The address in the PP memory to which to write.
///   - buffer: The location from which to get the words to write.
///   - count: The number of words to write.
CYBER_EXPORT void Cyber962PPWriteMultiple(struct Cyber962PP *processor, CyberWord16 address, CyberWord16 *buffer, CyberWord16 count);


CYBER_HEADER_END

#endif /* __CYBER_CYBER962PP_H__ */

