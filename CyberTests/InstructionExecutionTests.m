//
//  InstructionExecutionTests.m
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

#import "CyberTestCase.h"

#import "Cyber180CP_Internal.h"
#import "Cyber180CPInstructions_Internal.h"

#import "NOSVEBootCode.h"


NS_ASSUME_NONNULL_BEGIN


/// Tests for instruction decoding.
@interface InstructionExecutionTests : CyberTestCase
@end


@implementation InstructionExecutionTests {
    struct Cyber962 *_system;
    struct Cyber180CP *_processor;
    struct Cyber180CM *_memory;
    struct Cyber180CMPort *_port;
}

- (void)setUp
{
    [super setUp];

    // Create a system and gets its various components so we can manipulate them.

    _system = Cyber962Create("Test", (256 * 1024 * 1024), 1, 1);
    XCTAssertNotEqual(_system, NULL);

    _processor = Cyber962GetCentralProcessor(_system, 0);
    XCTAssertNotEqual(_processor, NULL);

    _memory = Cyber962GetCentralMemory(_system);
    XCTAssertNotEqual(_memory, NULL);

    _port = Cyber180CPGetCentralMemoryPort(_processor);
    XCTAssertNotEqual(_port, NULL);

    // Load the bootstrap code so there's something in memory.

    Cyber180CMPortWriteBytesPhysical(_port, 0x000000000000, NOSVEBootCode, NOSVEBootCodeLength);
}

- (void)tearDown
{
    Cyber962Dispose(_system);
    _system = NULL;

    [super tearDown];
}

- (void)testBitMaskCalculation
{
    XCTAssertEqual(0x3E00000000000000LL, Cyber180CPInstruction_CalculateBitMask(2,5));
}

- (void)testInstruction_INCX
{
    // Xk = Xk + j
    union Cyber180CPInstructionWord instruction;
    instruction._jk.opcode = 0x10;
    instruction._jk.j = 0x3;
    instruction._jk.k = 0x2;

    // Set up the registers and memory.
    Cyber180CPSetX(_processor, 2, 0x1234);
    CyberWord64 advance = Cyber180CPInstruction_INCX(_processor, instruction, 0x00);
    XCTAssertEqual(2, advance);

    CyberWord64 X2 = Cyber180CPGetX(_processor, 2);
    XCTAssertEqual(0x1237, X2);

    // TODO: Test INCX overflow.
}

- (void)testInstruction_DECX
{
    // Xk = Xk + j
    union Cyber180CPInstructionWord instruction;
    instruction._jk.opcode = 0x11;
    instruction._jk.j = 0x3;
    instruction._jk.k = 0x2;

    // Set up the registers and memory.
    Cyber180CPSetX(_processor, 2, 0x1234);
    CyberWord64 advance = Cyber180CPInstruction_DECX(_processor, instruction, 0x00);
    XCTAssertEqual(2, advance);

    CyberWord64 X2 = Cyber180CPGetX(_processor, 2);
    XCTAssertEqual(0x1231, X2);

    // TODO: Test DECX overflow.
}

- (void)testInstruction_ADDR
{
    // XkR = XkR + XjR
    union Cyber180CPInstructionWord instruction;
    instruction._jk.opcode = 0x20;
    instruction._jk.j = 0x3;
    instruction._jk.k = 0x2;

    // Set up the registers and memory.
    Cyber180CPSetX(_processor, 2, 0x123456789abcdef0);
    Cyber180CPSetX(_processor, 3, 0x0fedcba911111111);
    CyberWord64 advance = Cyber180CPInstruction_ADDR(_processor, instruction, 0x00);
    XCTAssertEqual(2, advance);

    CyberWord64 X2 = Cyber180CPGetX(_processor, 2);
    XCTAssertEqual(0x12345678abcdf001, X2);

    // TODO: Test ADDR overflow.
}

