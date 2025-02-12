//
//  CyberState_Internal.h
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

#include "CyberState.h"

#include <pthread.h>

#ifndef __CYBER_CYBERSTATE_INTERNAL_H__
#define __CYBER_CYBERSTATE_INTERNAL_H__

CYBER_HEADER_BEGIN


struct CyberState {
    int _value;
    pthread_mutex_t _mutex;
    pthread_cond_t _condition;
};


CYBER_HEADER_END

#endif /* __CYBER_CYBERSTATE_INTERNAL_H__ */
