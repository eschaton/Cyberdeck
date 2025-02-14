//
//  Cyber180CPInstructions.c
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

#include "Cyber180CPInstructions_Internal.h"

#include "Cyber180CP_Internal.h"

#include <assert.h>
#include <stdbool.h>


CYBER_SOURCE_BEGIN


Cyber180CPInstruction _Nullable Cyber180CPInstructionDecode(struct Cyber180CP *processor, union Cyber180CPInstructionWord instructionWord, CyberWord48 address)
{
    // All opcodes are 8 bits; even SjkiD instructions effectively use 8-bit opcodes, just putting S in the lower bits. So instruction functions can be handled entirely via table lookup rather than any more complicated dispatching.

    CyberWord8 opcode = instructionWord._raw >> 24;

    static Cyber180CPInstruction instructions[256] = {
        Cyber180CPInstruction_HALT, // 0x00
        Cyber180CPInstruction_SYNC, // 0x01
        Cyber180CPInstruction_EXCHANGE, // 0x02
        Cyber180CPInstruction_INTRUPT, // 0x03
        Cyber180CPInstruction_RETURN, // 0x04
        Cyber180CPInstruction_PURGE, // 0x05
        Cyber180CPInstruction_POP, // 0x06
        Cyber180CPInstruction_PSFSA, // 0x07
        Cyber180CPInstruction_CPYTX, // 0x08
        Cyber180CPInstruction_CPYAA, // 0x09
        Cyber180CPInstruction_CPYXA, // 0x0a
        Cyber180CPInstruction_CYPAX, // 0x0b
        Cyber180CPInstruction_CPYRR, // 0x0c
        Cyber180CPInstruction_CPYXX, // 0x0d
        Cyber180CPInstruction_CPYSX, // 0x0e
        Cyber180CPInstruction_CPYXS,  // 0x0f

        Cyber180CPInstruction_INCX, // 0x10
        Cyber180CPInstruction_DECX, // 0x11
        NULL, // 0x12
        NULL, // 0x13
        Cyber180CPInstruction_LBSET, // 0x14
        NULL, // 0x15
        Cyber180CPInstruction_TPAGE, // 0x16
        Cyber180CPInstruction_LPAGE, // 0x17
        Cyber180CPInstruction_IORX, // 0x18
        Cyber180CPInstruction_XORX, // 0x19
        Cyber180CPInstruction_ANDX, // 0x1a
        Cyber180CPInstruction_NOTX, // 0x1b
        Cyber180CPInstruction_INHX, // 0x1c
        NULL, // 0x1d
        Cyber180CPInstruction_MARK, // 0x1e
        Cyber180CPInstruction_ENTZOS,  // 0x1f

        Cyber180CPInstruction_ADDR, // 0x20
        Cyber180CPInstruction_SUBR, // 0x21
        Cyber180CPInstruction_MULR, // 0x22
        Cyber180CPInstruction_DIVR, // 0x23
        Cyber180CPInstruction_ADDX, // 0x24
        Cyber180CPInstruction_SUBX, // 0x25
        Cyber180CPInstruction_MULX, // 0x26
        Cyber180CPInstruction_DIVX, // 0x27
        Cyber180CPInstruction_INCR, // 0x28
        Cyber180CPInstruction_DECR, // 0x29
        Cyber180CPInstruction_ADDAX, // 0x2a
        NULL, // 0x2b
        Cyber180CPInstruction_CMPR, // 0x2c
        Cyber180CPInstruction_CMPX, // 0x2d
        Cyber180CPInstruction_BRREL, // 0x2e
        Cyber180CPInstruction_BRDIR,  // 0x2f

        Cyber180CPInstruction_ADDF, // 0x30
        Cyber180CPInstruction_SUBF, // 0x31
        Cyber180CPInstruction_MULF, // 0x32
        Cyber180CPInstruction_DIVF, // 0x33
        Cyber180CPInstruction_ADDD, // 0x34
        Cyber180CPInstruction_SUBD, // 0x35
        Cyber180CPInstruction_MULD, // 0x36
        Cyber180CPInstruction_DIVD, // 0x37
        NULL, // 0x38
        Cyber180CPInstruction_ENTX, // 0x39
        Cyber180CPInstruction_CNIF, // 0x3a
        Cyber180CPInstruction_CNFI, // 0x3b
        Cyber180CPInstruction_CMPF, // 0x3c
        Cyber180CPInstruction_ENTP, // 0x3d
        Cyber180CPInstruction_ENTN, // 0x3e
        Cyber180CPInstruction_ENTL,  // 0x3f

        Cyber180CPInstruction_ADDFV, // 0x40
        Cyber180CPInstruction_SUBFV, // 0x41
        Cyber180CPInstruction_MULFV, // 0x42
        Cyber180CPInstruction_DIVFV, // 0x43
        Cyber180CPInstruction_ADDXV, // 0x44
        Cyber180CPInstruction_SUBXV, // 0x45
        NULL, // 0x46
        NULL, // 0x47
        Cyber180CPInstruction_IORV, // 0x48
        Cyber180CPInstruction_XORV, // 0x49
        Cyber180CPInstruction_ANDV, // 0x4a
        Cyber180CPInstruction_CNIFV, // 0x4b
        Cyber180CPInstruction_CNFIV, // 0x4c
        Cyber180CPInstruction_SHFV, // 0x4d
        NULL, // 0x4e
        NULL, // 0x4f

        Cyber180CPInstruction_COMPEQV, // 0x50
        Cyber180CPInstruction_CMPLTV, // 0x51
        Cyber180CPInstruction_CMPGEV, // 0x52
        Cyber180CPInstruction_CMPNEV, // 0x53
        Cyber180CPInstruction_MRGV, // 0x54
        Cyber180CPInstruction_GTHV, // 0x55
        Cyber180CPInstruction_SCTV, // 0x56
        Cyber180CPInstruction_SUMFV, // 0x57
        Cyber180CPInstruction_TPSFV, // 0x58
        Cyber180CPInstruction_TPDFV, // 0x59
        Cyber180CPInstruction_TSPFV, // 0x5a
        Cyber180CPInstruction_TDPFV, // 0x5b
        Cyber180CPInstruction_SUMPFV, // 0x5c
        Cyber180CPInstruction_GTHIV, // 0x5d
        Cyber180CPInstruction_SCTIV, // 0x5e

        NULL, // 0x60
        NULL, // 0x61
        NULL, // 0x62
        NULL, // 0x63
        NULL, // 0x64
        NULL, // 0x65
        NULL, // 0x66
        NULL, // 0x67
        NULL, // 0x68
        NULL, // 0x69
        NULL, // 0x6a
        NULL, // 0x6b
        NULL, // 0x6c
        NULL, // 0x6d
        NULL, // 0x6e
        NULL, // 0x6f

        Cyber180CPInstruction_ADDN, // 0x70
        Cyber180CPInstruction_SUBN, // 0x71
        Cyber180CPInstruction_MULN, // 0x72
        Cyber180CPInstruction_DIVN, // 0x73
        Cyber180CPInstruction_CMPN, // 0x74
        Cyber180CPInstruction_MOVN, // 0x75
        Cyber180CPInstruction_MOVB, // 0x76
        Cyber180CPInstruction_CMPB, // 0x77
        NULL, // 0x78
        NULL, // 0x79
        NULL, // 0x7a
        NULL, // 0x7b
        NULL, // 0x7c
        NULL, // 0x7d
        NULL, // 0x7e
        NULL, // 0x7f

        Cyber180CPInstruction_LMULT, // 0x80
        Cyber180CPInstruction_SMULT, // 0x81
        Cyber180CPInstruction_LX, // 0x82
        Cyber180CPInstruction_SX, // 0x83
        Cyber180CPInstruction_LA, // 0x84
        Cyber180CPInstruction_SA, // 0x85
        Cyber180CPInstruction_LBYTP, // 0x86
        Cyber180CPInstruction_ENTC, // 0x87
        Cyber180CPInstruction_LBIT, // 0x88
        Cyber180CPInstruction_SBIT, // 0x89
        Cyber180CPInstruction_ADDRQ, // 0x8a
        Cyber180CPInstruction_ADDXQ, // 0x8b
        Cyber180CPInstruction_MULRQ, // 0x8c
        Cyber180CPInstruction_ENTE, // 0x8d
        Cyber180CPInstruction_ADDAQ, // 0x8e
        Cyber180CPInstruction_ADDPXQ, // 0x8f

        Cyber180CPInstruction_BRREQ, // 0x90
        Cyber180CPInstruction_BRRNE, // 0x91
        Cyber180CPInstruction_BRRGT, // 0x92
        Cyber180CPInstruction_BRRGE, // 0x93
        Cyber180CPInstruction_BRXEQ, // 0x94
        Cyber180CPInstruction_BRXNE, // 0x95
        Cyber180CPInstruction_BRXGT, // 0x96
        Cyber180CPInstruction_BRXGE, // 0x97
        Cyber180CPInstruction_BRFEQ, // 0x98
        Cyber180CPInstruction_BRFNE, // 0x99
        Cyber180CPInstruction_BRFGT, // 0x9a
        Cyber180CPInstruction_BRFGE, // 0x9b
        Cyber180CPInstruction_BRINC, // 0x9c
        Cyber180CPInstruction_BRSEG, // 0x9d
        Cyber180CPInstruction_BRxxx, // 0x9e
        Cyber180CPInstruction_BRCR,  // 0x9f

        Cyber180CPInstruction_LAI, // 0xa0
        Cyber180CPInstruction_SAI, // 0xa1
        Cyber180CPInstruction_LXI, // 0xa2
        Cyber180CPInstruction_SXI, // 0xa3
        Cyber180CPInstruction_LBYT, // 0xa4
        Cyber180CPInstruction_SBYT, // 0xa5
        NULL, // 0xa6
        Cyber180CPInstruction_ADDAD, // 0xa7
        Cyber180CPInstruction_SHFC, // 0xa8
        Cyber180CPInstruction_SHFX, // 0xa9
        Cyber180CPInstruction_SHFR, // 0xaa
        NULL, // 0xab
        Cyber180CPInstruction_ISOM, // 0xac
        Cyber180CPInstruction_ISOB, // 0xad
        Cyber180CPInstruction_INSB, // 0xae
        NULL, // 0xaf

        Cyber180CPInstruction_CALLREL, // 0xb0
        Cyber180CPInstruction_KEYPOINT, // 0xb1
        Cyber180CPInstruction_MULXQ, // 0xb2
        Cyber180CPInstruction_ENTA, // 0xb3
        Cyber180CPInstruction_CMPXA, // 0xb4
        Cyber180CPInstruction_CALLSEG, // 0xb5
        NULL, // 0xb6
        NULL, // 0xb7
        NULL, // 0xb8
        NULL, // 0xb9
        NULL, // 0xba
        NULL, // 0xbb
        NULL, // 0xbc
        Cyber180CPInstruction_RESERVEDBD, // 0xbd
        Cyber180CPInstruction_RESERVEDBE, // 0xbe
        Cyber180CPInstruction_RESERVEDBF, // 0xbf

        Cyber180CPInstruction_EXECUTE, // 0xc0
        Cyber180CPInstruction_EXECUTE, // 0xc1
        Cyber180CPInstruction_EXECUTE, // 0xc2
        Cyber180CPInstruction_EXECUTE, // 0xc3
        Cyber180CPInstruction_EXECUTE, // 0xc4
        Cyber180CPInstruction_EXECUTE, // 0xc5
        Cyber180CPInstruction_EXECUTE, // 0xc6
        Cyber180CPInstruction_EXECUTE, // 0xc7
        Cyber180CPInstruction_EXECUTE, // 0xc8
        Cyber180CPInstruction_EXECUTE, // 0xc9
        Cyber180CPInstruction_EXECUTE, // 0xca
        Cyber180CPInstruction_EXECUTE, // 0xcb
        Cyber180CPInstruction_EXECUTE, // 0xcc
        Cyber180CPInstruction_EXECUTE, // 0xcd
        Cyber180CPInstruction_EXECUTE, // 0xce
        Cyber180CPInstruction_EXECUTE, // 0xcf

        Cyber180CPInstruction_LBYTS, // 0xd0
        Cyber180CPInstruction_LBYTS, // 0xd1
        Cyber180CPInstruction_LBYTS, // 0xd2
        Cyber180CPInstruction_LBYTS, // 0xd3
        Cyber180CPInstruction_LBYTS, // 0xd4
        Cyber180CPInstruction_LBYTS, // 0xd5
        Cyber180CPInstruction_LBYTS, // 0xd6
        Cyber180CPInstruction_LBYTS, // 0xd7
        Cyber180CPInstruction_SBYTS, // 0xd8
        Cyber180CPInstruction_SBYTS, // 0xd9
        Cyber180CPInstruction_SBYTS, // 0xda
        Cyber180CPInstruction_SBYTS, // 0xdb
        Cyber180CPInstruction_SBYTS, // 0xdc
        Cyber180CPInstruction_SBYTS, // 0xdd
        Cyber180CPInstruction_SBYTS, // 0xde
        Cyber180CPInstruction_SBYTS, // 0xdf

        NULL, // 0xe0
        NULL, // 0xe1
        NULL, // 0xe2
        NULL, // 0xe3
        Cyber180CPInstruction_SCLN, // 0xe4
        Cyber180CPInstruction_SCLR, // 0xe5
        NULL, // 0xe6
        NULL, // 0xe7
        NULL, // 0xe8
        Cyber180CPInstruction_CMPC, // 0xe9
        NULL, // 0xea
        Cyber180CPInstruction_TRANB, // 0xeb
        NULL, // 0xec
        Cyber180CPInstruction_EDIT, // 0xed
        NULL, // 0xee
        NULL, // 0xef

        NULL, // 0xf0
        NULL, // 0xf1
        NULL, // 0xf2
        Cyber180CPInstruction_SCNB, // 0xf3
        NULL, // 0xf4
        NULL, // 0xf5
        NULL, // 0xf6
        NULL, // 0xf7
        NULL, // 0xf8
        Cyber180CPInstruction_MOVI, // 0xf9
        Cyber180CPInstruction_CMPI, // 0xfa
        Cyber180CPInstruction_ADDI, // 0xfb
        NULL, // 0xfc
        NULL, // 0xfd
        NULL, // 0xfe
        NULL, // 0xff
    };

    return instructions[opcode];
}


