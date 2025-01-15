//
//  Cyber962.c
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

#include <Cyber/Cyber962.h>

#include <Cyber/Cyber180CM.h>
#include <Cyber/Cyber180CP.h>
#include <Cyber/Cyber962IOU.h>

#include <assert.h>
#include <stdlib.h>
#include <string.h>


CYBER_SOURCE_BEGIN


/// A Cyber 962 system.
///
/// A Cyber 962 system always consists of:
/// - One or two Central Processor (CP)
/// - One Central Memory (CM) containing:
///   - 32MB (4MW) RAM
/// - One I/O Unit (IOU) containing:
///   - 10 CIO (Concurrent I/O) Peripheral Processors
///   - 8 DMA channels
///
/// One or two adaditional IOU can be added with:
/// - 10-20 CIO PP
/// - 10-20 DMA channels
///
/// The CM can be expanded to the following sizes:
/// - 64MB (8MW)
/// - 128MB (16MW)
/// - 192MB (24MW)
/// - 256MB (32MW)
struct Cyber962 {
    /// The Central Memory in this system.
    struct Cyber180CM *_centralMemory;

    /// The one or two Central Processors in this system.
    struct Cyber180CP * _Nullable _centralProcessors[2];

    /// The I/O Units in this system.
    struct Cyber962IOU * _Nullable _inputOutputUnits[3];

    /// The human-readable name or identifier of this system.
    char *_identifier;
};


struct Cyber962 * _Nullable Cyber962Create(const char *identifier, size_t memorySize, int centralProcessors, int inputOutputUnits)
{
    assert(identifier != NULL);
    assert(memorySize <= (256 * 1024 * 1024));
    assert((centralProcessors > 0) && (centralProcessors <= 1));
    assert((inputOutputUnits > 0) && (inputOutputUnits <= 3));

    // Create the system components and connect them together.

    struct Cyber962 *system = calloc(0, sizeof(struct Cyber962));

    system->_identifier = strdup(identifier);

    int portCount = centralProcessors + inputOutputUnits;
    struct Cyber180CM *centralMemory = Cyber180CMCreate(system, memorySize, portCount);
    system->_centralMemory = centralMemory;

    for (int cp = 0; cp < centralProcessors; cp++) {
        struct Cyber180CP *centralProcessor = Cyber180CPCreate(system, cp);
        system->_centralProcessors[cp] = centralProcessor;
        // FIXME: Connect Central Memory ports to Central Processors
    }

    const int iouPortsBase = centralProcessors;
    for (int iou = 0; iou < inputOutputUnits; iou++) {
        struct Cyber962IOU *inputOutputUnit = Cyber962IOUCreate(system, iou);
        struct Cyber180CMPort *centralMemoryPort = Cyber180CMGetPortAtIndex(system->_centralMemory, iouPortsBase + iou);
        Cyber962IOUSetCentralMemoryPort(inputOutputUnit, centralMemoryPort);
        system->_inputOutputUnits[iou] = inputOutputUnit;
    }

    // FIXME: Connect I/O Channels.

    return system;
}


void Cyber962Dispose(struct Cyber962 * _Nullable system)
{
    if (system == NULL) return;

    Cyber180CMDispose(system->_centralMemory);

    Cyber180CPDispose(system->_centralProcessors[0]);
    Cyber180CPDispose(system->_centralProcessors[1]);

    Cyber962IOUDispose(system->_inputOutputUnits[0]);
    Cyber962IOUDispose(system->_inputOutputUnits[1]);
    Cyber962IOUDispose(system->_inputOutputUnits[2]);

    free(system->_identifier);
}


char *Cyber962GetIdentifier(struct Cyber962 *system)
{
    assert(system != NULL);

    return strdup(system->_identifier);
}


struct Cyber180CM *Cyber962GetCentralMemory(struct Cyber962 *system)
{
    assert(system != NULL);

    return system->_centralMemory;
}


struct Cyber180CP *Cyber962GetCentralProcessor(struct Cyber962 *system, int index)
{
    assert(system != NULL);
    assert((index >= 0) && (index <= 1));

    return system->_centralProcessors[index];
}


struct Cyber962IOU * _Nullable Cyber962GetInputOutputUnit(struct Cyber962 *system, int index)
{
    assert(system != NULL);
    assert((index >= 0) && (index <= 2));

    return system->_inputOutputUnits[index];
}


CYBER_SOURCE_END
