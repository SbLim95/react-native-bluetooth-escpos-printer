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

#import "VZZXBitMatrix.h"
#import "VZZXQRCodeDataMask.h"

/**
 * 000: mask bits for which (x + y) mod 2 == 0
 */
@interface VZZXDataMask000 : VZZXQRCodeDataMask

@end

@implementation VZZXDataMask000

- (BOOL)isMasked:(int)i j:(int)j {
  return ((i + j) & 0x01) == 0;
}

@end


/**
 * 001: mask bits for which x mod 2 == 0
 */
@interface VZZXDataMask001 : VZZXQRCodeDataMask

@end

@implementation VZZXDataMask001

- (BOOL)isMasked:(int)i j:(int)j {
  return (i & 0x01) == 0;
}

@end


/**
 * 010: mask bits for which y mod 3 == 0
 */
@interface VZZXDataMask010 : VZZXQRCodeDataMask

@end

@implementation VZZXDataMask010

- (BOOL)isMasked:(int)i j:(int)j {
  return j % 3 == 0;
}

@end


/**
 * 011: mask bits for which (x + y) mod 3 == 0
 */
@interface VZZXDataMask011 : VZZXQRCodeDataMask

@end

@implementation VZZXDataMask011

- (BOOL)isMasked:(int)i j:(int)j {
  return (i + j) % 3 == 0;
}

@end


/**
 * 100: mask bits for which (x/2 + y/3) mod 2 == 0
 */
@interface VZZXDataMask100 : VZZXQRCodeDataMask

@end

@implementation VZZXDataMask100

- (BOOL)isMasked:(int)i j:(int)j {
  return (((i / 2) + (j /3)) & 0x01) == 0;
}

@end


/**
 * 101: mask bits for which xy mod 2 + xy mod 3 == 0
 */
@interface VZZXDataMask101 : VZZXQRCodeDataMask

@end

@implementation VZZXDataMask101

- (BOOL)isMasked:(int)i j:(int)j {
  int temp = i * j;
  return (temp & 0x01) + (temp % 3) == 0;
}

@end


/**
 * 110: mask bits for which (xy mod 2 + xy mod 3) mod 2 == 0
 */
@interface VZZXDataMask110 : VZZXQRCodeDataMask

@end

@implementation VZZXDataMask110

- (BOOL)isMasked:(int)i j:(int)j {
  int temp = i * j;
  return (((temp & 0x01) + (temp % 3)) & 0x01) == 0;
}

@end


/**
 * 111: mask bits for which ((x+y)mod 2 + xy mod 3) mod 2 == 0
 */
@interface VZZXDataMask111 : VZZXQRCodeDataMask

@end

@implementation VZZXDataMask111

- (BOOL)isMasked:(int)i j:(int)j {
  return ((((i + j) & 0x01) + ((i * j) % 3)) & 0x01) == 0;
}

@end


@implementation VZZXQRCodeDataMask

/**
 * See ISO 18004:2006 6.8.1
 */
static NSArray *DATA_MASKS = nil;

/**
 * Implementations of this method reverse the data masking process applied to a QR Code and
 * make its bits ready to read.
 */
- (void)unmaskBitMatrix:(VZZXBitMatrix *)bits dimension:(int)dimension {
  for (int i = 0; i < dimension; i++) {
    for (int j = 0; j < dimension; j++) {
      if ([self isMasked:i j:j]) {
        [bits flipX:j y:i];
      }
    }
  }
}

- (BOOL)isMasked:(int)i j:(int)j {
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                               userInfo:nil];
}


+ (VZZXQRCodeDataMask *)forReference:(int)reference {
  if (!DATA_MASKS) {
    DATA_MASKS = @[[[VZZXDataMask000 alloc] init],
                   [[VZZXDataMask001 alloc] init],
                   [[VZZXDataMask010 alloc] init],
                   [[VZZXDataMask011 alloc] init],
                   [[VZZXDataMask100 alloc] init],
                   [[VZZXDataMask101 alloc] init],
                   [[VZZXDataMask110 alloc] init],
                   [[VZZXDataMask111 alloc] init]];
  }

  if (reference < 0 || reference > 7) {
    [NSException raise:NSInvalidArgumentException format:@"Invalid reference value"];
  }
  return DATA_MASKS[reference];
}

@end
