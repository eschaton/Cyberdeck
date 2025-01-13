//
//  Cyber962IOU.c
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

#include <Cyber/Cyber962IOU.h>

#include <Cyber/Cyber962PP.h>

#include <assert.h>
#include <stdlib.h>


CYBER_SOURCE_BEGIN


/// A Cyber962IOU implements a Cyber 962 Input/Output Unit.
///
/// Each Cyber 962 Input/Output Unit has:
///
/// - 5-20 Peripheral Processors
/// - 5-20 I/O channels
struct Cyber962IOU {

    /// The system that this is a part of.
    struct Cyber962 *_system;

    /// Index of this Input/Output Unit in the system.
    int _index;

    /// This Input/Output Unit's Peripheral Processors.
    struct Cyber962PP * _Nullable _peripheralProcessors[20];

    // FIXME: Flesh out.
};


struct Cyber962IOU * _Nullable Cyber962IOUCreate(struct Cyber962 * _Nonnull system, int index)
{
    assert(system != NULL);
    assert((index >= 0) && (index <= 1));

    struct Cyber962IOU *iou = calloc(1, sizeof(struct Cyber962IOU));

    iou->_system = system;
    iou->_index = index;

    for (int pp = 0; pp < 20; pp++) {
        iou->_peripheralProcessors[pp] = Cyber962PPCreate(iou, pp);
    }

    return iou;
}


void Cyber962IOUDispose(struct Cyber962IOU * _Nullable iou)
{
    if (iou == NULL) return;

    for (int pp = 0; pp < 20; pp++) {
        free(iou->_peripheralProcessors[pp]);
    }

    free(iou);
}


CYBER_SOURCE_END
