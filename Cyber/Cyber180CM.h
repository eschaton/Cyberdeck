//
//  Cyber180CM.h
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

#ifndef __CYBER_CYBER180CM_H__
#define __CYBER_CYBER180CM_H__

CYBER_HEADER_BEGIN


struct Cyber180CM;
struct Cyber180CMPort;
struct Cyber962;


/// Create a Cyber 180 Central Memory attached to a system.
///
/// - Parameters:
///   - system: The system to which the Central Memory is attached.
///   - capacity: The amount of memory (in bytes) to support.
///   - ports: The number of ports to support for accessing the Central Memory (minimum 2), which should be one per Central Processor and one per IOU in the system.
///
///   - Warning: Only certain capacities are allowed:
///     - 64MB (8MW)
///     - 128MB (16MW)
///     - 192MB (24MW)
///     - 256MB (32MW)
///
/// - Returns: A Central Memory to connect to the system, or `NULL` on failure.
CYBER_EXPORT struct Cyber180CM * _Nullable Cyber180CMCreate(struct Cyber962 * _Nonnull system, CyberWord32 capacity, int ports);


/// Dispose of a Cyber180CM.
CYBER_EXPORT void Cyber180CMDispose(struct Cyber180CM * _Nullable cm);


/// Get a port that can be used to access the Central Memory given an index.
CYBER_EXPORT struct Cyber180CMPort *Cyber180CMGetPortAtIndex(struct Cyber180CM *cm, int index);


CYBER_HEADER_END

#endif /* __CYBER_CYBER180CM_H__ */
