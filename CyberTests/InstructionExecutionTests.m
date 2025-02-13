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
    union Cyber180CPInstructionWord instruction;
    instruction._jkQ.opcode = 0x82;
    instruction._jkQ.j = 0x1;
    instruction._jkQ.k = 0x2;
    instruction._jkQ.Q = 0x3;

    // Set up the registers and memory.
    Cyber180CPSetA(_processor, 0x1, 0x100);
    CyberWord8 wordbytes[8] = {0x12, 0x34, 0x56, 0x78, 0x9a, 0xbc, 0xde, 0xf0};
    Cyber180CPWriteBytes(_processor, 0x100 + (0x3 * 8), wordbytes, 8);

    CyberWord64 advance = Cyber180CPInstruction_LX(_processor, instruction, 0x00);
    XCTAssertEqual(4, advance);
    XCTAssertEqual(0x123456789abcdef0, Cyber180CPGetX(_processor, 2));
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
    CyberWord8 wordbytes[8] = {0x12, 0x34, 0x56, 0x78, 0x9a, 0xbc, 0xde, 0xf0};
    Cyber180CPWriteBytes(_processor, 0x100 + ((0x3 * 8) + (0x4 * 8)), wordbytes, 8);

    CyberWord64 advance = Cyber180CPInstruction_LXI(_processor, instruction, 0x00);
    XCTAssertEqual(4, advance);
    XCTAssertEqual(0x123456789abcdef0, Cyber180CPGetX(_processor, 0x2));
}

@end


NS_ASSUME_NONNULL_END
