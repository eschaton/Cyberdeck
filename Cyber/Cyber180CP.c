//
//  CentralProcessor.c
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

#include "Cyber180CP_Internal.h"

#include <Cyber/Cyber180CMPort.h>

#include "Cyber180CPInstructions_Internal.h"
#include "CyberThread.h"

#include <assert.h>
#include <stdlib.h>


CYBER_SOURCE_BEGIN


static void Cyber180CPMainLoop(struct CyberThread *thread, void * _Nullable cpv);

static void Cyber180CPSingleStep(struct Cyber180CP *cp);


struct Cyber180CP * _Nullable Cyber180CPCreate(struct Cyber962 * _Nonnull system, int index)
{
    assert(system != NULL);
    assert((index >= 0) && (index <= 1));

    struct Cyber180CP *cp = calloc(1, sizeof(struct Cyber180CP));

    cp->_system = system;
    cp->_index = index;

    static struct CyberThreadFunctions Cyber180CPThreadFunctions = {
        .start = NULL,
        .loop = Cyber180CPMainLoop,
        .stop = NULL,
        .terminate = NULL,
    };

    cp->_thread = CyberThreadCreate(&Cyber180CPThreadFunctions, cp);

    cp->_mode = Cyber180CPModeMonitor;

    return cp;
}


void Cyber180CPDispose(struct Cyber180CP * _Nullable cp)
{
    if (cp == NULL) return;

    free(cp);
}


void Cyber180CPStart(struct Cyber180CP *cp)
{
    assert(cp != NULL);

    CyberThreadStart(cp->_thread);
}

void Cyber180CPStop(struct Cyber180CP *cp)
{
    assert(cp != NULL);

    CyberThreadStop(cp->_thread);
}

void Cyber180CPShutDown(struct Cyber180CP *cp)
{
    assert(cp != NULL);

    CyberThreadTerminate(cp->_thread);
}


void Cyber180CPMainLoop(struct CyberThread *thread, void * _Nullable cpv)
{
    struct Cyber180CP *cp = (struct Cyber180CP *)cpv;
    assert(cp != NULL);

    // Run the main loop once.
    Cyber180CPSingleStep(cp);
}


struct Cyber180CMPort * _Nonnull Cyber180CPGetCentralMemoryPort(struct Cyber180CP *cp)
{
    assert(cp != NULL);

    return cp->_centralMemoryPort;
}


void Cyber180CPSetCentralMemoryPort(struct Cyber180CP *cp, struct Cyber180CMPort *port)
{
    assert(cp != NULL);
    assert(port != NULL);
    assert(cp->_centralMemoryPort == NULL);

    cp->_centralMemoryPort = port;
}


CyberWord48 Cyber180CPGetA(struct Cyber180CP *cp, int i)
{
    assert(cp != NULL);
    assert((i >= 0) && (i <= 0xf));

    return cp->_regA[i] & 0x0000FFFFFFFFFFFF;
}

void Cyber180CPSetA(struct Cyber180CP *cp, int i, CyberWord48 value)
{
    assert(cp != NULL);
    assert((i >= 0) && (i <= 0xf));

    if (i != 0) {
        cp->_regA[i] = value & 0x0000FFFFFFFFFFFF;
    }
}


CyberWord64 Cyber180CPGetX(struct Cyber180CP *cp, int i)
{
    assert(cp != NULL);
    assert((i >= 0) && (i <= 0xf));

    if (i != 0) {
        return cp->_regX[i];
    } else {
        return 0;
    }
}

void Cyber180CPSetX(struct Cyber180CP *cp, int i, CyberWord64 value)
{
    assert(cp != NULL);
    assert((i >= 0) && (i <= 0xf));

    if (i != 0) {
        cp->_regX[i] = value;
    }
}


void Cyber180CPWriteBytes(struct Cyber180CP *cp, CyberWord64 virtualAddress, CyberWord8 *buf, CyberWord32 count)
{
    assert(cp != NULL);

    CyberWord64 physicalAddress = Cyber180CPTranslateAddress(cp, virtualAddress);

    struct Cyber180CMPort *port = Cyber180CPGetCentralMemoryPort(cp);
    Cyber180CMPortWriteBytesPhysical(port, physicalAddress, buf, count);
}


void Cyber180CPReadBytes(struct Cyber180CP *cp, CyberWord64 virtualAddress, CyberWord8 *buf, CyberWord32 count)
{
    assert(cp != NULL);

    CyberWord64 physicalAddress = Cyber180CPTranslateAddress(cp, virtualAddress);

    struct Cyber180CMPort *port = Cyber180CPGetCentralMemoryPort(cp);
    Cyber180CMPortReadBytesPhysical(port, physicalAddress, buf, count);
}


CyberWord64 Cyber180CPTranslateAddress(struct Cyber180CP *cp, CyberWord64 virtualAddress)
{
    assert(cp != NULL);

    // TODO: Implement virtual memory.

    return virtualAddress;
}


union Cyber180CPInstructionWord Cyber180CPReadInstructionWord(struct Cyber180CP *cp, CyberWord64 address)
{
    union Cyber180CPInstructionWord result;

    assert(cp != NULL);

    CyberWord64 physicalAddress = Cyber180CPTranslateAddress(cp, address);

    // TODO: Implement instruction cache.

    CyberWord16 minimalWord;
    struct Cyber180CMPort *port = Cyber180CPGetCentralMemoryPort(cp);
    Cyber180CMPortReadBytesPhysical(port, physicalAddress, (CyberWord8 *)&minimalWord, sizeof(CyberWord16));

    result._raw = ((CyberWord32)minimalWord) << 16;

    CyberWord64 advance = Cyber180CPInstructionAdvance(result);
    if (advance == 4) {
        Cyber180CMPortReadBytesPhysical(port, physicalAddress + 2, (CyberWord8 *)&minimalWord, sizeof(CyberWord16));
        result._raw |= ((CyberWord32)minimalWord);
    }

    return result;
}


void Cyber180CPSingleStep(struct Cyber180CP *cp)
{
    assert(cp != NULL);

    CyberWord64 oldP = cp->_regP;
    union Cyber180CPInstructionWord instructionWord = Cyber180CPReadInstructionWord(cp, oldP);
    Cyber180CPInstruction instruction = Cyber180CPInstructionDecode(cp, instructionWord, oldP);
    if (instruction) {
        CyberWord64 advance = instruction(cp, instructionWord, oldP);
        if (advance != ~0x0) {
            CyberWord64 newP = oldP + advance;
            cp->_regP = newP;
        }
    } else {
        // TODO: Illegal instruction interrupt
        assert(false);
    }
}


CYBER_SOURCE_END
