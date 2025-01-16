//
//  Cyber962PPInstructions.c
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

#include "Cyber962PPInstructions_Internal.h"

#include <Cyber/Cyber180CMPort.h>
#include <Cyber/Cyber962IOU.h>

#include "Cyber962PP_Internal.h"

#include <assert.h>
#include <stdlib.h>


CYBER_SOURCE_BEGIN


/// Compute a combined `m.d` value as an 18-bit quantity.
///
/// To compute a combined value, `d` provides the most significant 6 bits and `m` provides the least significant 12 bits.
static inline CyberWord18 Cyber962PPComputeConstant(struct Cyber962PP *processor, CyberWord6 d)
{
    CyberWord18 d18 = d & 0x3F;
    CyberWord18 m18 = Cyber962PPReadSingle(processor, processor->_regP + 1) & 0x0FFF;
    CyberWord18 result = (d18 << 12) | m18;
    return result;
}


/// Compute an address for the Indirect address mode `((d))`
///
/// To compute an address for the Indirect address mode, the address to use is located at the address pointed to by `d`.
static inline CyberWord16 Cyber962PPComputeIndirectAddress(struct Cyber962PP *processor, CyberWord6 d)
{
    CyberWord16 intermediateAddress = Cyber962PPReadSingle(processor, d);
    CyberWord16 address = Cyber962PPReadSingle(processor, intermediateAddress);
    return address;
}


/// Compute an address for the Memory address mode `(m+(d))`.
///
/// "Memory" mode is what most other processors refer to as "indexed" mode, and uses the `d` and `m` fields to compose the address of a 12-bit or 16-bit word in memory, according to the following rules:
///
/// 1. If `d` is `0`, the operand address  is the address to use.
/// 2. If `d` is nonzero, `d` is the address of a 12-bit word that is added to `m` to generate an address.
///
/// - Note: This may access memory.
static inline CyberWord16 Cyber962PPComputeMemoryAddress(struct Cyber962PP *processor, CyberWord6 d)
{
    CyberWord16 address;

    if (d == 0) {
        address = processor->_regP;
    } else {
        CyberWord16 m = Cyber962PPReadSingle(processor, processor->_regP + 1);
        CyberWord16 index = Cyber962PPReadSingle(processor, d);
        address = m + index;
    }

    return address;
}


/// Compute an address in the Central Memory using `A` and `R`.
///
/// If the high bit of `A` is set, `R` is shifted to the right and added to the rest of `A` to form the address.
/// If the high bit of `A` is clear, then the address is `A` as-is.
static inline CyberWord48 Cyber962PPComputeCentralMemoryAddress(struct Cyber962PP *processor)
{
    CyberWord48 address;
    CyberWord18 A = processor->_regA;
    CyberWord48 R = processor->_regR;
    CyberWord48 maskedA = processor->_regA & 0x1FFFF;

    // Relocation is only performed if A has its most significant bit set.
    // Either way, the most significant bit of A is not used as an address.

    if ((A & 0x20000) != 0x00000) {
        address = maskedA;
    } else {
        address = ((R << 4) + maskedA) & 0x0FFFFFFF;
    }

    return address;
}


