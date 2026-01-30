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

#import "VZZXBinarizer.h"
#import "VZZXBinaryBitmap.h"
#import "VZZXBitArray.h"
#import "VZZXBitMatrix.h"

@interface VZZXBinaryBitmap ()

@property (nonatomic, strong, readonly) VZZXBinarizer *binarizer;
@property (nonatomic, strong) VZZXBitMatrix *matrix;

@end

@implementation VZZXBinaryBitmap

- (id)initWithBinarizer:(VZZXBinarizer *)binarizer {
  if (self = [super init]) {
    if (binarizer == nil) {
      [NSException raise:NSInvalidArgumentException format:@"Binarizer must be non-null."];
    }

    _binarizer = binarizer;
  }

  return self;
}

+ (id)binaryBitmapWithBinarizer:(VZZXBinarizer *)binarizer {
  return [[self alloc] initWithBinarizer:binarizer];
}

- (int)width {
  return self.binarizer.width;
}

- (int)height {
  return self.binarizer.height;
}

- (VZZXBitArray *)blackRow:(int)y row:(VZZXBitArray *)row error:(NSError **)error {
  return [self.binarizer blackRow:y row:row error:error];
}

- (VZZXBitMatrix *)blackMatrixWithError:(NSError **)error {
  if (self.matrix == nil) {
    self.matrix = [self.binarizer blackMatrixWithError:error];
  }
  return self.matrix;
}

- (BOOL)cropSupported {
  return [self.binarizer luminanceSource].cropSupported;
}

- (VZZXBinaryBitmap *)crop:(int)left top:(int)top width:(int)aWidth height:(int)aHeight {
  VZZXLuminanceSource *newSource = [[self.binarizer luminanceSource] crop:left top:top width:aWidth height:aHeight];
  return [[VZZXBinaryBitmap alloc] initWithBinarizer:[self.binarizer createBinarizer:newSource]];
}

- (BOOL)rotateSupported {
  return [self.binarizer luminanceSource].rotateSupported;
}

- (VZZXBinaryBitmap *)rotateCounterClockwise {
  VZZXLuminanceSource *newSource = [[self.binarizer luminanceSource] rotateCounterClockwise];
  return [[VZZXBinaryBitmap alloc] initWithBinarizer:[self.binarizer createBinarizer:newSource]];
}

- (VZZXBinaryBitmap *)rotateCounterClockwise45 {
  VZZXLuminanceSource *newSource = [[self.binarizer luminanceSource] rotateCounterClockwise45];
  return [[VZZXBinaryBitmap alloc] initWithBinarizer:[self.binarizer createBinarizer:newSource]];
}

- (NSString *)description {
  VZZXBitMatrix *matrix = [self blackMatrixWithError:nil];
  if (matrix) {
    return [matrix description];
  } else {
    return @"";
  }
}

@end