// MARK: - Instruction Implementation Utilities

bool IN_RANGE(uint8_t value, uint8_t lower, uint8_t upper)
{
    return (value >= lower) && (value <= upper);
}


enum Cyber180CPInstructionType Cyber180CPGetInstructionType(union Cyber180CPInstructionWord instructionWord)
{
    CyberWord8 opcode = instructionWord._raw >> 24;

    if      (IN_RANGE(opcode, 0x00, 0x3f)) { return Cyber180CPInstructionType_jk; }    // jk
    else if (IN_RANGE(opcode, 0x40, 0x6f)) { return Cyber180CPInstructionType_jkiD; }  // jkiD
    else if (IN_RANGE(opcode, 0x70, 0x7f)) { return Cyber180CPInstructionType_jk; }    // jk(2)
    else if (IN_RANGE(opcode, 0x80, 0x9f)) { return Cyber180CPInstructionType_jkQ; }   // jkQ
    else if (IN_RANGE(opcode, 0xa0, 0xaf)) { return Cyber180CPInstructionType_jkiD; }  // jkiD
    else if (IN_RANGE(opcode, 0xb0, 0xbf)) { return Cyber180CPInstructionType_jkQ; }   // jkQ
    else if (IN_RANGE(opcode, 0xc0, 0xdf)) { return Cyber180CPInstructionType_SjkiD; } // SjkiD
    else if (IN_RANGE(opcode, 0xe0, 0xef)) { return Cyber180CPInstructionType_jkiD; }  // jkiD(2)
    else if (IN_RANGE(opcode, 0xf0, 0xff)) { return Cyber180CPInstructionType_jkiD; }  // jkiD(1)
    else {
        assert(false); // Should be unreachable.
    }
}

