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

#import "VZZXBitArray.h"
#import "VZZXByteArray.h"
#import "VZZXCode128Reader.h"
#import "VZZXDecodeHints.h"
#import "VZZXErrors.h"
#import "VZZXIntArray.h"
#import "VZZXOneDReader.h"
#import "VZZXResult.h"
#import "VZZXResultPoint.h"

const int VZZX_CODE128_CODE_PATTERNS_LEN = 107;
const int VZZX_CODE128_CODE_PATTERNS[VZZX_CODE128_CODE_PATTERNS_LEN][7] = {
  {2, 1, 2, 2, 2, 2}, // 0
  {2, 2, 2, 1, 2, 2},
  {2, 2, 2, 2, 2, 1},
  {1, 2, 1, 2, 2, 3},
  {1, 2, 1, 3, 2, 2},
  {1, 3, 1, 2, 2, 2}, // 5
  {1, 2, 2, 2, 1, 3},
  {1, 2, 2, 3, 1, 2},
  {1, 3, 2, 2, 1, 2},
  {2, 2, 1, 2, 1, 3},
  {2, 2, 1, 3, 1, 2}, // 10
  {2, 3, 1, 2, 1, 2},
  {1, 1, 2, 2, 3, 2},
  {1, 2, 2, 1, 3, 2},
  {1, 2, 2, 2, 3, 1},
  {1, 1, 3, 2, 2, 2}, // 15
  {1, 2, 3, 1, 2, 2},
  {1, 2, 3, 2, 2, 1},
  {2, 2, 3, 2, 1, 1},
  {2, 2, 1, 1, 3, 2},
  {2, 2, 1, 2, 3, 1}, // 20
  {2, 1, 3, 2, 1, 2},
  {2, 2, 3, 1, 1, 2},
  {3, 1, 2, 1, 3, 1},
  {3, 1, 1, 2, 2, 2},
  {3, 2, 1, 1, 2, 2}, // 25
  {3, 2, 1, 2, 2, 1},
  {3, 1, 2, 2, 1, 2},
  {3, 2, 2, 1, 1, 2},
  {3, 2, 2, 2, 1, 1},
  {2, 1, 2, 1, 2, 3}, // 30
  {2, 1, 2, 3, 2, 1},
  {2, 3, 2, 1, 2, 1},
  {1, 1, 1, 3, 2, 3},
  {1, 3, 1, 1, 2, 3},
  {1, 3, 1, 3, 2, 1}, // 35
  {1, 1, 2, 3, 1, 3},
  {1, 3, 2, 1, 1, 3},
  {1, 3, 2, 3, 1, 1},
  {2, 1, 1, 3, 1, 3},
  {2, 3, 1, 1, 1, 3}, // 40
  {2, 3, 1, 3, 1, 1},
  {1, 1, 2, 1, 3, 3},
  {1, 1, 2, 3, 3, 1},
  {1, 3, 2, 1, 3, 1},
  {1, 1, 3, 1, 2, 3}, // 45
  {1, 1, 3, 3, 2, 1},
  {1, 3, 3, 1, 2, 1},
  {3, 1, 3, 1, 2, 1},
  {2, 1, 1, 3, 3, 1},
  {2, 3, 1, 1, 3, 1}, // 50
  {2, 1, 3, 1, 1, 3},
  {2, 1, 3, 3, 1, 1},
  {2, 1, 3, 1, 3, 1},
  {3, 1, 1, 1, 2, 3},
  {3, 1, 1, 3, 2, 1}, // 55
  {3, 3, 1, 1, 2, 1},
  {3, 1, 2, 1, 1, 3},
  {3, 1, 2, 3, 1, 1},
  {3, 3, 2, 1, 1, 1},
  {3, 1, 4, 1, 1, 1}, // 60
  {2, 2, 1, 4, 1, 1},
  {4, 3, 1, 1, 1, 1},
  {1, 1, 1, 2, 2, 4},
  {1, 1, 1, 4, 2, 2},
  {1, 2, 1, 1, 2, 4}, // 65
  {1, 2, 1, 4, 2, 1},
  {1, 4, 1, 1, 2, 2},
  {1, 4, 1, 2, 2, 1},
  {1, 1, 2, 2, 1, 4},
  {1, 1, 2, 4, 1, 2}, // 70
  {1, 2, 2, 1, 1, 4},
  {1, 2, 2, 4, 1, 1},
  {1, 4, 2, 1, 1, 2},
  {1, 4, 2, 2, 1, 1},
  {2, 4, 1, 2, 1, 1}, // 75
  {2, 2, 1, 1, 1, 4},
  {4, 1, 3, 1, 1, 1},
  {2, 4, 1, 1, 1, 2},
  {1, 3, 4, 1, 1, 1},
  {1, 1, 1, 2, 4, 2}, // 80
  {1, 2, 1, 1, 4, 2},
  {1, 2, 1, 2, 4, 1},
  {1, 1, 4, 2, 1, 2},
  {1, 2, 4, 1, 1, 2},
  {1, 2, 4, 2, 1, 1}, // 85
  {4, 1, 1, 2, 1, 2},
  {4, 2, 1, 1, 1, 2},
  {4, 2, 1, 2, 1, 1},
  {2, 1, 2, 1, 4, 1},
  {2, 1, 4, 1, 2, 1}, // 90
  {4, 1, 2, 1, 2, 1},
  {1, 1, 1, 1, 4, 3},
  {1, 1, 1, 3, 4, 1},
  {1, 3, 1, 1, 4, 1},
  {1, 1, 4, 1, 1, 3}, // 95
  {1, 1, 4, 3, 1, 1},
  {4, 1, 1, 1, 1, 3},
  {4, 1, 1, 3, 1, 1},
  {1, 1, 3, 1, 4, 1},
  {1, 1, 4, 1, 3, 1}, // 100
  {3, 1, 1, 1, 4, 1},
  {4, 1, 1, 1, 3, 1},
  {2, 1, 1, 4, 1, 2},
  {2, 1, 1, 2, 1, 4},
  {2, 1, 1, 2, 3, 2}, // 105
  {2, 3, 3, 1, 1, 1, 2}
};

