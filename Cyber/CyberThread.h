//
//  CyberThread.h
//  Cyber
//
//  Copyright © 2025 Christopher M. Hanson. All rights reserved.
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

#ifndef __CYBER_CYBERTHREAD_H__
#define __CYBER_CYBERTHREAD_H__

CYBER_HEADER_BEGIN


/// A threading abstraction, wrapping POSIX threads.
struct CyberThread;


/// The functions used to represent this thread.
struct CyberThreadFunctions {

    /// Called at thread start.
    void (* _Nullable start)(struct CyberThread *thread, void * _Nullable context);

    /// Called repeatedly while not halted or shut down.
    void (*loop)(struct CyberThread *thread, void * _Nullable context);

    /// Called at thread stop.
    void (* _Nullable stop)(struct CyberThread *thread, void * _Nullable context);

    /// Called at thread termination.
    void (* _Nullable terminate)(struct CyberThread *thread, void * _Nullable context);
};


/// Creates a detached thread.
///
/// - Warning: The thread is not started automatically.
CYBER_EXPORT struct CyberThread * _Nullable CyberThreadCreate(struct CyberThreadFunctions *threadFunctions, void * _Nullable context);

/// Disposes of a thread.
///
/// - Warning: The thread must be halted or shut down before disposal.
CYBER_EXPORT void CyberThreadDispose(struct CyberThread * _Nullable thread);


/// Start a stopped thread.
///
/// Transitions the thread to a running state, causes its `start` function to be called, and then causes its `loop` function to be called repeatedly.
///
/// - Warning: A thread is considered running as soon as its `start` function exits.
CYBER_EXPORT void CyberThreadStart(struct CyberThread *thread);

/// Stop a running thread.
///
/// Transitions the thread to a stopped state and causes its `stop` function to be called.
///
/// - Warning: A thread is not stopped until after its `stop` function has exited.
CYBER_EXPORT void CyberThreadStop(struct CyberThread *thread);

/// Terminate a running or halted thread.
///
/// Transitions the thread to a terminated state and causes its `terminate` function to be called.
///
/// - Warning: A thread is not terminated until after its `terminate` function exits.
CYBER_EXPORT void CyberThreadTerminate(struct CyberThread *thread);


CYBER_HEADER_END

#endif /* __CYBER_CYBERTHREAD_H__ */