- (void)testInstruction_SUBR
{
    // XkR = XkR + XjR
    union Cyber180CPInstructionWord instruction;
    instruction._jk.opcode = 0x21;
    instruction._jk.j = 0x3;
    instruction._jk.k = 0x2;

    // Set up the registers and memory.
    Cyber180CPSetX(_processor, 2, 0x123456789abcdef0);
    Cyber180CPSetX(_processor, 3, 0x0fedcba911111111);
    CyberWord64 advance = Cyber180CPInstruction_SUBR(_processor, instruction, 0x00);
    XCTAssertEqual(2, advance);

    CyberWord64 X2 = Cyber180CPGetX(_processor, 2);
    XCTAssertEqual(0x1234567889abcddf, X2);

    // TODO: Test ADDR overflow.
}

- (void)testInstruction_ADDX
{
    // Xk = Xk + Xj
    union Cyber180CPInstructionWord instruction;
    instruction._jk.opcode = 0x24;
    instruction._jk.j = 0x3;
    instruction._jk.k = 0x2;

    // Set up the registers and memory.
    Cyber180CPSetX(_processor, 2, 0x1234);
    Cyber180CPSetX(_processor, 3, 0x5678);
    CyberWord64 advance = Cyber180CPInstruction_ADDX(_processor, instruction, 0x00);
    XCTAssertEqual(2, advance);

    CyberWord64 X2 = Cyber180CPGetX(_processor, 2);
    XCTAssertEqual(0x68AC, X2);

    // TODO: Test ADDX overflow.
}

- (void)testInstruction_SUBX
{
    // Xk = Xk + j
    union Cyber180CPInstructionWord instruction;
    instruction._jk.opcode = 0x25;
    instruction._jk.j = 0x3;
    instruction._jk.k = 0x2;

    // Set up the registers and memory.
    Cyber180CPSetX(_processor, 2, 0x1234);
    Cyber180CPSetX(_processor, 3, 0x5678);
    CyberWord64 advance = Cyber180CPInstruction_SUBX(_processor, instruction, 0x00);
    XCTAssertEqual(2, advance);

    CyberWord64 X2 = Cyber180CPGetX(_processor, 2);
    XCTAssertEqual(-0x4444, X2);

    // TODO: Test SUBX overflow.
}

- (void)testInstruction_INCR
{
    // XkR = XkR + j
    union Cyber180CPInstructionWord instruction;
    instruction._jk.opcode = 0x28;
    instruction._jk.j = 0x3;
    instruction._jk.k = 0x2;

    // Set up the registers and memory.
    Cyber180CPSetX(_processor, 2, 0x1234567887654321);
    CyberWord64 advance = Cyber180CPInstruction_INCR(_processor, instruction, 0x00);
    XCTAssertEqual(2, advance);

    CyberWord64 X2 = Cyber180CPGetX(_processor, 2);
    XCTAssertEqual(0x1234567887654324, X2);

    // TODO: Test INCR overflow.
}

- (void)testInstruction_DECR
{
    // XkR = XkR - j
    union Cyber180CPInstructionWord instruction;
    instruction._jk.opcode = 0x29;
    instruction._jk.j = 0x3;
    instruction._jk.k = 0x2;

    // Set up the registers and memory.
    Cyber180CPSetX(_processor, 2, 0x1234567887654321);
    CyberWord64 advance = Cyber180CPInstruction_DECR(_processor, instruction, 0x00);
    XCTAssertEqual(2, advance);

    CyberWord64 X2 = Cyber180CPGetX(_processor, 2);
    XCTAssertEqual(0x123456788765431E, X2);

    // TODO: Test DECR overflow.
}

- (void)testInstruction_ENTX
{
    union Cyber180CPInstructionWord instruction;
    instruction._jk.opcode = 0x39;
    instruction._jk.j = 0xA;
    instruction._jk.k = 0xB;

    CyberWord64 advance = Cyber180CPInstruction_ENTX(_processor, instruction, 0x00);
    XCTAssertEqual(2, advance);
    XCTAssertEqual(0xAB, Cyber180CPGetX(_processor, 1));
}

- (void)testInstruction_ENTP
{
    union Cyber180CPInstructionWord instruction;
    instruction._jk.opcode = 0x3d;
    instruction._jk.j = 0xA;
    instruction._jk.k = 3;

    CyberWord64 advance = Cyber180CPInstruction_ENTP(_processor, instruction, 0x00);
    XCTAssertEqual(2, advance);
    XCTAssertEqual(0xALL, Cyber180CPGetX(_processor, 3));
}

