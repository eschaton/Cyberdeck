//
//  Cyber962IOU_Internal.h
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

#include <Cyber/Cyber962IOU.h>

#ifndef __CYBER_CYBER962IOU_INTERNAL_H__
#define __CYBER_CYBER962IOU_INTERNAL_H__

CYBER_HEADER_BEGIN


/// A Cyber962IOU implements a Cyber 962 Input/Output Unit.
///
/// Each Cyber 962 Input/Output Unit has:
///
/// - 5-20 Peripheral Processors
/// - 5-20 I/O channels
struct Cyber962IOU {

    /// The system that this is a part of.
    struct Cyber962 *_system;

    /// Index of this Input/Output Unit in the system.
    int _index;

    /// This Input/Output Unit's Peripheral Processors.
    struct Cyber962PP * _Nullable _peripheralProcessors[20];

    /// This Input/Output Unit's Central Memory port.
    struct Cyber180CMPort * _Nonnull _centralMemoryPort;

    /// The Input/Output Unit's Input/Output Channels.
    struct Cyber962IOChannel * _Nonnull _inputOutputChannels[20];

    // TODO: Flesh out.
};


/// Sets the Central Memory port that this IOU can use to access the Central Memory.
CYBER_EXPORT void Cyber962IOUSetCentralMemoryPort(struct Cyber962IOU *iou, struct Cyber180CMPort *port);


CYBER_HEADER_END

#endif /* __CYBER_CYBER962IOU_INTERNAL_H__ */
