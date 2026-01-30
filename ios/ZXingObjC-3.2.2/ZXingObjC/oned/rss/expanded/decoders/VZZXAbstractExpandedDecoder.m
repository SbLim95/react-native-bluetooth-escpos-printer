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

#import "VZZXAbstractExpandedDecoder.h"
#import "VZZXAI013103decoder.h"
#import "VZZXAI01320xDecoder.h"
#import "VZZXAI01392xDecoder.h"
#import "VZZXAI01393xDecoder.h"
#import "VZZXAI013x0x1xDecoder.h"
#import "VZZXAI01AndOtherAIs.h"
#import "VZZXAnyAIDecoder.h"
#import "VZZXBitArray.h"
#import "VZZXRSSExpandedGeneralAppIdDecoder.h"

@implementation VZZXAbstractExpandedDecoder

- (id)initWithInformation:(VZZXBitArray *)information {
  if (self = [super init]) {
    _information = information;
    _generalDecoder = [[VZZXRSSExpandedGeneralAppIdDecoder alloc] initWithInformation:information];
  }

  return self;
}

- (NSString *)parseInformationWithError:(NSError **)error {
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                               userInfo:nil];
}

+ (VZZXAbstractExpandedDecoder *)createDecoder:(VZZXBitArray *)information {
  if ([information get:1]) {
    return [[VZZXAI01AndOtherAIs alloc] initWithInformation:information];
  }
  if (![information get:2]) {
    return [[VZZXAnyAIDecoder alloc] initWithInformation:information];
  }

  int fourBitEncodationMethod = [VZZXRSSExpandedGeneralAppIdDecoder extractNumericValueFromBitArray:information pos:1 bits:4];

  switch (fourBitEncodationMethod) {
  case 4:
    return [[VZZXAI013103decoder alloc] initWithInformation:information];
  case 5:
    return [[VZZXAI01320xDecoder alloc] initWithInformation:information];
  }

  int fiveBitEncodationMethod = [VZZXRSSExpandedGeneralAppIdDecoder extractNumericValueFromBitArray:information pos:1 bits:5];
  switch (fiveBitEncodationMethod) {
  case 12:
    return [[VZZXAI01392xDecoder alloc] initWithInformation:information];
  case 13:
    return [[VZZXAI01393xDecoder alloc] initWithInformation:information];
  }

  int sevenBitEncodationMethod = [VZZXRSSExpandedGeneralAppIdDecoder extractNumericValueFromBitArray:information pos:1 bits:7];
  switch (sevenBitEncodationMethod) {
  case 56:
    return [[VZZXAI013x0x1xDecoder alloc] initWithInformation:information firstAIdigits:@"310" dateCode:@"11"];
  case 57:
    return [[VZZXAI013x0x1xDecoder alloc] initWithInformation:information firstAIdigits:@"320" dateCode:@"11"];
  case 58:
    return [[VZZXAI013x0x1xDecoder alloc] initWithInformation:information firstAIdigits:@"310" dateCode:@"13"];
  case 59:
    return [[VZZXAI013x0x1xDecoder alloc] initWithInformation:information firstAIdigits:@"320" dateCode:@"13"];
  case 60:
    return [[VZZXAI013x0x1xDecoder alloc] initWithInformation:information firstAIdigits:@"310" dateCode:@"15"];
  case 61:
    return [[VZZXAI013x0x1xDecoder alloc] initWithInformation:information firstAIdigits:@"320" dateCode:@"15"];
  case 62:
    return [[VZZXAI013x0x1xDecoder alloc] initWithInformation:information firstAIdigits:@"310" dateCode:@"17"];
  case 63:
    return [[VZZXAI013x0x1xDecoder alloc] initWithInformation:information firstAIdigits:@"320" dateCode:@"17"];
  }

  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"unknown decoder: %@", information]
                               userInfo:nil];
}

@end
