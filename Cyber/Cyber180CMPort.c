//
//  Cyber180CMPort.c
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

#include <Cyber/Cyber180CMPort.h>

#include "Cyber180CM_Internal.h"

#include <assert.h>
#include <stdlib.h>


CYBER_SOURCE_BEGIN


/// A Cyber180CMPort provides an access port to a Central Memory.
struct Cyber180CMPort {

    /// The Central Memory that this is a part of.
    struct Cyber180CM *_centralMemory;

    /// The index of this port within the Central Memory.
    int _index;

    // FIXME: Flesh out.
};


struct Cyber180CMPort * _Nullable Cyber180CMPortCreate(struct Cyber180CM * _Nonnull cm, int index)
{
    assert(cm != NULL);
    assert((index >= 0) && (index < 5));

    struct Cyber180CMPort *port = calloc(1, sizeof(struct Cyber180CMPort));

    port->_centralMemory = cm;
    port->_index = index;

    return port;
}


void Cyber180CMPortDispose(struct Cyber180CMPort * _Nullable port)
{
    if (port == NULL) return;

    free(port);
}


void Cyber180CMPortAcquireLock(struct Cyber180CMPort *port)
{
    assert(port != NULL);
    struct Cyber180CM *cm = port->_centralMemory;

    Cyber180CMAcquireLock(cm);
}


void Cyber180CMPortRelinquishLock(struct Cyber180CMPort *port)
{
    assert(port != NULL);
    struct Cyber180CM *cm = port->_centralMemory;

    Cyber180CMRelinquishLock(cm);
}


void Cyber180CMPortReadWordsPhysical(struct Cyber180CMPort *port, CyberWord32 address, CyberWord64 *buffer, CyberWord32 wordCount)
{
    assert(port != NULL);
    struct Cyber180CM *cm = port->_centralMemory;

    assert(address < cm->_capacity);
    assert((address % 8) == 0); // must be on a word boundary
    assert(buffer != NULL);
    assert((address + (wordCount * sizeof(CyberWord64))) <= cm->_capacity); // Don't allow rollover.

    Cyber180CMPortAcquireLock(port); {
        CyberWord64 *storage = cm->_storage;
        CyberWord32 firstWord = address / 8;

        for (CyberWord32 i = 0; i < wordCount; i++) {
            buffer[i] = storage[firstWord + i];
        }
    } Cyber180CMPortRelinquishLock(port);
}

void Cyber180CMPortWriteWordsPhysical(struct Cyber180CMPort *port, CyberWord32 address, CyberWord64 *buffer, CyberWord32 wordCount)
{
    assert(port != NULL);
    struct Cyber180CM *cm = port->_centralMemory;

    assert(address < cm->_capacity);
    assert((address % 8) == 0); // must be on a word boundary
    assert(buffer != NULL);
    assert((address + (wordCount * sizeof(CyberWord64))) <= cm->_capacity); // Don't allow rollover.

    Cyber180CMPortAcquireLock(port); {
        CyberWord64 *storage = cm->_storage;
        CyberWord32 firstWord = address / 8;

        for (CyberWord32 i = 0; i < wordCount; i++) {
            storage[firstWord + i] = buffer[i];
        }
    } Cyber180CMPortRelinquishLock(port);
}


void Cyber180CMPortReadBytesPhysical(struct Cyber180CMPort *port, CyberWord32 address, CyberWord8 *buffer, CyberWord32 byteCount)
{
    assert(port != NULL);
    struct Cyber180CM *cm = port->_centralMemory;

    assert(address < cm->_capacity);
    assert(buffer != NULL);
    assert((address + byteCount) <= cm->_capacity); // Don't allow rollover.

    Cyber180CMPortAcquireLock(port); {
        Cyber180CMPortReadBytesPhysical_Unlocked(port, address, buffer, byteCount);
    } Cyber180CMPortRelinquishLock(port);
}

void Cyber180CMPortWriteBytesPhysical(struct Cyber180CMPort *port, CyberWord32 address, CyberWord8 *buffer, CyberWord32 byteCount)
{
    assert(port != NULL);
    struct Cyber180CM *cm = port->_centralMemory;

    assert(address < cm->_capacity);
    assert(buffer != NULL);
    assert((address + byteCount) <= cm->_capacity); // Don't allow rollover.

    Cyber180CMPortAcquireLock(port); {
        Cyber180CMPortWriteBytesPhysical_Unlocked(port, address, buffer, byteCount);
    } Cyber180CMPortRelinquishLock(port);
}


void Cyber180CMPortReadBytesPhysical_Unlocked(struct Cyber180CMPort *port, CyberWord32 address, CyberWord8 *buffer, CyberWord32 byteCount)
{
    struct Cyber180CM *cm = port->_centralMemory;

    CyberWord64 *storage = cm->_storage;
    CyberWord32 firstWord = address / 8;
    CyberWord32 firstOffset = address % 8;
    CyberWord8 *firstByte = ((CyberWord8 *)&storage[firstWord]) + firstOffset;

    for (CyberWord32 i = 0; i < byteCount; i++) {
        buffer[i] = firstByte[i];
    }
}

void Cyber180CMPortWriteBytesPhysical_Unlocked(struct Cyber180CMPort *port, CyberWord32 address, CyberWord8 *buffer, CyberWord32 byteCount)
{
    struct Cyber180CM *cm = port->_centralMemory;

    CyberWord64 *storage = cm->_storage;
    CyberWord32 firstWord = address / 8;
    CyberWord32 firstOffset = address % 8;
    CyberWord8 *firstByte = ((CyberWord8 *)&storage[firstWord]) + firstOffset;

    for (CyberWord32 i = 0; i < byteCount; i++) {
        firstByte[i] = buffer[i];
    }
}


CyberWord64 Cyber180CMPortReadWordPhysical_Unlocked(struct Cyber180CMPort *port, CyberWord32 address)
{
    assert(port != NULL);
    struct Cyber180CM *cm = port->_centralMemory;

    assert(address < cm->_capacity);

    CyberWord64 *storage = cm->_storage;
    CyberWord32 wordIndex = address / 8;

    return storage[wordIndex];
}

void Cyber180CMPortWriteWordPhysical_Unlocked(struct Cyber180CMPort *port, CyberWord32 address, CyberWord64 word)
{
    assert(port != NULL);
    struct Cyber180CM *cm = port->_centralMemory;

    assert(address < cm->_capacity);

    CyberWord64 *storage = cm->_storage;
    CyberWord32 wordIndex = address / 8;

    storage[wordIndex] = word;
}


CYBER_SOURCE_END
