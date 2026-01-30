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

#import "VZZXAI013x0xDecoder.h"
#import "VZZXBitArray.h"
#import "VZZXErrors.h"

const int VZZX_AI013x0x_HEADER_SIZE = 4 + 1;
const int VZZX_AI013x0x_WEIGHT_SIZE = 15;

@implementation VZZXAI013x0xDecoder

- (NSString *)parseInformationWithError:(NSError **)error {
  if (self.information.size != VZZX_AI013x0x_HEADER_SIZE + VZZX_AI01_GTIN_SIZE + VZZX_AI013x0x_WEIGHT_SIZE) {
    if (error) *error = VZZXNotFoundErrorInstance();
    return nil;
  }

  NSMutableString *buf = [NSMutableString string];

  [self encodeCompressedGtin:buf currentPos:VZZX_AI013x0x_HEADER_SIZE];
  [self encodeCompressedWeight:buf currentPos:VZZX_AI013x0x_HEADER_SIZE + VZZX_AI01_GTIN_SIZE weightSize:VZZX_AI013x0x_WEIGHT_SIZE];

  return buf;
}

@end
