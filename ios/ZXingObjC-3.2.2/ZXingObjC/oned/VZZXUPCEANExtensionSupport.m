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

#import "VZZXUPCEANExtensionSupport.h"
#import "VZZXUPCEANExtension2Support.h"
#import "VZZXUPCEANExtension5Support.h"
#import "VZZXUPCEANReader.h"

const int VZZX_UPCEAN_EXTENSION_START_PATTERN[] = {1,1,2};

@interface VZZXUPCEANExtensionSupport ()

@property (nonatomic, strong, readonly) VZZXUPCEANExtension2Support *twoSupport;
@property (nonatomic, strong, readonly) VZZXUPCEANExtension5Support *fiveSupport;

@end

@implementation VZZXUPCEANExtensionSupport

- (id)init {
  if (self = [super init]) {
    _twoSupport = [[VZZXUPCEANExtension2Support alloc] init];
    _fiveSupport = [[VZZXUPCEANExtension5Support alloc] init];
  }

  return self;
}

- (VZZXResult *)decodeRow:(int)rowNumber row:(VZZXBitArray *)row rowOffset:(int)rowOffset error:(NSError **)error {
  NSRange extensionStartRange = [VZZXUPCEANReader findGuardPattern:row
                                                       rowOffset:rowOffset
                                                      whiteFirst:NO
                                                         pattern:VZZX_UPCEAN_EXTENSION_START_PATTERN
                                                      patternLen:sizeof(VZZX_UPCEAN_EXTENSION_START_PATTERN)/sizeof(int)
                                                           error:error];

  if (extensionStartRange.location == NSNotFound) {
    return nil;
  }

  VZZXResult *result = [self.fiveSupport decodeRow:rowNumber row:row extensionStartRange:extensionStartRange error:error];
  if (!result) {
    result = [self.twoSupport decodeRow:rowNumber row:row extensionStartRange:extensionStartRange error:error];
  }

  return result;
}

@end
