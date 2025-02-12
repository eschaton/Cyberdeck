//
//  CyberThread_Internal.h
//  Cyber
//
//  Copyright © 2025 Christopher M. Hanson. All rights reserved.
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

#include "CyberThread.h"

#include <pthread.h>

#ifndef __CYBER_CYBERTHREAD_INTERNAL_H__
#define __CYBER_CYBERTHREAD_INTERNAL_H__

CYBER_HEADER_BEGIN


/// The current state of the thread.
enum CyberThreadState {
    CyberThreadState_Stopped = 0,
    CyberThreadState_Started,
    CyberThreadState_Running,
    CyberThreadState_Terminated,
};


struct CyberThread {

    /// The POSIX thread backing this CyberThread.
    pthread_t _pthread;

    /// The name of this CyberThread.
    const char * _name;

    /// The developer-supplied context for this CyberThread.
    void * _Nullable _context;

    /// The state of this thread, wrapping a ``CyberThreadState``.
    struct CyberState *_state;

    /// The functions called by this thread, copied into place at creation.
    struct CyberThreadFunctions _functions;
};


CYBER_HEADER_END

#endif /* __CYBER_CYBERTHREAD_INTERNAL_H__ */