Cyber962PPInstruction _Nullable Cyber962PPInstructionDecode(struct Cyber962PP *processor, union Cyber962PPInstructionWord instructionWord, CyberWord16 address)
{
    uint16_t opcode = instructionWord._d.f | (instructionWord._d.g << 9);

    Cyber962PPInstruction _Nullable instruction = processor->_instructionCache[opcode];
    if (instruction) return instruction;

    uint8_t d = instructionWord._d.d;

    switch (opcode) {
            // Load and Store Instructions

            // Load
        case 00014: // LDN d
        case 00015: // LCN d
        case 00020: // LDC d,m
        case 00030: // LDD (d)
        case 01030: // LDDL (d)
        case 00040: // LDI ((d))
        case 01040: // LDIL ((d))
        case 00050: // LDM (m+(d))
        case 01050: // LDML (m+(d))
            instruction = Cyber962PPInstruction_LDx;
            break;

            // Store
        case 00034: // STD (d)
        case 01034: // STDL (d)
        case 00044: // STI ((d))
        case 01044: // STIL ((d))
        case 00054: // STM (m+(d))
        case 01054: // STML (m+(d))
            instruction = Cyber962PPInstruction_STx;
            break;

            // Arithmetic Instructions

            // Add
        case 00016: // ADN d
        case 00021: // ADC d,m
        case 00031: // ADD (d)
        case 01031: // ADDL (d)
        case 00041: // ADI ((d))
        case 01041: // ADIL ((d))
        case 00051: // ADM (m+(d))
        case 01051: // ADML (m+(d))
            instruction = Cyber962PPInstruction_ADx;
            break;

            // Subtract
        case 00017: // SBN d
        case 00032: // SBD (d)
        case 01032: // SBDL (d)
        case 00042: // SBI ((d))
        case 01042: // SBIL ((d))
        case 00052: // SBM (m+(d))
        case 01052: // SBML (m+(d))
            instruction = Cyber962PPInstruction_SBx;
            break;

            // Logical Instructions

            // Shift
        case 00010: // SHN d
            instruction = Cyber962PPInstruction_SHN;
            break;

            // Logical Difference
        case 00011: // LMN d
        case 00023: // LMC d,m
        case 00033: // LMD (d)
        case 01033: // LMDL (d)
        case 00043: // LMI ((d))
        case 01043: // LMIL ((d))
        case 00053: // LMM (m+(d))
        case 01053: // LMNL (m+(d))
            instruction = Cyber962PPInstruction_LMx;
            break;

            // Logical Product
        case 00012: // LPN d
        case 00022: // LPC m,d
        case 01022: // LPDL (d)
        case 01023: // LPIL ((d))
        case 01024: // LPML (m+(d))
            instruction = Cyber962PPInstruction_LPx;
            break;

            // Selective Clear
        case 00013: // SCN d
            instruction = Cyber962PPInstruction_SCN;
            break;

            // Replace Instructions

            // Replace Add
        case 00035: // RAD (d)
        case 01035: // RADL (d)
        case 00045: // RAI ((d))
        case 01045: // RAIL ((d))
        case 00055: // RAM (m+(d))
        case 01055: // RAML (m+(d))
            instruction = Cyber962PPInstruction_RAx;
            break;

            // Replace Add One
        case 00036: // AOD (d)
        case 01036: // AODL (d)
        case 00046: // AOI ((d))
        case 01046: // AOIL ((d))
        case 00056: // AOM (m+(d))
        case 01056: // AOML (m+(d))
            instruction = Cyber962PPInstruction_AOx;
            break;

            // Replace Subtract
        case 00037: // SOD (d)
        case 01037: // SODL (d)
        case 00047: // SOI ((d))
        case 01047: // SOIL ((d))
        case 00057: // SOM (m+(d))
        case 01057: // SOML (d+(d))
            instruction = Cyber962PPInstruction_SOx;
            break;

            // Branch Instructions

        case 00001: // LJM (m+(d))
        case 00002: // RJM (m+(d))
            instruction = Cyber962PPInstruction_xJM;
            break;

        case 00003: // UJN d
        case 00004: // ZJN d
        case 00005: // NJN d
        case 00006: // PJN d
        case 00007: // MJN d
            instruction = Cyber962PPInstruction_xJN;
            break;

            // Central Memory Access Instructions

        case 00024: // LRD d
        case 00025: // SRD d
            instruction = Cyber962PPInstruction_xRD;
            break;

        case 00060: // CRD (A),d
        case 01060: // CRDL (A),d
        case 00061: // CRM (d),(A),m
        case 01061: // CRML (d),(A),m
            instruction = Cyber962PPInstruction_CRx;
            break;

        case 01000: // RDSL d,(A)
        case 01001: // RDCL d,(A)
            instruction = Cyber962PPInstruction_RDxL;
            break;

        case 00062: // CWD (A),(d)
        case 01062: // CWDL (A),d
        case 00063: // CWM (d),(A),m
        case 01063: // CWML (d),(A),m
            instruction = Cyber962PPInstruction_CWx;
            break;

            // Input/Output Instructions

        case 00064: // AJM c,m || SCF c,m (s)
        case 01064: // FSJM c,m
        case 00065: // IJM c,m || CCF c,m (s)
        case 01065: // FCJM c,m
        case 00066: // FJM c,m || SFM c,m (s)
        case 00067: // EJM c,m || CFM c,m (s)
            instruction = (instructionWord._sc.s) ? Cyber962PPInstruction_CTRL : Cyber962PPInstruction_IOJ;
            break;

        case 00070: // IANW c || IANI c
        case 00071: // IAM c,m
        case 01071: // IAPM c,m
            instruction = Cyber962PPInstruction_IN;
            break;

        case 00072: // OANW c || OANI c
        case 00073: // OAM c,m
        case 01073: // OAPM c,m
            instruction = Cyber962PPInstruction_OUT;
            break;

        case 00074: // ACNW c || ACNU c
        case 00075: // DCNW c || DCNU c
        case 00076: // FANW c || FANI c
        case 00077: // FNCW c || FNCI c
            instruction = Cyber962PPInstruction_CTRL;
            break;

            // Other IOU Instructions

            // Pass Instructions
        case 00000:
        case 01002:
        case 01003:
        case 01004:
        case 01005:
        case 01006:
        case 01007:
        case 01010:
        case 01011:
        case 01012:
        case 01013:
        case 01014:
        case 01015:
        case 01016:
        case 01017:
        case 01020:
        case 01021:
        case 01025:
        case 01027:
        case 01066:
        case 01067:
        case 01070:
        case 01072:
        case 01074:
        case 01076:
        case 01077: // PSN
            instruction = Cyber962PPInstruction_PSN;
            break;

            // Keypoint Instruction
        case 00027: // KPT d
            instruction = Cyber962PPInstruction_KPT;
            break;

            // Exchange Jumps
        case 00026: {
            switch (d) {
                case 000: // EXN d
                case 001: // EXN d
                case 002: // EXN d
                case 003: // EXN d
                case 004: // EXN d
                case 005: // EXN d
                case 006: // EXN d
                case 007: // EXN d
                    instruction = Cyber962PPInstruction_EXN;
                    break;

                case 010: // MXN d
                    instruction = Cyber962PPInstruction_MXN;
                    break;

                case 020: // MAN d
                    instruction = Cyber962PPInstruction_MAN;
                    break;

                case 030: // MAN 2*d
                case 031: // MAN 2*d
                case 032: // MAN 2*d
                case 033: // MAN 2*d
                case 034: // MAN 2*d
                case 035: // MAN 2*d
                case 036: // MAN 2*d
                case 037: // MAN 2*d
                    instruction = Cyber962PPInstruction_MAN2;
                    break;

                default: // none
                    assert(false); // Unknown instruction
                    instruction = Cyber962PPInstruction_PSN;
                    break;
            }
        } break;
        case 01026: // INPN d
            instruction = Cyber962PPInstruction_INPN;
            break;

        default: // none
            assert(false); // Unknown instruction
            instruction = Cyber962PPInstruction_PSN;
            break;
    }

    processor->_instructionCache[opcode] = (void *)instruction;

    return instruction;
}


// MARK: - Instruction Implementations

/// Implementation of "Load" instrucitons.
CyberWord16 Cyber962PPInstruction_LDx(struct Cyber962PP *processor, union Cyber962PPInstructionWord instructionWord)
{
    CyberWord12 opcode = instructionWord._d.f | (instructionWord._d.g << 9);

    switch (opcode) {
        case 00014: { // LDN d
            CyberWord18 newA = instructionWord._d.d;
            processor->_regA = newA;
            return 1;
        } break;

        case 00015: { // LCN d
            CyberWord18 newA = 0x3FFC0 | ~instructionWord._d.d;
            processor->_regA = newA;
            return 1;
        } break;

        case 00020: { // LDC d,m
            CyberWord18 newA = Cyber962PPComputeConstant(processor, instructionWord._d.d);
            processor->_regA = newA;
            return 2;
        } break;

        case 00030: { // LDD (d)
            CyberWord16 d16 = instructionWord._d.d;
            CyberWord18 newA = Cyber962PPReadSingle(processor, d16) & 0x0FFF;
            processor->_regA = newA;
            return 1;
        } break;

        case 01030: { // LDDL (d)
            CyberWord16 d16 = instructionWord._d.d;
            CyberWord18 newA = Cyber962PPReadSingle(processor, d16) & 0xFFFF;
            processor->_regA = newA;
            return 1;
        } break;

        case 00040: { // LDI ((d))
            CyberWord16 address = Cyber962PPComputeIndirectAddress(processor, instructionWord._d.d);
            CyberWord18 newA = Cyber962PPReadSingle(processor, address) & 0x0FFF;
            processor->_regA = newA;
            return 1;
        } break;

        case 01040: { // LDIL ((d))
            CyberWord16 address = Cyber962PPComputeIndirectAddress(processor, instructionWord._d.d);
            CyberWord18 newA = Cyber962PPReadSingle(processor, address) & 0xFFFF;
            processor->_regA = newA;
            return 1;
        } break;

        case 00050: { // LDM (m+(d))
            CyberWord16 address = Cyber962PPComputeMemoryAddress(processor, instructionWord._d.d);
            CyberWord18 newA = Cyber962PPReadSingle(processor, address) & 0x0FFF;
            processor->_regA = newA;
            return 2;
        } break;

        case 01050: { // LDML (m+(d))
            CyberWord16 address = Cyber962PPComputeMemoryAddress(processor, instructionWord._d.d);
            CyberWord18 newA = Cyber962PPReadSingle(processor, address) & 0xFFFF;
            processor->_regA = newA;
            return 2;
        } break;

        default:
            assert(false); // should be unreachable
            break;
    }

    return 0;
}

