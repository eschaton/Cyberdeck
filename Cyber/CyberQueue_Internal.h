//
//  CyberQueue_Internal.h
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


#include "CyberQueue.h"

#include <pthread.h>


#ifndef __CYBER_CYBERQUEUE_INTERNAL_H__
#define __CYBER_CYBERQUEUE_INTERNAL_H__

CYBER_HEADER_BEGIN


struct CyberQueueElement;


struct CyberQueue {

    /// The element at the head of the queue.
    struct CyberQueueElement * _Nullable _head;

    /// The element at the tail of the queue.
    struct CyberQueueElement * _Nullable _tail;

    /// The queue lock.
    pthread_mutex_t _lock;

    /// The queue condition.
    pthread_cond_t _condition;
};


/// An element within a CyberQueue, which is a doubly-linked list for ease of manipulation.
struct CyberQueueElement {

    /// The next element in the list. Will be `NULL` at the tail of the queue.
    struct CyberQueueElement * _Nullable _next;

    /// The previous element in the list. Will be `NULL` at the head of the queue.
    struct CyberQueueElement * _Nullable _previous;

    /// The payload for this element.
    void * _Nullable _payload;
};


CYBER_HEADER_END

#endif /* __CYBER_CYBERQUEUE_INTERNAL_H__ */
