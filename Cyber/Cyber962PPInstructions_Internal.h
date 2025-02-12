//
//  Cyber962PPInstructions_Internal.h
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

#include <Cyber/Cyber962PPInstructions.h>


#ifndef __CYBER_CYBER962PPINSTRUCTIONS_INTERNAL_H__
#define __CYBER_CYBER962PPINSTRUCTIONS_INTERNAL_H__

CYBER_HEADER_BEGIN


/// A Cyber 962 Peripheral Process Address Mode.
enum Cyber962PPAddressMode {

    /// "No-Address" mode is what most other processors refer to as "immediate" mode, and treats `d` as a 6-bit quantity.
    Cyber962PPAddressMode_NoAddress = 0,

    /// "Constant" mode is what most other processors refer to as "extended immediate" mode, where it treats the least significant 6 bits of `d` as the most significant bits and the least significant 12 bits of `m` as the least significant bits as an 18-bit quanitty.
    Cyber962PPAddressMode_Constant,

    /// Direct mode uses the least significant 6 bits of `d` as the address of a 12-bit or 16-bit word in memory.
    Cyber962PPAddressMode_Direct,

    /// Indirect mode uses the least significant 6 bits of `d` as the address of a word in memory that is used as the address of the 12-bit or 16-bit word in memory.
    Cyber962PPAddressMode_Indirect,

    /// "Memory" mode is what most other processors refer to as "indexed" mode, and uses the `d` and `m` fields to compose the address of a 12-bit or 16-bit word in memory, according to the following rules:
    ///
    /// 1. If `d` is `0`, `m` is the address to use.
    /// 2. If `d` is nonzero, `d` is the address of a 12-bit word that is added to `m` to generate an address.
    Cyber962PPAddressMode_Memory,

    /// "Block I/O & Central Memory Access" mode is used to form addresses specifically for block I/O and Central Memory Access instructions.
    Cyber962PPAddressMode_IO,
};


// MARK: - Instruction Declarations

#define CYBER_962_PP_DECLARE_INSTRUCTION(mn) CyberWord16 Cyber962PPInstruction_ ## mn (struct Cyber962PP *processor, union Cyber962PPInstructionWord instructionWord)

CYBER_962_PP_DECLARE_INSTRUCTION(LDx);
CYBER_962_PP_DECLARE_INSTRUCTION(STx);
CYBER_962_PP_DECLARE_INSTRUCTION(ADx);
CYBER_962_PP_DECLARE_INSTRUCTION(SBx);
CYBER_962_PP_DECLARE_INSTRUCTION(SHN);
CYBER_962_PP_DECLARE_INSTRUCTION(LMx);
CYBER_962_PP_DECLARE_INSTRUCTION(LPx);
CYBER_962_PP_DECLARE_INSTRUCTION(SCN);
CYBER_962_PP_DECLARE_INSTRUCTION(RAx);
CYBER_962_PP_DECLARE_INSTRUCTION(AOx);
CYBER_962_PP_DECLARE_INSTRUCTION(SOx);
CYBER_962_PP_DECLARE_INSTRUCTION(xJM);
CYBER_962_PP_DECLARE_INSTRUCTION(xJN);
CYBER_962_PP_DECLARE_INSTRUCTION(xRD);
CYBER_962_PP_DECLARE_INSTRUCTION(CRx);
CYBER_962_PP_DECLARE_INSTRUCTION(RDxL);
CYBER_962_PP_DECLARE_INSTRUCTION(CWx);
CYBER_962_PP_DECLARE_INSTRUCTION(IOJ);
CYBER_962_PP_DECLARE_INSTRUCTION(IN);
CYBER_962_PP_DECLARE_INSTRUCTION(OUT);
CYBER_962_PP_DECLARE_INSTRUCTION(CTRL);
CYBER_962_PP_DECLARE_INSTRUCTION(PSN);
CYBER_962_PP_DECLARE_INSTRUCTION(KPT);
CYBER_962_PP_DECLARE_INSTRUCTION(EXN);
CYBER_962_PP_DECLARE_INSTRUCTION(MXN);
CYBER_962_PP_DECLARE_INSTRUCTION(MAN);
CYBER_962_PP_DECLARE_INSTRUCTION(MAN2);
CYBER_962_PP_DECLARE_INSTRUCTION(INPN);

#undef CYBER_DECLARE_INSTRUCTION


CYBER_HEADER_END

#endif /* __CYBER_CYBER962PPINSTRUCTIONS_INTERNAL_H__ */
