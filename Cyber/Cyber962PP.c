//
//  Cyber962PP.c
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

#include <Cyber/Cyber962PP.h>

#include <assert.h>
#include <stdlib.h>


CYBER_SOURCE_BEGIN


/// A Cyber962PP implements a Cyber 962 Peripheral Processor.
struct Cyber962PP {

    /// The Input/Output Unit that this is a part of.
    struct Cyber962IOU *_inputOutputUnit;

    /// Index of this Peripheral Processor in the Input/Output Unit.
    int _index;

    /// The memory for this Peripheral Processor.
    CyberWord16 *_storage;

    // Registers

    /// Arithmetic Register
    CyberWord18 _regA;

    /// Program Address Register (program counter)
    CyberWord16 _regP;

    /// Relocation Register
    CyberWord32 _regR;

    // FIXME: Flesh out.
};


struct Cyber962PP * _Nullable Cyber962PPCreate(struct Cyber962IOU *inputOutputUnit, int index)
{
    assert(inputOutputUnit != NULL);
    assert((index >= 0) && (index <= 20));

    struct Cyber962PP *pp = calloc(1, sizeof(struct Cyber962PP));

    pp->_inputOutputUnit = inputOutputUnit;
    pp->_index = index;

    pp->_storage = calloc(8192, sizeof(CyberWord16));

    Cyber962PPReset(pp);

    return pp;
}


void Cyber962PPDispose(struct Cyber962PP * _Nullable pp)
{
    if (pp == NULL) return;

    free(pp->_storage);

    free(pp);
}


void Cyber962PPReset(struct Cyber962PP *pp)
{
    pp->_regA = 010000;
    pp->_regP = 0x0001;
    pp->_regR = 0x00000000;
}


CyberWord16 Cyber962PPReadSingle(struct Cyber962PP *processor, CyberWord16 address)
{
    assert(processor != NULL);

    return processor->_storage[address];
}


void Cyber962PPWriteSingle(struct Cyber962PP *processor, CyberWord16 address, CyberWord16 value)
{
    assert(processor != NULL);

    processor->_storage[address] = value;
}


CYBER_SOURCE_END