static float VZZX_CODE128_MAX_AVG_VARIANCE = 0.25f;
static float VZZX_CODE128_MAX_INDIVIDUAL_VARIANCE = 0.7f;

const int VZZX_CODE128_CODE_SHIFT = 98;
const int VZZX_CODE128_CODE_CODE_C = 99;
const int VZZX_CODE128_CODE_CODE_B = 100;
const int VZZX_CODE128_CODE_CODE_A = 101;
const int VZZX_CODE128_CODE_FNC_1 = 102;
const int VZZX_CODE128_CODE_FNC_2 = 97;
const int VZZX_CODE128_CODE_FNC_3 = 96;
const int VZZX_CODE128_CODE_FNC_4_A = 101;
const int VZZX_CODE128_CODE_FNC_4_B = 100;
const int VZZX_CODE128_CODE_START_A = 103;
const int VZZX_CODE128_CODE_START_B = 104;
const int VZZX_CODE128_CODE_START_C = 105;
const int VZZX_CODE128_CODE_STOP = 106;

@implementation VZZXCode128Reader

- (VZZXIntArray *)findStartPattern:(VZZXBitArray *)row {
  int width = row.size;
  int rowOffset = [row nextSet:0];

  int counterPosition = 0;
  VZZXIntArray *counters = [[VZZXIntArray alloc] initWithLength:6];
  int32_t *array = counters.array;
  int patternStart = rowOffset;
  BOOL isWhite = NO;
  int patternLength = (int)counters.length;

  for (int i = rowOffset; i < width; i++) {
    if ([row get:i] ^ isWhite) {
      array[counterPosition]++;
    } else {
      if (counterPosition == patternLength - 1) {
        float bestVariance = VZZX_CODE128_MAX_AVG_VARIANCE;
        int bestMatch = -1;
        for (int startCode = VZZX_CODE128_CODE_START_A; startCode <= VZZX_CODE128_CODE_START_C; startCode++) {
          float variance = [VZZXOneDReader patternMatchVariance:counters pattern:VZZX_CODE128_CODE_PATTERNS[startCode] maxIndividualVariance:VZZX_CODE128_MAX_INDIVIDUAL_VARIANCE];
          if (variance < bestVariance) {
            bestVariance = variance;
            bestMatch = startCode;
          }
        }
        // Look for whitespace before start pattern, >= 50% of width of start pattern
        if (bestMatch >= 0 &&
            [row isRange:MAX(0, patternStart - (i - patternStart) / 2) end:patternStart value:NO]) {
          return [[VZZXIntArray alloc] initWithInts:patternStart, i, bestMatch, -1];
        }
        patternStart += array[0] + array[1];
        for (int y = 2; y < patternLength; y++) {
          array[y - 2] = array[y];
        }
        array[patternLength - 2] = 0;
        array[patternLength - 1] = 0;
        counterPosition--;
      } else {
        counterPosition++;
      }
      array[counterPosition] = 1;
      isWhite = !isWhite;
    }
  }

  return nil;
}

