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

@interface VZZXInvertedLuminanceSource ()

@property (nonatomic, weak, readonly) VZZXLuminanceSource *delegate;

@end

@implementation VZZXInvertedLuminanceSource

- (id)initWithDelegate:(VZZXLuminanceSource *)delegate {
  self = [super initWithWidth:delegate.width height:delegate.height];
  if (self) {
    _delegate = delegate;
  }

  return self;
}

- (VZZXByteArray *)rowAtY:(int)y row:(VZZXByteArray *)row {
  row = [self.delegate rowAtY:y row:row];
  int width = self.width;
  int8_t *rowArray = row.array;
  for (int i = 0; i < width; i++) {
    rowArray[i] = (int8_t) (255 - (rowArray[i] & 0xFF));
  }
  return row;
}

- (VZZXByteArray *)matrix {
  VZZXByteArray *matrix = [self.delegate matrix];
  int length = self.width * self.height;
  VZZXByteArray *invertedMatrix = [[VZZXByteArray alloc] initWithLength:length];
  int8_t *invertedMatrixArray = invertedMatrix.array;
  int8_t *matrixArray = matrix.array;
  for (int i = 0; i < length; i++) {
    invertedMatrixArray[i] = (int8_t) (255 - (matrixArray[i] & 0xFF));
  }
  return invertedMatrix;
}

- (BOOL)cropSupported {
  return self.delegate.cropSupported;
}

- (VZZXLuminanceSource *)crop:(int)left top:(int)top width:(int)aWidth height:(int)aHeight {
  return [[VZZXInvertedLuminanceSource alloc] initWithDelegate:[self.delegate crop:left top:top width:aWidth height:aHeight]];
}

- (BOOL)rotateSupported {
  return self.delegate.rotateSupported;
}

/**
 * @return original delegate VZZXLuminanceSource since invert undoes itself
 */
- (VZZXLuminanceSource *)invert {
  return self.delegate;
}

- (VZZXLuminanceSource *)rotateCounterClockwise {
  return [[VZZXInvertedLuminanceSource alloc] initWithDelegate:[self.delegate rotateCounterClockwise]];
}

- (VZZXLuminanceSource *)rotateCounterClockwise45 {
  return [[VZZXInvertedLuminanceSource alloc] initWithDelegate:[self.delegate rotateCounterClockwise45]];
}

@end
