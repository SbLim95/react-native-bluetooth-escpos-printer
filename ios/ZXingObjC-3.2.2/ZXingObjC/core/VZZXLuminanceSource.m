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

#import "VZZXByteArray.h"
#import "VZZXInvertedLuminanceSource.h"
#import "VZZXLuminanceSource.h"

@implementation VZZXLuminanceSource

- (id)initWithWidth:(int)width height:(int)height {
  if (self = [super init]) {
    _width = width;
    _height = height;
    _cropSupported = NO;
    _rotateSupported = NO;
  }

  return self;
}

- (VZZXByteArray *)rowAtY:(int)y row:(VZZXByteArray *)row {
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                               userInfo:nil];
}

- (VZZXByteArray *)matrix {
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                               userInfo:nil];
}

- (VZZXLuminanceSource *)crop:(int)left top:(int)top width:(int)width height:(int)height {
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:@"This luminance source does not support cropping."
                               userInfo:nil];
}

- (VZZXLuminanceSource *)invert {
  return [[VZZXInvertedLuminanceSource alloc] initWithDelegate:self];
}

- (VZZXLuminanceSource *)rotateCounterClockwise {
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:@"This luminance source does not support rotation by 90 degrees."
                               userInfo:nil];
}

- (VZZXLuminanceSource *)rotateCounterClockwise45 {
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:@"This luminance source does not support rotation by 45 degrees."
                               userInfo:nil];
}

- (NSString *)description {
  VZZXByteArray *row = [[VZZXByteArray alloc] initWithLength:self.width];
  NSMutableString *result = [NSMutableString stringWithCapacity:self.height * (self.width + 1)];
  for (int y = 0; y < self.height; y++) {
    row = [self rowAtY:y row:row];
    for (int x = 0; x < self.width; x++) {
      int luminance = row.array[x] & 0xFF;
      unichar c;
      if (luminance < 0x40) {
        c = '#';
      } else if (luminance < 0x80) {
        c = '+';
      } else if (luminance < 0xC0) {
        c = '.';
      } else {
        c = ' ';
      }
      [result appendFormat:@"%C", c];
    }
    [result appendString:@"\n"];
  }
  return result;
}

@end
