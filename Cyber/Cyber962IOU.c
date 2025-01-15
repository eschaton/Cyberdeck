//
//  Cyber962IOU.c
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

#include "Cyber962IOU_Internal.h"

#include <Cyber/Cyber962PP.h>
#include <Cyber/Cyber962IOChannel.h>

#include <assert.h>
#include <stdlib.h>


CYBER_SOURCE_BEGIN


struct Cyber962IOU * _Nullable Cyber962IOUCreate(struct Cyber962 * _Nonnull system, int index)
{
    assert(system != NULL);
    assert((index >= 0) && (index <= 1));

    struct Cyber962IOU *iou = calloc(1, sizeof(struct Cyber962IOU));

    iou->_system = system;
    iou->_index = index;

    for (int pp = 0; pp < 20; pp++) {
        struct Cyber962PP *peripheralProcessor = Cyber962PPCreate(iou, pp);
        iou->_peripheralProcessors[pp] = peripheralProcessor;
    }

    for (int ioc = 0; ioc < 20; ioc++) {
        struct Cyber962IOChannel *inputOutputChannel = Cyber962IOChannelCreate(iou, ioc);
        iou->_inputOutputChannels[ioc] = inputOutputChannel;
    }

    return iou;
}


void Cyber962IOUDispose(struct Cyber962IOU * _Nullable iou)
{
    if (iou == NULL) return;

    for (int pp = 0; pp < 20; pp++) {
        Cyber962PPDispose(iou->_peripheralProcessors[pp]);
    }

    for (int ioc = 0; ioc < 20; ioc++) {
        Cyber962IOChannelDispose(iou->_inputOutputChannels[ioc]);
    }

    free(iou);
}


struct Cyber962PP *Cyber962IOUGetPeripheralProcessor(struct Cyber962IOU *iou, int index)
{
    assert(iou != NULL);
    assert((index >= 0) && (index < 20));

    return iou->_peripheralProcessors[index];
}


struct Cyber180CMPort *Cyber962IOUGetCentralMemoryPort(struct Cyber962IOU *iou)
{
    assert(iou != NULL);

    return iou->_centralMemoryPort;
}


void Cyber962IOUSetCentralMemoryPort(struct Cyber962IOU *iou, struct Cyber180CMPort *port)
{
    assert(iou != NULL);
    assert(port != NULL);
    assert(iou->_centralMemoryPort == NULL);

    iou->_centralMemoryPort = port;
}


struct Cyber962IOChannel *Cyber962GetIOChannelAtIndex(struct Cyber962IOU *iou, int index)
{
    assert(iou != NULL);
    assert((index >= 0) && (index < 20));

    return iou->_inputOutputChannels[index];
}


CYBER_SOURCE_END
