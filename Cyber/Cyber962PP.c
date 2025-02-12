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

#include "Cyber962PP_Internal.h"

#include "Cyber962PPInstructions.h"
#include "CyberState.h"
#include "CyberThread.h"

#include <assert.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


CYBER_SOURCE_BEGIN


static void Cyber962PPMainLoop(struct CyberThread *thread, void * _Nullable ppv);

static void Cyber962PPSingleStep(struct Cyber962PP *processor);


struct Cyber962PP * _Nullable Cyber962PPCreate(struct Cyber962IOU *inputOutputUnit, int index)
{
    assert(inputOutputUnit != NULL);
    assert((index >= 0) && (index <= 20));

    struct Cyber962PP *pp = calloc(1, sizeof(struct Cyber962PP));

    pp->_inputOutputUnit = inputOutputUnit;
    pp->_index = index;

    pp->_storage = calloc(8192, sizeof(CyberWord16));

    static struct CyberThreadFunctions Cyber962PPThreadFunctions = {
        .start = NULL,
        .loop = Cyber962PPMainLoop,
        .stop = NULL,
        .terminate = NULL,
    };

    char name[32];
    snprintf(name, 32, "Cyber962PP-%d", index);

    pp->_thread = CyberThreadCreate(name, &Cyber962PPThreadFunctions, pp);

    pp->_instructionCache = calloc(65536, sizeof(void *));

    for (int keypoint = 0; keypoint < 64; keypoint++) {
        pp->_keypoints[keypoint] = 0;
    }

    Cyber962PPReset(pp);

    return pp;
}

void Cyber962PPDispose(struct Cyber962PP * _Nullable pp)
{
    if (pp == NULL) return;

    free(pp->_storage);

    CyberThreadDispose(pp->_thread);

    free(pp->_instructionCache);

    free(pp);
}


void Cyber962PPReset(struct Cyber962PP *pp)
{
    pp->_regA = 0010000;
    pp->_regP = 0000001;
    pp->_regR = 0x00000000;
}


void Cyber962PPStart(struct Cyber962PP *pp)
{
    assert(pp != NULL);

    CyberThreadStart(pp->_thread);
}

void Cyber962PPStop(struct Cyber962PP *pp)
{
    assert(pp != NULL);

    CyberThreadStop(pp->_thread);
}

void Cyber962PPShutdown(struct Cyber962PP *pp)
{
    assert(pp != NULL);

    CyberThreadTerminate(pp->_thread);
}

/// The thread function for the main loop for a Peripheral Processor.
static void Cyber962PPMainLoop(struct CyberThread *thread, void * _Nullable ppv)
{
    struct Cyber962PP *pp = (struct Cyber962PP *)ppv;
    assert(pp != NULL);

    // Run the main loop once.
    Cyber962PPSingleStep(pp);
}


/// The main loop for a Peripheral Processor, which runs a single step of its execution.
static void Cyber962PPSingleStep(struct Cyber962PP *processor)
{
    assert(processor != NULL);

    CyberWord16 oldP = processor->_regP;
    union Cyber962PPInstructionWord instructionWord;
    instructionWord._raw = Cyber962PPReadSingle(processor, oldP);
    Cyber962PPInstruction instruction = Cyber962PPInstructionDecode(processor, instructionWord, oldP);
    CyberWord16 advance = instruction(processor, instructionWord);
    CyberWord16 newP = oldP + advance;
    processor->_regP = newP;
}


int Cyber962PPGetBarrel(struct Cyber962PP *processor)
{
    assert(processor != NULL);

    return processor->_index % 5;
}


CyberWord16 Cyber962PPReadSingle(struct Cyber962PP *processor, CyberWord16 address)
{
    assert(processor != NULL);

    return processor->_storage[address];
}


void Cyber962PPReadMultiple(struct Cyber962PP *processor, CyberWord16 address, CyberWord16 *buffer, CyberWord16 count)
{
    assert(processor != NULL);
    assert(buffer != NULL);

    // Instead of using memcpy, use a loop to get wrapping.
    for (CyberWord16 i = 0; i < count; i++) {
        buffer[i] = processor->_storage[address + i];
    }
}


void Cyber962PPWriteSingle(struct Cyber962PP *processor, CyberWord16 address, CyberWord16 value)
{
    assert(processor != NULL);

    processor->_storage[address] = value;
}


void Cyber962PPWriteMultiple(struct Cyber962PP *processor, CyberWord16 address, CyberWord16 *buffer, CyberWord16 count)
{
    assert(processor != NULL);
    assert(buffer != NULL);

    // Instead of using memcpy, use a loop to get wrapping.
    for (CyberWord16 i = 0; i < count; i++) {
        processor->_storage[address + i] = buffer[i];
    }
}


CYBER_SOURCE_END
