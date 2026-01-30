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
#import "VZZXDecodeHints.h"
#import "VZZXEANManufacturerOrgSupport.h"
#import "VZZXErrors.h"
#import "VZZXIntArray.h"
#import "VZZXResult.h"
#import "VZZXResultPoint.h"
#import "VZZXResultPointCallback.h"
#import "VZZXUPCEANReader.h"
#import "VZZXUPCEANExtensionSupport.h"

static float VZZX_UPC_EAN_MAX_AVG_VARIANCE = 0.48f;
static float VZZX_UPC_EAN_MAX_INDIVIDUAL_VARIANCE = 0.7f;

/**
 * Start/end guard pattern.
 */
const int VZZX_UPC_EAN_START_END_PATTERN_LEN = 3;
const int VZZX_UPC_EAN_START_END_PATTERN[VZZX_UPC_EAN_START_END_PATTERN_LEN] = {1, 1, 1};

/**
 * Pattern marking the middle of a UPC/EAN pattern, separating the two halves.
 */
const int VZZX_UPC_EAN_MIDDLE_PATTERN_LEN = 5;
const int VZZX_UPC_EAN_MIDDLE_PATTERN[VZZX_UPC_EAN_MIDDLE_PATTERN_LEN] = {1, 1, 1, 1, 1};

/**
 * "Odd", or "L" patterns used to encode UPC/EAN digits.
 */
const int VZZX_UPC_EAN_L_PATTERNS_LEN = 10;
const int VZZX_UPC_EAN_L_PATTERNS_SUB_LEN = 4;
const int VZZX_UPC_EAN_L_PATTERNS[VZZX_UPC_EAN_L_PATTERNS_LEN][VZZX_UPC_EAN_L_PATTERNS_SUB_LEN] = {
  {3, 2, 1, 1}, // 0
  {2, 2, 2, 1}, // 1
  {2, 1, 2, 2}, // 2
  {1, 4, 1, 1}, // 3
  {1, 1, 3, 2}, // 4
  {1, 2, 3, 1}, // 5
  {1, 1, 1, 4}, // 6
  {1, 3, 1, 2}, // 7
  {1, 2, 1, 3}, // 8
  {3, 1, 1, 2}  // 9
};

/**
 * As above but also including the "even", or "G" patterns used to encode UPC/EAN digits.
 */
const int VZZX_UPC_EAN_L_AND_G_PATTERNS_LEN = 20;
const int VZZX_UPC_EAN_L_AND_G_PATTERNS_SUB_LEN = 4;
const int VZZX_UPC_EAN_L_AND_G_PATTERNS[VZZX_UPC_EAN_L_AND_G_PATTERNS_LEN][VZZX_UPC_EAN_L_AND_G_PATTERNS_SUB_LEN] = {
  {3, 2, 1, 1}, // 0
  {2, 2, 2, 1}, // 1
  {2, 1, 2, 2}, // 2
  {1, 4, 1, 1}, // 3
  {1, 1, 3, 2}, // 4
  {1, 2, 3, 1}, // 5
  {1, 1, 1, 4}, // 6
  {1, 3, 1, 2}, // 7
  {1, 2, 1, 3}, // 8
  {3, 1, 1, 2}, // 9
  {1, 1, 2, 3}, // 10 reversed 0
  {1, 2, 2, 2}, // 11 reversed 1
  {2, 2, 1, 2}, // 12 reversed 2
  {1, 1, 4, 1}, // 13 reversed 3
  {2, 3, 1, 1}, // 14 reversed 4
  {1, 3, 2, 1}, // 15 reversed 5
  {4, 1, 1, 1}, // 16 reversed 6
  {2, 1, 3, 1}, // 17 reversed 7
  {3, 1, 2, 1}, // 18 reversed 8
  {2, 1, 1, 3}  // 19 reversed 9
};

@interface VZZXUPCEANReader ()

