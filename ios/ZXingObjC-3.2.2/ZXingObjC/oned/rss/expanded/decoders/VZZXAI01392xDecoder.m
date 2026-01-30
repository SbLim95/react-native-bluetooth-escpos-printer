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

#import "VZZXAI01392xDecoder.h"
#import "VZZXBitArray.h"
#import "VZZXErrors.h"
#import "VZZXRSSExpandedDecodedInformation.h"
#import "VZZXRSSExpandedGeneralAppIdDecoder.h"

const int VZZX_AI01392x_HEADER_SIZE = 5 + 1 + 2;
const int VZZX_AI01392x_LAST_DIGIT_SIZE = 2;

@implementation VZZXAI01392xDecoder

- (NSString *)parseInformationWithError:(NSError **)error {
  if (self.information.size < VZZX_AI01392x_HEADER_SIZE + VZZX_AI01_GTIN_SIZE) {
    if (error) *error = VZZXNotFoundErrorInstance();
    return nil;
  }
  NSMutableString *buf = [NSMutableString string];
  [self encodeCompressedGtin:buf currentPos:VZZX_AI01392x_HEADER_SIZE];
  int lastAIdigit = [self.generalDecoder extractNumericValueFromBitArray:VZZX_AI01392x_HEADER_SIZE + VZZX_AI01_GTIN_SIZE bits:VZZX_AI01392x_LAST_DIGIT_SIZE];
  [buf appendFormat:@"(392%d)", lastAIdigit];
  VZZXRSSExpandedDecodedInformation *decodedInformation = [self.generalDecoder decodeGeneralPurposeField:VZZX_AI01392x_HEADER_SIZE + VZZX_AI01_GTIN_SIZE + VZZX_AI01392x_LAST_DIGIT_SIZE remaining:nil];
  [buf appendString:decodedInformation.theNewString];
  return buf;
}

@end
