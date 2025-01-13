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

#include <Cyber/Cyber180CM.h>

#include <Cyber/CyberTypes.h>

#include <assert.h>
#include <stdlib.h>


CYBER_SOURCE_BEGIN


/// A Cyber180CM implements a Cyber 180 Central Memory.
///
/// The Cyber 180 Central Memory is a 64-bit memory system
struct Cyber180CM {

    /// The system that this is a part of.
    struct Cyber962 *_system;

    /// Capacity of the Central Memory.
    size_t _capacity;

    /// Storage for the Central Memory.
    CyberWord64 *_storage;

    // FIXME: Flesh out.
};


struct Cyber180CM * _Nullable Cyber180CMCreate(struct Cyber962 * _Nonnull system, size_t capacity)
{
    assert(system != NULL);
    assert(   (capacity == (64 * 1) * 1048576)
           || (capacity == (64 * 2) * 1048576)
           || (capacity == (64 * 3) * 1048576)
           || (capacity == (64 * 4) * 1048576));

    struct Cyber180CM *cm = calloc(1, sizeof(struct Cyber180CM));

    cm->_system = system;
    cm->_capacity = capacity;
    cm->_storage = calloc(capacity / sizeof(CyberWord64), sizeof(CyberWord64));

    return cm;
}


void Cyber180CMDispose(struct Cyber180CM * _Nullable cm)
{
    if (cm == NULL) return;

    free(cm->_storage);

    free(cm);
}


CYBER_SOURCE_END
