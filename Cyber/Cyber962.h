//
//  Cyber962.h
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

#ifndef __CYBER_CYBER962_H__
#define __CYBER_CYBER962_H__

CYBER_HEADER_BEGIN


struct Cyber180CP;
struct Cyber180CM;
struct Cyber962;
struct Cyber962IOU;


/// Creates a Cyber 962 system.
///
/// Creates and configures a Cyber 962 system based on the given parameters.
///
/// - Note: The number of Peripheral Processors per I/O Unit is fixed at 20.
///
/// - Parameters:
///   - identifier: Name or other human-readable identifier for the system.
///   - memorySize: Size of the Central Memory in bytes.
///   - centralProcessors: Number of Central Processors in the system, 1 or 2.
///   - inputOutputUnits: Number of Input/Output Units in the system, 1 to 3.
///
/// - Returns: A configured Cyber 962 system or `NULL` on failure.
CYBER_EXPORT struct Cyber962 * _Nullable Cyber962Create(const char * _Nonnull identifier, size_t memorySize, int centralProcessors, int inputOutputUnits);

/// Disposes of a Cyber 962 system.
CYBER_EXPORT void Cyber962Dispose(struct Cyber962 * _Nullable system);

/// Get the identifier from a Cyber 962 system; the caller must free the result.
CYBER_EXPORT char *Cyber962GetIdentifier(struct Cyber962 *system);

/// Get the Central Memory for the given Cyber 962 system.
CYBER_EXPORT struct Cyber180CM *Cyber962GetCentralMemory(struct Cyber962 *system);

/// Get the given Central Processor for the given Cyber 962 system.
CYBER_EXPORT struct Cyber180CP * _Nullable Cyber962GetCentralProcessor(struct Cyber962 *system, int index);

/// Get the given I/O Unit for the given Cyber 962 system.
CYBER_EXPORT struct Cyber962IOU * _Nullable Cyber962GetInputOutputUnit(struct Cyber962 *system, int index);


CYBER_HEADER_END

#endif /* __CYBER_CYBER962_H__ */
