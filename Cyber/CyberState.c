//
//  CyberState.c
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

#include "CyberState.h"

#include <assert.h>
#include <stdlib.h>

#include <pthread.h>


CYBER_SOURCE_BEGIN


struct CyberState {
    int _value;
    pthread_mutex_t _mutex;
    pthread_cond_t _condition;
};


struct CyberState * _Nullable CyberStateCreate(int initialValue)
{
    struct CyberState *cs = calloc(1, sizeof(struct CyberState));

    cs->_value = initialValue;

    if (pthread_mutex_init(&cs->_mutex, NULL) != 0) {
        free(cs);
        return NULL;
    }

    if (pthread_cond_init(&cs->_condition, NULL) != 0) {
        (void) pthread_mutex_destroy(&cs->_mutex);
        free(cs);
        return NULL;
    }

    return cs;
}

void CyberStateDispose(struct CyberState * _Nullable cs)
{
    if (cs == NULL) return;

    (void) pthread_mutex_destroy(&cs->_mutex);
    (void) pthread_cond_destroy(&cs->_condition);
}


int CyberStateGetValue(struct CyberState *cs)
{
    assert(cs != NULL);

    int currentValue;

    pthread_mutex_lock(&cs->_mutex); {
        currentValue = cs->_value;
    } pthread_mutex_unlock(&cs->_mutex);

    return currentValue;
}

void CyberStateSetValue(struct CyberState *cs, int newValue)
{
    assert(cs != NULL);

    pthread_mutex_lock(&cs->_mutex); {
        cs->_value = newValue;
        pthread_cond_signal(&cs->_condition);
    } pthread_mutex_unlock(&cs->_mutex);
}

int CyberStateAwaitValueChange(int currentValue, struct CyberState *cs)
{
    assert(cs != NULL);

    int newValue = currentValue;

    pthread_mutex_lock(&cs->_mutex); {
        // Loop until the value actually changes because pthread_cond_wait can encounter spurious wakeups due to fundamental UNIX design flaws (e.g. EINTR).
        do {
            pthread_cond_wait(&cs->_condition, &cs->_mutex);
            newValue = cs->_value;
        } while (newValue == currentValue);
    } pthread_mutex_unlock(&cs->_mutex);

    return newValue;
}


CYBER_SOURCE_END
