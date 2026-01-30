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

#import "VZZXReader.h"

@class VZZXBitArray, VZZXDecodeHints, VZZXIntArray, VZZXResult;

/**
 * Encapsulates functionality and implementation that is common to all families
 * of one-dimensional barcodes.
 */
@interface VZZXOneDReader : NSObject <VZZXReader>

+ (BOOL)recordPattern:(VZZXBitArray *)row start:(int)start counters:(VZZXIntArray *)counters;
+ (BOOL)recordPatternInReverse:(VZZXBitArray *)row start:(int)start counters:(VZZXIntArray *)counters;
+ (float)patternMatchVariance:(VZZXIntArray *)counters pattern:(const int[])pattern maxIndividualVariance:(float)maxIndividualVariance;
- (VZZXResult *)decodeRow:(int)rowNumber row:(VZZXBitArray *)row hints:(VZZXDecodeHints *)hints error:(NSError **)error;

@end
