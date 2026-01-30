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
#import "VZZXDataMatrixDecoder.h"
#import "VZZXDataMatrixDetector.h"
#import "VZZXDataMatrixReader.h"
#import "VZZXDecodeHints.h"
#import "VZZXDecoderResult.h"
#import "VZZXDetectorResult.h"
#import "VZZXErrors.h"
#import "VZZXIntArray.h"
#import "VZZXResult.h"

@interface VZZXDataMatrixReader ()

@property (nonatomic, strong, readonly) VZZXDataMatrixDecoder *decoder;

@end

@implementation VZZXDataMatrixReader

- (id)init {
  if (self = [super init]) {
    _decoder = [[VZZXDataMatrixDecoder alloc] init];
  }

  return self;
}

/**
 * Locates and decodes a Data Matrix code in an image.
 *
 * @return a String representing the content encoded by the Data Matrix code
 */
- (VZZXResult *)decode:(VZZXBinaryBitmap *)image error:(NSError **)error {
  return [self decode:image hints:nil error:error];
}

- (VZZXResult *)decode:(VZZXBinaryBitmap *)image hints:(VZZXDecodeHints *)hints error:(NSError **)error {
  VZZXDecoderResult *decoderResult;
  NSArray *points;
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
    decoderResult = [self.decoder decodeMatrix:bits error:error];
    if (!decoderResult) {
      return nil;
    }
    points = @[];
  } else {
    VZZXBitMatrix *matrix = [image blackMatrixWithError:error];
    if (!matrix) {
      return nil;
    }
    VZZXDataMatrixDetector *detector = [[VZZXDataMatrixDetector alloc] initWithImage:matrix error:error];
    if (!detector) {
      return nil;
    }
    VZZXDetectorResult *detectorResult = [detector detectWithError:error];
    if (!detectorResult) {
      return nil;
    }
    decoderResult = [self.decoder decodeMatrix:detectorResult.bits error:error];
    if (!decoderResult) {
      return nil;
    }
    points = detectorResult.points;
  }
  VZZXResult *result = [VZZXResult resultWithText:decoderResult.text
                                     rawBytes:decoderResult.rawBytes
                                 resultPoints:points
                                       format:kBarcodeFormatDataMatrix];
  if (decoderResult.byteSegments != nil) {
    [result putMetadata:kResultMetadataTypeByteSegments value:decoderResult.byteSegments];
  }
  if (decoderResult.ecLevel != nil) {
    [result putMetadata:kResultMetadataTypeErrorCorrectionLevel value:decoderResult.ecLevel];
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
  VZZXIntArray *leftTopBlack = image.topLeftOnBit;
  VZZXIntArray *rightBottomBlack = image.bottomRightOnBit;
  if (leftTopBlack == nil || rightBottomBlack == nil) {
    return nil;
  }

  int moduleSize = [self moduleSize:leftTopBlack image:image];
  if (moduleSize == -1) {
    return nil;
  }

  int top = leftTopBlack.array[1];
  int bottom = rightBottomBlack.array[1];
  int left = leftTopBlack.array[0];
  int right = rightBottomBlack.array[0];

  int matrixWidth = (right - left + 1) / moduleSize;
  int matrixHeight = (bottom - top + 1) / moduleSize;
  if (matrixWidth <= 0 || matrixHeight <= 0) {
    return nil;
  }

  int nudge = moduleSize / 2;
  top += nudge;
  left += nudge;

  VZZXBitMatrix *bits = [[VZZXBitMatrix alloc] initWithWidth:matrixWidth height:matrixHeight];
  for (int y = 0; y < matrixHeight; y++) {
    int iOffset = top + y * moduleSize;
    for (int x = 0; x < matrixWidth; x++) {
      if ([image getX:left + x * moduleSize y:iOffset]) {
        [bits setX:x y:y];
      }
    }
  }

  return bits;
}

- (int)moduleSize:(VZZXIntArray *)leftTopBlack image:(VZZXBitMatrix *)image {
  int width = image.width;
  int x = leftTopBlack.array[0];
  int y = leftTopBlack.array[1];
  while (x < width && [image getX:x y:y]) {
    x++;
  }
  if (x == width) {
    return -1;
  }

  int moduleSize = x - leftTopBlack.array[0];
  if (moduleSize == 0) {
    return -1;
  }
  return moduleSize;
}

@end
