//
//  Cyber180CPInstructions.h
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

#ifndef __CYBER_CYBER180CPINSTRUCTIONS_H__
#define __CYBER_CYBER180CPINSTRUCTIONS_H__

CYBER_HEADER_BEGIN


struct Cyber180CP;


/// A Cyber 180 Central Processor instruction word is a bit field of either 16 or 32 bits, depending on the opcode.
///
/// Since a Cyber 180 Central Processor instruction can be either 16 or 32 bits, there can be between 2 and 4 instructions per 64-bit word.
///
/// The size/type are determined by the opcode; always use ``Cyber180CPInstructionAdvance`` to determine the true size of a fetched instruction.
union Cyber180CPInstructionWord {

    /// The raw in-memory value of the instruction word.
    ///
    /// - Note: For a 16-bit instruction, the second 16 bits are ignored.
    ///
    /// - Warning: Never use `sizeof(union Cyber180CPInstructionWord)`, always call 
    CyberWord32 _raw;

    struct {
        unsigned opcode : 8;
        unsigned j : 4;
        unsigned k : 4;
        unsigned i : 4;
        unsigned D : 12;
    } _jkiD;

    struct {
        unsigned opcode : 5;
        unsigned S : 3;
        unsigned j : 4;
        unsigned k : 4;
        unsigned i : 4;
        unsigned D : 12;
    } _SjkID;

    struct {
        unsigned opcode : 8;
        unsigned j : 4;
        unsigned k : 4;
        unsigned unused : 16;
    } _jk;

    struct {
        unsigned opcode : 8;
        unsigned j : 4;
        unsigned k : 4;
        unsigned Q : 12;
    } _jkQ;
};


/// The type of an instruction implementation.
///
/// - Parameters:
///   - processor: The state for this Central Processor at the start of instruction execution.
///   - word: The instruction word itself, for field recovery.
///   - address: The address at which the instruction word was found, for offset calculations.
///
/// - Returns: The amount by which to increment `P` after the instruction completes; a branch/jump instruction will modify `P` itself and return all 1s as a signal not to adjust `P`.
typedef CyberWord64 (*Cyber180CPInstruction)(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address);


/// Decode the instruction at the given address.
///
/// - Parameters:
///   - processor: The state for this Central Processor at the start of instruction decoding.
///   - instructionWord: The instruction word itself.
///   - address: The address at which the instruction was found.
///
/// - Returns: A function pointer if the instruction word can be decoded, `NULL` if not.
CYBER_EXPORT Cyber180CPInstruction _Nullable Cyber180CPInstructionDecode(struct Cyber180CP *processor, union Cyber180CPInstructionWord instructionWord, CyberWord64 address);


/// Gets the size of the given instruction word, *which may be shorter than* `sizeof(instructionWord)`.
CYBER_EXPORT CyberWord64 Cyber180CPInstructionAdvance(union Cyber180CPInstructionWord instructionWord);


CYBER_HEADER_END

#endif /* __CYBER_CYBER180CPINSTRUCTIONS_H__ */
