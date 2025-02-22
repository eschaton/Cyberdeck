//
//  Cyber180CMPort_Internal.h
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

#ifndef __CYBER_CYBER180CMPORT_INTERNAL_H__
#define __CYBER_CYBER180CMPORT_INTERNAL_H__

CYBER_HEADER_BEGIN


struct CyberQueue;


/// A Cyber180CMPort provides an access port to a Central Memory.
struct Cyber180CMPort {

    /// The Central Memory that this is a part of.
    struct Cyber180CM *_centralMemory;

    /// The index of this port within the Central Memory.
    int _index;

    /// The queue of cache line address ranges that need eviction, if any.
    struct CyberQueue * _Nullable _cacheEvictionQueue;
};


/// An entry in the cache eviction queue.
struct Cyber180CacheEvictionRange {
    /// The first affected cache line's real memory address.
    CyberWord32 _startLineAddress;

    /// The number of lines covered by this eviction range.
    CyberWord32 _lineCount;
};


/// Trigger a cache eviction for the given line range, if the port has an eviction queue.
CYBER_EXPORT void Cyber180CMPortTriggerCacheEvictionsForCacheLineRange(struct Cyber180CMPort *port, CyberWord32 startLineAddress, CyberWord32 lineCount);


CYBER_HEADER_END

#endif /* __CYBER_CYBER180CMPORT_INTERNAL_H__ */
