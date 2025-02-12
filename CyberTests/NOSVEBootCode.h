//
//  NOSVEBootCode.h
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

#ifndef __CYBERTESTS_NOSVEBOOTCODE_H__
#define __CYBERTESTS_NOSVEBOOTCODE_H__

CYBER_HEADER_BEGIN


/// NOS/VE boot code taken from listing `02.pdf` pp.16-17
CYBER_EXPORT CyberWord8 NOSVEBootCode[];

/// Length in bytes of ``NOSVEBootCode``.
CYBER_EXPORT const CyberWord32 NOSVEBootCodeLength;


CYBER_HEADER_END

#endif /* __CYBERTESTS_NOSVEBOOTCODE_H__ */
