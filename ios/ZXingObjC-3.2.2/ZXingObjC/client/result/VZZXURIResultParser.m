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

#import "VZZXURIResultParser.h"
#import "VZZXResult.h"
#import "VZZXURIParsedResult.h"

static NSRegularExpression *VZZX_URL_WITH_PROTOCOL_PATTERN = nil;
static NSRegularExpression *VZZX_URL_WITHOUT_PROTOCOL_PATTERN = nil;

@implementation VZZXURIResultParser

+ (void)initialize {
  if ([self class] != [VZZXURIResultParser class]) return;

  // See http://www.ietf.org/rfc/rfc2396.txt
  VZZX_URL_WITH_PROTOCOL_PATTERN = [[NSRegularExpression alloc] initWithPattern:@"^[a-zA-Z][a-zA-Z0-9+-.]+:"
                                                                      options:0
                                                                        error:nil];
  VZZX_URL_WITHOUT_PROTOCOL_PATTERN = [[NSRegularExpression alloc] initWithPattern:
                                     [[@"([a-zA-Z0-9\\-]+\\.)+[a-zA-Z]{2,}" // host name elements
                                       stringByAppendingString:@"(:\\d{1,5})?"] // maybe port
                                      stringByAppendingString:@"(/|\\?|$)"] // query, path or nothing
                                                                         options:0
                                                                           error:nil];
}

- (VZZXParsedResult *)parse:(VZZXResult *)result {
  NSString *rawText = [VZZXResultParser massagedText:result];
  // We specifically handle the odd "URL" scheme here for simplicity and add "URI" for fun
  // Assume anything starting this way really means to be a URI
  if ([rawText hasPrefix:@"URL:"] || [rawText hasPrefix:@"URI:"]) {
    return [[VZZXURIParsedResult alloc] initWithUri:[[rawText substringFromIndex:4] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                                            title:nil];
  }
  rawText = [rawText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  return [[self class] isBasicallyValidURI:rawText] ? [VZZXURIParsedResult uriParsedResultWithUri:rawText title:nil] : nil;
}


+ (BOOL)isBasicallyValidURI:(NSString *)uri {
  if ([uri rangeOfString:@" "].location != NSNotFound) {
    // Quick hack check for a common case
    return NO;
  }

  if ([VZZX_URL_WITH_PROTOCOL_PATTERN numberOfMatchesInString:uri options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(0, uri.length)] > 0) { // match at start only
    return YES;
  }
  return [VZZX_URL_WITHOUT_PROTOCOL_PATTERN numberOfMatchesInString:uri options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(0, uri.length)] > 0;
}

@end
