//
//  Cyber962IOChannel.h
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

#include <stdbool.h>

#ifndef __CYBER_Cyber962IOChannel_H__
#define __CYBER_Cyber962IOChannel_H__

CYBER_HEADER_BEGIN


struct Cyber962IOChannel;
struct Cyber962IOU;


/// Create a Cyber 180-style I/O Channel.
///
/// A Cyber 180 I/O channel is a 12- or 16-bit channel that can transfer 12-bit or 16-bit words asynchronously.
///
/// Each channel is implemented by a set of functions and an associated context pointer, which are used to implement devices.
CYBER_EXPORT struct Cyber962IOChannel * _Nullable Cyber962IOChannelCreate(struct Cyber962IOU *inputOutputUnit, int index);


/// Dispose of a Cyber962IOChannel.
CYBER_EXPORT void Cyber962IOChannelDispose(struct Cyber962IOChannel * _Nullable ioc);


/// Get the index of a
CYBER_EXPORT int Cyber962IOChannelGetIndex(struct Cyber962IOChannel *ioc);


/// I/O functions for a channel.
struct Cyber962IOChannelFunctions {

    /// The read function for the channel.
    ///
    /// - Returns: The number of words read.
    CyberWord32 (*readFunction)(struct Cyber962IOChannel *ioc, void *context, CyberWord16 *buffer, CyberWord32 count);

    /// The write function for the channel.
    ///
    /// - Returns: The number of words written.
    CyberWord32 (*writeFunction)(struct Cyber962IOChannel *ioc, void *context, CyberWord16 *buffer, CyberWord32 count);

    /// The control function for the channel.
    void (*controlFunction)(struct Cyber962IOChannel *ioc, void *context, CyberWord16 word);

    /// The check-state function for the channel.
    ///
    /// A function that the channel can call to request a device implementation check the channel state and make any necessary adjustments.
    /// For example, a Peripheral Processor may change some channel state during a read or write, whcih may affect whether the read or write continues or terminates early.
    void (*checkStateFunction)(struct Cyber962IOChannel *ioc, void *context);

    /// A pointer to any additional context needed by the channel implementation, whcih will be passed to the channel fucntions.
    void *context;
};


/// Indicates whether the channel is active or inactive.
CYBER_EXPORT bool Cyber962IOChannelIsActive(struct Cyber962IOChannel *ioc);

/// Indicates whether the channel is full or "empty" (not-full).
CYBER_EXPORT bool Cyber962IOChannelIsFull(struct Cyber962IOChannel *ioc);

/// Indicates the state of the channel's flag.
CYBER_EXPORT bool Cyber962IOChannelHasFlag(struct Cyber962IOChannel *ioc);

/// Indicates whether the channel has encountered an error.
CYBER_EXPORT bool Cyber962IOChannelHasError(struct Cyber962IOChannel *ioc);


/// Set the functions to use to handle I/O on this channel.
///
/// To remove the functions currently implementing a channel, pass `NULL`.
CYBER_EXPORT void Cyber962IOChannelSetFunctions(struct Cyber962IOChannel *ioc, struct Cyber962IOChannelFunctions * _Nullable functions);


CYBER_HEADER_END

#endif /* __CYBER_Cyber962IOChannel_H__ */
