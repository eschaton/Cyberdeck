//
//  Cyber962IOU.h
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

#ifndef __CYBER_CYBER962IOU_H__
#define __CYBER_CYBER962IOU_H__

CYBER_HEADER_BEGIN


struct Cyber180CMPort;
struct Cyber962IOChannel;
struct Cyber962;
struct Cyber962IOU;
struct Cyber962PP;


/// Create a Cyber 962 Input/Output Unit connected to a system.
///
/// - Parameters:
///   - system: The system to which the Central Processor is attached.
///   - index: The index of this Input/Output Unit in the system.
///
/// - Returns: An I/O Unit connected to the system, or `NULL` on failure.
///
/// - Note: An IOU is assumed to be fully-populated, thus no choice is available in how many Peripheral Processors or channels it supports.
CYBER_EXPORT struct Cyber962IOU * _Nullable Cyber962IOUCreate(struct Cyber962 * _Nonnull system, int index);


/// Dispose of a Cyber962IOU.
CYBER_EXPORT void Cyber962IOUDispose(struct Cyber962IOU * _Nullable iou);


/// Gets the Cyber 962 Peripheral Processor at the given index.
///
/// - Note: An IOU is assumed to be fully-populated, thus there's no need to figure out how many Peripheral Processors or channels it supports.
CYBER_EXPORT struct Cyber962PP *Cyber962IOUGetPeripheralProcessor(struct Cyber962IOU *iou, int index);


/// Gets the Central Memory port that can be used by this IOU to access the Central Memory.
CYBER_EXPORT struct Cyber180CMPort *Cyber962IOUGetCentralMemoryPort(struct Cyber962IOU *iou);


/// Gets the I/O Channel with the given index.
CYBER_EXPORT struct Cyber962IOChannel *Cyber962IOUGetIOChannelAtIndex(int index);


CYBER_HEADER_END

#endif /* __CYBER_CYBER180CM_H__ */
