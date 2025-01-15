//
//  Cyber962IOChannel_Internal.h
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

#include <Cyber/Cyber962IOChannel.h>

#ifndef __CYBER_Cyber962IOChannel_INTERNAL_H__
#define __CYBER_Cyber962IOChannel_INTERNAL_H__

CYBER_HEADER_BEGIN


/// A Cyber 180 I/O Channel.
///
/// An I/O channel can be 8 or 16 bits wide and has the following state flags:
/// - inactive/active
/// - empty/full
/// - flag
/// - error
struct Cyber962IOChannel {

    /// The I/O Unit this I/O Channel is a part of.
    struct Cyber962IOU *_inputOutputUnit;

    /// The index of this I/O Channel in the I/O Unit.
    int _index;

    /// Whether the channel is active or inactive.
    bool _active;

    /// Whether the channel is full or empty.
    bool _full;

    /// Whether a flag has been set on the channel.
    bool _flag;

    /// Whether the channel has encountered an error.
    bool _error;

    /// The functions used for this channel.
    struct Cyber962IOChannelFunctions *_functions;

    // TODO: Flesh out.
};


CYBER_HEADER_END

#endif /* __CYBER_Cyber962IOChannel_INTERNAL_H__ */
