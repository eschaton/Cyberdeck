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


// MARK: - Instruction Declarations

#define CYBER_DECLARE_INSTRUCTION(i) bool Cyber962PPInstruction_ ## i (struct Cyber962PP *processor, CyberWord16 word)

CYBER_DECLARE_INSTRUCTION(LDx);
CYBER_DECLARE_INSTRUCTION(STx);
CYBER_DECLARE_INSTRUCTION(ADx);
CYBER_DECLARE_INSTRUCTION(SBx);
CYBER_DECLARE_INSTRUCTION(SHN);
CYBER_DECLARE_INSTRUCTION(LMx);
CYBER_DECLARE_INSTRUCTION(LPx);
CYBER_DECLARE_INSTRUCTION(SCN);
CYBER_DECLARE_INSTRUCTION(RAx);
CYBER_DECLARE_INSTRUCTION(AOx);
CYBER_DECLARE_INSTRUCTION(SOx);
CYBER_DECLARE_INSTRUCTION(xJM);
CYBER_DECLARE_INSTRUCTION(xJN);
CYBER_DECLARE_INSTRUCTION(PSN);
CYBER_DECLARE_INSTRUCTION(KPT);
CYBER_DECLARE_INSTRUCTION(EXN);
CYBER_DECLARE_INSTRUCTION(MXN);
CYBER_DECLARE_INSTRUCTION(MAN);
CYBER_DECLARE_INSTRUCTION(MAN2);
CYBER_DECLARE_INSTRUCTION(INPN);

#undef CYBER_DECLARE_INSTRUCTION


CYBER_HEADER_END

#endif /* __CYBER_CYBER962PPINSTRUCTIONS_INTERNAL_H__ */
