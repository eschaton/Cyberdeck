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

#include <assert.h>
#include <stdlib.h>


CYBER_SOURCE_BEGIN


static void * _Nullable Cyber180CPThread(void * _Nullable cpv);

static void Cyber180CPSingleStep(struct Cyber180CP *cp);


struct Cyber180CP * _Nullable Cyber180CPCreate(struct Cyber962 * _Nonnull system, int index)
{
    assert(system != NULL);
    assert((index >= 0) && (index <= 1));

    struct Cyber180CP *cp = calloc(1, sizeof(struct Cyber180CP));

    cp->_system = system;
    cp->_index = index;

    pthread_attr_t thread_attr;
    int thread_attr_err = pthread_attr_init(&thread_attr);
    if (thread_attr_err != 0) {
        assert(thread_attr_err != 0); // halt here in debug builds
        Cyber180CPDispose(cp);
        return NULL;
    }

    (void)pthread_attr_setdetachstate(&thread_attr, PTHREAD_CREATE_DETACHED);

    int thread_err = pthread_create(&cp->_thread, &thread_attr, Cyber180CPThread, cp);
    if (thread_err != 0) {
        assert(thread_err != 0); // halt here in debug builds
        Cyber180CPDispose(cp);
        return NULL;
    }

    (void)pthread_attr_destroy(&thread_attr);

    cp->_state = CyberStateCreate(Cyber180CPState_Halted);

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

    CyberStateSetValue(cp->_state, Cyber180CPState_Running);
}

void Cyber180CPStop(struct Cyber180CP *cp)
{
    assert(cp != NULL);

    CyberStateSetValue(cp->_state, Cyber180CPState_Halted);
}

void Cyber180CPShutDown(struct Cyber180CP *cp)
{
    assert(cp != NULL);

    CyberStateSetValue(cp->_state, Cyber180CPState_Shutdown);
}


void * _Nullable Cyber180CPThread(void * _Nullable cpv)
{
    struct Cyber180CP *cp = (struct Cyber180CP *)cpv;
    assert(cp != NULL);

    // Disable cancellation for this thread.

    pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, NULL);

    // Loop indefinitely until shut down.

    bool running = true;
    while (running) {
        // Check the current state.
        enum Cyber180CPState state = CyberStateGetValue(cp->_state);

        switch (state) {
            case Cyber180CPState_Halted:
                // Wait for the state to change out of Halted.
                state = CyberStateAwaitValueChange(state, cp->_state);
                break;

            case Cyber180CPState_Running:
                // Run the main loop once.
                Cyber180CPSingleStep(cp);
                break;

            case Cyber180CPState_Shutdown:
                // Just exit.
                running = false;
                break;
        }
    }

    return NULL;
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
