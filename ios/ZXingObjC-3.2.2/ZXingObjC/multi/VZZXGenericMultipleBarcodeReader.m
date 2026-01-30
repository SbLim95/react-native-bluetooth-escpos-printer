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

#import "VZZXErrors.h"
#import "VZZXGenericMultipleBarcodeReader.h"
#import "VZZXReader.h"
#import "VZZXResultPoint.h"

const int VZZX_MIN_DIMENSION_TO_RECUR = 100;
const int VZZX_MAX_DEPTH = 4;

@interface VZZXGenericMultipleBarcodeReader ()

@property (nonatomic, readonly) id<VZZXReader> delegate;

@end

@implementation VZZXGenericMultipleBarcodeReader

- (id)initWithDelegate:(id<VZZXReader>)delegate {
  if (self = [super init]) {
    _delegate = delegate;
  }

  return self;
}

- (NSArray *)decodeMultiple:(VZZXBinaryBitmap *)image error:(NSError **)error {
  return [self decodeMultiple:image hints:nil error:error];
}

- (NSArray *)decodeMultiple:(VZZXBinaryBitmap *)image hints:(VZZXDecodeHints *)hints error:(NSError **)error {
  NSMutableArray *results = [NSMutableArray array];
  [self doDecodeMultiple:image hints:hints results:results xOffset:0 yOffset:0 currentDepth:0 error:error];
  if (results.count == 0) {
    if (error) *error = VZZXNotFoundErrorInstance();
    return nil;
  }

  return results;
}

- (void)doDecodeMultiple:(VZZXBinaryBitmap *)image hints:(VZZXDecodeHints *)hints results:(NSMutableArray *)results
                 xOffset:(int)xOffset yOffset:(int)yOffset currentDepth:(int)currentDepth error:(NSError **)error {
  if (currentDepth > VZZX_MAX_DEPTH) {
    return;
  }

  VZZXResult *result = [self.delegate decode:image hints:hints error:error];
  if (!result) {
    return;
  }

  BOOL alreadyFound = NO;
  for (VZZXResult *existingResult in results) {
    if ([[existingResult text] isEqualToString:[result text]]) {
      alreadyFound = YES;
      break;
    }
  }
  if (!alreadyFound) {
    [results addObject:[self translateResultPoints:result xOffset:xOffset yOffset:yOffset]];
  }
  NSMutableArray *resultPoints = [result resultPoints];
  if (resultPoints == nil || resultPoints.count == 0) {
    return;
  }
  int width = [image width];
  int height = [image height];
  float minX = width;
  float minY = height;
  float maxX = 0.0f;
  float maxY = 0.0f;
  for (VZZXResultPoint *point in resultPoints) {
    if ((id)point == [NSNull null]) {
      continue;
    }
    float x = [point x];
    float y = [point y];
    if (x < minX) {
      minX = x;
    }
    if (y < minY) {
      minY = y;
    }
    if (x > maxX) {
      maxX = x;
    }
    if (y > maxY) {
      maxY = y;
    }
  }

  if (minX > VZZX_MIN_DIMENSION_TO_RECUR) {
    [self doDecodeMultiple:[image crop:0 top:0 width:(int)minX height:height] hints:hints results:results xOffset:xOffset yOffset:yOffset currentDepth:currentDepth + 1 error:error];
  }
  if (minY > VZZX_MIN_DIMENSION_TO_RECUR) {
    [self doDecodeMultiple:[image crop:0 top:0 width:width height:(int)minY] hints:hints results:results xOffset:xOffset yOffset:yOffset currentDepth:currentDepth + 1 error:error];
  }
  if (maxX < width - VZZX_MIN_DIMENSION_TO_RECUR) {
    [self doDecodeMultiple:[image crop:(int)maxX top:0 width:width - (int)maxX height:height] hints:hints results:results xOffset:xOffset + (int)maxX yOffset:yOffset currentDepth:currentDepth + 1 error:error];
  }
  if (maxY < height - VZZX_MIN_DIMENSION_TO_RECUR) {
    [self doDecodeMultiple:[image crop:0 top:(int)maxY width:width height:height - (int)maxY] hints:hints results:results xOffset:xOffset yOffset:yOffset + (int)maxY currentDepth:currentDepth + 1 error:error];
  }
}

- (VZZXResult *)translateResultPoints:(VZZXResult *)result xOffset:(int)xOffset yOffset:(int)yOffset {
  NSArray *oldResultPoints = [result resultPoints];
  if (oldResultPoints == nil) {
    return result;
  }
  NSMutableArray *newResultPoints = [NSMutableArray arrayWithCapacity:[oldResultPoints count]];
  for (VZZXResultPoint *oldPoint in oldResultPoints) {
    if ((id)oldPoint != [NSNull null]) {
      [newResultPoints addObject:[[VZZXResultPoint alloc] initWithX:[oldPoint x] + xOffset y:[oldPoint y] + yOffset]];
    }
  }

  VZZXResult *newResult = [VZZXResult resultWithText:result.text rawBytes:result.rawBytes resultPoints:newResultPoints format:result.barcodeFormat];
  [newResult putAllMetadata:result.resultMetadata];
  return newResult;
}

@end
