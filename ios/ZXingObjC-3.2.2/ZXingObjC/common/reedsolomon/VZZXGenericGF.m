/*
 * Copyright 2012 ZXing authors
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

#import "VZZXGenericGF.h"
#import "VZZXGenericGFPoly.h"
#import "VZZXIntArray.h"

@interface VZZXGenericGF ()

@property (nonatomic, assign, readonly) int32_t *expTable;
@property (nonatomic, assign, readonly) int32_t *logTable;
@property (nonatomic, assign, readonly) int primitive;

@end

@implementation VZZXGenericGF {
  VZZXGenericGFPoly *_one;
  VZZXGenericGFPoly *_zero;
}

- (id)initWithPrimitive:(int)primitive size:(int)size b:(int)b {
  if (self = [super init]) {
    _primitive = primitive;
    _size = size;
    _generatorBase = b;

    _expTable = (int32_t *)calloc(self.size, sizeof(int32_t));
    _logTable = (int32_t *)calloc(self.size, sizeof(int32_t));
    int32_t x = 1;
    for (int i = 0; i < self.size; i++) {
      _expTable[i] = x;
      x <<= 1; // we're assuming the generator alpha is 2
      if (x >= self.size) {
        x ^= (int32_t)self.primitive;
        x &= (int32_t)self.size - 1;
      }
    }

    for (int32_t i = 0; i < (int32_t)self.size-1; i++) {
      _logTable[_expTable[i]] = i;
    }
    // logTable[0] == 0 but this should never be used
    _zero = [[VZZXGenericGFPoly alloc] initWithField:self coefficients:[[VZZXIntArray alloc] initWithLength:1]];

    _one = [[VZZXGenericGFPoly alloc] initWithField:self coefficients:[[VZZXIntArray alloc] initWithInts:1, -1]];
  }

  return self;
}

+ (VZZXGenericGF *)AztecData12 {
  static VZZXGenericGF *AztecData12 = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    AztecData12 = [[VZZXGenericGF alloc] initWithPrimitive:0x1069 size:4096 b:1]; // x^12 + x^6 + x^5 + x^3 + 1
  });
  return AztecData12;
}

+ (VZZXGenericGF *)AztecData10 {
  static VZZXGenericGF *AztecData10 = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    AztecData10 = [[VZZXGenericGF alloc] initWithPrimitive:0x409 size:1024 b:1]; // x^10 + x^3 + 1
  });
  return AztecData10;
}

+ (VZZXGenericGF *)AztecData6 {
  static VZZXGenericGF *AztecData6 = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    AztecData6 = [[VZZXGenericGF alloc] initWithPrimitive:0x43 size:64 b:1]; // x^6 + x + 1
  });
  return AztecData6;
}

+ (VZZXGenericGF *)AztecParam {
  static VZZXGenericGF *AztecParam = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    AztecParam = [[VZZXGenericGF alloc] initWithPrimitive:0x13 size:16 b:1]; // x^4 + x + 1
  });
  return AztecParam;
}

+ (VZZXGenericGF *)QrCodeField256 {
  static VZZXGenericGF *QrCodeField256 = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    QrCodeField256 = [[VZZXGenericGF alloc] initWithPrimitive:0x011D size:256 b:0]; // x^8 + x^4 + x^3 + x^2 + 1
  });
  return QrCodeField256;
}

+ (VZZXGenericGF *)DataMatrixField256 {
  static VZZXGenericGF *DataMatrixField256 = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    DataMatrixField256 = [[VZZXGenericGF alloc] initWithPrimitive:0x012D size:256 b:1]; // x^8 + x^5 + x^3 + x^2 + 1
  });
  return DataMatrixField256;
}

+ (VZZXGenericGF *)AztecData8 {
  return [self DataMatrixField256];
}

+ (VZZXGenericGF *)MaxiCodeField64 {
  return [self AztecData6];
}

- (VZZXGenericGFPoly *)buildMonomial:(int)degree coefficient:(int32_t)coefficient {
  if (degree < 0) {
    [NSException raise:NSInvalidArgumentException format:@"Degree must be greater than 0."];
  }
  if (coefficient == 0) {
    return self.zero;
  }
  VZZXIntArray *coefficients = [[VZZXIntArray alloc] initWithLength:degree + 1];
  coefficients.array[0] = coefficient;
  return [[VZZXGenericGFPoly alloc] initWithField:self coefficients:coefficients];
}

+ (int32_t)addOrSubtract:(int32_t)a b:(int32_t)b {
  return a ^ b;
}

- (int32_t)exp:(int)a {
  return _expTable[a];
}

- (int32_t)log:(int)a {
  if (a == 0) {
    [NSException raise:NSInvalidArgumentException format:@"Argument must be non-zero."];
  }

  return _logTable[a];
}

- (int32_t)inverse:(int)a {
  if (a == 0) {
    [NSException raise:NSInvalidArgumentException format:@"Argument must be non-zero."];
  }

  return _expTable[_size - _logTable[a] - 1];
}

- (int32_t)multiply:(int)a b:(int)b {
  if (a == 0 || b == 0) {
    return 0;
  }

  return _expTable[(_logTable[a] + _logTable[b]) % (_size - 1)];
}

- (BOOL)isEqual:(VZZXGenericGF *)object {
  return self.primitive == object.primitive && self.size == object.size;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"GF(0x%X,%d)", self.primitive, self.size];
}

@end
