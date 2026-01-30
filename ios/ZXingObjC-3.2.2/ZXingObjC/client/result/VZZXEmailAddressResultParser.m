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

#import "VZZXEmailAddressParsedResult.h"
#import "VZZXEmailAddressResultParser.h"
#import "VZZXEmailDoCoMoResultParser.h"
#import "VZZXResult.h"

static NSCharacterSet *VZZX_EMAIL_ADDRESS_RESULT_COMMA = nil;

@implementation VZZXEmailAddressResultParser

+ (void)initialize {
  if ([self class] != [VZZXEmailAddressResultParser class]) return;

  VZZX_EMAIL_ADDRESS_RESULT_COMMA = [NSCharacterSet characterSetWithCharactersInString:@","];
}

- (VZZXParsedResult *)parse:(VZZXResult *)result {
  NSString *rawText = [VZZXResultParser massagedText:result];
  if ([rawText hasPrefix:@"mailto:"] || [rawText hasPrefix:@"MAILTO:"]) {
    // If it starts with mailto:, assume it is definitely trying to be an email address
    NSString *hostEmail = [rawText substringFromIndex:7];
    NSUInteger queryStart = [hostEmail rangeOfString:@"?"].location;
    if (queryStart != NSNotFound) {
      hostEmail = [hostEmail substringToIndex:queryStart];
    }
    hostEmail = [[self class] urlDecode:hostEmail];
    NSArray *tos;
    if (hostEmail.length > 0) {
      tos = [hostEmail componentsSeparatedByCharactersInSet:VZZX_EMAIL_ADDRESS_RESULT_COMMA];
    }
    NSMutableDictionary *nameValues = [self parseNameValuePairs:rawText];
    NSArray *ccs;
    NSArray *bccs;
    NSString *subject = nil;
    NSString *body = nil;
    if (nameValues != nil) {
      if (!tos) {
        NSString *tosString = nameValues[@"to"];
        if (tosString) {
          tos = [tosString componentsSeparatedByCharactersInSet:VZZX_EMAIL_ADDRESS_RESULT_COMMA];
        }
      }
      NSString *ccString = nameValues[@"cc"];
      if (ccString) {
        ccs = [ccString componentsSeparatedByCharactersInSet:VZZX_EMAIL_ADDRESS_RESULT_COMMA];
      }
      NSString *bccString = nameValues[@"bcc"];
      if (bccString) {
        bccs = [bccString componentsSeparatedByCharactersInSet:VZZX_EMAIL_ADDRESS_RESULT_COMMA];
      }
      subject = nameValues[@"subject"];
      body = nameValues[@"body"];
    }
    return [[VZZXEmailAddressParsedResult alloc] initWithTos:tos ccs:ccs bccs:bccs subject:subject body:body];
  } else {
    if (![VZZXEmailDoCoMoResultParser isBasicallyValidEmailAddress:rawText]) {
      return nil;
    }
    return [[VZZXEmailAddressParsedResult alloc] initWithTo:rawText];
  }
}

@end
