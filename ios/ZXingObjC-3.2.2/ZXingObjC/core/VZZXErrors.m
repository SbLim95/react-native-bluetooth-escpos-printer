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

#import "VZZXErrors.h"

NSError *VZZXChecksumErrorInstance() {
  NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"This barcode failed its checksum"};

  return [[NSError alloc] initWithDomain:VZZXErrorDomain code:VZZXChecksumError userInfo:userInfo];
}

NSError *VZZXFormatErrorInstance() {
  NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"This barcode does not confirm to the format's rules"};

  return [[NSError alloc] initWithDomain:VZZXErrorDomain code:VZZXFormatError userInfo:userInfo];
}

NSError *VZZXNotFoundErrorInstance() {
  NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"A barcode was not found in this image"};

  return [[NSError alloc] initWithDomain:VZZXErrorDomain code:VZZXNotFoundError userInfo:userInfo];
}
