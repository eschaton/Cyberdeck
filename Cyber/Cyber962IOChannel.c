//
//  Cyber962IOChannel.c
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

#include "Cyber962IOChannel_Internal.h"

#include <assert.h>
#include <stdlib.h>


CYBER_SOURCE_BEGIN


struct Cyber962IOChannel * _Nullable Cyber962IOChannelCreate(struct Cyber962IOU *inputOutputUnit, int index)
{
    assert(inputOutputUnit != NULL);
    assert((index >= 0) && (index < 20));

    struct Cyber962IOChannel *ioc = calloc(1, sizeof(struct Cyber962IOChannel));

    ioc->_inputOutputUnit = inputOutputUnit;
    ioc->_index = index;

    return ioc;
}


void Cyber962IOChannelDispose(struct Cyber962IOChannel * _Nullable ioc)
{
    if (ioc == NULL) return;

    free(ioc);
}


int Cyber962IOChannelGetIndex(struct Cyber962IOChannel *ioc)
{
    return ioc->_index;
}


bool Cyber962IOChannelIsActive(struct Cyber962IOChannel *ioc)
{
    return ioc->_active;
}


bool Cyber962IOChannelIsFull(struct Cyber962IOChannel *ioc)
{
    return ioc->_full;
}


bool Cyber962IOChannelHasFlag(struct Cyber962IOChannel *ioc)
{
    return ioc->_flag;
}


bool Cyber962IOChannelHasError(struct Cyber962IOChannel *ioc)
{
    return ioc->_error;
}


void Cyber962IOChannelSetFunctions(struct Cyber962IOChannel *ioc, struct Cyber962IOChannelFunctions * _Nullable functions)
{
    assert(ioc != NULL);
    assert(functions != NULL);

    assert(functions->readFunction != NULL);
    assert(functions->writeFunction != NULL);
    assert(functions->controlFunction != NULL);
    assert(functions->checkStateFunction != NULL);

    ioc->_functions = functions;
}


CYBER_SOURCE_END
