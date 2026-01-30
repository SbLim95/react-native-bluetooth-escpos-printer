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

#import "VZZXGlobalHistogramBinarizer.h"
#import "VZZXBitArray.h"
#import "VZZXBitMatrix.h"
#import "VZZXByteArray.h"
#import "VZZXErrors.h"
#import "VZZXIntArray.h"
#import "VZZXLuminanceSource.h"

const int VZZX_LUMINANCE_BITS = 5;
const int VZZX_LUMINANCE_SHIFT = 8 - VZZX_LUMINANCE_BITS;
const int VZZX_LUMINANCE_BUCKETS = 1 << VZZX_LUMINANCE_BITS;

@interface VZZXGlobalHistogramBinarizer ()

@property (nonatomic, strong) VZZXByteArray *luminances;
@property (nonatomic, strong) VZZXIntArray *buckets;

@end

@implementation VZZXGlobalHistogramBinarizer

- (id)initWithSource:(VZZXLuminanceSource *)source {
  if (self = [super initWithSource:source]) {
    _luminances = [[VZZXByteArray alloc] initWithLength:0];
    _buckets = [[VZZXIntArray alloc] initWithLength:VZZX_LUMINANCE_BUCKETS];
  }

  return self;
}

- (VZZXBitArray *)blackRow:(int)y row:(VZZXBitArray *)row error:(NSError **)error {
  VZZXLuminanceSource *source = self.luminanceSource;
  int width = source.width;
  if (row == nil || row.size < width) {
    row = [[VZZXBitArray alloc] initWithSize:width];
  } else {
    [row clear];
  }

  [self initArrays:width];
  VZZXByteArray *localLuminances = [source rowAtY:y row:self.luminances];
  VZZXIntArray *localBuckets = self.buckets;
  for (int x = 0; x < width; x++) {
    int pixel = localLuminances.array[x] & 0xff;
    localBuckets.array[pixel >> VZZX_LUMINANCE_SHIFT]++;
  }
  int blackPoint = [self estimateBlackPoint:localBuckets];
  if (blackPoint == -1) {
    if (error) *error = VZZXNotFoundErrorInstance();
    return nil;
  }

  int left = localLuminances.array[0] & 0xff;
  int center = localLuminances.array[1] & 0xff;
  for (int x = 1; x < width - 1; x++) {
    int right = localLuminances.array[x + 1] & 0xff;
    // A simple -1 4 -1 box filter with a weight of 2.
    int luminance = ((center * 4) - left - right) >> 1;
    if (luminance < blackPoint) {
      [row set:x];
    }
    left = center;
    center = right;
  }

  return row;
}

- (VZZXBitMatrix *)blackMatrixWithError:(NSError **)error {
  VZZXLuminanceSource *source = self.luminanceSource;
  int width = source.width;
  int height = source.height;
  VZZXBitMatrix *matrix = [[VZZXBitMatrix alloc] initWithWidth:width height:height];

  // Quickly calculates the histogram by sampling four rows from the image. This proved to be
  // more robust on the blackbox tests than sampling a diagonal as we used to do.
  [self initArrays:width];

  // We delay reading the entire image luminance until the black point estimation succeeds.
  // Although we end up reading four rows twice, it is consistent with our motto of
  // "fail quickly" which is necessary for continuous scanning.
  VZZXIntArray *localBuckets = self.buckets;
  for (int y = 1; y < 5; y++) {
    int row = height * y / 5;
    VZZXByteArray *localLuminances = [source rowAtY:row row:self.luminances];
    int right = (width * 4) / 5;
    for (int x = width / 5; x < right; x++) {
      int pixel = localLuminances.array[x] & 0xff;
      localBuckets.array[pixel >> VZZX_LUMINANCE_SHIFT]++;
    }
  }
  int blackPoint = [self estimateBlackPoint:localBuckets];
  if (blackPoint == -1) {
    if (error) *error = VZZXNotFoundErrorInstance();
    return nil;
  }

  VZZXByteArray *localLuminances = source.matrix;
  for (int y = 0; y < height; y++) {
    int offset = y * width;
    for (int x = 0; x < width; x++) {
      int pixel = localLuminances.array[offset + x] & 0xff;
      if (pixel < blackPoint) {
        [matrix setX:x y:y];
      }
    }
  }

  return matrix;
}

- (VZZXBinarizer *)createBinarizer:(VZZXLuminanceSource *)source {
  return [[VZZXGlobalHistogramBinarizer alloc] initWithSource:source];
}

- (void)initArrays:(int)luminanceSize {
  if (self.luminances.length < luminanceSize) {
    self.luminances = [[VZZXByteArray alloc] initWithLength:luminanceSize];
  }

  for (int x = 0; x < VZZX_LUMINANCE_BUCKETS; x++) {
    self.buckets.array[x] = 0;
  }
}

- (int)estimateBlackPoint:(VZZXIntArray *)buckets {
  // Find the tallest peak in the histogram.
  int numBuckets = buckets.length;
  int maxBucketCount = 0;
  int firstPeak = 0;
  int firstPeakSize = 0;
  for (int x = 0; x < numBuckets; x++) {
    if (buckets.array[x] > firstPeakSize) {
      firstPeak = x;
      firstPeakSize = buckets.array[x];
    }
    if (buckets.array[x] > maxBucketCount) {
      maxBucketCount = buckets.array[x];
    }
  }

  // Find the second-tallest peak which is somewhat far from the tallest peak.
  int secondPeak = 0;
  int secondPeakScore = 0;
  for (int x = 0; x < numBuckets; x++) {
    int distanceToBiggest = x - firstPeak;
    // Encourage more distant second peaks by multiplying by square of distance.
    int score = buckets.array[x] * distanceToBiggest * distanceToBiggest;
    if (score > secondPeakScore) {
      secondPeak = x;
      secondPeakScore = score;
    }
  }

  // Make sure firstPeak corresponds to the black peak.
  if (firstPeak > secondPeak) {
    int temp = firstPeak;
    firstPeak = secondPeak;
    secondPeak = temp;
  }

  // If there is too little contrast in the image to pick a meaningful black point, throw rather
  // than waste time trying to decode the image, and risk false positives.
  if (secondPeak - firstPeak <= numBuckets / 16) {
    return -1;
  }

  // Find a valley between them that is low and closer to the white peak.
  int bestValley = secondPeak - 1;
  int bestValleyScore = -1;
  for (int x = secondPeak - 1; x > firstPeak; x--) {
    int fromFirst = x - firstPeak;
    int score = fromFirst * fromFirst * (secondPeak - x) * (maxBucketCount - buckets.array[x]);
    if (score > bestValleyScore) {
      bestValley = x;
      bestValleyScore = score;
    }
  }

  return bestValley << VZZX_LUMINANCE_SHIFT;
}

@end