- (void)testInstruction_ENTN
{
    union Cyber180CPInstructionWord instruction;
    instruction._jk.opcode = 0x3e;
    instruction._jk.j = 0xA;
    instruction._jk.k = 3;

    CyberWord64 advance = Cyber180CPInstruction_ENTN(_processor, instruction, 0x00);
    XCTAssertEqual(2, advance);
    XCTAssertEqual(0xFFFFFFFFFFFFFFF5LL, Cyber180CPGetX(_processor, 3));
}

- (void)testInstruction_ENTL
{
    union Cyber180CPInstructionWord instruction;
    instruction._jk.opcode = 0x3f;
    instruction._jk.j = 0xA;
    instruction._jk.k = 0xB;

    CyberWord64 advance = Cyber180CPInstruction_ENTL(_processor, instruction, 0x00);
    XCTAssertEqual(2, advance);
    XCTAssertEqual(0xAB, Cyber180CPGetX(_processor, 0));
}

- (void)testInstruction_LX
{
    // Xk = (Aj + 8*Q)
    union Cyber180CPInstructionWord instruction;
    instruction._jkQ.opcode = 0x82;
    instruction._jkQ.j = 0x1;
    instruction._jkQ.k = 0x2;
    instruction._jkQ.Q = 0x3;

    // Set up the registers and memory.
    Cyber180CPSetA(_processor, 0x1, 0x100);
    CyberWord8 wordBytes[8] = {0x12, 0x34, 0x56, 0x78, 0x9a, 0xbc, 0xde, 0xf0};
    Cyber180CPWriteBytes(_processor, 0x100 + (0x3 * 8), wordBytes, 8);

    CyberWord64 advance = Cyber180CPInstruction_LX(_processor, instruction, 0x00);
    XCTAssertEqual(4, advance);
    XCTAssertEqual(0x123456789abcdef0, Cyber180CPGetX(_processor, 2));
}

- (void)testInstruction_SX
{
    // (Aj + 8*Q) = Xk
    union Cyber180CPInstructionWord instruction;
    instruction._jkQ.opcode = 0x83;
    instruction._jkQ.j = 0x1;
    instruction._jkQ.k = 0x2;
    instruction._jkQ.Q = 0x3;

    // Set up the registers and memory.
    Cyber180CPSetA(_processor, 0x1, 0x100);
    Cyber180CPSetX(_processor, 0x2, 0x123456789abcdef0);

    CyberWord64 advance = Cyber180CPInstruction_SX(_processor, instruction, 0x00);
    XCTAssertEqual(4, advance);

    CyberWord8 wordBytes[8];
    Cyber180CPReadBytes(_processor, 0x100 + (0x3 * 8), wordBytes, 8);
    CyberWord8 expectedBytes[8] = {0x12, 0x34, 0x56, 0x78, 0x9a, 0xbc, 0xde, 0xf0};
    XCTAssert(memcmp(expectedBytes, wordBytes, 8) == 0);
}

- (void)testInstruction_ADDXQ
{
    // Xk = Xk + Xj + Q
    union Cyber180CPInstructionWord instruction;
    instruction._jkQ.opcode = 0x8B;
    instruction._jkQ.j = 0x3;
    instruction._jkQ.k = 0x2;
    instruction._jkQ.Q = 0xFFFF; // -1

    // Set up the registers and memory.
    Cyber180CPSetX(_processor, 2, 0x1234);
    Cyber180CPSetX(_processor, 3, 0x5678);
    CyberWord64 advance = Cyber180CPInstruction_ADDXQ(_processor, instruction, 0x00);
    XCTAssertEqual(4, advance);

    CyberWord64 X2 = Cyber180CPGetX(_processor, 2);
    XCTAssertEqual(0x68AB, X2);

    // TODO: Test ADDX overflow.

}