/// Implementation of "Store" instructions.
CyberWord16 Cyber962PPInstruction_STx(struct Cyber962PP *processor, union Cyber962PPInstructionWord instructionWord)
{
    uint16_t opcode = instructionWord._d.f | (instructionWord._d.g << 9);

    switch (opcode) {
        case 00034: { // STD (d)
            CyberWord16 address = instructionWord._d.d;
            CyberWord16 newValue = processor->_regA & 0x00FFF;
            Cyber962PPWriteSingle(processor, address, newValue);
            return 1;
        } break;

        case 01034: { // STDL (d)
            CyberWord16 address = instructionWord._d.d;
            CyberWord16 newValue = processor->_regA & 0x0FFFF;
            Cyber962PPWriteSingle(processor, address, newValue);
            return 1;
        } break;

        case 00044: { // STI ((d))
            CyberWord16 address = Cyber962PPComputeIndirectAddress(processor, instructionWord._d.d);
            CyberWord16 newValue = processor->_regA & 0x00FFF;
            Cyber962PPWriteSingle(processor, address, newValue);
            return 1;
        } break;

        case 01044: { // STIL ((d))
            CyberWord16 address = Cyber962PPComputeIndirectAddress(processor, instructionWord._d.d);
            CyberWord16 newValue = processor->_regA & 0x0FFFF;
            Cyber962PPWriteSingle(processor, address, newValue);
            return 1;
        } break;

        case 00054: { // STM (m+(d))
            CyberWord16 address = Cyber962PPComputeMemoryAddress(processor, instructionWord._d.d);
            CyberWord16 newValue = processor->_regA & 0x00FFF;
            Cyber962PPWriteSingle(processor, address, newValue);
            return 2;
        } break;

        case 01054: { // STML (m+(d))
            CyberWord16 address = Cyber962PPComputeMemoryAddress(processor, instructionWord._d.d);
            CyberWord16 newValue = processor->_regA & 0x0FFFF;
            Cyber962PPWriteSingle(processor, address, newValue);
            return 2;
        } break;

        default:
            assert(false); // should be unreachable
            break;
    }

    return 0;
}

/// Implementation of "Add" instruction.
CyberWord16 Cyber962PPInstruction_ADx(struct Cyber962PP *processor, union Cyber962PPInstructionWord instructionWord)
{
    uint16_t opcode = instructionWord._d.f | (instructionWord._d.g << 9);

    switch (opcode) {
        case 00016: { // ADN d
            CyberWord18 addend = instructionWord._d.d;
            CyberWord18 newA = processor->_regA + addend;
            processor->_regA = newA;
            return 1;
        } break;

        case 00021: { // ADC d,m
            CyberWord18 addend = Cyber962PPComputeConstant(processor, instructionWord._d.d);
            CyberWord18 newA = processor->_regA + addend;
            processor->_regA = newA;
            return 2;
        } break;

        case 00031: { // ADD (d)
            CyberWord18 addend = Cyber962PPReadSingle(processor, instructionWord._d.d) & 0x0FFF;
            CyberWord18 newA = processor->_regA + addend;
            processor->_regA = newA;
            return 1;
        } break;

        case 01031: { // ADDL (d)
            CyberWord18 addend = Cyber962PPReadSingle(processor, instructionWord._d.d) & 0xFFFF;
            CyberWord18 newA = processor->_regA + addend;
            processor->_regA = newA;
            return 1;
        } break;

        case 00041: { // ADI ((d))
            CyberWord16 address = Cyber962PPComputeIndirectAddress(processor, instructionWord._d.d);
            CyberWord18 addend = Cyber962PPReadSingle(processor, address) & 0x0FFF;
            CyberWord18 newA = processor->_regA + addend;
            processor->_regA = newA;
            return 1;
        } break;

        case 01041: { // ADIL ((d))
            CyberWord16 address = Cyber962PPComputeIndirectAddress(processor, instructionWord._d.d);
            CyberWord18 addend = Cyber962PPReadSingle(processor, address) & 0xFFFF;
            CyberWord18 newA = processor->_regA + addend;
            processor->_regA = newA;
            return 1;
        } break;

        case 00051: { // ADM (m+(d))
            CyberWord16 address = Cyber962PPComputeMemoryAddress(processor, instructionWord._d.d);
            CyberWord18 addend = Cyber962PPReadSingle(processor, address) & 0x0FFF;
            CyberWord18 newA = processor->_regA + addend;
            processor->_regA = newA;
            return 2;
        } break;

        case 01051: { // ADML (m+(d))
            CyberWord16 address = Cyber962PPComputeMemoryAddress(processor, instructionWord._d.d);
            CyberWord18 addend = Cyber962PPReadSingle(processor, address) & 0xFFFF;
            CyberWord18 newA = processor->_regA + addend;
            processor->_regA = newA;
            return 2;
        } break;

        default:
            assert(false); // should be unreachable
            break;
    }

    return 0;
}

/// Implementation of "Subtract" instructions.
CyberWord16 Cyber962PPInstruction_SBx(struct Cyber962PP *processor, union Cyber962PPInstructionWord instructionWord)
{
    uint16_t opcode = instructionWord._d.f | (instructionWord._d.g << 9);

    switch (opcode) {
        case 00017: { // SBN d
            CyberWord18 subtractend = instructionWord._d.d;
            CyberWord18 newA = processor->_regA - subtractend;
            processor->_regA = newA;
            return 1;
        } break;

        case 00032: { // SBD (d)
            CyberWord18 subtractend = Cyber962PPReadSingle(processor, instructionWord._d.d) & 0x0FFF;
            CyberWord18 newA = processor->_regA - subtractend;
            processor->_regA = newA;
            return 1;
        } break;

        case 01032: { // SBDL (d)
            CyberWord18 subtractend = Cyber962PPReadSingle(processor, instructionWord._d.d) & 0xFFFF;
            CyberWord18 newA = processor->_regA - subtractend;
            processor->_regA = newA;
            return 1;
        } break;

        case 00042: { // SBI ((d))
            CyberWord16 address = Cyber962PPComputeIndirectAddress(processor, instructionWord._d.d);
            CyberWord18 subtractend = Cyber962PPReadSingle(processor, address) & 0x0FFF;
            CyberWord18 newA = processor->_regA - subtractend;
            processor->_regA = newA;
            return 1;
        } break;

        case 01042: { // SBIL ((d))
            CyberWord16 address = Cyber962PPComputeIndirectAddress(processor, instructionWord._d.d);
            CyberWord18 subtractend = Cyber962PPReadSingle(processor, address) & 0xFFFF;
            CyberWord18 newA = processor->_regA - subtractend;
            processor->_regA = newA;
            return 1;
        } break;

        case 00052: { // SBM (m+(d))
            CyberWord16 address = Cyber962PPComputeMemoryAddress(processor, instructionWord._d.d);
            CyberWord18 subtractend = Cyber962PPReadSingle(processor, address) & 0x0FFF;
            CyberWord18 newA = processor->_regA - subtractend;
            processor->_regA = newA;
            return 2;
        } break;

        case 01052: { // SBML (m+(d))
            CyberWord16 address = Cyber962PPComputeMemoryAddress(processor, instructionWord._d.d);
            CyberWord18 subtractend = Cyber962PPReadSingle(processor, address) & 0xFFFF;
            CyberWord18 newA = processor->_regA - subtractend;
            processor->_regA = newA;
            return 2;
        } break;

        default:
            assert(false); // should be unreachable
            break;
    }

    return 0;
}

