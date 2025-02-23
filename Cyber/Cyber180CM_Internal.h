//
//  Cyber180CM_Internal.h
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

#include <pthread.h>

#ifndef __CYBER_CYBER180CM_INTERNAL_H__
#define __CYBER_CYBER180CM_INTERNAL_H__

CYBER_HEADER_BEGIN


/// A Cyber180CM implements a Cyber 180 Central Memory.
///
/// The Cyber 180 Central Memory is a 64-bit memory system
struct Cyber180CM {

    /// The system that this is a part of.
    struct Cyber962 *_system;

    /// Capacity of the Central Memory.
    CyberWord32 _capacity;

    /// Storage for the Central Memory.
    CyberWord64 *_storage;

    /// Number of ports.
    int _portCount;

    /// Ports that can access this Central Memory.
    struct Cyber180CMPort * _Nonnull * _Nullable _ports;

    /// Ports can only perform memory transactions while the access lock is held.
    pthread_mutex_t _lock;

    // FIXME: Flesh out.
};


// MARK: - Port Interface

/// Acquire the port access lock.
CYBER_EXPORT void Cyber180CMAcquireLock(struct Cyber180CM *cm);

/// Relinquish the port access lock.
CYBER_EXPORT void Cyber180CMRelinquishLock(struct Cyber180CM *cm);


/// Trigger the eviction of any caches attached to ports other than the one which is associated with this address range.
///
/// When writing to a memory, this is used to tell it to tell anything attached to ports other than the one performing the write that they need to evict any cache lines covering the associated address range.
///
/// - Parameters:
///   - cm: The Central Memory being worked with.
///   - port: The port on which the eviction originated, since whatever triggers an eviction should avoid triggering itself.
///   - realMemoryAddress: The Real Memory Address of the first byte whose cache line should be evicted.
///   - count: The number of bytes whose cache lines need eviction.
///
/// - Warning: This must be invoked with the lock held, which will happen automatically by the use from within Cyber180CMPort.
CYBER_EXPORT void Cyber180CMTriggerCacheEvictionsForAddressSpan_Unlocked(struct Cyber180CM *cm, struct Cyber180CMPort *port, CyberWord32 realMemoryAddress, CyberWord32 count);


CYBER_HEADER_END

#endif /* __CYBER_CYBER180CM_INTERNAL_H__ */
