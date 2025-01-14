//
//  Cyber962PP_Internal.h
//  Cyberdeck
//
//  Created by Chris Hanson on 1/13/25.
//  Copyright © 2025 Christopher M. Hanson. All rights reserved.
//

#ifndef __CYBER_CYBER962PP_INTERNAL_H__
#define __CYBER_CYBER962PP_INTERNAL_H__

#include <Cyber/Cyber962PP.h>

CYBER_HEADER_BEGIN


/// A Cyber962PP implements a Cyber 962 Peripheral Processor.
struct Cyber962PP {

    /// The Input/Output Unit that this is a part of.
    struct Cyber962IOU *_inputOutputUnit;

    /// Index of this Peripheral Processor in the Input/Output Unit.
    int _index;

    /// The memory for this Peripheral Processor.
    CyberWord16 *_storage;

    // Registers

    /// Arithmetic Register, 18 bits
    CyberWord18 _regA;

    /// Program Address Register (program counter), 16 bits
    CyberWord16 _regP;

    /// Relocation Register, 22 bits
    CyberWord32 _regR;

    /// Instruction cache.
    void * _Nullable * _Nullable _instructionCache;

    // FIXME: Flesh out.
};


CYBER_HEADER_END

#endif /* __CYBER_CYBER962PP_INTERNAL_H__ */
