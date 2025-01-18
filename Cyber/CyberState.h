//
//  CyberState.h
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

#ifndef __CYBER_CYBERSTATE_H__
#define __CYBER_CYBERSTATE_H__

#include <Cyber/CyberTypes.h>

CYBER_HEADER_BEGIN


/// A CyberState is a state plus a lock plus a condition variable that can be used to implement a state that can be get, set, or blocked on.
struct CyberState;


/// Create a state with an initial value.
CYBER_EXPORT struct CyberState * _Nullable CyberStateCreate(int initialValue);

/// Dispose of a state.
CYBER_EXPORT void CyberStateDispose(struct CyberState * _Nullable cs);


/// Get the current state.
CYBER_EXPORT int CyberStateGetValue(struct CyberState *cs);

/// Change the current state, unblocknig any threads awaiting a change.
CYBER_EXPORT void CyberStateSetValue(struct CyberState *cs, int newValue);

/// Block until the state changes from the given current value.
CYBER_EXPORT int CyberStateAwaitValueChange(int currentValue, struct CyberState *cs);


CYBER_HEADER_END

#endif /* __CYBER_CYBERSTATE_H__ */
