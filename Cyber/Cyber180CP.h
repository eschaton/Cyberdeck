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


struct Cyber180CP;
struct Cyber962;


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


CYBER_HEADER_END


#endif /* __CYBER_CYBER180CP_H__ */