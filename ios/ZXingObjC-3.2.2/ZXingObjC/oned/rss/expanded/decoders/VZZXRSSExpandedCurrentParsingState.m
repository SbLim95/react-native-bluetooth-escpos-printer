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

#import "VZZXRSSExpandedCurrentParsingState.h"

enum {
  VZZX_NUMERIC_STATE,
  VZZX_ALPHA_STATE,
  VZZX_ISO_IEC_646_STATE
};

@interface VZZXRSSExpandedCurrentParsingState ()

@property (nonatomic, assign) int encoding;

@end

@implementation VZZXRSSExpandedCurrentParsingState

- (id)init {
  if (self = [super init]) {
    _position = 0;
    _encoding = VZZX_NUMERIC_STATE;
  }
  return self;
}

- (BOOL)alpha {
  return self.encoding == VZZX_ALPHA_STATE;
}

- (BOOL)numeric {
  return self.encoding == VZZX_NUMERIC_STATE;
}

- (BOOL)isoIec646 {
  return self.encoding == VZZX_ISO_IEC_646_STATE;
}

- (void)setNumeric {
  self.encoding = VZZX_NUMERIC_STATE;
}

- (void)setAlpha {
  self.encoding = VZZX_ALPHA_STATE;
}

- (void)setIsoIec646 {
  self.encoding = VZZX_ISO_IEC_646_STATE;
}

@end
