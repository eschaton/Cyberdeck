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


/// The current running state of a Cyber 180 Central Processor.
///
/// A Cyber 180 Central Processor can be in one of three states:
/// - Halted, not running but able to run.
/// - Running, running and able to either halt or shut down.
/// - Shutdown, no longer running and requiring a deadstart to recover.
enum Cyber180CPState {
    /// The Peripheral Processor is halted.
    Cyber180CPState_Halted = 0,

    /// The Peripheral Processor is running.
    Cyber180CPState_Running = 1,

    /// The Peripheral Processor is shutting down, with no resumption possible.
    Cyber180CPState_Shutdown = 2,
};


struct Cyber180CP {

    /// The system that this is a part of.
    struct Cyber962 *_system;

    /// Index of this Cyber 180 Central Processor within the system.
    int _index;

    /// The port that this Central Processor can use to access Central Memory.
    struct Cyber180CMPort *_centralMemoryPort;

    /// The thread that represents this Central Processor.
    pthread_t _thread;

    /// The runtime state of this Central Processor.
    ///
    /// - Note: The payload is a Cyber180CPState.
    struct CyberState *_state;

    // Registers

    // TODO: Add register definitions.

    // FIXME: Flesh out.
};


CYBER_HEADER_END

#endif /* __CYBER_CYBER180CP_INTERNAL_H__ */
