//
//  CyberThread.c
//  Cyber
//
//  Copyright © 2025 Christopher M. Hanson. All rights reserved.
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

#include "CyberThread_Internal.h"

#include <assert.h>
#include <stdlib.h>

#include "CyberState.h"


CYBER_SOURCE_BEGIN


static void * _Nullable CyberThreadPthreadFunction(void * _Nullable t);


struct CyberThread * _Nullable CyberThreadCreate(struct CyberThreadFunctions *threadFunctions, void * _Nullable context)
{
    assert(threadFunctions != NULL);
    assert(threadFunctions->loop != NULL);

    struct CyberThread *thread = calloc(1, sizeof(struct CyberThread));

    thread->_context = context;

    thread->_state = CyberStateCreate(CyberThreadState_Stopped);
    if (thread->_state == NULL) {
        assert(thread->_state != NULL); // halt here in debug build
        CyberThreadDispose(thread);
        return NULL;
    }

    pthread_attr_t pthread_attrs;
    int pthread_attrs_err = pthread_attr_init(&pthread_attrs);
    if (pthread_attrs_err != 0) {
        assert(pthread_attrs_err == 0); // halt here in debug build
        CyberThreadDispose(thread);
        return NULL;
    }

    (void) pthread_attr_setdetachstate(&pthread_attrs, PTHREAD_CREATE_DETACHED);

    int pthread_err = pthread_create(&thread->_pthread, &pthread_attrs, CyberThreadPthreadFunction, thread);
    if (pthread_err != 0) {
        assert(pthread_err == 0); // halt here in debug build
        CyberThreadDispose(thread);
        return NULL;
    }

    (void) pthread_attr_destroy(&pthread_attrs);

    return thread;
}


void CyberThreadDispose(struct CyberThread * _Nullable thread)
{
    if (thread == NULL) return;

    // thread->_pthread will be cleaned up by the system

    CyberStateDispose(thread->_state);

    free (thread);
}


void CyberThreadStart(struct CyberThread *thread)
{
    assert(thread != NULL);

    CyberStateSetValue(thread->_state, CyberThreadState_Started);
}

void CyberThreadStop(struct CyberThread *thread)
{
    assert(thread != NULL);

    CyberStateSetValue(thread->_state, CyberThreadState_Stopped);
}

void CyberThreadTerminate(struct CyberThread *thread)
{
    assert(thread != NULL);

    CyberStateSetValue(thread->_state, CyberThreadState_Terminated);
}


static void * _Nullable CyberThreadPthreadFunction(void * _Nullable t)
{
    struct CyberThread * _Nullable thread = (struct CyberThread *)t;
    assert(thread != NULL);

    // Disable cancellation for this thread.

    pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, NULL);

    // Loop indefinitely until shut down.

    bool running = true;
    while (running) {
        // Check the current state.
        enum CyberThreadState state = CyberStateGetValue(thread->_state);

#define CALL_IF(fn) \
    do { \
        if ((fn) != NULL) { \
            ((fn))(thread, thread->_context); \
        } \
    } while(0)

        switch (state) {
            case CyberThreadState_Stopped:
                // Call the stop function if there is one.
                CALL_IF(thread->_functions->stop);

                // Wait for the state to change out of Stopped.
                state = CyberStateAwaitValueChange(state, thread->_state);
                break;

            case CyberThreadState_Started:
                // Call the start function if there is one.
                CALL_IF(thread->_functions->start);

                // Transition to running state.
                CyberStateSetValue(thread->_state, CyberThreadState_Running);
                break;

            case CyberThreadState_Running:
                // Run the main loop once.
                thread->_functions->loop(thread, thread->_context);
                break;

            case CyberThreadState_Terminated:
                // Call the terminate function if there is one.
                CALL_IF(thread->_functions->terminate);

                // Just exit.
                running = false;
                break;
        }

#undef CALL_IF
    }

    return NULL;
}


CYBER_SOURCE_END
