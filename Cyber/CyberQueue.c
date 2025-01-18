//
//  CyberQueue.c
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

#include "CyberQueue_Internal.h"

#include <assert.h>
#include <stdlib.h>


CYBER_SOURCE_BEGIN


struct CyberQueue * _Nullable CyberQueueCreate(void)
{
    struct CyberQueue *q = calloc(1, sizeof(struct CyberQueue));

    int mutex_err = pthread_mutex_init(&q->_lock, NULL);
    if (mutex_err != 0) {
        assert(mutex_err != 0); // halt here in debug builds
        CyberQueueDispose(q);
        return NULL;
    }

    int cond_err = pthread_cond_init(&q->_condition, NULL);
    if (cond_err != 0) {
        assert(cond_err != 0); // halt here in debug builds
        CyberQueueDispose(q);
        return NULL;
    }

    return q;
}

void CyberQueueDispose(struct CyberQueue * _Nullable q)
{
    if (q == NULL) return;

    (void) pthread_mutex_destroy(&q->_lock);
    (void) pthread_cond_destroy(&q->_condition);

    free(q);
}


void CyberQueueEnqueue(struct CyberQueue *q, void *element)
{
    assert(q != NULL);
    assert(element != NULL);

    // Items are enqueued at the head, dequeued at the tail.

    struct CyberQueueElement *qe = calloc(1, sizeof(struct CyberQueueElement));
    assert(qe != NULL);

    qe->_payload = element;

    pthread_mutex_lock(&q->_lock); {
        qe->_next = q->_head;
        qe->_previous = NULL;

        q->_head = qe;
        if (q->_tail == NULL) q->_tail = qe;
        if (qe->_next != NULL) qe->_next->_previous = qe;

        (void) pthread_cond_signal(&q->_condition);
    } pthread_mutex_unlock(&q->_lock);
}

void *CyberQueueDequeue(struct CyberQueue *q)
{
    assert(q != NULL);

    struct CyberQueueElement *qe = NULL;

    pthread_mutex_lock(&q->_lock); {
        while (qe == NULL) {
            pthread_cond_wait(&q->_condition, &q->_lock);
            qe = q->_tail;
        }

        q->_tail = qe->_previous;
        if (qe->_previous != NULL) qe->_previous->_next = NULL;
    } pthread_mutex_unlock(&q->_lock);

    void *result = qe->_payload;
    free(qe);

    return result;
}

void * _Nullable CyberQueueTryDequeue(struct CyberQueue *q)
{
    assert(q != NULL);

    struct CyberQueueElement *qe = NULL;

    if (pthread_mutex_trylock(&q->_lock) == 0) {
        qe = q->_tail;

        if (qe) {
            q->_tail = qe->_previous;
            if (qe->_previous != NULL) qe->_previous->_next = NULL;
        }

        pthread_mutex_unlock(&q->_lock);
    }

    void *result;

    if (qe != NULL) {
        result = qe->_payload;
        free(qe);
    } else {
        result = NULL;
    }

    return result;
}


CYBER_SOURCE_END
