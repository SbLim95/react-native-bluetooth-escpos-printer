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

#import "VZZXAztecDecoder.h"
#import "VZZXAztecDetector.h"
#import "VZZXAztecDetectorResult.h"
#import "VZZXAztecReader.h"
#import "VZZXBinaryBitmap.h"
#import "VZZXDecodeHints.h"
#import "VZZXDecoderResult.h"
#import "VZZXReader.h"
#import "VZZXResult.h"
#import "VZZXResultPointCallback.h"

@implementation VZZXAztecReader

- (VZZXResult *)decode:(VZZXBinaryBitmap *)image error:(NSError **)error {
  return [self decode:image hints:nil error:error];
}

- (VZZXResult *)decode:(VZZXBinaryBitmap *)image hints:(VZZXDecodeHints *)hints error:(NSError **)error {
  VZZXBitMatrix *matrix = [image blackMatrixWithError:error];
  if (!matrix) {
    return nil;
  }

  VZZXAztecDetector *detector = [[VZZXAztecDetector alloc] initWithImage:matrix];
  NSArray *points = nil;
  VZZXDecoderResult *decoderResult = nil;

  VZZXAztecDetectorResult *detectorResult = [detector detectWithMirror:NO error:error];
  if (detectorResult) {
    points = detectorResult.points;
    decoderResult = [[[VZZXAztecDecoder alloc] init] decode:detectorResult error:error];
  }

  if (decoderResult == nil) {
    detectorResult = [detector detectWithMirror:YES error:nil];
    points = detectorResult.points;
    if (detectorResult) {
      decoderResult = [[[VZZXAztecDecoder alloc] init] decode:detectorResult error:nil];
    }
  }

  if (!decoderResult) {
    return nil;
  }

  if (hints != nil) {
    id <VZZXResultPointCallback> rpcb = hints.resultPointCallback;
    if (rpcb != nil) {
      for (VZZXResultPoint *p in points) {
        [rpcb foundPossibleResultPoint:p];
      }
    }
  }

  VZZXResult *result = [VZZXResult resultWithText:decoderResult.text rawBytes:decoderResult.rawBytes resultPoints:points format:kBarcodeFormatAztec];

  NSMutableArray *byteSegments = decoderResult.byteSegments;
  if (byteSegments != nil) {
    [result putMetadata:kResultMetadataTypeByteSegments value:byteSegments];
  }
  NSString *ecLevel = decoderResult.ecLevel;
  if (ecLevel != nil) {
    [result putMetadata:kResultMetadataTypeErrorCorrectionLevel value:ecLevel];
  }

  return result;
}

- (void)reset {
  // do nothing
}

@end
