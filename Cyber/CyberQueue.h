//
//  CyberQueue.h
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

#ifndef __CYBER_CYBERQUEUE_H__
#define __CYBER_CYBERQUEUE_H__ 1

CYBER_HEADER_BEGIN


/// A CyberQueue is a first-in first-out queue of elements (repersented as a `void *` that is safe to use from multiple threads.
///
/// - Warning: The only disallowed value as a queue element payload is `NULL`.
struct CyberQueue;


/// Creates a first-in, first-out queue protected by a lock.
CYBER_EXPORT struct CyberQueue * _Nullable CyberQueueCreate(void);

/// Disposes of a CyberQueue.
CYBER_EXPORT void CyberQueueDispose(struct CyberQueue * _Nullable q);


/// Add a new item to a CyberQueue.
CYBER_EXPORT void CyberQueueEnqueue(struct CyberQueue *q, void *element);

/// Get an element from a CyberQueue, blocking if there isn't one.
CYBER_EXPORT void *CyberQueueDequeue(struct CyberQueue *q);

/// Attempt to get an element from a CyberQueue, returning `NULL` if there isn't one.
CYBER_EXPORT void * _Nullable CyberQueueTryDequeue(struct CyberQueue *q);


CYBER_HEADER_END

#endif /* __CYBER_CYBERQUEUE_H__ */
