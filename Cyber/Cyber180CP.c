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


void Cyber180CPSingleStep(struct Cyber180CP *cp)
{
    // TODO: Implement instruction decoding and execution.
}


CYBER_SOURCE_END