/// Implementation of Shift instruction.
CyberWord16 Cyber962PPInstruction_SHN(struct Cyber962PP *processor, union Cyber962PPInstructionWord instructionWord)
{
    CyberWord64 d64 = instructionWord._d.d;
    CyberWord64 oldA64 = processor->_regA;

    // SHN d
    if (d64 < 040) {
        // Positive is a left shift, circular.
        CyberWord64 left = d64;
        CyberWord64 right = (18 - d64);
        CyberWord64 shifted = (oldA64 << left) | (oldA64 >> right);
        CyberWord18 newA = shifted & 0x0003FFFF;
        processor->_regA = newA;
    } else {
        // Negative is a right shift, end-off.
        CyberWord64 right = 077 - d64;
        CyberWord64 shifted = oldA64 >> right;
        CyberWord18 newA = shifted & 0x0003FFFF;
        processor->_regA = newA;
    }

    return 1;
}

/// Implementation of "Logical Minus" (XOR) instructions.
CyberWord16 Cyber962PPInstruction_LMx(struct Cyber962PP *processor, union Cyber962PPInstructionWord instructionWord)
{
    uint16_t opcode = instructionWord._d.f | (instructionWord._d.g << 9);

    switch (opcode) {
        case 00011: { // LMN d
            CyberWord18 xorend = instructionWord._d.d;
            CyberWord18 newA = processor->_regA ^ xorend;
            processor->_regA = newA;
            return 1;
        } break;

        case 00023: { // LMC d,m
            CyberWord18 xorend = Cyber962PPComputeConstant(processor, instructionWord._d.d);
            CyberWord18 newA = processor->_regA ^ xorend;
            processor->_regA = newA;
            return 2;
        } break;

        case 00033: { // LMD (d)
            CyberWord18 xorend = Cyber962PPReadSingle(processor, instructionWord._d.d) & 0x0FFF;
            CyberWord18 newA = processor->_regA ^ xorend;
            processor->_regA = newA;
            return 1;
        } break;

        case 01033: { // LMDL (d)
            CyberWord18 xorend = Cyber962PPReadSingle(processor, instructionWord._d.d) & 0xFFFF;
            CyberWord18 newA = processor->_regA ^ xorend;
            processor->_regA = newA;
            return 1;
        } break;

        case 00043: { // LMI ((d))
            CyberWord16 address = Cyber962PPComputeIndirectAddress(processor, instructionWord._d.d);
            CyberWord18 xorend = Cyber962PPReadSingle(processor, address) & 0x0FFF;
            CyberWord18 newA = processor->_regA ^ xorend;
            processor->_regA = newA;
            return 1;
        } break;

        case 01043: { // LMIL ((d))
            CyberWord16 address = Cyber962PPComputeIndirectAddress(processor, instructionWord._d.d);
            CyberWord18 xorend = Cyber962PPReadSingle(processor, address) & 0xFFFF;
            CyberWord18 newA = processor->_regA ^ xorend;
            processor->_regA = newA;
            return 1;
        } break;

        case 00053: { // LMM (m+(d))
            CyberWord16 address = Cyber962PPComputeMemoryAddress(processor, instructionWord._d.d);
            CyberWord18 xorend = Cyber962PPReadSingle(processor, address) & 0x0FFF;
            CyberWord18 newA = processor->_regA ^ xorend;
            processor->_regA = newA;
            return 2;
        } break;

        case 01053: { // LMNL (m+(d))
            CyberWord16 address = Cyber962PPComputeMemoryAddress(processor, instructionWord._d.d);
            CyberWord18 xorend = Cyber962PPReadSingle(processor, address) & 0xFFFF;
            CyberWord18 newA = processor->_regA ^ xorend;
            processor->_regA = newA;
            return 2;
        } break;

        default:
            assert(false); // should be unreachable
            break;
    }

   return 0;
}

/// Implementation of "Logical Product" (AND) instructions.
CyberWord16 Cyber962PPInstruction_LPx(struct Cyber962PP *processor, union Cyber962PPInstructionWord instructionWord)
{
    uint16_t opcode = instructionWord._d.f | (instructionWord._d.g << 9);

    switch (opcode) {
        case 00012: { // LPN d
            CyberWord18 andend = instructionWord._d.d;
            CyberWord18 newA = processor->_regA & andend;
            processor->_regA = newA;
            return 1;
        } break;

        case 00022: { // LPC m,d
            CyberWord18 andend = Cyber962PPComputeConstant(processor, instructionWord._d.d);
            CyberWord18 newA = processor->_regA & andend;
            processor->_regA = newA;
            return 2;
        } break;

        case 01022: { // LPDL (d)
            CyberWord18 andend = Cyber962PPReadSingle(processor, instructionWord._d.d) & 0xFFFF;
            CyberWord18 newA = processor->_regA & andend;
            processor->_regA = newA;
            return 1;
        } break;

        case 01023: { // LPIL ((d))
            CyberWord16 address = Cyber962PPComputeIndirectAddress(processor, instructionWord._d.d);
            CyberWord18 andend = Cyber962PPReadSingle(processor, address) & 0xFFFF;
            CyberWord18 newA = processor->_regA & andend;
            processor->_regA = newA;
            return 1;
        } break;

        case 01024: { // LPML (m+(d))
            CyberWord16 address = Cyber962PPComputeMemoryAddress(processor, instructionWord._d.d);
            CyberWord18 andend = Cyber962PPReadSingle(processor, address) & 0xFFFF;
            CyberWord18 newA = processor->_regA & andend;
            processor->_regA = newA;
            return 2;
        } break;

        default:
            assert(false); // should be unreachable
            break;
    }

    return 0;
}

/// Implementation of "Selective Clear" instruction, which clears bits of `A` based on which bits of `d` are `1`.
CyberWord16 Cyber962PPInstruction_SCN(struct Cyber962PP *processor, union Cyber962PPInstructionWord instructionWord)
{
    CyberWord18 d18 = instructionWord._d.d;
    CyberWord18 d18inv = ~d18 & 0x0003FFFF;
    CyberWord18 oldA = processor->_regA;
    CyberWord18 newA = oldA & d18inv;
    processor->_regA = newA;
    return 1;
}

