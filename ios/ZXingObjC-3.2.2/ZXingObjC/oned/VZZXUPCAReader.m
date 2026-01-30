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

#import "VZZXEAN13Reader.h"
#import "VZZXErrors.h"
#import "VZZXResult.h"
#import "VZZXUPCAReader.h"

@interface VZZXUPCAReader ()

@property (nonatomic, strong, readonly) VZZXUPCEANReader *ean13Reader;

@end

@implementation VZZXUPCAReader

- (id)init {
  if (self = [super init]) {
    _ean13Reader = [[VZZXEAN13Reader alloc] init];
  }

  return self;
}

- (VZZXResult *)decodeRow:(int)rowNumber row:(VZZXBitArray *)row startGuardRange:(NSRange)startGuardRange hints:(VZZXDecodeHints *)hints error:(NSError **)error {
  VZZXResult *result = [self.ean13Reader decodeRow:rowNumber row:row startGuardRange:startGuardRange hints:hints error:error];
  if (result) {
    result = [self maybeReturnResult:result];
    if (!result) {
      if (error) *error = VZZXFormatErrorInstance();
      return nil;
    }
    return result;
  } else {
    return nil;
  }
}

- (VZZXResult *)decodeRow:(int)rowNumber row:(VZZXBitArray *)row hints:(VZZXDecodeHints *)hints error:(NSError **)error {
  VZZXResult *result = [self.ean13Reader decodeRow:rowNumber row:row hints:hints error:error];
  if (result) {
    result = [self maybeReturnResult:result];
    if (!result) {
      if (error) *error = VZZXFormatErrorInstance();
      return nil;
    }
    return result;
  } else {
    return nil;
  }
}

- (VZZXResult *)decode:(VZZXBinaryBitmap *)image error:(NSError **)error {
  VZZXResult *result = [self.ean13Reader decode:image error:error];
  if (result) {
    result = [self maybeReturnResult:result];
    if (!result) {
      if (error) *error = VZZXFormatErrorInstance();
      return nil;
    }
    return result;
  } else {
    return nil;
  }
}

- (VZZXResult *)decode:(VZZXBinaryBitmap *)image hints:(VZZXDecodeHints *)hints error:(NSError **)error {
  VZZXResult *result = [self.ean13Reader decode:image hints:hints error:error];
  if (result) {
    result = [self maybeReturnResult:result];
    if (!result) {
      if (error) *error = VZZXFormatErrorInstance();
      return nil;
    }
    return result;
  } else {
    return nil;
  }
}

- (VZZXBarcodeFormat)barcodeFormat {
  return kBarcodeFormatUPCA;
}

- (int)decodeMiddle:(VZZXBitArray *)row startRange:(NSRange)startRange result:(NSMutableString *)result error:(NSError **)error {
  return [self.ean13Reader decodeMiddle:row startRange:startRange result:result error:error];
}

- (VZZXResult *)maybeReturnResult:(VZZXResult *)result {
  NSString *text = result.text;
  if ([text characterAtIndex:0] == '0') {
    return [VZZXResult resultWithText:[text substringFromIndex:1]
                           rawBytes:nil
                       resultPoints:result.resultPoints
                             format:kBarcodeFormatUPCA];
  } else {
    return nil;
  }
}

@end
