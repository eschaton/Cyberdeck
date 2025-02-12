//
//  Cyber180CP_Internal.h
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

#include <Cyber/Cyber180CP.h>

#include "CyberState.h"

#include <pthread.h>

#ifndef __CYBER_CYBER180CP_INTERNAL_H__
#define __CYBER_CYBER180CP_INTERNAL_H__

CYBER_HEADER_BEGIN


struct CyberThread;


struct Cyber180CP {

    /// The system that this is a part of.
    struct Cyber962 *_system;

    /// Index of this Cyber 180 Central Processor within the system.
    int _index;

    /// The port that this Central Processor can use to access Central Memory.
    struct Cyber180CMPort *_centralMemoryPort;

    /// The thread that represents this Central Processor.
    struct CyberThread *_thread;

    // Registers

    // TODO: Add register definitions.

    // FIXME: Flesh out.
};


CYBER_HEADER_END

#endif /* __CYBER_CYBER180CP_INTERNAL_H__ */
