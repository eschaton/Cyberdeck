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

#include <Cyber/Cyber962PP.h>


CYBER_SOURCE_BEGIN


/// A Cyber 962 Peripheral Processor instruction word is a bit field.
union Cyber962PPInstructionWord {
    CyberWord16 _raw;
    struct PPFormat_d {
        unsigned g : 1;
        unsigned e : 3;
        unsigned f : 6;
        unsigned d : 6;
    } _d;
    struct PPFormat_sc {
        unsigned g : 1;
        unsigned e : 3;
        unsigned f : 6;
        unsigned s : 1;
        unsigned c : 5;
    } _sc;
};


Cyber962PPInstruction _Nullable Cyber962PPInstructionDecode(struct Cyber962PP *processor, CyberWord16 word, CyberWord16 address)
{
    union Cyber962PPInstructionWord instructionWord;
    instructionWord._raw = word;
    uint16_t opcode = instructionWord._d.f | (instructionWord._d.g << 9);
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
            return Cyber962PPInstruction_LDx;

            // Store
        case 00034: // STD (d)
        case 01034: // STDL (d)
        case 00044: // STI ((d))
        case 01044: // STIL ((d))
        case 00054: // STM (m+(d))
        case 01054: // STML (m+(d))
            return Cyber962PPInstruction_STx;

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
            return Cyber962PPInstruction_ADx;

            // Subtract
        case 00017: // SBN d
        case 00032: // SBD (d)
        case 01032: // SBDL (d)
        case 00042: // SBI ((d))
        case 01042: // SBIL ((d))
        case 00052: // SBM (m+(d))
        case 01052: // SBML (m+(d))
            return Cyber962PPInstruction_SBx;

            // Logical Instructions

            // Shift
        case 00010: // SHN d
            return Cyber962PPInstruction_SHN;

            // Logical Difference
        case 00011: // LMN d
        case 00023: // LMC d,m
        case 00033: // LMD (d)
        case 01033: // LMDL (d)
        case 00043: // LMI ((d))
        case 01043: // LMIL ((d))
        case 00053: // LMM (m+(d))
        case 01053: // LMNL (m+(d))
            return Cyber962PPInstruction_LMx;

            // Logical Product
        case 00012: // LPN d
        case 00022: // LPC m,d
        case 01022: // LPDL (d)
        case 01023: // LPIL ((d))
        case 01024: // LPML (m+(d))
            return Cyber962PPInstruction_LPx;

            // Selective Clear
        case 00013: // SCN d
            return Cyber962PPInstruction_SCN;

            // Replace Instructions

            // Replace Add
        case 00035: // RAD (d)
        case 01035: // RADL (d)
        case 00045: // RAI ((d))
        case 01045: // RAIL ((d))
        case 00055: // RAM (m+(d))
        case 01055: // RAML (m+(d))
            return Cyber962PPInstruction_RAx;

            // Replace Add One
        case 00036: // AOD (d)
        case 01036: // AODL (d)
        case 00046: // AOI ((d))
        case 01046: // AOIL ((d))
        case 00056: // AOM (m+(d))
        case 01056: // AOML (m+(d))
            return Cyber962PPInstruction_AOx;

            // Replace Subtract
        case 00037: // SOD (d)
        case 01037: // SODL (d)
        case 00047: // SOI ((d))
        case 01047: // SOIL ((d))
        case 00057: // SOM (m+(d))
        case 01057: // SOML (d+(d))
            return Cyber962PPInstruction_SOx;

            // Branch Instructions

        case 00001: // LJM (m+(d))
        case 00002: // RJM (m+(d))
            return Cyber962PPInstruction_xJM;
        case 00003: // UJN d
        case 00004: // ZJN d
        case 00005: // NJN d
        case 00006: // PJN d
        case 00007: // MJN d
            return Cyber962PPInstruction_xJN;

            // Central Memory Access Instructions
            // FIXME: Add functions for these

        case 00024: // LRD d
        case 00025: // SRD d
        case 00060: // CRD (A),d
        case 01060: // CRDL (A),d
        case 00061: // CRM (d),(A),m
        case 01061: // CRML (d),(A),m
        case 01000: // RDSL d,(A)
        case 01001: // RDCL d,(A)
        case 00062: // CWD (A),(d)
        case 01062: // CWDL (A),d
        case 00063: // CWM (d),(A),m
        case 01063: // CWML (d),(A),m

            // Input/Output Instructions
            // FIXME: Add functions for these

        case 00064: // AJM c,m || SCF c,m
        case 01064: // FSJM c,m
        case 00065: // IJM c,m || CCF c,m
        case 01065: // FCJM c,m
        case 00066: // FJM c,m || SFM c,m
        case 00067: // EJM c,m || CFM c,m
        case 00070: // IANW c || IANI c
        case 00071: // IAM c,m
        case 01071: // IAPM c,m
        case 00072: // OANW c || OANI c
        case 00073: // OAM c,m
        case 01073: // OAPM c,m
        case 00074: // ACNW c || ACNU c
        case 00075: // DCNW c || DCNU c
        case 00076: // FANW c || FANI c
        case 00077: // FNCW c || FNCI c

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
            return Cyber962PPInstruction_PSN;

            // Keypoint Instruction
        case 00027: // KPT d
            return Cyber962PPInstruction_KPT;

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
                    return Cyber962PPInstruction_EXN;

                case 010: // MXN d
                    return Cyber962PPInstruction_MXN;

                case 020: // MAN d
                    return Cyber962PPInstruction_MAN;

                case 030: // MAN 2*d
                case 031: // MAN 2*d
                case 032: // MAN 2*d
                case 033: // MAN 2*d
                case 034: // MAN 2*d
                case 035: // MAN 2*d
                case 036: // MAN 2*d
                case 037: // MAN 2*d
                    return Cyber962PPInstruction_MAN2;

                default: // none
                    return NULL;
            }
        } break;
        case 01026: // INPN d
            return Cyber962PPInstruction_INPN;
    }

    return NULL;
}


