//
//  Cyber180CPInstructions_Internal.h
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

#include <Cyber/Cyber180CPInstructions.h>


#ifndef __CYBER_CYBER180CPINSTRUCTIONS_INTERNAL_H__
#define __CYBER_CYBER180CPINSTRUCTIONS_INTERNAL_H__

CYBER_HEADER_BEGIN

/// Type of a Cyber 180 Central Processor instruction, derived from its opcode.
enum Cyber180CPInstructionType {
    Cyber180CPInstructionType_jk = 0,
    Cyber180CPInstructionType_jkiD = 1,
    Cyber180CPInstructionType_SjkiD = 2,
    Cyber180CPInstructionType_jkQ = 3,
};


/// Get the instruciton type of the given instruction word.
CYBER_EXPORT enum Cyber180CPInstructionType Cyber180CPGetInstructionType(union Cyber180CPInstructionWord instructionWord);


// MARK: - Instruction Declarations

#define CYBER_180_CP_DECLARE_INSTRUCTION(mn) \
    CyberWord64 Cyber180CPInstruction_ ##mn (struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)


CYBER_180_CP_DECLARE_INSTRUCTION(EXECUTE); // 0xc0...0xc7

CYBER_180_CP_DECLARE_INSTRUCTION(LBYTS); // 0xd0...0xd7
CYBER_180_CP_DECLARE_INSTRUCTION(SBYTS); // 0xd8...0xdf

CYBER_180_CP_DECLARE_INSTRUCTION(SCLN); // 0xe4
CYBER_180_CP_DECLARE_INSTRUCTION(SCLR); // 0xe5
CYBER_180_CP_DECLARE_INSTRUCTION(CMPC); // 0xe9
CYBER_180_CP_DECLARE_INSTRUCTION(TRANB); // 0xeb
CYBER_180_CP_DECLARE_INSTRUCTION(EDIT); // 0xed

CYBER_180_CP_DECLARE_INSTRUCTION(SCNB); // 0xf3
CYBER_180_CP_DECLARE_INSTRUCTION(MOVI); // 0xf9
CYBER_180_CP_DECLARE_INSTRUCTION(CMPI); // 0xfa
CYBER_180_CP_DECLARE_INSTRUCTION(ADDI); // 0xfb


#undef CYBER_180_CP_DECLARE_INSTRUCTION


CYBER_HEADER_END

#endif /* __CYBER_CYBER180CPINSTRUCTIONS_INTERNAL_H__ */
