//
//  CyberTypes.h
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

#include <Cyber/CyberDefines.h>

#ifndef __CYBER_CYBERTYPES_H__
#define __CYBER_CYBERTYPES_H__

#include <stdbool.h>
#include <stdint.h>


CYBER_HEADER_BEGIN

/// A 6-bit Cyber word.
typedef uint8_t CyberWord6;


/// An 8-bit Cyber word.
typedef uint8_t CyberWord8;


/// A 12-bit Cyber word.
typedef uint16_t CyberWord12;


/// A 16-bit Cyber word.
typedef uint16_t CyberWord16;


/// An 18-bit Cyber word.
typedef uint32_t CyberWord18;


/// A 22-bit Cyber word.
typedef uint32_t CyberWord22;


/// A 32-bit Cyber word.
typedef uint32_t CyberWord32;


/// A 48-bit Cyber word.
typedef uint64_t CyberWord48;


/// A 60-bit Cyber word.
typedef uint64_t CyberWord60;


/// A 64-bit Cyber word.
typedef uint64_t CyberWord64;


// MARK: - Endianness

#if BIG_ENDIAN
#define CYBER_BIG_ENDIAN 1
#else
#define CYBER_LITTLE_ENDIAN 1
#endif

/// Swap a 16-bit Cyber word if necessary; the Cyber is big-endian.
static inline CyberWord16 CyberWord16Swap(CyberWord16 word)
{
#if CYBER_BIG_ENDIAN
    return word;
#else
    return ((word & 0xFF00) >> 8) | ((word & 0x00FF) << 8);
#endif
}

/// Swap a 32-bit Cyber word if necessary; the Cyber is big-endian.
static inline CyberWord32 CyberWord32Swap(CyberWord32 word)
{
#if CYBER_BIG_ENDIAN
    return word;
#else
    return (  ((word & 0xFF000000) >> 24)
            | ((word & 0x00FF0000) >>  8)
            | ((word & 0x0000FF00) <<  8)
            | ((word & 0x000000FF) << 24));
#endif
}

/// Swap a 64-bit Cyber word if necessary; the Cyber is big-endian.
static inline CyberWord64 CyberWord64Swap(CyberWord64 word)
{
#if CYBER_BIG_ENDIAN
    return word;
#else
    return (  ((word & 0xFF00000000000000) >> 56)
            | ((word & 0x00FF000000000000) >> 40)
            | ((word & 0x0000FF0000000000) >> 24)
            | ((word & 0x000000FF00000000) >>  8)
            | ((word & 0x00000000FF000000) <<  8)
            | ((word & 0x0000000000FF0000) << 24)
            | ((word & 0x000000000000FF00) << 40)
            | ((word & 0x00000000000000FF) << 56));
#endif
}


CYBER_HEADER_END


#endif /* __CYBER_CYBERTYPES_H__ */