CyberWord64 Cyber180CPInstructionAdvance(union Cyber180CPInstructionWord instructionWord)
{
    switch (Cyber180CPGetInstructionType(instructionWord)) {
        case Cyber180CPInstructionType_jk:    return 2;
        case Cyber180CPInstructionType_jkiD:  return 4;
        case Cyber180CPInstructionType_SjkiD: return 4;
        case Cyber180CPInstructionType_jkQ:   return 4;
    }
}


int32_t Signed32FromSigned16ViaExtend(int16_t word16)
{
    return word16;
}

int64_t Signed64FromSigned16ViaExtend(int16_t word16)
{
    return word16;
}

CyberWord64 Cyber180CPInstruction_CalculateBitMask(CyberWord64 bit_pos, CyberWord64 bit_len)
{
    CyberWord64 bits = 0;
    for (CyberWord64 i = 0; i < bit_len; i++) {
        bits |= (1 << i);
    }
    CyberWord64 mask = bits << (63 - bit_len - 1);
    return mask;
}

CyberWord48 Cyber180CPInstruction_CalculateAddressUsingSignedDisplacement16(CyberWord48 Aj, CyberWord16 Q)
{
    int16_t signed_Q = Q;
    int32_t signed_displacement = signed_Q << 3;
    uint32_t unsigned_AjR32 = Aj & 0x0000FFFFFFFF;
    uint32_t unsigned_adjusted_AjR32 = (unsigned_AjR32 + signed_displacement);
    CyberWord48 PVA = (Aj & 0xFFFF00000000) | ((CyberWord48) unsigned_adjusted_AjR32);
    return PVA;
}

