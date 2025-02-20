//
//  Cyber180Cache_Internal.h
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

#include <Cyber/Cyber180Cache.h>


#ifndef __CYBER_CYBER180CACHE_INTERNAL_H__
#define __CYBER_CYBER180CACHE_INTERNAL_H__

CYBER_HEADER_BEGIN


/// One line in a ``Cyber180Cache``.
struct Cyber180CacheLine {

    /// The real memory address for this cache line.
    CyberWord32 _address;

    /// The last-used point for this cache line, based on a monotonically-increasing count of accesses.
    CyberWord32 _lastUse;
    
    /// The contents of the cache line.
    CyberWord8 _words[64];
} CYBER_PACKED;


struct Cyber180Cache {
    
    /// The cache lines themselves.
    struct Cyber180CacheLine *_lines;

    /// The Central Processor of which this cache is a component.
    ///
    /// - Note: This is ordered after the lines, since those are what will be most commonly accessed.
    struct Cyber180CP *_cp;

    /// The use counter for the cache, from which the `_lastUse` of a ``Cyber180CacheLine`` is set.
    CyberWord16 _uses;
};


/// Get the cache line, if any, that covers the given real memory address.
///
/// - Parameters:
///   - cc: the cache being used
///   - realMemoryAddress: the real memory address we're hoping is in the cache
///
/// - Returns: The cache line that covers the given real memory address, or `NULL` if there is none.
CYBER_EXPORT struct Cyber180CacheLine * _Nullable Cyber180CacheGetCacheLineForAddress(struct Cyber180Cache *cc, CyberWord32 realMemoryAddress);


CYBER_HEADER_END

#endif /* __CYBER_CYBER180CACHE_INTERNAL_H__ */
