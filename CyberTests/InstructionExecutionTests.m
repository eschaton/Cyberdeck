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

- (void)testInstruction_ENTE
{
    // 0x8D000063 = ENTE X0,63(16) - should put 0x63 in x0
    union Cyber180CPInstructionWord instruction; instruction._raw = 0x8D000063;

    CyberWord64 advance = Cyber180CPInstruction_ENTE(_processor, instruction, 0x00);
    XCTAssertEqual(4, advance);
    XCTAssertEqual(0x63LL, Cyber180CPGetX(_processor, 0));
}

@end


NS_ASSUME_NONNULL_END