// MARK: - Instruction Implementations

bool Cyber962PPInstruction_LDx(struct Cyber962PP *processor, CyberWord16 word)
{
    return true;
}

bool Cyber962PPInstruction_STx(struct Cyber962PP *processor, CyberWord16 word)
{
    return true;
}

bool Cyber962PPInstruction_ADx(struct Cyber962PP *processor, CyberWord16 word)
{
    return true;
}

bool Cyber962PPInstruction_SBx(struct Cyber962PP *processor, CyberWord16 word)
{
    return true;
}

bool Cyber962PPInstruction_SHN(struct Cyber962PP *processor, CyberWord16 word)
{
    return true;
}

bool Cyber962PPInstruction_LMx(struct Cyber962PP *processor, CyberWord16 word)
{
    return true;
}

bool Cyber962PPInstruction_LPx(struct Cyber962PP *processor, CyberWord16 word)
{
    return true;
}

bool Cyber962PPInstruction_SCN(struct Cyber962PP *processor, CyberWord16 word)
{
    return true;
}

bool Cyber962PPInstruction_RAx(struct Cyber962PP *processor, CyberWord16 word)
{
    return true;
}

bool Cyber962PPInstruction_AOx(struct Cyber962PP *processor, CyberWord16 word)
{
    return true;
}

bool Cyber962PPInstruction_SOx(struct Cyber962PP *processor, CyberWord16 word)
{
    return true;
}

bool Cyber962PPInstruction_xJM(struct Cyber962PP *processor, CyberWord16 word)
{
    return true;
}

bool Cyber962PPInstruction_xJN(struct Cyber962PP *processor, CyberWord16 word)
{
    return true;
}

bool Cyber962PPInstruction_PSN(struct Cyber962PP *processor, CyberWord16 word)
{
    return true;
}

bool Cyber962PPInstruction_KPT(struct Cyber962PP *processor, CyberWord16 word)
{
    return true;
}

bool Cyber962PPInstruction_EXN(struct Cyber962PP *processor, CyberWord16 word)
{
    return true;
}

bool Cyber962PPInstruction_MXN(struct Cyber962PP *processor, CyberWord16 word)
{
    return true;
}

bool Cyber962PPInstruction_MAN(struct Cyber962PP *processor, CyberWord16 word)
{
    return true;
}

bool Cyber962PPInstruction_MAN2(struct Cyber962PP *processor, CyberWord16 word)
{
    return true;
}

bool Cyber962PPInstruction_INPN(struct Cyber962PP *processor, CyberWord16 word)
{
    return true;
}


CYBER_SOURCE_END
