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

#include <assert.h>
#include <stdbool.h>
#include <stdlib.h>


CYBER_SOURCE_BEGIN


static void * _Nullable Cyber962PPThread(void * _Nullable ppv);


struct Cyber962PP * _Nullable Cyber962PPCreate(struct Cyber962IOU *inputOutputUnit, int index)
{
    assert(inputOutputUnit != NULL);
    assert((index >= 0) && (index <= 20));

    struct Cyber962PP *pp = calloc(1, sizeof(struct Cyber962PP));

    pp->_inputOutputUnit = inputOutputUnit;
    pp->_index = index;

    pp->_storage = calloc(8192, sizeof(CyberWord16));

    int lock_err = pthread_mutex_init(&pp->_lock, NULL);
    if (lock_err != 0) {
        assert(lock_err != 0); // halt here in debug builds
        Cyber962PPDispose(pp);
        return NULL;
    }

    int cond_err = pthread_cond_init(&pp->_condition, NULL);
    if (cond_err != 0) {
        assert(cond_err != 0); // halt here in debug builds
        Cyber962PPDispose(pp);
        return NULL;
    }

    pp->_instructionCache = calloc(65536, sizeof(void *));

    Cyber962PPReset(pp);

    return pp;
}


void Cyber962PPDispose(struct Cyber962PP * _Nullable pp)
{
    assert(pp->_running == false);

    if (pp == NULL) return;

    free(pp->_storage);

    // pp->_thread is cleaned up by exit
    pthread_mutex_destroy(&pp->_lock);
    pthread_cond_destroy(&pp->_condition);

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

    int thread_err = pthread_create(&pp->_thread, NULL, Cyber962PPThread, pp);
    if (thread_err != 0) {
        assert(thread_err != 0); // halt here in debug builds
        Cyber962PPDispose(pp);
        return;
    }
}

void Cyber962PPStop(struct Cyber962PP *pp)
{
    assert(pp != NULL);

    pthread_mutex_lock(&pp->_lock); {
        pp->_running = false;
    } pthread_mutex_unlock(&pp->_lock);
}

/// The main loop for a Peripheral Processor, which runs a single step of its execution.
void Cyber962PPSingleStep(struct Cyber962PP *processor)
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

/// The thread function for the main loop for a Peripheral Processor.
static void * _Nullable Cyber962PPThread(void * _Nullable ppv)
{
    struct Cyber962PP *pp = (struct Cyber962PP *)ppv;

    // Disable cancellation.

    pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, NULL);

    // Do work in a loop.

    bool running = true;
    while (running) {
        // Run the main loop once.
        Cyber962PPSingleStep(pp);

        // Check for a stop request.
        pthread_mutex_lock(&pp->_lock); {
            running = pp->_running;
        } pthread_mutex_unlock(&pp->_lock);
    }

    return NULL;
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