@property (nonatomic, strong, readonly) NSMutableString *decodeRowNSMutableString;
@property (nonatomic, strong, readonly) VZZXUPCEANExtensionSupport *extensionReader;
@property (nonatomic, strong, readonly) VZZXEANManufacturerOrgSupport *eanManSupport;

@end

@implementation VZZXUPCEANReader

- (id)init {
  if (self = [super init]) {
    _decodeRowNSMutableString = [NSMutableString stringWithCapacity:20];
    _extensionReader = [[VZZXUPCEANExtensionSupport alloc] init];
    _eanManSupport = [[VZZXEANManufacturerOrgSupport alloc] init];
  }

  return self;
}

+ (NSRange)findStartGuardPattern:(VZZXBitArray *)row error:(NSError **)error {
  BOOL foundStart = NO;
  NSRange startRange = NSMakeRange(NSNotFound, 0);
  int nextStart = 0;
  VZZXIntArray *counters = [[VZZXIntArray alloc] initWithLength:VZZX_UPC_EAN_START_END_PATTERN_LEN];
  while (!foundStart) {
    [counters clear];
    startRange = [self findGuardPattern:row rowOffset:nextStart
                             whiteFirst:NO
                                pattern:VZZX_UPC_EAN_START_END_PATTERN
                             patternLen:VZZX_UPC_EAN_START_END_PATTERN_LEN
                               counters:counters
                                  error:error];
    if (startRange.location == NSNotFound) {
      return startRange;
    }
    int start = (int)startRange.location;
    nextStart = (int)NSMaxRange(startRange);
    // Make sure there is a quiet zone at least as big as the start pattern before the barcode.
    // If this check would run off the left edge of the image, do not accept this barcode,
    // as it is very likely to be a false positive.
    int quietStart = start - (nextStart - start);
    if (quietStart >= 0) {
      foundStart = [row isRange:quietStart end:start value:NO];
    }
  }
  return startRange;
}

- (VZZXResult *)decodeRow:(int)rowNumber row:(VZZXBitArray *)row hints:(VZZXDecodeHints *)hints error:(NSError **)error {
  return [self decodeRow:rowNumber row:row startGuardRange:[[self class] findStartGuardPattern:row error:error] hints:hints error:error];
}

