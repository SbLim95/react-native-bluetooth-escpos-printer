/*
 * Copyright 2014 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "VZZXAztecBinaryShiftToken.h"
#import "VZZXAztecSimpleToken.h"
#import "VZZXAztecToken.h"
#import "VZZXBitArray.h"

@implementation VZZXAztecToken

- (id)initWithPrevious:(VZZXAztecToken *)previous {
  if (self = [super init]) {
    _previous = previous;
  }

  return self;
}

+ (VZZXAztecToken *)empty {
  return [[VZZXAztecSimpleToken alloc] initWithPrevious:nil value:0 bitCount:0];
}

- (VZZXAztecToken *)add:(int)value bitCount:(int)bitCount {
  return [[VZZXAztecSimpleToken alloc] initWithPrevious:self value:value bitCount:bitCount];
}

- (VZZXAztecToken *)addBinaryShift:(int)start byteCount:(int)byteCount {
//  int bitCount = (byteCount * 8) + (byteCount <= 31 ? 10 : byteCount <= 62 ? 20 : 21);
  return [[VZZXAztecBinaryShiftToken alloc] initWithPrevious:self binaryShiftStart:start binaryShiftByteCount:byteCount];
}

- (void)appendTo:(VZZXBitArray *)bitArray text:(VZZXByteArray *)text {
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                               userInfo:nil];
}

@end
