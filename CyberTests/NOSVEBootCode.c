//
//  NOSVEBootCode.c
//  CyberTests
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

#include <Cyber/Cyber.h>

#include "NOSVEBootCode.h"

CYBER_SOURCE_BEGIN


CyberWord8 NOSVEBootCode[256] = {
    0x8d, 0x00, 0x00, 0x63,
    0xac, 0x01, 0x04, 0x10,
    0x0f, 0x01,
    0x8d, 0x00, 0x00, 0x47,
    0x0e, 0x01,
    0x0b, 0x42,
    0x24, 0x21,
    0x0a, 0x15,
    0x85, 0x15, 0x00, 0x0a,
    0x3f, 0x10,
    0x0e, 0x00,
    0x83, 0x50, 0x00, 0x0e,
    0x3d, 0x00,
    0x83, 0x50, 0x00, 0x0b,
    0x83, 0x50, 0x00, 0x0c,
    0x82, 0x41, 0x00, 0x8d,
    0x95, 0x10, 0x00, 0xcc,

    0x83, 0x4d, 0x00, 0xc8,
    0x8d, 0x01, 0x10, 0x14,
    0xa9, 0x11, 0x00, 0x20,
    0x8b, 0x11, 0x01, 0x00,
    0x0a, 0x16,
    0x3d, 0x11,
    0xd8, 0x41, 0x06, 0x3f,

    0x84, 0x47, 0x04, 0x70,
    0x2a, 0xf7,

    0x84, 0x4e, 0x05, 0x5b,
    0x84, 0x4f, 0x04, 0x7c,
    0xd7, 0xe1, 0x00, 0x28,
    0xdf, 0xf1, 0x00, 0x28,
    0xd7, 0xe1, 0x00, 0x20,
    0xdf, 0xf1, 0x00, 0x20,
    0xdf, 0x41, 0x06, 0x48,
    0xd7, 0xe1, 0x00, 0x90,
    0xdf, 0xf1, 0x00, 0x80,

    0x85, 0x56, 0x00, 0x20,
    0x16, 0x61,
    0x83, 0x51, 0x00, 0x05,

    0x3f, 0x61,
    0x0f, 0x01,
    0x16, 0x71,
    0xd8, 0x51, 0x00, 0x68,
    0x84, 0x4d, 0x04, 0x70,
    0x85, 0x47, 0x04, 0x70,
    0x08, 0x11,
    0x83, 0x41, 0x00, 0x07,
    0x3f, 0x10,
    0x83, 0x41, 0x00, 0x8d,
    0x0e, 0x0e,
    0x3d, 0x56,
    0xad, 0xee, 0x0a, 0x03,

    0xd0, 0x51, 0x00, 0x04,
    0x91, 0xe6, 0x00, 0x07,
    0x28, 0x31,
    0x3d, 0x42,
    0x94, 0x12, 0x00, 0x03,
    0x3d, 0x81,
    0xd8, 0x51, 0x00, 0x04,
    0xd8, 0x41, 0x04, 0xf6,
    0x82, 0x4e, 0x00, 0x94,
    0x83, 0x7e, 0x00, 0x0f,

    0x82, 0x71, 0x00, 0x08,
    0xad, 0x1e, 0x04, 0x17,
    0xa9, 0xee, 0x00, 0x0c,
    0xdb, 0x4e, 0x00, 0x10,
    0x84, 0x4e, 0x06, 0x2b,
    0x16, 0xee,
    0xdb, 0x4e, 0x00, 0x18,
    0xdb, 0x4e, 0x00, 0x14,

    0xd1, 0x76, 0x01, 0x0a,
    0xa9, 0x66, 0x00, 0x15,
    0xd1, 0x7b, 0x01, 0x0c,
    0xa9, 0xbb, 0x00, 0x09,
    0x24, 0xb6,
    0xd1, 0x7b, 0x01, 0x08,
    0xa9, 0xbb, 0x00, 0x03,
};


const CyberWord32 NOSVEBootCodeLength = 256;


CYBER_SOURCE_END