- (VZZXResult *)decodeRow:(int)rowNumber row:(VZZXBitArray *)row startGuardRange:(NSRange)startGuardRange hints:(VZZXDecodeHints *)hints error:(NSError **)error {
  id<VZZXResultPointCallback> resultPointCallback = hints == nil ? nil : hints.resultPointCallback;

  if (resultPointCallback != nil) {
    [resultPointCallback foundPossibleResultPoint:[[VZZXResultPoint alloc] initWithX:(startGuardRange.location + NSMaxRange(startGuardRange)) / 2.0f y:rowNumber]];
  }

  NSMutableString *result = [NSMutableString string];
  int endStart = [self decodeMiddle:row startRange:startGuardRange result:result error:error];
  if (endStart == -1) {
    return nil;
  }

  if (resultPointCallback != nil) {
    [resultPointCallback foundPossibleResultPoint:[[VZZXResultPoint alloc] initWithX:endStart y:rowNumber]];
  }

  NSRange endRange = [self decodeEnd:row endStart:endStart error:error];
  if (endRange.location == NSNotFound) {
    return nil;
  }

  if (resultPointCallback != nil) {
    [resultPointCallback foundPossibleResultPoint:[[VZZXResultPoint alloc] initWithX:(endRange.location + NSMaxRange(endRange)) / 2.0f y:rowNumber]];
  }

  // Make sure there is a quiet zone at least as big as the end pattern after the barcode. The
  // spec might want more whitespace, but in practice this is the maximum we can count on.
  int end = (int)NSMaxRange(endRange);
  int quietEnd = end + (end - (int)endRange.location);
  if (quietEnd >= [row size] || ![row isRange:end end:quietEnd value:NO]) {
    if (error) *error = VZZXNotFoundErrorInstance();
    return nil;
  }

  NSString *resultString = [result description];
  // UPC/EAN should never be less than 8 chars anyway
  if ([resultString length] < 8) {
    if (error) *error = VZZXFormatErrorInstance();
    return nil;
  }
  if (![self checkChecksum:resultString error:error]) {
    if (error) *error = VZZXChecksumErrorInstance();
    return nil;
  }

  float left = (float)(NSMaxRange(startGuardRange) + startGuardRange.location) / 2.0f;
  float right = (float)(NSMaxRange(endRange) + endRange.location) / 2.0f;
  VZZXBarcodeFormat format = [self barcodeFormat];

  VZZXResult *decodeResult = [VZZXResult resultWithText:resultString
                                           rawBytes:nil
                                       resultPoints:@[[[VZZXResultPoint alloc] initWithX:left y:(float)rowNumber], [[VZZXResultPoint alloc] initWithX:right y:(float)rowNumber]]
                                             format:format];

  int extensionLength = 0;

  VZZXResult *extensionResult = [self.extensionReader decodeRow:rowNumber row:row rowOffset:(int)NSMaxRange(endRange) error:error];
  if (extensionResult) {
    [decodeResult putMetadata:kResultMetadataTypeUPCEANExtension value:extensionResult.text];
    [decodeResult putAllMetadata:[extensionResult resultMetadata]];
    [decodeResult addResultPoints:[extensionResult resultPoints]];
    extensionLength = (int)[extensionResult.text length];
  }

  VZZXIntArray *allowedExtensions = hints == nil ? nil : hints.allowedEANExtensions;
  if (allowedExtensions != nil) {
    BOOL valid = NO;
    for (int i = 0; i < allowedExtensions.length; i++) {
      if (extensionLength == allowedExtensions.array[i]) {
        valid = YES;
        break;
      }
    }
    if (!valid) {
      if (error) *error = VZZXNotFoundErrorInstance();
      return nil;
    }
  }

  if (format == kBarcodeFormatEan13 || format == kBarcodeFormatUPCA) {
    NSString *countryID = [self.eanManSupport lookupCountryIdentifier:resultString];
    if (countryID != nil) {
      [decodeResult putMetadata:kResultMetadataTypePossibleCountry value:countryID];
    }
  }
  return decodeResult;
}

- (BOOL)checkChecksum:(NSString *)s error:(NSError **)error {
  if ([[self class] checkStandardUPCEANChecksum:s]) {
    return YES;
  } else {
    if (error) *error = VZZXFormatErrorInstance();
    return NO;
  }
}

+ (BOOL)checkStandardUPCEANChecksum:(NSString *)s {
  int length = (int)[s length];
  if (length == 0) {
    return NO;
  }
  int sum = 0;

  for (int i = length - 2; i >= 0; i -= 2) {
    int digit = (int)[s characterAtIndex:i] - (int)'0';
    if (digit < 0 || digit > 9) {
      return NO;
    }
    sum += digit;
  }

  sum *= 3;

  for (int i = length - 1; i >= 0; i -= 2) {
    int digit = (int)[s characterAtIndex:i] - (int)'0';
    if (digit < 0 || digit > 9) {
      return NO;
    }
    sum += digit;
  }

  return sum % 10 == 0;
}

- (NSRange)decodeEnd:(VZZXBitArray *)row endStart:(int)endStart error:(NSError **)error {
  return [[self class] findGuardPattern:row
                              rowOffset:endStart
                             whiteFirst:NO
                                pattern:VZZX_UPC_EAN_START_END_PATTERN
                             patternLen:VZZX_UPC_EAN_START_END_PATTERN_LEN
                                  error:error];
}

+ (NSRange)findGuardPattern:(VZZXBitArray *)row rowOffset:(int)rowOffset whiteFirst:(BOOL)whiteFirst pattern:(const int[])pattern patternLen:(int)patternLen error:(NSError **)error {
  VZZXIntArray *counters = [[VZZXIntArray alloc] initWithLength:patternLen];
  return [self findGuardPattern:row rowOffset:rowOffset whiteFirst:whiteFirst pattern:pattern patternLen:patternLen counters:counters error:error];
}

