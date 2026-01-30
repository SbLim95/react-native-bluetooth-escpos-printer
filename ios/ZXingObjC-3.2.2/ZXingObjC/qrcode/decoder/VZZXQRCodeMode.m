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

#import "VZZXQRCodeMode.h"
#import "VZZXQRCodeVersion.h"

@interface VZZXQRCodeMode ()

@property (nonatomic, strong, readonly) NSArray *characterCountBitsForVersions;

@end

@implementation VZZXQRCodeMode

- (id)initWithCharacterCountBitsForVersions:(NSArray *)characterCountBitsForVersions bits:(int)bits name:(NSString *)name {
  if (self = [super init]) {
    _characterCountBitsForVersions = characterCountBitsForVersions;
    _bits = bits;
    _name = name;
  }

  return self;
}

+ (VZZXQRCodeMode *)forBits:(int)bits {
  switch (bits) {
    case 0x0:
      return [VZZXQRCodeMode terminatorMode];
    case 0x1:
      return [VZZXQRCodeMode numericMode];
    case 0x2:
      return [VZZXQRCodeMode alphanumericMode];
    case 0x3:
      return [VZZXQRCodeMode structuredAppendMode];
    case 0x4:
      return [VZZXQRCodeMode byteMode];
    case 0x5:
      return [VZZXQRCodeMode fnc1FirstPositionMode];
    case 0x7:
      return [VZZXQRCodeMode eciMode];
    case 0x8:
      return [VZZXQRCodeMode kanjiMode];
    case 0x9:
      return [VZZXQRCodeMode fnc1SecondPositionMode];
    case 0xD:
      return [VZZXQRCodeMode hanziMode];
    default:
      return nil;
  }
}

- (int)characterCountBits:(VZZXQRCodeVersion *)version {
  int number = version.versionNumber;
  int offset;
  if (number <= 9) {
    offset = 0;
  } else if (number <= 26) {
    offset = 1;
  } else {
    offset = 2;
  }
  return [self.characterCountBitsForVersions[offset] intValue];
}

- (NSString *)description {
  return self.name;
}

+ (VZZXQRCodeMode *)terminatorMode {
  static VZZXQRCodeMode *thisMode = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    thisMode = [[VZZXQRCodeMode alloc] initWithCharacterCountBitsForVersions:@[@0, @0, @0] bits:0x00 name:@"TERMINATOR"];
  });
  return thisMode;
}

+ (VZZXQRCodeMode *)numericMode {
  static VZZXQRCodeMode *thisMode = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    thisMode = [[VZZXQRCodeMode alloc] initWithCharacterCountBitsForVersions:@[@10, @12, @14] bits:0x01 name:@"NUMERIC"];
  });
  return thisMode;
}

+ (VZZXQRCodeMode *)alphanumericMode {
  static VZZXQRCodeMode *thisMode = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    thisMode = [[VZZXQRCodeMode alloc] initWithCharacterCountBitsForVersions:@[@9, @11, @13] bits:0x02 name:@"ALPHANUMERIC"];
  });
  return thisMode;
}

+ (VZZXQRCodeMode *)structuredAppendMode {
  static VZZXQRCodeMode *thisMode = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    thisMode = [[VZZXQRCodeMode alloc] initWithCharacterCountBitsForVersions:@[@0, @0, @0] bits:0x03 name:@"STRUCTURED_APPEND"];
  });
  return thisMode;
}

+ (VZZXQRCodeMode *)byteMode {
  static VZZXQRCodeMode *thisMode = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    thisMode = [[VZZXQRCodeMode alloc] initWithCharacterCountBitsForVersions:@[@8, @16, @16] bits:0x04 name:@"BYTE"];
  });
  return thisMode;
}

+ (VZZXQRCodeMode *)eciMode {
  static VZZXQRCodeMode *thisMode = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    thisMode = [[VZZXQRCodeMode alloc] initWithCharacterCountBitsForVersions:@[@0, @0, @0] bits:0x07 name:@"ECI"];
  });
  return thisMode;
}

+ (VZZXQRCodeMode *)kanjiMode {
  static VZZXQRCodeMode *thisMode = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    thisMode = [[VZZXQRCodeMode alloc] initWithCharacterCountBitsForVersions:@[@8, @10, @12] bits:0x08 name:@"KANJI"];
  });
  return thisMode;
}

+ (VZZXQRCodeMode *)fnc1FirstPositionMode {
  static VZZXQRCodeMode *thisMode = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    thisMode = [[VZZXQRCodeMode alloc] initWithCharacterCountBitsForVersions:@[@0, @0, @0] bits:0x05 name:@"FNC1_FIRST_POSITION"];
  });
  return thisMode;
}

+ (VZZXQRCodeMode *)fnc1SecondPositionMode {
  static VZZXQRCodeMode *thisMode = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    thisMode = [[VZZXQRCodeMode alloc] initWithCharacterCountBitsForVersions:@[@0, @0, @0] bits:0x09 name:@"FNC1_SECOND_POSITION"];
  });
  return thisMode;
}

+ (VZZXQRCodeMode *)hanziMode {
  static VZZXQRCodeMode *thisMode = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    thisMode = [[VZZXQRCodeMode alloc] initWithCharacterCountBitsForVersions:@[@8, @10, @12] bits:0x0D name:@"HANZI"];
  });
  return thisMode;
}

@end