/// Implementation of "Replace Add" instructions.
CyberWord16 Cyber962PPInstruction_RAx(struct Cyber962PP *processor, union Cyber962PPInstructionWord instructionWord)
{
    uint16_t opcode = instructionWord._d.f | (instructionWord._d.g << 9);
    CyberWord16 d16 = instructionWord._d.d;

    switch (opcode) {
        case 00035: { // RAD (d)
            CyberWord18 addend = Cyber962PPReadSingle(processor, d16) & 0x0FFF;
            CyberWord18 newA = (processor->_regA + addend) & 0x0FFF;
            processor->_regA = newA;
            Cyber962PPWriteSingle(processor, d16, newA);
            return 1;
        } break;

        case 01035: { // RADL (d)
            CyberWord18 addend = Cyber962PPReadSingle(processor, d16) & 0xFFFF;
            CyberWord18 newA = (processor->_regA + addend) & 0xFFFF;
            processor->_regA = newA;
            Cyber962PPWriteSingle(processor, d16, newA);
            return 1;
        } break;

        case 00045: { // RAI ((d))
            CyberWord16 address = Cyber962PPComputeIndirectAddress(processor, d16);
            CyberWord18 addend = Cyber962PPReadSingle(processor, address) & 0x0FFF;
            CyberWord18 newA = (processor->_regA + addend) & 0x0FFF;
            processor->_regA = newA;
            Cyber962PPWriteSingle(processor, d16, newA);
            return 1;
        } break;

        case 01045: { // RAIL ((d))
            CyberWord16 address = Cyber962PPComputeIndirectAddress(processor, d16);
            CyberWord18 addend = Cyber962PPReadSingle(processor, address) & 0xFFFF;
            CyberWord18 newA = (processor->_regA + addend) & 0xFFFF;
            processor->_regA = newA;
            Cyber962PPWriteSingle(processor, d16, newA);
        } break;

        case 00055: { // RAM (m+(d))
            CyberWord16 address = Cyber962PPComputeMemoryAddress(processor, d16);
            CyberWord18 addend = Cyber962PPReadSingle(processor, address) & 0x0FFF;
            CyberWord18 newA = (processor->_regA + addend) & 0x0FFF;
            processor->_regA = newA;
            Cyber962PPWriteSingle(processor, d16, newA);
            return 2;
        } break;

        case 01055: { // RAML (m+(d))
            CyberWord16 address = Cyber962PPComputeMemoryAddress(processor, d16);
            CyberWord18 addend = Cyber962PPReadSingle(processor, address) & 0xFFFF;
            CyberWord18 newA = (processor->_regA + addend) & 0xFFFF;
            processor->_regA = newA;
            Cyber962PPWriteSingle(processor, d16, newA);
            return 2;
        } break;

        default:
            assert(false); // should be unreachable
            break;
    }

    return 0;
}

/// Implementation of "Replace Add One" instructions.
CyberWord16 Cyber962PPInstruction_AOx(struct Cyber962PP *processor, union Cyber962PPInstructionWord instructionWord)
{
    uint16_t opcode = instructionWord._d.f | (instructionWord._d.g << 9);
    CyberWord16 d16 = instructionWord._d.d;

    switch (opcode) {
        case 00036: { // AOD (d)
            CyberWord18 addend = Cyber962PPReadSingle(processor, d16) & 0x0FFF;
            CyberWord18 newA = (1 + addend) & 0x0FFF;
            processor->_regA = newA;
            Cyber962PPWriteSingle(processor, d16, newA);
            return 1;
        } break;

        case 01036: { // AODL (d)
            CyberWord18 addend = Cyber962PPReadSingle(processor, d16) & 0xFFFF;
            CyberWord18 newA = (1 + addend) & 0xFFFF;
            processor->_regA = newA;
            Cyber962PPWriteSingle(processor, d16, newA);
            return 1;
        } break;

        case 00046: { // AOI ((d))
            CyberWord16 address = Cyber962PPComputeIndirectAddress(processor, d16);
            CyberWord18 addend = Cyber962PPReadSingle(processor, address) & 0x0FFF;
            CyberWord18 newA = (1 + addend) & 0x0FFF;
            processor->_regA = newA;
            Cyber962PPWriteSingle(processor, d16, newA);
            return 1;
        } break;

        case 01046: { // AOIL ((d))
            CyberWord16 address = Cyber962PPComputeIndirectAddress(processor, d16);
            CyberWord18 addend = Cyber962PPReadSingle(processor, address) & 0xFFFF;
            CyberWord18 newA = (1 + addend) & 0xFFFF;
            processor->_regA = newA;
            Cyber962PPWriteSingle(processor, d16, newA);
            return 1;
        } break;

        case 00056: { // AOM (m+(d))
            CyberWord16 address = Cyber962PPComputeMemoryAddress(processor, d16);
            CyberWord18 addend = Cyber962PPReadSingle(processor, address) & 0x0FFF;
            CyberWord18 newA = (1 + addend) & 0x0FFF;
            processor->_regA = newA;
            Cyber962PPWriteSingle(processor, d16, newA);
            return 2;
        } break;

        case 01056: { // AOML (m+(d))
            CyberWord16 address = Cyber962PPComputeMemoryAddress(processor, d16);
            CyberWord18 addend = Cyber962PPReadSingle(processor, address) & 0xFFFF;
            CyberWord18 newA = (1 + addend) & 0xFFFF;
            processor->_regA = newA;
            Cyber962PPWriteSingle(processor, d16, newA);
            return 2;
        } break;

        default:
            assert(false); // should be unreachable
            break;
    }

    return 0;
}

