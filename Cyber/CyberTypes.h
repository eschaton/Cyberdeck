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


/// A 12-bit Cyber word.
typedef uint16_t CyberWord12;


/// A 16-bit Cyber word.
typedef uint16_t CyberWord16;


/// An 18-bit Cyber word.
typedef uint32_t CyberWord18;


/// A 32-bit Cyber word.
typedef uint32_t CyberWord32;


/// A 48-bit Cyber word.
typedef uint64_t CyberWord48;


/// A 64-bit Cyber word.
typedef uint64_t CyberWord64;


CYBER_HEADER_END


#endif /* __CYBER_CYBERTYPES_H__ */
