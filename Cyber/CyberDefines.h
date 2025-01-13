//
//  CyberDefines.h
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

#ifndef __CYBER_CYBERDEFINES_H__
#define __CYBER_CYBERDEFINES_H__


#if defined(__cplusplus)
#define CYBER_EXPORT        extern "C"
#else
#define CYBER_EXPORT        extern
#endif


#define CYBER_NONNULL_BEGIN _Pragma("clang assume_nonnull begin")
#define CYBER_NONNULL_END   _Pragma("clang assume_nonnull end")

#define CYBER_HEADER_BEGIN  CYBER_NONNULL_BEGIN
#define CYBER_HEADER_END    CYBER_NONNULL_END

#define CYBER_SOURCE_BEGIN  CYBER_NONNULL_BEGIN
#define CYBER_SOURCE_END    CYBER_NONNULL_END


#endif /* __CYBER_CYBERDEFINES_H__ */