/// Implementation of "Replace Subtract One" instructions.
CyberWord16 Cyber962PPInstruction_SOx(struct Cyber962PP *processor, union Cyber962PPInstructionWord instructionWord)
{
    uint16_t opcode = instructionWord._d.f | (instructionWord._d.g << 9);
    CyberWord16 d16 = instructionWord._d.d;

    switch (opcode) {
        case 00037: { // SOD (d)
            CyberWord18 subtractend = Cyber962PPReadSingle(processor, d16) & 0x0FFF;
            CyberWord18 newA = (subtractend - 1) & 0x0FFF;
            processor->_regA = newA;
            Cyber962PPWriteSingle(processor, d16, newA);
            return 1;
        } break;

        case 01037: { // SODL (d)
            CyberWord18 subtractend = Cyber962PPReadSingle(processor, d16) & 0xFFFF;
            CyberWord18 newA = (subtractend - 1) & 0xFFFF;
            processor->_regA = newA;
            Cyber962PPWriteSingle(processor, d16, newA);
            return 1;
        } break;

        case 00047: { // SOI ((d))
            CyberWord16 address = Cyber962PPComputeIndirectAddress(processor, d16);
            CyberWord18 subtractend = Cyber962PPReadSingle(processor, address) & 0x0FFF;
            CyberWord18 newA = (subtractend - 1) & 0x0FFF;
            processor->_regA = newA;
            Cyber962PPWriteSingle(processor, d16, newA);
            return 1;
        } break;

        case 01047: { // SOIL ((d))
            CyberWord16 address = Cyber962PPComputeIndirectAddress(processor, d16);
            CyberWord18 subtractend = Cyber962PPReadSingle(processor, address) & 0xFFFF;
            CyberWord18 newA = (subtractend - 1) & 0xFFFF;
            processor->_regA = newA;
            Cyber962PPWriteSingle(processor, d16, newA);
            return 1;
        } break;

        case 00057: { // SOM (m+(d))
            CyberWord16 address = Cyber962PPComputeMemoryAddress(processor, d16);
            CyberWord18 subtractend = Cyber962PPReadSingle(processor, address) & 0x0FFF;
            CyberWord18 newA = (subtractend - 1) & 0x0FFF;
            processor->_regA = newA;
            Cyber962PPWriteSingle(processor, d16, newA);
            return 2;
        } break;

        case 01057: { // SOML (d+(d))
            CyberWord16 address = Cyber962PPComputeMemoryAddress(processor, d16);
            CyberWord18 subtractend = Cyber962PPReadSingle(processor, address) & 0xFFFF;
            CyberWord18 newA = (subtractend - 1) & 0xFFFF;
            processor->_regA = newA;
            Cyber962PPWriteSingle(processor, d16, newA);
            return 2;
        } break;

        default:
            assert(false); // should be unreachable
            break;
    }

    return 0;
}

/// Implementation of some "Jump" instructions, specifically Long Jump and Return Jump.
CyberWord16 Cyber962PPInstruction_xJM(struct Cyber962PP *processor, union Cyber962PPInstructionWord instructionWord)
{
    uint16_t opcode = instructionWord._d.f | (instructionWord._d.g << 9);

    switch (opcode) {
        case 00001: { // LJM (m+(d))
            CyberWord16 address = Cyber962PPComputeMemoryAddress(processor, instructionWord._d.d);
            processor->_regP = address;
            return 0;
        } break;

        case 00002: { // RJM (m+(d))
            CyberWord16 address = Cyber962PPComputeMemoryAddress(processor, instructionWord._d.d);
            CyberWord16 oldP = processor->_regP;
            Cyber962PPWriteSingle(processor, address, oldP + 2);
            processor->_regP = address + 1;
            return 0;
        } break;

        default:
            assert(false); // should be unreachable
            break;
    }

    return 0;
}

/// Implementation of  "Branch" instructions.
CyberWord16 Cyber962PPInstruction_xJN(struct Cyber962PP *processor, union Cyber962PPInstructionWord instructionWord)
{
    CyberWord12 opcode = instructionWord._d.f | (instructionWord._d.g << 9);

    int64_t oldP64 = processor->_regP;
    int64_t d64 = instructionWord._d.d;
    int64_t pAdj = (d64 < 040) ? d64 : -(077 - d64);
    bool condition = false;

    switch (opcode) {
        case 00003: // UJN d
            condition = true;
            break;

        case 00004: // ZJN d
            condition = (processor->_regA == 0x00000000);
            break;

        case 00005: // NJN d
            condition = (processor->_regA != 0x00000000);
            break;

        case 00006: // PJN d
            condition = ((processor->_regA & 0x00020000) == 0x00000000);
            break;

        case 00007: // MJN d
            condition = ((processor->_regA & 0x00020000) == 0x00020000);
            break;

        default:
            assert(false); // should be unreachable
            break;
    }

    if (condition) {
        int64_t newP64 = oldP64 + pAdj;
        processor->_regP = newP64 & 0x000000000000FFFF;
    }

    return 0;
}

/// Implementation of "Load/Store R" instructions.
CyberWord16 Cyber962PPInstruction_xRD(struct Cyber962PP *processor, union Cyber962PPInstructionWord instructionWord)
{
    CyberWord12 opcode = instructionWord._d.f | (instructionWord._d.g << 9);

    CyberWord6 d = instructionWord._d.d;
    if (d == 0) {
        // If `d` is 0, the instruction is a pass.
        return 1;
    }

    switch (opcode) {
        case 00024: { // LRD d
            CyberWord32 lower = Cyber962PPReadSingle(processor, d) & 0x03FF;
            CyberWord32 upper = Cyber962PPReadSingle(processor, d + 1) & 0x07FF;
            CyberWord32 newR = (upper << 18) | (lower << 6);
            processor->_regR = newR;
        } break;

        case 00025: { // SRD d
            CyberWord32 oldR = processor->_regR;
            CyberWord16 lower = (oldR >> 6) & 0x03FF;
            CyberWord16 upper = (oldR >> 18) & 0x07FF;
            Cyber962PPWriteSingle(processor, d, lower);
            Cyber962PPWriteSingle(processor, d + 1, upper);
        } break;

        default:
            assert(false); // should be unreachable
            break;
    }

    return 1;
}

/// Copy the given 64-bit (well, 60-bit) CM word
static inline void Cyber962PPWriteCMWord60ToPPMWord12(struct Cyber962PP *processor, CyberWord60 word, CyberWord16 ppmAddress)
{
    CyberWord16 word12[5] = {0};
    word12[0] = (word >> 48) & 0x0FFF;
    word12[1] = (word >> 36) & 0x0FFF;
    word12[2] = (word >> 24) & 0x0FFF;
    word12[3] = (word >> 12) & 0x0FFF;
    word12[4] = (word >>  0) & 0x0FFF;
    Cyber962PPWriteMultiple(processor, ppmAddress, word12, 5);
}

static inline void Cyber962PPWriteCMWord64ToPPMWord16(struct Cyber962PP *processor, CyberWord64 word, CyberWord16 ppmAddress)
{
    CyberWord16 word16[4] = {0};
    word16[0] = (word >> 48) & 0xFFFF;
    word16[1] = (word >> 32) & 0xFFFF;
    word16[2] = (word >> 16) & 0xFFFF;
    word16[3] = (word >>  0) & 0xFFFF;
    Cyber962PPWriteMultiple(processor, ppmAddress, word16, 4);
}

static inline CyberWord60 Cyber962PPReadPPMWord12ToCMWord60(struct Cyber962PP *processor, CyberWord16 ppmAddress)
{
    CyberWord60 word60 = 0;
    CyberWord12 word12[5];
    Cyber962PPReadMultiple(processor, ppmAddress, word12, 5);
    word60 |= ((CyberWord64)(word12[0] & 0x0FFF)) << 48;
    word60 |= ((CyberWord64)(word12[1] & 0x0FFF)) << 36;
    word60 |= ((CyberWord64)(word12[2] & 0x0FFF)) << 24;
    word60 |= ((CyberWord64)(word12[3] & 0x0FFF)) << 12;
    word60 |= ((CyberWord64)(word12[4] & 0x0FFF)) <<  0;
    return word60;
}

