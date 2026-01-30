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

#import "VZZXAbstractRSSReader.h"
#import "VZZXIntArray.h"

static float VZZX_RSS_MAX_AVG_VARIANCE = 0.2f;
static float VZZX_RSS_MAX_INDIVIDUAL_VARIANCE = 0.45f;

float const VZZX_RSS_MIN_FINDER_PATTERN_RATIO = 9.5f / 12.0f;
float const VZZX_RSS_MAX_FINDER_PATTERN_RATIO = 12.5f / 14.0f;

#define VZZX_RSS14_FINDER_PATTERNS_LEN 9
#define VZZX_RSS14_FINDER_PATTERNS_SUB_LEN 4
const int VZZX_RSS14_FINDER_PATTERNS[VZZX_RSS14_FINDER_PATTERNS_LEN][VZZX_RSS14_FINDER_PATTERNS_SUB_LEN] = {
  {3,8,2,1},
  {3,5,5,1},
  {3,3,7,1},
  {3,1,9,1},
  {2,7,4,1},
  {2,5,6,1},
  {2,3,8,1},
  {1,5,7,1},
  {1,3,9,1},
};

#define VZZX_RSS_EXPANDED_FINDER_PATTERNS_LEN 6
#define VZZX_RSS_EXPANDED_FINDER_PATTERNS_SUB_LEN 4
const int VZZX_RSS_EXPANDED_FINDER_PATTERNS[VZZX_RSS_EXPANDED_FINDER_PATTERNS_LEN][VZZX_RSS_EXPANDED_FINDER_PATTERNS_SUB_LEN] = {
  {1,8,4,1}, // A
  {3,6,4,1}, // B
  {3,4,6,1}, // C
  {3,2,8,1}, // D
  {2,6,5,1}, // E
  {2,2,9,1}  // F
};

@implementation VZZXAbstractRSSReader

- (id)init {
  if (self = [super init]) {
    _decodeFinderCounters = [[VZZXIntArray alloc] initWithLength:4];
    _dataCharacterCounters = [[VZZXIntArray alloc] initWithLength:8];

    _oddRoundingErrorsLen = 4;
    _oddRoundingErrors = (float *)malloc(_oddRoundingErrorsLen * sizeof(float));
    memset(_oddRoundingErrors, 0, _oddRoundingErrorsLen * sizeof(float));

    _evenRoundingErrorsLen = 4;
    _evenRoundingErrors = (float *)malloc(_evenRoundingErrorsLen * sizeof(float));
    memset(_evenRoundingErrors, 0, _evenRoundingErrorsLen * sizeof(float));

    _oddCounts = [[VZZXIntArray alloc] initWithLength:_dataCharacterCounters.length / 2];
    _evenCounts = [[VZZXIntArray alloc] initWithLength:_dataCharacterCounters.length / 2];
  }

  return self;
}

- (void)dealloc {
  if (_oddRoundingErrors != NULL) {
    free(_oddRoundingErrors);
    _oddRoundingErrors = NULL;
  }

  if (_evenRoundingErrors != NULL) {
    free(_evenRoundingErrors);
    _evenRoundingErrors = NULL;
  }
}

+ (int)parseFinderValue:(VZZXIntArray *)counters finderPatternType:(VZZX_RSS_PATTERNS)finderPatternType {
  switch (finderPatternType) {
    case VZZX_RSS_PATTERNS_RSS14_PATTERNS:
      for (int value = 0; value < VZZX_RSS14_FINDER_PATTERNS_LEN; value++) {
        if ([self patternMatchVariance:counters pattern:VZZX_RSS14_FINDER_PATTERNS[value] maxIndividualVariance:VZZX_RSS_MAX_INDIVIDUAL_VARIANCE] < VZZX_RSS_MAX_AVG_VARIANCE) {
          return value;
        }
      }
      break;

    case VZZX_RSS_PATTERNS_RSS_EXPANDED_PATTERNS:
      for (int value = 0; value < VZZX_RSS_EXPANDED_FINDER_PATTERNS_LEN; value++) {
        if ([self patternMatchVariance:counters pattern:VZZX_RSS_EXPANDED_FINDER_PATTERNS[value] maxIndividualVariance:VZZX_RSS_MAX_INDIVIDUAL_VARIANCE] < VZZX_RSS_MAX_AVG_VARIANCE) {
          return value;
        }
      }
      break;

    default:
      break;
  }

  return -1;
}

+ (int)count:(VZZXIntArray *)array {
  return [array sum];
}

+ (void)increment:(VZZXIntArray *)array errors:(float *)errors {
  int index = 0;
  float biggestError = errors[0];
  for (int i = 1; i < array.length; i++) {
    if (errors[i] > biggestError) {
      biggestError = errors[i];
      index = i;
    }
  }
  array.array[index]++;
}

+ (void)decrement:(VZZXIntArray *)array errors:(float *)errors {
  int index = 0;
  float biggestError = errors[0];
  for (int i = 1; i < array.length; i++) {
    if (errors[i] < biggestError) {
      biggestError = errors[i];
      index = i;
    }
  }
  array.array[index]--;
}

+ (BOOL)isFinderPattern:(VZZXIntArray *)counters {
  int32_t *array = counters.array;
  int firstTwoSum = array[0] + array[1];
  int sum = firstTwoSum + array[2] + array[3];
  float ratio = (float)firstTwoSum / (float)sum;
  if (ratio >= VZZX_RSS_MIN_FINDER_PATTERN_RATIO && ratio <= VZZX_RSS_MAX_FINDER_PATTERN_RATIO) {
    int minCounter = INT_MAX;
    int maxCounter = INT_MIN;
    for (int i = 0; i < counters.length; i++) {
      int counter = array[i];
      if (counter > maxCounter) {
        maxCounter = counter;
      }
      if (counter < minCounter) {
        minCounter = counter;
      }
    }

    return maxCounter < 10 * minCounter;
  }
  return NO;
}

@end
