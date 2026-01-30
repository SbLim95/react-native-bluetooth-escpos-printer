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

#import "VZZXBitMatrix.h"
#import "VZZXByteArray.h"
#import "VZZXDecodeHints.h"
#import "VZZXDecoderResult.h"
#import "VZZXErrors.h"
#import "VZZXGenericGF.h"
#import "VZZXIntArray.h"
#import "VZZXMaxiCodeBitMatrixParser.h"
#import "VZZXMaxiCodeDecodedBitStreamParser.h"
#import "VZZXMaxiCodeDecoder.h"
#import "VZZXReedSolomonDecoder.h"

const int VZZX_MAXI_CODE_ALL = 0;
const int VZZX_MAXI_CODE_EVEN = 1;
const int VZZX_MAXI_CODE_ODD = 2;

@interface VZZXMaxiCodeDecoder ()

@property (nonatomic, strong, readonly) VZZXReedSolomonDecoder *rsDecoder;

@end

@implementation VZZXMaxiCodeDecoder

- (id)init {
  if (self = [super init]) {
    _rsDecoder = [[VZZXReedSolomonDecoder alloc] initWithField:[VZZXGenericGF MaxiCodeField64]];
  }

  return self;
}

- (VZZXDecoderResult *)decode:(VZZXBitMatrix *)bits error:(NSError **)error {
  return [self decode:bits hints:nil error:error];
}

- (VZZXDecoderResult *)decode:(VZZXBitMatrix *)bits hints:(VZZXDecodeHints *)hints error:(NSError **)error {
  VZZXMaxiCodeBitMatrixParser *parser = [[VZZXMaxiCodeBitMatrixParser alloc] initWithBitMatrix:bits error:error];
  if (!parser) {
    return nil;
  }
  VZZXByteArray *codewords = [parser readCodewords];

  if (![self correctErrors:codewords start:0 dataCodewords:10 ecCodewords:10 mode:VZZX_MAXI_CODE_ALL error:error]) {
    return nil;
  }
  int mode = codewords.array[0] & 0x0F;
  VZZXByteArray *datawords;
  switch (mode) {
    case 2:
    case 3:
    case 4:
      if (![self correctErrors:codewords start:20 dataCodewords:84 ecCodewords:40 mode:VZZX_MAXI_CODE_EVEN error:error]) {
        return nil;
      }
      if (![self correctErrors:codewords start:20 dataCodewords:84 ecCodewords:40 mode:VZZX_MAXI_CODE_ODD error:error]) {
        return nil;
      }
      datawords = [[VZZXByteArray alloc] initWithLength:94];
      break;
    case 5:
      if (![self correctErrors:codewords start:20 dataCodewords:68 ecCodewords:56 mode:VZZX_MAXI_CODE_EVEN error:error]) {
        return nil;
      }
      if (![self correctErrors:codewords start:20 dataCodewords:68 ecCodewords:56 mode:VZZX_MAXI_CODE_ODD error:error]) {
        return nil;
      }
      datawords = [[VZZXByteArray alloc] initWithLength:78];
      break;
    default:
      if (error) *error = VZZXNotFoundErrorInstance();
      return nil;
  }

  for (int i = 0; i < 10; i++) {
    datawords.array[i] = codewords.array[i];
  }
  for (int i = 20; i < datawords.length + 10; i++) {
    datawords.array[i - 10] = codewords.array[i];
  }

  return [VZZXMaxiCodeDecodedBitStreamParser decode:datawords mode:mode];
}

- (BOOL)correctErrors:(VZZXByteArray *)codewordBytes start:(int)start dataCodewords:(int)dataCodewords
          ecCodewords:(int)ecCodewords mode:(int)mode error:(NSError **)error {
  int codewords = dataCodewords + ecCodewords;

  // in EVEN or ODD mode only half the codewords
  int divisor = mode == VZZX_MAXI_CODE_ALL ? 1 : 2;

  // First read into an array of ints
  VZZXIntArray *codewordsInts = [[VZZXIntArray alloc] initWithLength:codewords / divisor];
  for (int i = 0; i < codewords; i++) {
    if ((mode == VZZX_MAXI_CODE_ALL) || (i % 2 == (mode - 1))) {
      codewordsInts.array[i / divisor] = codewordBytes.array[i + start] & 0xFF;
    }
  }

  NSError *decodeError = nil;
  if (![self.rsDecoder decode:codewordsInts twoS:ecCodewords / divisor error:&decodeError]) {
    if (decodeError.code == VZZXReedSolomonError && error) {
      *error = VZZXChecksumErrorInstance();
    }
    return NO;
  }
  // Copy back into array of bytes -- only need to worry about the bytes that were data
  // We don't care about errors in the error-correction codewords
  for (int i = 0; i < dataCodewords; i++) {
    if ((mode == VZZX_MAXI_CODE_ALL) || (i % 2 == (mode - 1))) {
      codewordBytes.array[i + start] = (int8_t) codewordsInts.array[i / divisor];
    }
  }

  return YES;
}

@end
