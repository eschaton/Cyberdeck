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

#include <Cyber/Cyber180CP.h>

#include <assert.h>
#include <stdlib.h>


CYBER_SOURCE_BEGIN


/// A Cyber180CP implements a Cyber 180 Central Processor.
///
/// The Cyber 180 Central Processor is a 64-bit processor with:
///
/// - Byte rather than word addressing
/// - Two's complement rather than one's complement representation
/// - 16 X registers of 64 bits each
/// - 16 A registers of 48 bits each
/// - A "4096 times 2^31" byte user address space
///
/// The Cyber uses IBM-style bit numbering; that is, bit 0 is the "leftmost" (most significant) bit in a word.
struct Cyber180CP {

    /// The system that this is a part of.
    struct Cyber962 *_system;

    /// Index of this Cyber 180 Central Processor within the system.
    int _index;

    // Registers

    // TODO: Add register definitions.

    // FIXME: Flesh out.
};


struct Cyber180CP * _Nullable Cyber180CPCreate(struct Cyber962 * _Nonnull system, int index)
{
    assert(system != NULL);
    assert((index >= 0) && (index <= 1));

    struct Cyber180CP *cp = calloc(1, sizeof(struct Cyber180CP));

    cp->_system = system;
    cp->_index = index;

    return cp;
}


void Cyber180CPDispose(struct Cyber180CP * _Nullable cp)
{
    if (cp == NULL) return;

    free(cp);
}


CYBER_SOURCE_END
