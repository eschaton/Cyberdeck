//
//  Cyber962PPInstructions.h
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

#ifndef __CYBER_CYBER962PPInstructions_H__
#define __CYBER_CYBER962PPInstructions_H__

CYBER_HEADER_BEGIN


struct Cyber962PP;


/// The type of an instruction implementation.
///
/// - Parameters:
///   - processor: The state for this Peripheral Processor at the start of instruction execution.
///   - word: The instruction word itself, for field recovery.
///
/// - Returns: `true` to auto-increment `_regP`, `false` if the instruction implementation changes `_regP` itself.
typedef bool (*Cyber962PPInstruction)(struct Cyber962PP *processor, CyberWord16 word);


/// Decode the instruction at the given address.
///
/// - Parameters:
///   - processor: The state for this Peripheral Processor at the start of instruction decoding.
///   - word: The instruction word itself, for field recovery.
///   - address: The address at which the instruction was found.
///
/// - Returns: A function pointer if the instruction word can be decoded, `NULL` if not.
CYBER_EXPORT Cyber962PPInstruction _Nullable Cyber962PPInstructionDecode(struct Cyber962PP *processor, CyberWord16 word, CyberWord16 address);


CYBER_HEADER_END

#endif /* __CYBER_CYBER962PPInstructions_H__ */
