//
//  Cyber180CM.c
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

#include "Cyber180CM_Internal.h"

#include <Cyber/Cyber180CMPort.h>

#include <assert.h>
#include <stdlib.h>


CYBER_SOURCE_BEGIN


struct Cyber180CM * _Nullable Cyber180CMCreate(struct Cyber962 * _Nonnull system, CyberWord32 capacity, int ports)
{
    assert(system != NULL);
    assert(   (capacity == (64 * 1) * 1048576)
           || (capacity == (64 * 2) * 1048576)
           || (capacity == (64 * 3) * 1048576)
           || (capacity == (64 * 4) * 1048576));
    assert(ports >= 2);

    struct Cyber180CM *cm = calloc(1, sizeof(struct Cyber180CM));

    cm->_system = system;
    cm->_capacity = capacity;
    cm->_storage = calloc(capacity / sizeof(CyberWord64), sizeof(CyberWord64));
    cm->_portCount = ports;
    cm->_ports = calloc(ports, sizeof(struct Cyber180CMPort *));

    for (int port = 0; port < ports; port++) {
        cm->_ports[port] = Cyber180CMPortCreate(cm, port);
    }

    int err = pthread_mutex_init(&cm->_lock, NULL);
    if (err != 0) {
        assert(err != 0); // halt when built for debugging
        Cyber180CMDispose(cm);
        return NULL;
    }

    return cm;
}


void Cyber180CMDispose(struct Cyber180CM * _Nullable cm)
{
    if (cm == NULL) return;

    free(cm->_storage);

    for (int port = 0; port < cm->_portCount; port++) {
        free(cm->_ports[port]);
    }

    int err = pthread_mutex_destroy(&cm->_lock);
    if (err != 0) {
        assert(err != 0); // halt when built for debugging
    }

    free(cm);
}


struct Cyber180CMPort *Cyber180CMGetPortAtIndex(struct Cyber180CM *cm, int index)
{
    assert(cm != NULL);
    assert(index < cm->_portCount);

    return cm->_ports[index];
}


void Cyber180CMAcquireLock(struct Cyber180CM *cm)
{
    pthread_mutex_lock(&cm->_lock);
}


void Cyber180CMRelinquishLock(struct Cyber180CM *cm)
{
    pthread_mutex_unlock(&cm->_lock);
}


CYBER_SOURCE_END
