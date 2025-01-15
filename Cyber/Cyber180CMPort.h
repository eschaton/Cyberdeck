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


/// Read words from physical memory into a buffer.
///
/// - Warning: The port access lock must be held around calls to this function.
CYBER_EXPORT void Cyber180CMPortReadWordsPhysical(struct Cyber180CMPort *port, CyberWord48 address, CyberWord64 *buffer, CyberWord32 wordCount);

/// Write words from a buffer to physical memory.
///
/// - Warning: The port access lock must be held around calls to this function.
CYBER_EXPORT void Cyber180CMPortWriteWordsPhysical(struct Cyber180CMPort *port, CyberWord48 address, CyberWord64 *buffer, CyberWord32 wordCount);

/// Read bytes from physical memory into a buffer.
///
/// - Warning: The port access lock must be held around calls to this function.
CYBER_EXPORT void Cyber180CMPortReadBytesPhysical(struct Cyber180CMPort *port, CyberWord48 address, CyberWord8 *buffer, CyberWord32 byteCount);

/// Write bytes from a buffer to physical memory.
///
/// - Warning: The port access lock must be held around calls to this function.
CYBER_EXPORT void Cyber180CMPortWriteBytesPhysical(struct Cyber180CMPort *port, CyberWord48 address, CyberWord8 *buffer, CyberWord32 byteCount);


CYBER_HEADER_END

#endif /* __CYBER_CYBER180CMPORT_H__ */
