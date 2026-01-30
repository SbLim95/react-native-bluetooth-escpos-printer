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

#import "VZZXBookmarkDoCoMoResultParser.h"
#import "VZZXResult.h"
#import "VZZXURIParsedResult.h"
#import "VZZXURIResultParser.h"

@implementation VZZXBookmarkDoCoMoResultParser

- (VZZXParsedResult *)parse:(VZZXResult *)result {
  NSString *rawText = [result text];
  if (![rawText hasPrefix:@"MEBKM:"]) {
    return nil;
  }
  NSString *title = [[self class] matchSingleDoCoMoPrefixedField:@"TITLE:" rawText:rawText trim:YES];
  NSArray *rawUri = [[self class] matchDoCoMoPrefixedField:@"URL:" rawText:rawText trim:YES];
  if (rawUri == nil) {
    return nil;
  }
  NSString *uri = rawUri[0];
  if (![VZZXURIResultParser isBasicallyValidURI:uri]) {
    return nil;
  }
  return [VZZXURIParsedResult uriParsedResultWithUri:uri title:title];
}

@end