static inline CyberWord64 Cyber962PPReadPPMWord16ToCMWord64(struct Cyber962PP *processor, CyberWord16 ppmAddress)
{
    CyberWord64 word64 = 0;
    CyberWord16 word16[4];
    Cyber962PPReadMultiple(processor, ppmAddress, word16, 4);
    word64 |= ((CyberWord64)(word16[0] & 0xFFFF)) << 48;
    word64 |= ((CyberWord64)(word16[1] & 0xFFFF)) << 32;
    word64 |= ((CyberWord64)(word16[2] & 0xFFFF)) << 16;
    word64 |= ((CyberWord64)(word16[3] & 0xFFFF)) <<  0;
    return word64;
}

/// Implementation of "Central Read" instructions.
CyberWord16 Cyber962PPInstruction_CRx(struct Cyber962PP *processor, union Cyber962PPInstructionWord instructionWord)
{
    uint16_t opcode = instructionWord._d.f | (instructionWord._d.g << 9);
    CyberWord16 d16 = instructionWord._d.d;
    struct Cyber180CMPort *port = Cyber962IOUGetCentralMemoryPort(processor->_inputOutputUnit);

    switch (opcode) {
        case 00060: { // CRD (A),d
            CyberWord48 cmAddress = Cyber962PPComputeCentralMemoryAddress(processor);
            CyberWord64 word;
            Cyber180CMPortReadWordsPhysical(port, cmAddress, &word, 1);
            Cyber962PPWriteCMWord60ToPPMWord12(processor, word & 0x0FFFFFFFFFFFFFFF, d16);
            return 1;
        } break;

        case 01060: { // CRDL (A),d
            CyberWord48 cmAddress = Cyber962PPComputeCentralMemoryAddress(processor);
            CyberWord64 word;
            Cyber180CMPortReadWordsPhysical(port, cmAddress, &word, 1);
            Cyber962PPWriteCMWord64ToPPMWord16(processor, word & 0xFFFFFFFFFFFFFFFF, d16);
            return 1;
        } break;

        case 00061: { // CRM (d),(A),m
            CyberWord48 cmAddress = Cyber962PPComputeCentralMemoryAddress(processor);
            CyberWord16 m = Cyber962PPReadSingle(processor, processor->_regP + 1);
            CyberWord12 count = Cyber962PPReadSingle(processor, d16) & 0x0FFF;
            CyberWord64 *buffer = calloc(count, sizeof(CyberWord64));
            Cyber180CMPortReadWordsPhysical(port, cmAddress, buffer, count);
            for (CyberWord12 i = 0; i < count; i++) {
                Cyber962PPWriteCMWord60ToPPMWord12(processor, buffer[i] & 0x0FFFFFFFFFFFFFFF, m + (5 * i));
            }
            free(buffer);
            return 2;
        } break;

        case 01061: { // CRML (d),(A),m
            CyberWord48 cmAddress = Cyber962PPComputeCentralMemoryAddress(processor);
            CyberWord16 m = Cyber962PPReadSingle(processor, processor->_regP + 1);
            CyberWord16 count = Cyber962PPReadSingle(processor, d16) & 0xFFFF;
            CyberWord64 *buffer = calloc(count, sizeof(CyberWord64));
            Cyber180CMPortReadWordsPhysical(port, cmAddress, buffer, count);
            for (CyberWord12 i = 0; i < count; i++) {
                Cyber962PPWriteCMWord64ToPPMWord16(processor, buffer[i] & 0xFFFFFFFFFFFFFFFF, m + (4 * i));
            }
            free(buffer);
            return 2;
        } break;

        default:
            assert(false); // should be unreachable
            break;
    }

    return 0;
}

/// Implementation of "Central Read with Lock" instructions.
CyberWord16 Cyber962PPInstruction_RDxL(struct Cyber962PP *processor, union Cyber962PPInstructionWord instructionWord)
{
    uint16_t opcode = instructionWord._d.f | (instructionWord._d.g << 9);
    CyberWord16 d16 = instructionWord._d.d;
    struct Cyber180CMPort *port = Cyber962IOUGetCentralMemoryPort(processor->_inputOutputUnit);

    switch (opcode) {
        case 01000: { // RDSL d,(A)
            CyberWord48 cmAddress = Cyber962PPComputeCentralMemoryAddress(processor);
            CyberWord16 ppmAddress = d16;
            Cyber180CMPortAcquireLock(port);
            CyberWord64 x = Cyber180CMPortReadWordPhysical_Unlocked(port, cmAddress);
            CyberWord64 y = Cyber962PPReadPPMWord16ToCMWord64(processor, ppmAddress);
            Cyber962PPWriteCMWord64ToPPMWord16(processor, x, ppmAddress);
            CyberWord64 xORy = x | y;
            Cyber180CMPortWriteWordPhysical_Unlocked(port, cmAddress, xORy);
            Cyber180CMPortRelinquishLock(port);
        } break;

        case 01001: { // RDCL d,(A)
            CyberWord48 cmAddress = Cyber962PPComputeCentralMemoryAddress(processor);
            CyberWord16 ppmAddress = d16;
            Cyber180CMPortAcquireLock(port);
            CyberWord64 x = Cyber180CMPortReadWordPhysical_Unlocked(port, cmAddress);
            CyberWord64 y = Cyber962PPReadPPMWord16ToCMWord64(processor, ppmAddress);
            Cyber962PPWriteCMWord64ToPPMWord16(processor, x, ppmAddress);
            CyberWord64 xANDy = x & y;
            Cyber180CMPortWriteWordPhysical_Unlocked(port, cmAddress, xANDy);
            Cyber180CMPortRelinquishLock(port);
        } break;

        default:
            assert(false); // should be unreachable
            break;
    }

    return 0;
}

