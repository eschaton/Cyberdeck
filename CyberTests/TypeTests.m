//
//  TypeTests.m
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

NS_ASSUME_NONNULL_BEGIN


@interface TypeTests : CyberTestCase
@end


@implementation TypeTests

- (void)testCyberWord16Swap
{
    CyberWord16 unswapped = 0x1234;
#if CYBER_BIG_ENDIAN
    CyberWord16   swapped = 0x1234;
#else
    CyberWord16   swapped = 0x3412;
#endif

    XCTAssertEqual(swapped, CyberWord16Swap(unswapped), @"Expected %x got %x", swapped, CyberWord16Swap(unswapped));
    XCTAssertEqual(unswapped, CyberWord16Swap(swapped), @"Expected %x got %x", unswapped, CyberWord16Swap(swapped));
}

- (void)testCyberWord32Swap
{
    CyberWord32 unswapped = 0x12345678;
#if CYBER_BIG_ENDIAN
    CyberWord32   swapped = 0x12345678;
#else
    CyberWord32   swapped = 0x78563412;
#endif

    XCTAssertEqual(swapped, CyberWord32Swap(unswapped), @"Expected %x got %x", swapped, CyberWord32Swap(unswapped));
    XCTAssertEqual(unswapped, CyberWord32Swap(swapped), @"Expected %x got %x", unswapped, CyberWord32Swap(swapped));
}

- (void)testCyberWord64Swap
{
    CyberWord64 unswapped = 0x123456789abcdef0;
#if CYBER_BIG_ENDIAN
    CyberWord64   swapped = 0x123456789abcdef0;
#else
    CyberWord64   swapped = 0xf0debc9a78563412;
#endif

    XCTAssertEqual(swapped, CyberWord64Swap(unswapped), @"Expected %llx got %llx", swapped, CyberWord64Swap(unswapped));
    XCTAssertEqual(unswapped, CyberWord64Swap(swapped), @"Expected %llx got %llx", unswapped, CyberWord64Swap(swapped));
}

@end


NS_ASSUME_NONNULL_END
