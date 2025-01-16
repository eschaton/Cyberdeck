//
//  Cyber962PP.h
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

#ifndef __CYBER_CYBER962PP_H__
#define __CYBER_CYBER962PP_H__

CYBER_HEADER_BEGIN


struct Cyber962IOU;
struct Cyber962PP;


/// Create a Cyber 962 Peripheral Processor connected to an Input/Output Unit.
///
/// - Parameters:
///   - inputOutputUnit: The Input/Output Unit to which this Peripheral Processor is attached.
///   - index: The index of this Peripheral Processor in the Input/Output Unit.
///
/// - Returns: A Peripheral Processor connected to the Input/Output Unit, or `NULL` on failure.
CYBER_EXPORT struct Cyber962PP * _Nullable Cyber962PPCreate(struct Cyber962IOU *inputOutputUnit, int index);


/// Dispose of a Cyber 962 Peripheral Processor.
CYBER_EXPORT void Cyber962PPDispose(struct Cyber962PP * _Nullable pp);


/// Reset the given Cyber 962 Peripheral Processor.
CYBER_EXPORT void Cyber962PPReset(struct Cyber962PP *pp);

/// Start the Peripheral Processor.
CYBER_EXPORT void Cyber962PPStart(struct Cyber962PP *pp);

/// Stop the Peripheral Processor.
CYBER_EXPORT void Cyber962PPStop(struct Cyber962PP *pp);

/// Shut down the Peripheral Processor because the system is shutting down.
CYBER_EXPORT void Cyber962PPShutdown(struct Cyber962PP *pp);


CYBER_HEADER_END

#endif /* __CYBER_CYBER962PP_H__ */