- (void)testInstruction_ENTE
{
    // 0x8D000063 = ENTE X0,63(16)
    union Cyber180CPInstructionWord instruction;
    instruction._jkQ.opcode = 0x8d;
    instruction._jkQ.j = 0;
    instruction._jkQ.k = 0;
    instruction._jkQ.Q = 0x63;

    CyberWord64 advance = Cyber180CPInstruction_ENTE(_processor, instruction, 0x00);
    XCTAssertEqual(4, advance);
    XCTAssertEqual(0x63LL, Cyber180CPGetX(_processor, 0));
}

- (void)testInstruction_LXI
{
    // Xk = (Aj + 8*D + 8*XiR)
    union Cyber180CPInstructionWord instruction;
    instruction._jkiD.opcode = 0xA2;
    instruction._jkiD.j = 0x1;
    instruction._jkiD.k = 0x2;
    instruction._jkiD.i = 0x3;
    instruction._jkiD.D = 0x4;

    // Set up the registers and memory.
    Cyber180CPSetA(_processor, 0x1, 0x100);
    Cyber180CPSetX(_processor, 0x3, 0x3);
    CyberWord8 wordBytes[8] = {0x12, 0x34, 0x56, 0x78, 0x9a, 0xbc, 0xde, 0xf0};
    Cyber180CPWriteBytes(_processor, 0x100 + ((0x3 * 8) + (0x4 * 8)), wordBytes, 8);

    CyberWord64 advance = Cyber180CPInstruction_LXI(_processor, instruction, 0x00);
    XCTAssertEqual(4, advance);
    XCTAssertEqual(0x123456789abcdef0, Cyber180CPGetX(_processor, 0x2));
}

- (void)testInstruction_SXI
{
    // (Aj + 8*D + 8*XiR) = Xk
    union Cyber180CPInstructionWord instruction;
    instruction._jkiD.opcode = 0xA3;
    instruction._jkiD.j = 0x1;
    instruction._jkiD.k = 0x2;
    instruction._jkiD.i = 0x3;
    instruction._jkiD.D = 0x4;

    // Set up the registers and memory.
    Cyber180CPSetA(_processor, 0x1, 0x100);
    Cyber180CPSetX(_processor, 0x3, 0x3);
    Cyber180CPSetX(_processor, 0x2, 0x123456789abcdef0);

    CyberWord64 advance = Cyber180CPInstruction_SXI(_processor, instruction, 0x00);
    XCTAssertEqual(4, advance);

    CyberWord8 wordBytes[8];
    Cyber180CPReadBytes(_processor, 0x100 + ((0x3 * 8) + (0x4 * 8)), wordBytes, 8);
    CyberWord8 expectedBytes[8] = {0x12, 0x34, 0x56, 0x78, 0x9a, 0xbc, 0xde, 0xf0};
    XCTAssert(memcmp(expectedBytes, wordBytes, 8) == 0);
}

- (void)testInstruction_LBYT
{
    // Xk = (Aj + D + XiR), right-justified based on count
    // LBYT,X0 X2,A1,X3,0x4
    union Cyber180CPInstructionWord instruction;
    instruction._jkiD.opcode = 0xA4;
    instruction._jkiD.j = 0x1;
    instruction._jkiD.k = 0x2;
    instruction._jkiD.i = 0x3;
    instruction._jkiD.D = 0x4;

    // Set up the registers and memory to put a word at 0x108 (loading only 0x108...0x10B of it).
    Cyber180CPSetA(_processor, 0x1, 0x100);
    Cyber180CPSetX(_processor, 0x3, 0x4);
    Cyber180CPSetX(_processor, 0x0, 0x3);
    CyberWord8 wordBytes[8] = {0x12, 0x34, 0x56, 0x78, 0x9a, 0xbc, 0xde, 0xf0};
    Cyber180CPWriteBytes(_processor, 0x108, wordBytes, 8);

    CyberWord64 advance = Cyber180CPInstruction_LBYT(_processor, instruction, 0x00);
    XCTAssertEqual(4, advance);

    CyberWord64 Xk = Cyber180CPGetX(_processor, 0x2);
    XCTAssertEqual(0x0000000012345678, Xk);
}

