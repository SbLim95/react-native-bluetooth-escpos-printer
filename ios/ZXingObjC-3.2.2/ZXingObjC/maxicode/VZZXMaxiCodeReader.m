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

#import "VZZXBinaryBitmap.h"
#import "VZZXBitMatrix.h"
#import "VZZXDecodeHints.h"
#import "VZZXDecoderResult.h"
#import "VZZXErrors.h"
#import "VZZXIntArray.h"
#import "VZZXMaxiCodeDecoder.h"
#import "VZZXMaxiCodeReader.h"
#import "VZZXResult.h"

const int VZZX_MATRIX_WIDTH = 30;
const int VZZX_MATRIX_HEIGHT = 33;

@interface VZZXMaxiCodeReader ()

@property (nonatomic, strong, readonly) VZZXMaxiCodeDecoder *decoder;

@end

@implementation VZZXMaxiCodeReader

- (id)init {
  if (self = [super init]) {
    _decoder = [[VZZXMaxiCodeDecoder alloc] init];
  }

  return self;
}

/**
 * Locates and decodes a MaxiCode in an image.
 *
 * @return a String representing the content encoded by the MaxiCode
 * @return nil if a MaxiCode cannot be found
 * @return nil if a MaxiCode cannot be decoded
 * @return nil if error correction fails
 */
- (VZZXResult *)decode:(VZZXBinaryBitmap *)image error:(NSError **)error {
  return [self decode:image hints:nil error:error];
}

- (VZZXResult *)decode:(VZZXBinaryBitmap *)image hints:(VZZXDecodeHints *)hints error:(NSError **)error {
  VZZXDecoderResult *decoderResult;
  if (hints != nil && hints.pureBarcode) {
    VZZXBitMatrix *matrix = [image blackMatrixWithError:error];
    if (!matrix) {
      return nil;
    }
    VZZXBitMatrix *bits = [self extractPureBits:matrix];
    if (!bits) {
      if (error) *error = VZZXNotFoundErrorInstance();
      return nil;
    }
    decoderResult = [self.decoder decode:bits hints:hints error:error];
    if (!decoderResult) {
      return nil;
    }
  } else {
    if (error) *error = VZZXNotFoundErrorInstance();
    return nil;
  }

  NSArray *points = @[];
  VZZXResult *result = [VZZXResult resultWithText:decoderResult.text
                                      rawBytes:decoderResult.rawBytes
                                  resultPoints:points
                                        format:kBarcodeFormatMaxiCode];

  NSString *ecLevel = decoderResult.ecLevel;
  if (ecLevel != nil) {
    [result putMetadata:kResultMetadataTypeErrorCorrectionLevel value:ecLevel];
  }
  return result;
}

- (void)reset {
  // do nothing
}

/**
 * This method detects a code in a "pure" image -- that is, pure monochrome image
 * which contains only an unrotated, unskewed, image of a code, with some white border
 * around it. This is a specialized method that works exceptionally fast in this special
 * case.
 */
- (VZZXBitMatrix *)extractPureBits:(VZZXBitMatrix *)image {
  VZZXIntArray *enclosingRectangle = image.enclosingRectangle;
  if (enclosingRectangle == nil) {
    return nil;
  }

  int left = enclosingRectangle.array[0];
  int top = enclosingRectangle.array[1];
  int width = enclosingRectangle.array[2];
  int height = enclosingRectangle.array[3];

  // Now just read off the bits
  VZZXBitMatrix *bits = [[VZZXBitMatrix alloc] initWithWidth:VZZX_MATRIX_WIDTH height:VZZX_MATRIX_HEIGHT];
  for (int y = 0; y < VZZX_MATRIX_HEIGHT; y++) {
    int iy = top + (y * height + height / 2) / VZZX_MATRIX_HEIGHT;
    for (int x = 0; x < VZZX_MATRIX_WIDTH; x++) {
      int ix = left + (x * width + width / 2 + (y & 0x01) *  width / 2) / VZZX_MATRIX_WIDTH;
      if ([image getX:ix y:iy]) {
        [bits setX:x y:y];
      }
    }
  }

  return bits;
}

@end