/// Implementation of "Central Write" instructions.
CyberWord16 Cyber962PPInstruction_CWx(struct Cyber962PP *processor, union Cyber962PPInstructionWord instructionWord)
{
    uint16_t opcode = instructionWord._d.f | (instructionWord._d.g << 9);
    CyberWord16 d16 = instructionWord._d.d;
    struct Cyber180CMPort *port = Cyber962IOUGetCentralMemoryPort(processor->_inputOutputUnit);

    switch (opcode) {
        case 00062: { // CWD (A),d
            CyberWord48 cmAddress = Cyber962PPComputeCentralMemoryAddress(processor);
            CyberWord16 ppmAddress = d16 & 0x0FFF;
            CyberWord64 word60 = Cyber962PPReadPPMWord12ToCMWord60(processor, ppmAddress);
            Cyber180CMPortWriteWordsPhysical(port, cmAddress, &word60, 1);
            return 1;
        } break;

        case 01062: { // CWDL (A),d
            CyberWord48 cmAddress = Cyber962PPComputeCentralMemoryAddress(processor);
            CyberWord16 ppmAddress = d16 & 0xFFFF;
            CyberWord64 word64 = Cyber962PPReadPPMWord16ToCMWord64(processor, ppmAddress);
            Cyber180CMPortWriteWordsPhysical(port, cmAddress, &word64, 1);
            return 1;
        } break;

        case 00063: { // CWM (d),(A),m
            CyberWord48 cmAddress = Cyber962PPComputeCentralMemoryAddress(processor);
            CyberWord12 m = Cyber962PPReadSingle(processor, processor->_regP + 1);
            CyberWord16 ppmAddress = m & 0x0FFF;
            CyberWord16 count = Cyber962PPReadSingle(processor, d16);
            CyberWord60 *buffer = calloc(count, sizeof(CyberWord60));
            for (CyberWord16 i = 0; i < count; i++) {
                buffer[i] = Cyber962PPReadPPMWord12ToCMWord60(processor, ppmAddress + (i * 5)) & 0xFFFFFFFFFFFFFFFF;
            }
            Cyber180CMPortWriteWordsPhysical(port, cmAddress, buffer, count);
            free(buffer);
            return 2;
        } break;

        case 01063: { // CWML (d),(A),m
            CyberWord48 cmAddress = Cyber962PPComputeCentralMemoryAddress(processor);
            CyberWord16 m = Cyber962PPReadSingle(processor, processor->_regP + 1);
            CyberWord16 ppmAddress = m & 0xFFFF;
            CyberWord16 count = Cyber962PPReadSingle(processor, d16);
            CyberWord64 *buffer = calloc(count, sizeof(CyberWord64));
            for (CyberWord16 i = 0; i < count; i++) {
                buffer[i] = Cyber962PPReadPPMWord16ToCMWord64(processor, ppmAddress + (i * 4)) & 0xFFFFFFFFFFFFFFFF;
            }
            Cyber180CMPortWriteWordsPhysical(port, cmAddress, buffer, count);
            free(buffer);
            return 2;
        } break;

        default:
            assert(false); // should be unreachable
            break;
    }

    return 0;
}

/// Implementation of "I/O Jump" instructions.
CyberWord16 Cyber962PPInstruction_IOJ(struct Cyber962PP *processor, union Cyber962PPInstructionWord instructionWord)
{
    // TODO: Implement I/O Jump instructions.

    uint16_t opcode = instructionWord._d.f | (instructionWord._d.g << 9);

    switch (opcode) {
        case 00064: { // AJM c,m
        } break;

        case 01064: { // FSJM c,m
        } break;

        case 00065: { // IJM c,m
        } break;

        case 01065: { // FCJM c,m
        } break;

        case 00066: { // FJM c,m
        } break;

        case 00067: { // EJM c,m
        } break;

        default:
            assert(false); // should be unreachable
            break;
    }

    return 0;
}

/// Implementation of "I/O Input" instructions.
CyberWord16 Cyber962PPInstruction_IN(struct Cyber962PP *processor, union Cyber962PPInstructionWord instructionWord)
{
    // TODO: Implement I/O Input instructions.

    uint16_t opcode = instructionWord._d.f | (instructionWord._d.g << 9);

    switch (opcode) {
        case 00070: { // IANW c || IANI c
        } break;

        case 00071: { // IAM c,m
        } break;

        case 01071: { // IAPM c,m
        } break;

        default:
            assert(false); // should be unreachable
            break;
    }

    return 0;
}

/// Implementation of "I/O Output" instructions.
CyberWord16 Cyber962PPInstruction_OUT(struct Cyber962PP *processor, union Cyber962PPInstructionWord instructionWord)
{
    // TODO: Implement I/O Output instructions.

    uint16_t opcode = instructionWord._d.f | (instructionWord._d.g << 9);

    switch (opcode) {
        case 00072: { // OANW c || OANI c
        } break;

        case 00073: { // OAM c,m
        } break;

        case 01073: { // OAPM c,m
        } break;

        default:
            assert(false); // should be unreachable
            break;
    }

    return 0;
}

/// Implementation of "I/O Control" instructions.
CyberWord16 Cyber962PPInstruction_CTRL(struct Cyber962PP *processor, union Cyber962PPInstructionWord instructionWord)
{
    // TODO: Implement I/O Control instructions.

    uint16_t opcode = instructionWord._d.f | (instructionWord._d.g << 9);

    switch (opcode) {
        case 00074: { // ACNW c || ACNU c
        } break;

        case 00075: { // DCNW c || DCNU c
        } break;

        case 00076: { // FANW c || FANI c
        } break;

        case 00077: { // FNCW c || FNCI c
        } break;

        default:
            assert(false); // should be unreachable
            break;
    }

    return 0;
}

/// Implementation of "Pass" instructions.
CyberWord16 Cyber962PPInstruction_PSN(struct Cyber962PP *processor, union Cyber962PPInstructionWord instructionWord)
{
    // Do nothing but advance P.

    return 1;
}

/// Implementation of "Keypoint" instructions.
CyberWord16 Cyber962PPInstruction_KPT(struct Cyber962PP *processor, union Cyber962PPInstructionWord instructionWord)
{
    // Do nothing but set an indicator from `d` and advance P.

    // FIXME: Do something better for Keypoint.

    return 1;
}

CyberWord16 Cyber962PPInstruction_EXN(struct Cyber962PP *processor, union Cyber962PPInstructionWord instructionWord)
{
    // TODO: Implement Exchange Jump instruction.

    return 1;
}

/// Implementation of the "Monitor Exchange Jump" instruction.
CyberWord16 Cyber962PPInstruction_MXN(struct Cyber962PP *processor, union Cyber962PPInstructionWord instructionWord)
{
    // TODO: Implement Monitor Exchange Jump instruction.

    return 1;
}

/// Implementation of the "Monitor Exchange Jump to MA" instruction.
CyberWord16 Cyber962PPInstruction_MAN(struct Cyber962PP *processor, union Cyber962PPInstructionWord instructionWord)
{
    // TODO: Implement Monitor Exchange Jump to MA instruction.

    return 1;
}

/// Implementation of the "Monitor Exchange Jump to MA (2x)" instruction.
CyberWord16 Cyber962PPInstruction_MAN2(struct Cyber962PP *processor, union Cyber962PPInstructionWord instructionWord)
{
    // TODO: Implement Monitor Exchange Jump to MA (2x) instruction.

    return 1;
}

/// Implementation of "Interrupt Processor" instruction.
CyberWord16 Cyber962PPInstruction_INPN(struct Cyber962PP *processor, union Cyber962PPInstructionWord instructionWord)
{
    // TODO: Implement Interrupt Processor instruction.

    return 1;
}


CYBER_SOURCE_END
