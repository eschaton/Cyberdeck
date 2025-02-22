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

#include "Cyber180CMPort_Internal.h"

#include "Cyber180CM_Internal.h"
#include "CyberQueue.h"

#include <assert.h>
#include <stdlib.h>
#include <string.h>


CYBER_SOURCE_BEGIN


struct Cyber180CMPort * _Nullable Cyber180CMPortCreate(struct Cyber180CM * _Nonnull cm, int index, bool hasCacheEvictionQueue)
{
    assert(cm != NULL);
    assert((index >= 0) && (index < 5));

    struct Cyber180CMPort *port = calloc(1, sizeof(struct Cyber180CMPort));

    port->_centralMemory = cm;
    port->_index = index;

    port->_cacheEvictionQueue = CyberQueueCreate();

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

    memcpy(buffer, firstByte, byteCount);
}

void Cyber180CMPortWriteBytesPhysical_Unlocked(struct Cyber180CMPort *port, CyberWord32 address, CyberWord8 *buffer, CyberWord32 byteCount)
{
    struct Cyber180CM *cm = port->_centralMemory;

    CyberWord64 *storage = cm->_storage;
    CyberWord32 firstWord = address / 8;
    CyberWord32 firstOffset = address % 8;
    CyberWord8 *firstByte = ((CyberWord8 *)&storage[firstWord]) + firstOffset;

    memcpy(firstByte, buffer, byteCount);

    Cyber180CMTriggerCacheEvictionsForAddressSpan_Unlocked(cm, port, address, byteCount);
}

void Cyber180CMPortTriggerCacheEvictionsForCacheLineRange(struct Cyber180CMPort *port, CyberWord32 startLineAddress, CyberWord32 lineCount)
{
    assert(port != NULL);

    if (port->_cacheEvictionQueue) {
        struct Cyber180CacheEvictionRange *range = calloc(1, sizeof(struct Cyber180CacheEvictionRange));
        range->_startLineAddress = startLineAddress;
        range->_lineCount = lineCount;

        CyberQueueEnqueue(port->_cacheEvictionQueue, range);
    }
}

CYBER_SOURCE_END
