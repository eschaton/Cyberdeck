//
//  Cyber180Cache.h
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

#include <Cyber/CyberTypes.h>

#ifndef __CYBER_CYBER180CACHE_H__
#define __CYBER_CYBER180CACHE_H__

CYBER_HEADER_BEGIN


struct Cyber180CP;


/// A Cyber180Cache is an instruction & data cache used by a Cyber Central Processor.
///
/// Since the Central Memory is shared and many accesses are clustered together in time, each Central Processor has a cache to reduce the need to directly access the Central Memory.
struct Cyber180Cache;


/// Create a Cyber180Cache with the given line size and line count.
CYBER_EXPORT struct Cyber180Cache * _Nullable Cyber180CacheCreate(struct Cyber180CP *cp);

/// Dispose of a Cyber180Cache.
CYBER_EXPORT void Cyber180CacheDispose(struct Cyber180Cache * _Nullable cc);


/// Clear the cache.
CYBER_EXPORT void Cyber180CacheClear(struct Cyber180Cache *cc);


/// Add or update a line in the cache along with its use count.
///
/// Either adds a line to the cache, evicting the least recently used line, or updates the existing line in the cache to contain the given data.
///
/// The cache's use count and the affected line's use count are both updated.
///
/// - Parameters:
///   - cc: the cache being used
///   - realMemoryAddress: the address to add or update, must be aligned to ``Cyber180CacheLineSize`` bytes
///   - contents: the values for the given cache line
///
CYBER_EXPORT void Cyber180CacheAddOrUpdateDataForAddress(struct Cyber180Cache *cc, CyberWord32 realMemoryAddress, CyberWord8 *contents);


/// Get any data from the cache for the given real memory address, returning `true` if successful or `false` if that data is not in the cache.
CYBER_EXPORT bool Cyber180CacheGetDataForAddress(struct Cyber180Cache *cc, CyberWord32 realMemoryAddress, CyberWord8 *contents);


/// Evict data from the cache for the given real memory address, if any exists.
CYBER_EXPORT void Cyber180CacheEvictAddress(struct Cyber180Cache *cc, CyberWord32 realMemoryAddress);


/// Number of bytes in a cache line.
#define Cyber180CacheLineSize 64


/// Number of cache lines in a cache.
#define Cyber180CacheLineCount 512


/// Get the cache line address that would contain the given real memory address.
static inline CyberWord32 Cyber180CacheGetLineAddressForAddress(CyberWord32 realMemoryAddress)
{
    return realMemoryAddress & ~(Cyber180CacheLineSize - 1);
}


/// Get the cache line offset for the byte identified by the given real memory address.
static inline CyberWord32 Cyber180CacheGetLineOffsetForAddress(CyberWord32 realMemoryAddress)
{
    return realMemoryAddress & (Cyber180CacheLineSize - 1);
}


CYBER_HEADER_END

#endif /* __CYBER_CYBER180CACHE_H__ */

