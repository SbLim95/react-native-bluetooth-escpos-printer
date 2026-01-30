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

#import "VZZXOneDReader.h"

@class VZZXIntArray;

typedef enum {
	VZZX_RSS_PATTERNS_RSS14_PATTERNS = 0,
	VZZX_RSS_PATTERNS_RSS_EXPANDED_PATTERNS
} VZZX_RSS_PATTERNS;

@interface VZZXAbstractRSSReader : VZZXOneDReader

@property (nonatomic, strong, readonly) VZZXIntArray *decodeFinderCounters;
@property (nonatomic, strong, readonly) VZZXIntArray *dataCharacterCounters;
@property (nonatomic, assign, readonly) float *oddRoundingErrors;
@property (nonatomic, assign, readonly) unsigned int oddRoundingErrorsLen;
@property (nonatomic, assign, readonly) float *evenRoundingErrors;
@property (nonatomic, assign, readonly) unsigned int evenRoundingErrorsLen;
@property (nonatomic, strong, readonly) VZZXIntArray *oddCounts;
@property (nonatomic, strong, readonly) VZZXIntArray *evenCounts;

+ (int)parseFinderValue:(VZZXIntArray *)counters finderPatternType:(VZZX_RSS_PATTERNS)finderPatternType;
+ (int)count:(VZZXIntArray *)array;
+ (void)increment:(VZZXIntArray *)array errors:(float *)errors;
+ (void)decrement:(VZZXIntArray *)array errors:(float *)errors;
+ (BOOL)isFinderPattern:(VZZXIntArray *)counters;

@end
