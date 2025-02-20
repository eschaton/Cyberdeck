//
//  Cyber180Cache.c
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

#include "Cyber180Cache_Internal.h"

#include <assert.h>
#include <stdlib.h>
#include <string.h>


CYBER_SOURCE_BEGIN


struct Cyber180Cache * _Nullable Cyber180CacheCreate(struct Cyber180CP *cp)
{
    assert(cp != NULL);

    struct Cyber180Cache *cc = calloc(1, sizeof(struct Cyber180Cache));

    cc->_lines = calloc(Cyber180CacheLineCount, sizeof(struct Cyber180CacheLine));
    cc->_cp = cp;

    return cc;
}


void Cyber180CacheDispose(struct Cyber180Cache * _Nullable cc)
{
    if (cc == NULL) return;

    free(cc->_lines);
    free(cc);
}


void Cyber180CacheClear(struct Cyber180Cache *cc)
{
    assert(cc != NULL);

    memset(cc->_lines, 0, Cyber180CacheLineCount * sizeof(struct Cyber180Cache));
}


static inline CyberWord32 Cyber180CacheUpdateUses(struct Cyber180Cache *cc)
{
    assert(cc != NULL);

    cc->_uses += 1;
    return cc->_uses;
}


struct Cyber180CacheLine * _Nullable Cyber180CacheGetCacheLineForAddress(struct Cyber180Cache *cc, CyberWord32 realMemoryAddress)
{
    struct Cyber180CacheLine * _Nullable result = NULL;

    assert(cc != NULL);

    // Since the cache is being used (accessed), update its use count.

    const CyberWord32 uses = Cyber180CacheUpdateUses(cc);

    // Go through the cache until we find a line or fall off the end.

    CyberWord32 cacheAddress = Cyber180CacheGetLineAddressForAddress(realMemoryAddress);
    for (int i = 0; i < Cyber180CacheLineCount; i++) {
        if (cc->_lines[i]._address == cacheAddress) {
            cc->_lines[i]._lastUse = uses;
            result = &cc->_lines[i];
            break;
        }
    }

    return result;
}


void Cyber180CacheAddOrUpdateDataForAddress(struct Cyber180Cache *cc, CyberWord32 realMemoryAddress, CyberWord8 *contents)
{
    assert(cc != NULL);
    assert(Cyber180CacheGetLineOffsetForAddress(realMemoryAddress) == 0);
    assert(contents != NULL);

    // Since the cache is being used (updated), update its use count.

    const CyberWord32 uses = Cyber180CacheUpdateUses(cc);

    // Get either the least recently-used line or the line that matches the given address, if any.

    const CyberWord32 lineAddress = Cyber180CacheGetLineAddressForAddress(realMemoryAddress);

    struct Cyber180CacheLine * _Nullable leastRecentlyUsedLine = NULL;
    CyberWord32 leastRecentUse = 0xFFFFFFFF;

    for (int i = 0; i < Cyber180CacheLineCount; i++) {

        // If we find a match for the line address, stop looking.

        if (cc->_lines[i]._address == lineAddress) {
            leastRecentlyUsedLine = &cc->_lines[i];
            break;
        }

        // If we don't find a match for the line address, find the least recently used line within the cache.

        if (cc->_lines[i]._lastUse < leastRecentUse) {
            leastRecentUse = cc->_lines[i]._lastUse;
            leastRecentlyUsedLine = &cc->_lines[i];
        }
    }

    // Handle the case where there wasn't a least-recently used line.

    if (leastRecentlyUsedLine == NULL) leastRecentlyUsedLine = &cc->_lines[0];

    // Copy the new contents into the line.

    memcpy(leastRecentlyUsedLine->_words, contents, Cyber180CacheLineSize);

    // Update the line's use count.

    leastRecentlyUsedLine->_lastUse = uses;
}


bool Cyber180CacheGetDataForAddress(struct Cyber180Cache *cc, CyberWord32 realMemoryAddress, CyberWord8 *contents)
{
    assert(cc != NULL);
    assert(Cyber180CacheGetLineOffsetForAddress(realMemoryAddress) == 0);
    assert(contents != NULL);

    struct Cyber180CacheLine * _Nullable cacheLine = Cyber180CacheGetCacheLineForAddress(cc, realMemoryAddress);

    if (cacheLine) {
        const CyberWord32 uses = Cyber180CacheUpdateUses(cc);
        cacheLine->_lastUse = uses;
        memcpy(contents, cacheLine->_words, Cyber180CacheLineSize);
        return true;
    } else {
        return false;
    }
}


void Cyber180CacheEvictAddress(struct Cyber180Cache *cc, CyberWord32 realMemoryAddress)
{
    assert(cc != NULL);
    assert(Cyber180CacheGetLineOffsetForAddress(realMemoryAddress) == 0);

    struct Cyber180CacheLine * _Nullable cacheLine = Cyber180CacheGetCacheLineForAddress(cc, realMemoryAddress);

    if (cacheLine) {
        cacheLine->_address = 0x00000000;
        cacheLine->_lastUse = 0;
        memset(cacheLine->_words, 0, Cyber180CacheLineSize);
    }
}


CYBER_SOURCE_END
