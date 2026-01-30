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

#import "VZZXUPCEWriter.h"
#import "VZZXUPCEANReader.h"
#import "VZZXUPCEReader.h"
#import "VZZXBoolArray.h"

const int VZZX_UPCE_CODE_WIDTH = 3 + (7 * 6) + 6;

@implementation VZZXUPCEWriter

- (VZZXBitMatrix *)encode:(NSString *)contents format:(VZZXBarcodeFormat)format width:(int)width height:(int)height hints:(VZZXEncodeHints *)hints error:(NSError **)error {
  if (format != kBarcodeFormatUPCE) {
      [NSException raise:NSInvalidArgumentException format:@"Can only encode UPC_E"];
  }
  return [super encode:contents format:format width:width height:height hints:hints error:error];
}

- (VZZXBoolArray *)encode:(NSString *)contents {
  if ([contents length] != 8) {
    @throw [NSException exceptionWithName:@"IllegalArgumentException"
                                   reason:[NSString stringWithFormat:@"Requested contents should be 8 digits long, but got %d", (int)[contents length]]
                                 userInfo:nil];
  }

  int checkDigit = [[contents substringWithRange:NSMakeRange(7, 1)] intValue];
  int parities = CHECK_DIGIT_ENCODINGS[checkDigit];
  VZZXBoolArray *result = [[VZZXBoolArray alloc] initWithLength:VZZX_UPCE_CODE_WIDTH];
  int pos = 0;

  pos += [self appendPattern:result pos:pos pattern:VZZX_UPC_EAN_START_END_PATTERN patternLen:VZZX_UPC_EAN_START_END_PATTERN_LEN startColor:YES];

  for (int i = 1; i <= 6; i++) {
    int digit = [[contents substringWithRange:NSMakeRange(i, 1)] intValue];
    if ((parities >> (6 - i) & 1) == 1) {
      digit += 10;
    }
    pos += [self appendPattern:result pos:pos pattern:VZZX_UPC_EAN_L_AND_G_PATTERNS[digit] patternLen:VZZX_UPC_EAN_L_PATTERNS_SUB_LEN startColor:NO];
  }

  [self appendPattern:result pos:pos pattern:VZZX_UPCE_MIDDLE_END_PATTERN patternLen:VZZX_UPCE_MIDDLE_END_PATTERN_LEN startColor:NO];

  return result;
}

@end
