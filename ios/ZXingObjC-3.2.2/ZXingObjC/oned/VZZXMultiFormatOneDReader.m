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

#import "VZZXCodaBarReader.h"
#import "VZZXCode128Reader.h"
#import "VZZXCode39Reader.h"
#import "VZZXCode93Reader.h"
#import "VZZXDecodeHints.h"
#import "VZZXErrors.h"
#import "VZZXITFReader.h"
#import "VZZXMultiFormatOneDReader.h"
#import "VZZXMultiFormatUPCEANReader.h"
#import "VZZXRSS14Reader.h"
#import "VZZXRSSExpandedReader.h"

@interface VZZXMultiFormatOneDReader ()

@property (nonatomic, strong, readonly) NSMutableArray *readers;

@end

@implementation VZZXMultiFormatOneDReader

- (id)initWithHints:(VZZXDecodeHints *)hints {
  if (self = [super init]) {
    BOOL useCode39CheckDigit = hints != nil && hints.assumeCode39CheckDigit;
    _readers = [NSMutableArray array];
    if (hints != nil) {
      if ([hints containsFormat:kBarcodeFormatEan13] ||
          [hints containsFormat:kBarcodeFormatUPCA] ||
          [hints containsFormat:kBarcodeFormatEan8] ||
          [hints containsFormat:kBarcodeFormatUPCE]) {
        [_readers addObject:[[VZZXMultiFormatUPCEANReader alloc] initWithHints:hints]];
      }

      if ([hints containsFormat:kBarcodeFormatCode39]) {
        [_readers addObject:[[VZZXCode39Reader alloc] initUsingCheckDigit:useCode39CheckDigit]];
      }

      if ([hints containsFormat:kBarcodeFormatCode93]) {
        [_readers addObject:[[VZZXCode93Reader alloc] init]];
      }

      if ([hints containsFormat:kBarcodeFormatCode128]) {
        [_readers addObject:[[VZZXCode128Reader alloc] init]];
      }

      if ([hints containsFormat:kBarcodeFormatITF]) {
        [_readers addObject:[[VZZXITFReader alloc] init]];
      }

      if ([hints containsFormat:kBarcodeFormatCodabar]) {
        [_readers addObject:[[VZZXCodaBarReader alloc] init]];
      }

      if ([hints containsFormat:kBarcodeFormatRSS14]) {
        [_readers addObject:[[VZZXRSS14Reader alloc] init]];
      }

      if ([hints containsFormat:kBarcodeFormatRSSExpanded]) {
        [_readers addObject:[[VZZXRSSExpandedReader alloc] init]];
      }
    }

    if ([_readers count] == 0) {
      [_readers addObject:[[VZZXMultiFormatUPCEANReader alloc] initWithHints:hints]];
      [_readers addObject:[[VZZXCode39Reader alloc] init]];
      [_readers addObject:[[VZZXCodaBarReader alloc] init]];
      [_readers addObject:[[VZZXCode93Reader alloc] init]];
      [_readers addObject:[[VZZXCode128Reader alloc] init]];
      [_readers addObject:[[VZZXITFReader alloc] init]];
      [_readers addObject:[[VZZXRSS14Reader alloc] init]];
      [_readers addObject:[[VZZXRSSExpandedReader alloc] init]];
    }
  }

  return self;
}

- (VZZXResult *)decodeRow:(int)rowNumber row:(VZZXBitArray *)row hints:(VZZXDecodeHints *)hints error:(NSError **)error {
  for (VZZXOneDReader *reader in self.readers) {
    VZZXResult *result = [reader decodeRow:rowNumber row:row hints:hints error:error];
    if (result) {
      return result;
    }
  }

  if (error) *error = VZZXNotFoundErrorInstance();
  return nil;
}

- (void)reset {
  for (id<VZZXReader> reader in self.readers) {
    [reader reset];
  }
}

@end
