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


/// The operating mode of a Central Process.
enum Cyber180CPMode {

    /// The "normal" operating mode of a CP is "job" mode, where it executs a sequence of instructions.
    Cyber180CPModeJob = 0,

    /// The operating system itself runs in "monitor" mode, to control the loading, scheduling, execution, and output of user jobs.
    Cyber180CPModeMonitor = 1,
};


struct Cyber180CP {

    /// The system that this is a part of.
    struct Cyber962 *_system;

    /// Index of this Cyber 180 Central Processor within the system.
    int _index;

    /// The port that this Central Processor can use to access Central Memory.
    struct Cyber180CMPort *_centralMemoryPort;

    /// The thread that represents this Central Processor.
    struct CyberThread *_thread;

    /// The current operating mode of this Central Processor.
    enum Cyber180CPMode _mode;

    // Registers

    /// Program Address Register (program counter), 64 bits
    CyberWord64 _regP;

    /// Address Registers, 48 bits
    CyberWord48 _regA[16];

    /// Operand Registers, 64 bits
    CyberWord64 _regX[16];

    // FIXME: Flesh out register set.

    // Caching

    // FIXME: Flesh out cache.
};


/// Get the value of the Ai register.
CYBER_EXPORT CyberWord48 Cyber180CPGetA(struct Cyber180CP *cp, int i);

/// Set the value of the Xi register.
CYBER_EXPORT void Cyber180CPSetA(struct Cyber180CP *cp, int i, CyberWord48 value);

/// Get the value of the Xi register.
CYBER_EXPORT CyberWord64 Cyber180CPGetX(struct Cyber180CP *cp, int i);

/// Get the value of the Xi register, or 0 for X0.
CYBER_EXPORT CyberWord64 Cyber180CPGetXOr0(struct Cyber180CP *cp, int i);

/// Set the value of the Xi register.
CYBER_EXPORT void Cyber180CPSetX(struct Cyber180CP *cp, int i, CyberWord64 value);


/// Translate a virtual address to a physical address.
CYBER_EXPORT CyberWord64 Cyber180CPTranslateAddress(struct Cyber180CP *cp, CyberWord64 virtualAddress);


/// Write bytes to a virtual address.
CYBER_EXPORT void Cyber180CPWriteBytes(struct Cyber180CP *cp, CyberWord64 virtualAddress, CyberWord8 *buf, CyberWord32 count);

/// Read bytes from a virtual address.
CYBER_EXPORT void Cyber180CPReadBytes(struct Cyber180CP *cp, CyberWord64 virtualAddress, CyberWord8 *buf, CyberWord32 count);


CYBER_HEADER_END

#endif /* __CYBER_CYBER180CP_INTERNAL_H__ */