CyberWord48 Cyber180CPInstruction_CalculateAddressUsingIndex32WithDisplacement12(CyberWord48 Aj, CyberWord32 XiR, CyberWord12 D)
{
    uint32_t unsigned_displacement = D;
    uint32_t unsigned_index = XiR;
    uint32_t unsigned_AjR32 = Aj & 0x0000FFFFFFFF;
    uint32_t unsigned_adjusted_AjR32 = unsigned_AjR32 + (unsigned_index + unsigned_displacement);
    CyberWord48 PVA = (Aj & 0xFFFF00000000) | ((CyberWord48) unsigned_adjusted_AjR32);
    return PVA;
}

CyberWord48 Cyber180CPInstruction_CalculateAddressUsingIndex32WithDisplacement12Times8(CyberWord48 Aj, CyberWord32 XiR, CyberWord12 D)
{
    uint32_t unsigned_displacement = ((uint32_t)D) << 3;
    uint32_t unsigned_index = XiR << 3;
    uint32_t unsigned_AjR32 = Aj & 0x0000FFFFFFFF;
    uint32_t unsigned_adjusted_AjR32 = unsigned_AjR32 + (unsigned_index + unsigned_displacement);
    CyberWord48 PVA = (Aj & 0xFFFF00000000) | ((CyberWord48) unsigned_adjusted_AjR32);
    return PVA;
}