- (int)decodeCode:(VZZXBitArray *)row counters:(VZZXIntArray *)counters rowOffset:(int)rowOffset {
  if (![VZZXOneDReader recordPattern:row start:rowOffset counters:counters]) {
    return -1;
  }
  float bestVariance = VZZX_CODE128_MAX_AVG_VARIANCE;
  int bestMatch = -1;

  for (int d = 0; d < VZZX_CODE128_CODE_PATTERNS_LEN; d++) {
    float variance = [VZZXOneDReader patternMatchVariance:counters pattern:VZZX_CODE128_CODE_PATTERNS[d] maxIndividualVariance:VZZX_CODE128_MAX_INDIVIDUAL_VARIANCE];
    if (variance < bestVariance) {
      bestVariance = variance;
      bestMatch = d;
    }
  }

  if (bestMatch >= 0) {
    return bestMatch;
  } else {
    return -1;
  }
}

- (VZZXResult *)decodeRow:(int)rowNumber row:(VZZXBitArray *)row hints:(VZZXDecodeHints *)hints error:(NSError **)error {
  BOOL convertFNC1 = hints && hints.assumeGS1;

  VZZXIntArray *startPatternInfo = [self findStartPattern:row];
  if (!startPatternInfo) {
    if (error) *error = VZZXNotFoundErrorInstance();
    return nil;
  }

  int startCode = startPatternInfo.array[2];
  int codeSet;

  NSMutableArray *rawCodes = [NSMutableArray arrayWithObject:@(startCode)];

  switch (startCode) {
  case VZZX_CODE128_CODE_START_A:
    codeSet = VZZX_CODE128_CODE_CODE_A;
    break;
  case VZZX_CODE128_CODE_START_B:
    codeSet = VZZX_CODE128_CODE_CODE_B;
    break;
  case VZZX_CODE128_CODE_START_C:
    codeSet = VZZX_CODE128_CODE_CODE_C;
    break;
  default:
    if (error) *error = VZZXFormatErrorInstance();
    return nil;
  }

  BOOL done = NO;
  BOOL isNextShifted = NO;

  NSMutableString *result = [NSMutableString stringWithCapacity:20];

  int lastStart = startPatternInfo.array[0];
  int nextStart = startPatternInfo.array[1];
  VZZXIntArray *counters = [[VZZXIntArray alloc] initWithLength:6];

  int lastCode = 0;
  int code = 0;
  int checksumTotal = startCode;
  int multiplier = 0;
  BOOL lastCharacterWasPrintable = YES;
  BOOL upperMode = NO;
  BOOL shiftUpperMode = NO;

  while (!done) {
    BOOL unshift = isNextShifted;
    isNextShifted = NO;

    // Save off last code
    lastCode = code;

    // Decode another code from image
    code = [self decodeCode:row counters:counters rowOffset:nextStart];
    if (code == -1) {
      if (error) *error = VZZXNotFoundErrorInstance();
      return nil;
    }

    [rawCodes addObject:@(code)];

    // Remember whether the last code was printable or not (excluding VZZX_CODE128_CODE_STOP)
    if (code != VZZX_CODE128_CODE_STOP) {
      lastCharacterWasPrintable = YES;
    }

    // Add to checksum computation (if not VZZX_CODE128_CODE_STOP of course)
    if (code != VZZX_CODE128_CODE_STOP) {
      multiplier++;
      checksumTotal += multiplier * code;
    }

    // Advance to where the next code will to start
    lastStart = nextStart;
    nextStart += [counters sum];

    // Take care of illegal start codes
    switch (code) {
    case VZZX_CODE128_CODE_START_A:
    case VZZX_CODE128_CODE_START_B:
    case VZZX_CODE128_CODE_START_C:
      if (error) *error = VZZXFormatErrorInstance();
      return nil;
    }

    switch (codeSet) {
    case VZZX_CODE128_CODE_CODE_A:
      if (code < 64) {
        if (shiftUpperMode == upperMode) {
          [result appendFormat:@"%C", (unichar)(' ' + code)];
        } else {
          [result appendFormat:@"%C", (unichar)(' ' + code + 128)];
        }
        shiftUpperMode = NO;
      } else if (code < 96) {
        if (shiftUpperMode == upperMode) {
          [result appendFormat:@"%C", (unichar)(code - 64)];
        } else {
          [result appendFormat:@"%C", (unichar)(code + 64)];
        }
        shiftUpperMode = NO;
      } else {
        // Don't let CODE_STOP, which always appears, affect whether whether we think the last
        // code was printable or not.
        if (code != VZZX_CODE128_CODE_STOP) {
          lastCharacterWasPrintable = NO;
        }

        switch (code) {
          case VZZX_CODE128_CODE_FNC_1:
            if (convertFNC1) {
              if (result.length == 0) {
                // GS1 specification 5.4.3.7. and 5.4.6.4. If the first char after the start code
                // is FNC1 then this is GS1-128. We add the symbology identifier.
                [result appendString:@"]C1"];
              } else {
                // GS1 specification 5.4.7.5. Every subsequent FNC1 is returned as ASCII 29 (GS)
                [result appendFormat:@"%C", (unichar) 29];
              }
            }
            break;
          case VZZX_CODE128_CODE_FNC_2:
          case VZZX_CODE128_CODE_FNC_3:
            // do nothing?
            break;
          case VZZX_CODE128_CODE_FNC_4_A:
            if (!upperMode && shiftUpperMode) {
              upperMode = YES;
              shiftUpperMode = NO;
            } else if (upperMode && shiftUpperMode) {
              upperMode = NO;
              shiftUpperMode = NO;
            } else {
              shiftUpperMode = YES;
            }
            break;
          case VZZX_CODE128_CODE_SHIFT:
            isNextShifted = YES;
            codeSet = VZZX_CODE128_CODE_CODE_B;
            break;
          case VZZX_CODE128_CODE_CODE_B:
            codeSet = VZZX_CODE128_CODE_CODE_B;
            break;
          case VZZX_CODE128_CODE_CODE_C:
            codeSet = VZZX_CODE128_CODE_CODE_C;
            break;
          case VZZX_CODE128_CODE_STOP:
            done = YES;
            break;
        }
      }
      break;
    case VZZX_CODE128_CODE_CODE_B:
      if (code < 96) {
        if (shiftUpperMode == upperMode) {
          [result appendFormat:@"%C", (unichar)(' ' + code)];
        } else {
          [result appendFormat:@"%C", (unichar)(' ' + code + 128)];
        }
        shiftUpperMode = NO;
      } else {
        if (code != VZZX_CODE128_CODE_STOP) {
          lastCharacterWasPrintable = NO;
        }

        switch (code) {
          case VZZX_CODE128_CODE_FNC_1:
            if (convertFNC1) {
              if (result.length == 0) {
                // GS1 specification 5.4.3.7. and 5.4.6.4. If the first char after the start code
                // is FNC1 then this is GS1-128. We add the symbology identifier.
                [result appendString:@"]C1"];
              } else {
                // GS1 specification 5.4.7.5. Every subsequent FNC1 is returned as ASCII 29 (GS)
                [result appendFormat:@"%C", (unichar) 29];
              }
            }
            break;
          case VZZX_CODE128_CODE_FNC_2:
          case VZZX_CODE128_CODE_FNC_3:
            // do nothing?
            break;
          case VZZX_CODE128_CODE_FNC_4_B:
            if (!upperMode && shiftUpperMode) {
              upperMode = YES;
              shiftUpperMode = NO;
            } else if (upperMode && shiftUpperMode) {
              upperMode = NO;
              shiftUpperMode = NO;
            } else {
              shiftUpperMode = YES;
            }
            break;
          case VZZX_CODE128_CODE_SHIFT:
            isNextShifted = YES;
            codeSet = VZZX_CODE128_CODE_CODE_A;
            break;
          case VZZX_CODE128_CODE_CODE_A:
            codeSet = VZZX_CODE128_CODE_CODE_A;
            break;
          case VZZX_CODE128_CODE_CODE_C:
            codeSet = VZZX_CODE128_CODE_CODE_C;
            break;
          case VZZX_CODE128_CODE_STOP:
            done = YES;
            break;
        }
      }
      break;
    case VZZX_CODE128_CODE_CODE_C:
      if (code < 100) {
        if (code < 10) {
          [result appendString:@"0"];
        }
        [result appendFormat:@"%d", code];
      } else {
        if (code != VZZX_CODE128_CODE_STOP) {
          lastCharacterWasPrintable = NO;
        }

        switch (code) {
        case VZZX_CODE128_CODE_FNC_1:
            if (convertFNC1) {
              if (result.length == 0) {
                // GS1 specification 5.4.3.7. and 5.4.6.4. If the first char after the start code
                // is FNC1 then this is GS1-128. We add the symbology identifier.
                [result appendString:@"]C1"];
              } else {
                // GS1 specification 5.4.7.5. Every subsequent FNC1 is returned as ASCII 29 (GS)
                [result appendFormat:@"%C", (unichar) 29];
              }
            }
            break;
        case VZZX_CODE128_CODE_CODE_A:
          codeSet = VZZX_CODE128_CODE_CODE_A;
          break;
        case VZZX_CODE128_CODE_CODE_B:
          codeSet = VZZX_CODE128_CODE_CODE_B;
          break;
        case VZZX_CODE128_CODE_STOP:
          done = YES;
          break;
        }
      }
      break;
    }

    // Unshift back to another code set if we were shifted
    if (unshift) {
      codeSet = codeSet == VZZX_CODE128_CODE_CODE_A ? VZZX_CODE128_CODE_CODE_B : VZZX_CODE128_CODE_CODE_A;
    }
  }

  int lastPatternSize = nextStart - lastStart;

  // Check for ample whitespace following pattern, but, to do this we first need to remember that
  // we fudged decoding CODE_STOP since it actually has 7 bars, not 6. There is a black bar left
  // to read off. Would be slightly better to properly read. Here we just skip it:
  nextStart = [row nextUnset:nextStart];
  if (![row isRange:nextStart end:MIN(row.size, nextStart + (nextStart - lastStart) / 2) value:NO]) {
    if (error) *error = VZZXNotFoundErrorInstance();
    return nil;
  }

  // Pull out from sum the value of the penultimate check code
  checksumTotal -= multiplier * lastCode;
  // lastCode is the checksum then:
  if (checksumTotal % 103 != lastCode) {
    if (error) *error = VZZXChecksumErrorInstance();
    return nil;
  }

  // Need to pull out the check digits from string
  NSUInteger resultLength = [result length];
  if (resultLength == 0) {
    // false positive
    if (error) *error = VZZXNotFoundErrorInstance();
    return nil;
  }

  // Only bother if the result had at least one character, and if the checksum digit happened to
  // be a printable character. If it was just interpreted as a control code, nothing to remove.
  if (resultLength > 0 && lastCharacterWasPrintable) {
    if (codeSet == VZZX_CODE128_CODE_CODE_C) {
      [result deleteCharactersInRange:NSMakeRange(resultLength - 2, 2)];
    } else {
      [result deleteCharactersInRange:NSMakeRange(resultLength - 1, 1)];
    }
  }

  float left = (float)(startPatternInfo.array[1] + startPatternInfo.array[0]) / 2.0f;
  float right = lastStart + lastPatternSize / 2.0f;

  NSUInteger rawCodesSize = [rawCodes count];
  VZZXByteArray *rawBytes = [[VZZXByteArray alloc] initWithLength:(unsigned int)rawCodesSize];
  for (int i = 0; i < rawCodesSize; i++) {
    rawBytes.array[i] = (int8_t)[rawCodes[i] intValue];
  }

  return [VZZXResult resultWithText:result
                         rawBytes:rawBytes
                     resultPoints:@[[[VZZXResultPoint alloc] initWithX:left y:(float)rowNumber],
                                   [[VZZXResultPoint alloc] initWithX:right y:(float)rowNumber]]
                           format:kBarcodeFormatCode128];
}

@end