+ (NSRange)findGuardPattern:(VZZXBitArray *)row rowOffset:(int)rowOffset whiteFirst:(BOOL)whiteFirst pattern:(const int[])pattern patternLen:(int)patternLen counters:(VZZXIntArray *)counters error:(NSError **)error {
  int patternLength = patternLen;
  int width = row.size;
  BOOL isWhite = whiteFirst;
  rowOffset = whiteFirst ? [row nextUnset:rowOffset] : [row nextSet:rowOffset];
  int counterPosition = 0;
  int patternStart = rowOffset;
  int32_t *array = counters.array;
  for (int x = rowOffset; x < width; x++) {
    if ([row get:x] ^ isWhite) {
      array[counterPosition]++;
    } else {
      if (counterPosition == patternLength - 1) {
        if ([self patternMatchVariance:counters pattern:pattern maxIndividualVariance:VZZX_UPC_EAN_MAX_INDIVIDUAL_VARIANCE] < VZZX_UPC_EAN_MAX_AVG_VARIANCE) {
          return NSMakeRange(patternStart, x - patternStart);
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

  if (error) *error = VZZXNotFoundErrorInstance();
  return NSMakeRange(NSNotFound, 0);
}

/**
 * Attempts to decode a single UPC/EAN-encoded digit.
 */
+ (int)decodeDigit:(VZZXBitArray *)row counters:(VZZXIntArray *)counters rowOffset:(int)rowOffset patternType:(VZZX_UPC_EAN_PATTERNS)patternType error:(NSError **)error {
  if (![self recordPattern:row start:rowOffset counters:counters]) {
    if (error) *error = VZZXNotFoundErrorInstance();
    return -1;
  }
  float bestVariance = VZZX_UPC_EAN_MAX_AVG_VARIANCE;
  int bestMatch = -1;
  int max = 0;
  switch (patternType) {
    case VZZX_UPC_EAN_PATTERNS_L_PATTERNS:
      max = VZZX_UPC_EAN_L_PATTERNS_LEN;
      for (int i = 0; i < max; i++) {
        int pattern[counters.length];
        for (int j = 0; j < counters.length; j++){
          pattern[j] = VZZX_UPC_EAN_L_PATTERNS[i][j];
        }

        float variance = [self patternMatchVariance:counters pattern:pattern maxIndividualVariance:VZZX_UPC_EAN_MAX_INDIVIDUAL_VARIANCE];
        if (variance < bestVariance) {
          bestVariance = variance;
          bestMatch = i;
        }
      }
      break;
    case VZZX_UPC_EAN_PATTERNS_L_AND_G_PATTERNS:
      max = VZZX_UPC_EAN_L_AND_G_PATTERNS_LEN;
      for (int i = 0; i < max; i++) {
        int pattern[counters.length];
        for (int j = 0; j< counters.length; j++){
          pattern[j] = VZZX_UPC_EAN_L_AND_G_PATTERNS[i][j];
        }

        float variance = [self patternMatchVariance:counters pattern:pattern maxIndividualVariance:VZZX_UPC_EAN_MAX_INDIVIDUAL_VARIANCE];
        if (variance < bestVariance) {
          bestVariance = variance;
          bestMatch = i;
        }
      }
      break;
    default:
      break;
  }

  if (bestMatch >= 0) {
    return bestMatch;
  } else {
    if (error) *error = VZZXNotFoundErrorInstance();
    return -1;
  }
}

- (VZZXBarcodeFormat)barcodeFormat {
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                               userInfo:nil];
}

- (int)decodeMiddle:(VZZXBitArray *)row startRange:(NSRange)startRange result:(NSMutableString *)result error:(NSError **)error {
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                               userInfo:nil];
}

@end