// MARK: - Instruction Implementations

CyberWord64 Cyber180CPInstruction_HALT(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_SYNC(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_EXCHANGE(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_INTRUPT(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_RETURN(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_PURGE(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_POP(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_PSFSA(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_CPYTX(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_CPYAA(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_CPYXA(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_CYPAX(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_CPYRR(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_CPYXX(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_CPYSX(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_CPYXS(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_INCX(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_DECX(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_LBSET(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_TPAGE(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_LPAGE(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_IORX(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_XORX(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_ANDX(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_NOTX(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_INHX(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_MARK(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_ENTZOS(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_ADDR(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_SUBR(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_MULR(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_DIVR(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_ADDX(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_SUBX(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_MULX(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_DIVX(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_INCR(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_DECR(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_ADDAX(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_CMPR(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_CMPX(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_BRREL(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_BRDIR(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_ADDF(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_SUBF(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_MULF(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_DIVF(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_ADDD(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_SUBD(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_MULD(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_DIVD(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


/// Enter X1 with logical jk (2.2.6.3.b, 39jk)
CyberWord64 Cyber180CPInstruction_ENTX(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    CyberWord64 immediate = (((CyberWord64) word._jk.j) << 4) | ((CyberWord64) word._jk.k);
    Cyber180CPSetX(processor, 1, immediate);
    return 2;
}


CyberWord64 Cyber180CPInstruction_CNIF(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_CNFI(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_CMPF(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


/// Enter Xk with plus j (2.2.6.1.a, 3Djk)
CyberWord64 Cyber180CPInstruction_ENTP(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    CyberWord64 immediate = word._jk.j;
    Cyber180CPSetX(processor, word._jk.k, immediate);
    return 2;
}


/// Enter Xk with minus j (2.2.6.1.b, 3Ejk)
CyberWord64 Cyber180CPInstruction_ENTN(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    CyberWord64 immediate = word._jk.j;
    Cyber180CPSetX(processor, word._jk.k, ~immediate);
    return 2;
}


/// Enter X0 with logical jk (2.2.6.3.a, 3Fjk)
CyberWord64 Cyber180CPInstruction_ENTL(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    CyberWord64 immediate = (((CyberWord64) word._jk.j) << 4) | ((CyberWord64) word._jk.k);
    Cyber180CPSetX(processor, 0, immediate);
    return 2;
}


CyberWord64 Cyber180CPInstruction_ADDFV(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_SUBFV(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_MULFV(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_DIVFV(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_ADDXV(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_SUBXV(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_IORV(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_XORV(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_ANDV(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_CNIFV(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_CNFIV(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_SHFV(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_COMPEQV(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_CMPLTV(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_CMPGEV(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_CMPNEV(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_MRGV(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_GTHV(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_SCTV(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_SUMFV(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_TPSFV(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_TPDFV(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_TSPFV(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_TDPFV(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_SUMPFV(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_GTHIV(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_SCTIV(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_ADDN(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_SUBN(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_MULN(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_DIVN(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_CMPN(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_MOVN(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_MOVB(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_CMPB(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_LMULT(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_SMULT(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


/// Load `Xk` from (`Aj` displaced by `8*Q`) (2.2.1.2.b, `82jkQ`)
CyberWord64 Cyber180CPInstruction_LX(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    CyberWord48 Aj = Cyber180CPGetA(processor, word._jkQ.j);
    CyberWord16 Q = word._jkQ.Q;
    CyberWord64 sourcePVA = Cyber180CPInstruction_CalculateAddressUsingSignedDisplacement16(Aj, Q);
    if ((sourcePVA % 8) != 0) {
        // TODO: Address Specification Error (2.8.1.5)
    }
    CyberWord64 value;
    Cyber180CPReadBytes(processor, sourcePVA, (CyberWord8 *)&value, 8);
    Cyber180CPSetX(processor, word._jkQ.k, CyberWord64Swap(value));
    return 4;
}


/// Store `Xk` at (`Aj` displaced by `8*Q`) (2.2.1.2.d, `83jkQ`)
CyberWord64 Cyber180CPInstruction_SX(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    CyberWord48 Aj = Cyber180CPGetA(processor, word._jkQ.j);
    CyberWord16 Q = word._jkQ.Q;
    CyberWord64 destinationPVA = Cyber180CPInstruction_CalculateAddressUsingSignedDisplacement16(Aj, Q);
    if ((destinationPVA % 8) != 0) {
        // TODO: Address Specification Error (2.8.1.5)
    }
    CyberWord64 Xk = Cyber180CPGetX(processor, word._jkQ.k);
    CyberWord64 value = CyberWord64Swap(Xk);
    Cyber180CPWriteBytes(processor, destinationPVA, (CyberWord8 *)&value, 8);
    return 4;
}


CyberWord64 Cyber180CPInstruction_LA(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


/// Store Ak at (Aj displaced by Q) (2.2.1.6, 85jkQ)
CyberWord64 Cyber180CPInstruction_SA(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    int64_t Ak = processor->_regA[word._jkQ.k] & 0x0000FFFFFFFFFFFF;
    int64_t Aj = processor->_regA[word._jkQ.j] & 0x0000FFFFFFFFFFFF;
    int64_t signed_Q = Signed32FromSigned16ViaExtend(word._jkQ.Q);
    CyberWord48 AjQ = (Aj + signed_Q) & 0x0000FFFFFFFFFFFF;

    CyberWord8 *pAk = ((CyberWord8 *)&Ak) + 2;
    Cyber180CPWriteBytes(processor, AjQ, pAk, 6);

    return 4;
}


CyberWord64 Cyber180CPInstruction_LBYTP(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_ENTC(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_LBIT(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_SBIT(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_ADDRQ(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_ADDXQ(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_MULRQ(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


/// Enter Xk, Signed Immediate (2.2.6.2, 8DjkQ)
CyberWord64 Cyber180CPInstruction_ENTE(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    int64_t signed_Q = Signed64FromSigned16ViaExtend(word._jkQ.Q);
    int k = word._jkQ.k;
    Cyber180CPSetX(processor, k, signed_Q);
    return 4;
}


CyberWord64 Cyber180CPInstruction_ADDAQ(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_ADDPXQ(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}



CyberWord64 Cyber180CPInstruction_BRREQ(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_BRRNE(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_BRRGT(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_BRRGE(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_BRXEQ(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_BRXNE(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_BRXGT(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_BRXGE(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_BRFEQ(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_BRFNE(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_BRFGT(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_BRFGE(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_BRINC(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_BRSEG(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_BRxxx(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_BRCR(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_LAI(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_SAI(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


/// Load `Xk` from (`Aj` displaced by `8*D` and indexed by `8*XiR`) (2.2.1.2.a, `A2jkiD`)
CyberWord64 Cyber180CPInstruction_LXI(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    uint32_t XiR = (Cyber180CPGetXOr0(processor, word._jkiD.i) & 0x00000000FFFFFFFF);
    CyberWord48 Aj = Cyber180CPGetA(processor, word._jkiD.j);
    CyberWord12 D = word._jkiD.D;
    CyberWord48 sourcePVA = Cyber180CPInstruction_CalculateAddressUsingIndex32WithDisplacement12Times8(Aj, XiR, D);
    if ((sourcePVA % 8) != 0) {
        // TODO: Address Specification Error (2.8.1.5)
    }
    CyberWord64 value;
    Cyber180CPReadBytes(processor, sourcePVA, (CyberWord8 *)&value, 8);
    Cyber180CPSetX(processor, word._jkQ.k, CyberWord64Swap(value));
    return 4;
}


/// Store `Xk` from (`Aj` displaced by `8*D` and indexed by `8*XiR`) (2.2.1.2.c, `A3jkiD`)
CyberWord64 Cyber180CPInstruction_SXI(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    uint32_t XiR = (Cyber180CPGetXOr0(processor, word._jkiD.i) & 0x00000000FFFFFFFF);
    CyberWord48 Aj = Cyber180CPGetA(processor, word._jkiD.j);
    CyberWord12 D = word._jkiD.D;
    CyberWord48 destinationPVA = Cyber180CPInstruction_CalculateAddressUsingIndex32WithDisplacement12Times8(Aj, XiR, D);
    if ((destinationPVA % 8) != 0) {
        // TODO: Address Specification Error (2.8.1.5)
    }
    CyberWord64 Xk = Cyber180CPGetX(processor, word._jkQ.k);
    CyberWord64 value = CyberWord64Swap(Xk);
    Cyber180CPWriteBytes(processor, destinationPVA, (CyberWord8 *)&value, 8);
    return 4;
}


/// Load Bytes to `Xk` from (`Aj` displaced by `D` and indexed by `XiR`), Length Per `X0` (2.2.1.3.a, `A4jkiD`)
///
/// This should be the same as `LBYTS` except instead of `S` the number of bytes is specified by the rightmost 3 bits of `X0` plus `1`.
CyberWord64 Cyber180CPInstruction_LBYT(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    CyberWord48 Aj = Cyber180CPGetA(processor, word._jkiD.j);
    CyberWord32 XiR = Cyber180CPGetXOr0(processor, word._jkiD.i) & 0x00000000FFFFFFFF;
    CyberWord12 D = word._jkiD.D;

    CyberWord48 sourcePVA = Cyber180CPInstruction_CalculateAddressUsingIndex32WithDisplacement12(Aj, XiR, D);
    CyberWord64 X0 = Cyber180CPGetX(processor, 0);
    CyberWord32 count = (X0 & 0x0000000000000007LL) + 1;

    CyberWord8 bytes[8] = { 0 };
    Cyber180CPReadBytes(processor, sourcePVA, bytes, count);

    // Right-justify the bytes before assigning to Xk.
    CyberWord64 value = ((  (((CyberWord64)bytes[0]) << 56) | (((CyberWord64)bytes[1]) << 48)
                          | (((CyberWord64)bytes[2]) << 40) | (((CyberWord64)bytes[3]) << 32)
                          | (((CyberWord64)bytes[4]) << 24) | (((CyberWord64)bytes[5]) << 16)
                          | (((CyberWord64)bytes[6]) <<  8) | (((CyberWord64)bytes[7]) <<  0))
                         >> ((8 - ((CyberWord64)count)) * 8));

    // Don't need to swap after load because the above swaps for us if necessary.
    Cyber180CPSetX(processor, word._jkiD.k, value);

    return 4;
}


/// Store Bytes from `Xk` at (`Aj` displaced by `D` and indexed by `XiR`), Length Per `X0` (2.2.1.3.a, `A4jkiD`)
///
/// This should be the same as `SBYTS` except instead of `S` the number of bytes is specified by the rightmost 3 bits of `X0` plus `1`.
CyberWord64 Cyber180CPInstruction_SBYT(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    CyberWord48 Aj = Cyber180CPGetA(processor, word._jkiD.j);
    CyberWord32 XiR = Cyber180CPGetXOr0(processor, word._jkiD.i) & 0x00000000FFFFFFFF;
    CyberWord12 D = word._jkiD.D;

    CyberWord48 destinationPVA = Cyber180CPInstruction_CalculateAddressUsingIndex32WithDisplacement12(Aj, XiR, D);
    CyberWord64 X0 = Cyber180CPGetX(processor, 0);
    CyberWord32 count = (X0 & 0x0000000000000007LL) + 1;

    CyberWord64 Xk = Cyber180CPGetX(processor, word._jkiD.k);
    CyberWord8 bytes[8] = {
        ((Xk >> 56) & 0xFF),
        ((Xk >> 48) & 0xFF),
        ((Xk >> 40) & 0xFF),
        ((Xk >> 32) & 0xFF),
        ((Xk >> 24) & 0xFF),
        ((Xk >> 16) & 0xFF),
        ((Xk >>  8) & 0xFF),
        ((Xk >>  0) & 0xFF),
    };

    // Don't need to swap before store as the above swaps for us if necessary.
    Cyber180CPWriteBytes(processor, destinationPVA, &bytes[8-count], count);

    return 4;
}


CyberWord64 Cyber180CPInstruction_ADDAD(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_SHFC(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_SHFX(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_SHFR(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


/// Isolate Bit Mask into Xk per XiR plus D
CyberWord64 Cyber180CPInstruction_ISOM(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    CyberWord64 XiR = Cyber180CPGetXOr0(processor, word._jkiD.i) & 0x00000000FFFFFFFF;
    CyberWord64 D = word._jkiD.D;
    CyberWord64 XiR_D = XiR + D;
    CyberWord64 bit_pos = XiR_D >> 6;
    CyberWord64 bit_len = XiR_D & 0x3F;
    if ((bit_pos + bit_len) > 63) {
        // TODO: Handle Instruction Specification Error
    }
    CyberWord64 mask = Cyber180CPInstruction_CalculateBitMask(bit_pos, bit_len);
    Cyber180CPSetX(processor, word._jkiD.k, mask);

    return 4;
}


/// Isolate into Xk from Xj per XiR plus D (2.2.9.1, ADjkiD)
///
/// See 2.2.9 for bit mask descriptor specification.
CyberWord64 Cyber180CPInstruction_ISOB(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    CyberWord64 XiR = Cyber180CPGetXOr0(processor, word._jkiD.i) & 0x00000000FFFFFFFF;
    CyberWord64 D = word._jkiD.D;
    CyberWord64 XiR_D = XiR + D;
    CyberWord64 bit_pos = XiR_D >> 6;
    CyberWord64 bit_len = XiR_D & 0x3F;
    if ((bit_pos + bit_len) > 63) {
        // TODO: Handle Instruction Specification Error
    }
    CyberWord64 mask = Cyber180CPInstruction_CalculateBitMask(bit_pos, bit_len);
    CyberWord64 bits = Cyber180CPGetX(processor, word._jkiD.j) & mask;
    CyberWord64 Xk = bits >> (63 - bit_len); // right-justify the bits
    Cyber180CPSetX(processor, word._jkiD.k, Xk);
    return 4;
}


CyberWord64 Cyber180CPInstruction_INSB(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_CALLREL(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_KEYPOINT(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_MULXQ(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_ENTA(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_CMPXA(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_CALLSEG(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_RESERVEDBD(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_RESERVEDBE(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_RESERVEDBF(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_EXECUTE(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


/// Load Bytes to Xk from (`Aj` displaced by `D` and indexed by `XiR`), Length per S (2.2.1.1.a, `DSjkiD`)
CyberWord64 Cyber180CPInstruction_LBYTS(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    CyberWord48 Aj = Cyber180CPGetA(processor, word._SjkiD.j);
    CyberWord32 XiR = Cyber180CPGetXOr0(processor, word._SjkiD.i) & 0x00000000FFFFFFFF;
    CyberWord12 D = word._SjkiD.D;

    CyberWord48 sourcePVA = Cyber180CPInstruction_CalculateAddressUsingIndex32WithDisplacement12(Aj, XiR, D);
    CyberWord32 count = word._SjkiD.S + 1;

    CyberWord8 bytes[8] = { 0 };
    Cyber180CPReadBytes(processor, sourcePVA, bytes, count);

    // Right-justify the bytes before assigning to Xk.
    CyberWord64 value = ((  (((CyberWord64)bytes[0]) << 56) | (((CyberWord64)bytes[1]) << 48)
                          | (((CyberWord64)bytes[2]) << 40) | (((CyberWord64)bytes[3]) << 32)
                          | (((CyberWord64)bytes[4]) << 24) | (((CyberWord64)bytes[5]) << 16)
                          | (((CyberWord64)bytes[6]) <<  8) | (((CyberWord64)bytes[7]) <<  0))
                         >> ((8 - ((CyberWord64)count)) * 8));

    // Don't need to swap after load because the above swaps for us if necessary.
    Cyber180CPSetX(processor, word._SjkiD.k, value);

    return 4;
}


/// Store Bytes from Xk at (`Aj` displaced by `D` and indexed by `XiR`), Length Per S (2.2.1.1.b, `DSjkiD`)
CyberWord64 Cyber180CPInstruction_SBYTS(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    CyberWord48 Aj = Cyber180CPGetA(processor, word._SjkiD.j);
    CyberWord32 XiR = Cyber180CPGetXOr0(processor, word._SjkiD.i) & 0x00000000FFFFFFFF;
    CyberWord12 D = word._SjkiD.D;

    CyberWord48 destinationPVA = Cyber180CPInstruction_CalculateAddressUsingIndex32WithDisplacement12(Aj, XiR, D);
    CyberWord32 count = word._SjkiD.S - 7;

    CyberWord64 Xk = Cyber180CPGetX(processor, word._SjkiD.k);
    CyberWord8 bytes[8] = {
        ((Xk >> 56) & 0xFF),
        ((Xk >> 48) & 0xFF),
        ((Xk >> 40) & 0xFF),
        ((Xk >> 32) & 0xFF),
        ((Xk >> 24) & 0xFF),
        ((Xk >> 16) & 0xFF),
        ((Xk >>  8) & 0xFF),
        ((Xk >>  0) & 0xFF),
    };

    // Don't need to swap before store as the above swaps for us if necessary.
    Cyber180CPWriteBytes(processor, destinationPVA, &bytes[8-count], count);

    return 4;
}


CyberWord64 Cyber180CPInstruction_SCLN(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_SCLR(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_CMPC(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_TRANB(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_EDIT(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_SCNB(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_MOVI(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_CMPI(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CyberWord64 Cyber180CPInstruction_ADDI(struct Cyber180CP *processor, union Cyber180CPInstructionWord word, CyberWord64 address)
{
    return 0;// TODO: Implement
}


CYBER_SOURCE_END
