//
//  Cyber180CMPort.h
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

#ifndef __CYBER_CYBER180CMPORT_H__
#define __CYBER_CYBER180CMPORT_H__

CYBER_HEADER_BEGIN


struct Cyber180CM;
struct Cyber180CMPort;


/// Create a Cyber 180 Central Memory access port and let it know its index.
CYBER_EXPORT struct Cyber180CMPort * _Nullable Cyber180CMPortCreate(struct Cyber180CM *cm, int index);

/// Dispose of a Cyber 180 Central Memory access port.
CYBER_EXPORT void Cyber180CMPortDispose(struct Cyber180CMPort * _Nullable port);


/// Lock access to the CM via this and other ports.
CYBER_EXPORT void Cyber180CMPortAcquireLock(struct Cyber180CMPort *port);

/// Unlock access to the CM via this and other ports.
CYBER_EXPORT void Cyber180CMPortRelinquishLock(struct Cyber180CMPort *port);


/// Read words from physical memory into a buffer.
///
/// - Warning: This acquires and holds the port access lock.
CYBER_EXPORT void Cyber180CMPortReadWordsPhysical(struct Cyber180CMPort *port, CyberWord48 address, CyberWord64 *buffer, CyberWord32 wordCount);

/// Write words from a buffer to physical memory.
///
/// - Warning: This acquires and holds the port access lock.
CYBER_EXPORT void Cyber180CMPortWriteWordsPhysical(struct Cyber180CMPort *port, CyberWord48 address, CyberWord64 *buffer, CyberWord32 wordCount);

/// Read bytes from physical memory into a buffer.
///
/// - Warning: This acquires and holds the port access lock.
CYBER_EXPORT void Cyber180CMPortReadBytesPhysical(struct Cyber180CMPort *port, CyberWord48 address, CyberWord8 *buffer, CyberWord32 byteCount);

/// Write bytes from a buffer to physical memory.
///
/// - Warning: This acquires and holds the port access lock.
CYBER_EXPORT void Cyber180CMPortWriteBytesPhysical(struct Cyber180CMPort *port, CyberWord48 address, CyberWord8 *buffer, CyberWord32 byteCount);


/// Read a word from physical memory, without holding a lock.
///
/// - Warning: This **DOES NOT** acquires and holds the port access lock itself.
CYBER_EXPORT CyberWord64 Cyber180CMPortReadWordPhysical_Unlocked(struct Cyber180CMPort *port, CyberWord48 address);

/// Write a word to physical memory, without hodling a lock.
///
/// - Warning: This **DOES NOT** acquires and holds the port access lock itself.
CYBER_EXPORT void Cyber180CMPortWriteWordPhysical_Unlocked(struct Cyber180CMPort *port, CyberWord48 address, CyberWord64 word);


CYBER_HEADER_END

#endif /* __CYBER_CYBER180CMPORT_H__ */