- (void)testInstruction_SBYT
{
    // (Aj + D + XiR) = Xk, right-justified based on count
    // SBYT,X0 X2,A1,X3,0x4
    union Cyber180CPInstructionWord instruction;
    instruction._jkiD.opcode = 0xA5;
    instruction._jkiD.j = 0x1;
    instruction._jkiD.k = 0x2;
    instruction._jkiD.i = 0x3;
    instruction._jkiD.D = 0x4;

    // Set up the registers and memory to put the right 4 bytes at 0x108
    Cyber180CPSetA(_processor, 0x1, 0x100);
    Cyber180CPSetX(_processor, 0x3, 0x4);
    Cyber180CPSetX(_processor, 0x0, 0x2);
    Cyber180CPSetX(_processor, 0x2, 0x12345678abcdef0);

    CyberWord64 advance = Cyber180CPInstruction_SBYT(_processor, instruction, 0x00);
    XCTAssertEqual(4, advance);

    CyberWord8 wordBytes[3] = {0};
    Cyber180CPReadBytes(_processor, 0x108, wordBytes, 3);
    CyberWord8 expectedBytes[3] = {0xbc, 0xde, 0xf0};
    XCTAssert((memcmp(expectedBytes, wordBytes, 3) == 0),
              @"expected: [%02x, %02x, %02x], actual: [%02x, %02x, %02x]",
              expectedBytes[0], expectedBytes[1], expectedBytes[2],
              wordBytes[0], wordBytes[1], wordBytes[2]);
}

- (void)testInstruction_LBYTS
{
    // Xk = (Aj + D + XiR), right-justified based on count
    // LBYTS,3 X2,A1,X3,0x4
    union Cyber180CPInstructionWord instruction;
    instruction._SjkiD.opcode = 0xD;
    instruction._SjkiD.S = 3;
    instruction._SjkiD.j = 0x1;
    instruction._SjkiD.k = 0x2;
    instruction._SjkiD.i = 0x3;
    instruction._SjkiD.D = 0x4;

    // Set up the registers and memory to put a word at 0x108 (loading only 0x108...0x10B of it).
    Cyber180CPSetA(_processor, 0x1, 0x100);
    Cyber180CPSetX(_processor, 0x3, 0x4);
    CyberWord8 wordBytes[8] = {0x12, 0x34, 0x56, 0x78, 0x9a, 0xbc, 0xde, 0xf0};
    Cyber180CPWriteBytes(_processor, 0x108, wordBytes, 8);

    CyberWord64 advance = Cyber180CPInstruction_LBYTS(_processor, instruction, 0x00);
    XCTAssertEqual(4, advance);

    CyberWord64 Xk = Cyber180CPGetX(_processor, 0x2);
    XCTAssertEqual(0x0000000012345678, Xk);
}

- (void)testInstruction_SBYTS
{
    // (Aj + D + XiR) = Xk, right-justified based on count
    // SBYTS,3 X2,A1,X3,0x4
    union Cyber180CPInstructionWord instruction;
    instruction._SjkiD.opcode = 0xD;
    instruction._SjkiD.S = 3 + 7;
    instruction._SjkiD.j = 0x1;
    instruction._SjkiD.k = 0x2;
    instruction._SjkiD.i = 0x3;
    instruction._SjkiD.D = 0x4;

    // Set up the registers and memory to put the right 4 bytes at 0x108
    Cyber180CPSetA(_processor, 0x1, 0x100);
    Cyber180CPSetX(_processor, 0x3, 0x4);
    Cyber180CPSetX(_processor, 0x2, 0x12345678abcdef0);

    CyberWord64 advance = Cyber180CPInstruction_SBYTS(_processor, instruction, 0x00);
    XCTAssertEqual(4, advance);

    CyberWord8 wordBytes[3] = {0};
    Cyber180CPReadBytes(_processor, 0x108, wordBytes, 3);
    CyberWord8 expectedBytes[3] = {0xbc, 0xde, 0xf0};
    XCTAssert((memcmp(expectedBytes, wordBytes, 3) == 0),
              @"expected: [%02x, %02x, %02x], actual: [%02x, %02x, %02x]",
              expectedBytes[0], expectedBytes[1], expectedBytes[2],
              wordBytes[0], wordBytes[1], wordBytes[2]);
}

@end


NS_ASSUME_NONNULL_END
