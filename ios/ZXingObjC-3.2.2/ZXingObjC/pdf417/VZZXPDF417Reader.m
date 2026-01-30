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

#import "VZZXBarcodeFormat.h"
#import "VZZXBinaryBitmap.h"
#import "VZZXBitMatrix.h"
#import "VZZXDecodeHints.h"
#import "VZZXDecoderResult.h"
#import "VZZXDetectorResult.h"
#import "VZZXErrors.h"
#import "VZZXPDF417Common.h"
#import "VZZXPDF417Detector.h"
#import "VZZXPDF417DetectorResult.h"
#import "VZZXPDF417Reader.h"
#import "VZZXPDF417ResultMetadata.h"
#import "VZZXPDF417ScanningDecoder.h"
#import "VZZXResult.h"
#import "VZZXResultPoint.h"

@implementation VZZXPDF417Reader

/**
 * Locates and decodes a PDF417 code in an image.
 *
 * @return a String representing the content encoded by the PDF417 code
 * @return nil if a PDF417 code cannot be found,
 * @return nil if a PDF417 cannot be decoded
 */
- (VZZXResult *)decode:(VZZXBinaryBitmap *)image error:(NSError **)error {
  return [self decode:image hints:nil error:error];
}

- (VZZXResult *)decode:(VZZXBinaryBitmap *)image hints:(VZZXDecodeHints *)hints error:(NSError **)error {
  NSArray *result = [self decode:image hints:hints multiple:NO error:error];
  if (!result || result.count == 0 || !result[0]) {
    if (error) *error = VZZXNotFoundErrorInstance();
    return nil;
  }
  return result[0];
}

- (NSArray *)decodeMultiple:(VZZXBinaryBitmap *)image error:(NSError **)error {
  return [self decodeMultiple:image hints:nil error:error];
}

- (NSArray *)decodeMultiple:(VZZXBinaryBitmap *)image hints:(VZZXDecodeHints *)hints error:(NSError **)error {
  return [self decode:image hints:hints multiple:YES error:error];
}

- (NSArray *)decode:(VZZXBinaryBitmap *)image hints:(VZZXDecodeHints *)hints multiple:(BOOL)multiple error:(NSError **)error {
  NSMutableArray *results = [NSMutableArray array];
  VZZXPDF417DetectorResult *detectorResult = [VZZXPDF417Detector detect:image hints:hints multiple:multiple error:error];
  if (!detectorResult) {
    return nil;
  }
  for (NSArray *points in detectorResult.points) {
    VZZXResultPoint *imageTopLeft = points[4] == [NSNull null] ? nil : points[4];
    VZZXResultPoint *imageBottomLeft = points[5] == [NSNull null] ? nil : points[5];
    VZZXResultPoint *imageTopRight = points[6] == [NSNull null] ? nil : points[6];
    VZZXResultPoint *imageBottomRight = points[7] == [NSNull null] ? nil : points[7];

    VZZXDecoderResult *decoderResult = [VZZXPDF417ScanningDecoder decode:detectorResult.bits
                                                        imageTopLeft:imageTopLeft
                                                     imageBottomLeft:imageBottomLeft
                                                       imageTopRight:imageTopRight
                                                    imageBottomRight:imageBottomRight
                                                    minCodewordWidth:[self minCodewordWidth:points]
                                                    maxCodewordWidth:[self maxCodewordWidth:points]
                                                               error:error];
    if (!decoderResult) {
      return nil;
    }
    VZZXResult *result = [[VZZXResult alloc] initWithText:decoderResult.text
                                             rawBytes:decoderResult.rawBytes
                                               resultPoints:points
                                               format:kBarcodeFormatPDF417];
    [result putMetadata:kResultMetadataTypeErrorCorrectionLevel value:decoderResult.ecLevel];
    VZZXPDF417ResultMetadata *pdf417ResultMetadata = decoderResult.other;
    if (pdf417ResultMetadata) {
      [result putMetadata:kResultMetadataTypePDF417ExtraMetadata value:pdf417ResultMetadata];
    }
    [results addObject:result];
  }
  return [NSArray arrayWithArray:results];
}

- (int)maxWidth:(VZZXResultPoint *)p1 p2:(VZZXResultPoint *)p2 {
  if (!p1 || !p2 || (id)p1 == [NSNull null] || p2 == (id)[NSNull null]) {
    return 0;
  }
  return fabsf(p1.x - p2.x);
}

- (int)minWidth:(VZZXResultPoint *)p1 p2:(VZZXResultPoint *)p2 {
  if (!p1 || !p2 || (id)p1 == [NSNull null] || p2 == (id)[NSNull null]) {
    return INT_MAX;
  }
  return fabsf(p1.x - p2.x);
}

- (int)maxCodewordWidth:(NSArray *)p {
  return MAX(
             MAX([self maxWidth:p[0] p2:p[4]], [self maxWidth:p[6] p2:p[2]] * VZZX_PDF417_MODULES_IN_CODEWORD /
                 VZZX_PDF417_MODULES_IN_STOP_PATTERN),
             MAX([self maxWidth:p[1] p2:p[5]], [self maxWidth:p[7] p2:p[3]] * VZZX_PDF417_MODULES_IN_CODEWORD /
                 VZZX_PDF417_MODULES_IN_STOP_PATTERN));
}

- (int)minCodewordWidth:(NSArray *)p {
  return MIN(
             MIN([self minWidth:p[0] p2:p[4]], [self minWidth:p[6] p2:p[2]] * VZZX_PDF417_MODULES_IN_CODEWORD /
                 VZZX_PDF417_MODULES_IN_STOP_PATTERN),
             MIN([self minWidth:p[1] p2:p[5]], [self minWidth:p[7] p2:p[3]] * VZZX_PDF417_MODULES_IN_CODEWORD /
                 VZZX_PDF417_MODULES_IN_STOP_PATTERN));
}

- (void)reset {
  // nothing needs to be reset
}

@end
