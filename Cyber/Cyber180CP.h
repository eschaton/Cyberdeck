//
//  CentralProcessor.h
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

#ifndef __CYBER_CYBER180CP_H__
#define __CYBER_CYBER180CP_H__

CYBER_HEADER_BEGIN


struct Cyber962;
struct Cyber180CMPort;


/// A Cyber180CP implements a Cyber 180 Central Processor.
///
/// The Cyber 180 Central Processor is a 64-bit processor with:
///
/// - Byte rather than word addressing
/// - Two's complement rather than one's complement representation
/// - 16 X registers of 64 bits each
/// - 16 A registers of 48 bits each
/// - A "4096 times 2^31" byte user address space
///
/// The Cyber uses IBM-style bit numbering; that is, bit 0 is the "leftmost" (most significant) bit in a word.
struct Cyber180CP;


/// Create a Cyber 180 Central Processor attached to a system.
///
/// - Parameters:
///   - system: The system to which the Central Processor is attached.
///   - index: The index of the Central Processor within the system, must be 0 or 1.
///
/// - Returns: A configured Central Processor to connect to the system, or `NULL` on failure.
CYBER_EXPORT struct Cyber180CP * _Nullable Cyber180CPCreate(struct Cyber962 * _Nonnull system, int index);


/// Dispose of a Cyber180CP.
CYBER_EXPORT void Cyber180CPDispose(struct Cyber180CP * _Nullable cp);


/// Start this Central Processor.
CYBER_EXPORT void Cyber180CPStart(struct Cyber180CP *cp);

/// Stop this Central Processor.
CYBER_EXPORT void Cyber180CPStop(struct Cyber180CP *cp);

/// Shut down this Central Processor.
CYBER_EXPORT void Cyber180CPShutDown(struct Cyber180CP *cp);


/// Gets the Central Memory port that can be used by this Central Processor to access the Central Memory.
CYBER_EXPORT struct Cyber180CMPort * _Nonnull Cyber180CPGetCentralMemoryPort(struct Cyber180CP *cp);

/// Sets the Central Memory port that this Central Processor can use to access the Central Memory.
CYBER_EXPORT void Cyber180CPSetCentralMemoryPort(struct Cyber180CP *cp, struct Cyber180CMPort *port);


CYBER_HEADER_END

#endif /* __CYBER_CYBER180CP_H__ */
