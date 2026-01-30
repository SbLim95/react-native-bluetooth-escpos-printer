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

#import "VZZXBarcodeFormat.h"
#import "VZZXOneDReader.h"

typedef enum {
  VZZX_UPC_EAN_PATTERNS_L_PATTERNS = 0,
  VZZX_UPC_EAN_PATTERNS_L_AND_G_PATTERNS
} VZZX_UPC_EAN_PATTERNS;

extern const int VZZX_UPC_EAN_START_END_PATTERN_LEN;
extern const int VZZX_UPC_EAN_START_END_PATTERN[];
extern const int VZZX_UPC_EAN_MIDDLE_PATTERN_LEN;
extern const int VZZX_UPC_EAN_MIDDLE_PATTERN[];
extern const int VZZX_UPC_EAN_L_PATTERNS_LEN;
extern const int VZZX_UPC_EAN_L_PATTERNS_SUB_LEN;
extern const int VZZX_UPC_EAN_L_PATTERNS[][4];
extern const int VZZX_UPC_EAN_L_AND_G_PATTERNS_LEN;
extern const int VZZX_UPC_EAN_L_AND_G_PATTERNS_SUB_LEN;
extern const int VZZX_UPC_EAN_L_AND_G_PATTERNS[][4];

@class VZZXDecodeHints, VZZXEANManufacturerOrgSupport, VZZXIntArray, VZZXResult, VZZXUPCEANExtensionSupport;

/**
 * Encapsulates functionality and implementation that is common to UPC and EAN families
 * of one-dimensional barcodes.
 */
@interface VZZXUPCEANReader : VZZXOneDReader

+ (NSRange)findStartGuardPattern:(VZZXBitArray *)row error:(NSError **)error;

/**
 * Like decodeRow:row:hints:, but allows caller to inform method about where the UPC/EAN start pattern is
 * found. This allows this to be computed once and reused across many implementations.
 */
- (VZZXResult *)decodeRow:(int)rowNumber row:(VZZXBitArray *)row startGuardRange:(NSRange)startGuardRange hints:(VZZXDecodeHints *)hints error:(NSError **)error;

/**
 * @return checkStandardUPCEANChecksum:
 */
- (BOOL)checkChecksum:(NSString *)s error:(NSError **)error;

/**
 * Computes the UPC/EAN checksum on a string of digits, and reports
 * whether the checksum is correct or not.
 *
 * @param s string of digits to check
 * @return YES iff string of digits passes the UPC/EAN checksum algorithm
 * @return NO if the string does not contain only digits
 */
+ (BOOL)checkStandardUPCEANChecksum:(NSString *)s;

- (NSRange)decodeEnd:(VZZXBitArray *)row endStart:(int)endStart error:(NSError **)error;

+ (NSRange)findGuardPattern:(VZZXBitArray *)row rowOffset:(int)rowOffset whiteFirst:(BOOL)whiteFirst pattern:(const int[])pattern patternLen:(int)patternLen error:(NSError **)error;

/**
 * @param row row of black/white values to search
 * @param rowOffset position to start search
 * @param whiteFirst if true, indicates that the pattern specifies white/black/white/...
 * pixel counts, otherwise, it is interpreted as black/white/black/...
 * @param pattern pattern of counts of number of black and white pixels that are being
 * searched for as a pattern
 * @param counters array of counters, as long as pattern, to re-use
 * @return start/end horizontal offset of guard pattern, as an array of two ints
 */
+ (NSRange)findGuardPattern:(VZZXBitArray *)row rowOffset:(int)rowOffset whiteFirst:(BOOL)whiteFirst pattern:(const int[])pattern patternLen:(int)patternLen counters:(VZZXIntArray *)counters error:(NSError **)error;

/**
 * Attempts to decode a single UPC/EAN-encoded digit.
 *
 * @param row row of black/white values to decode
 * @param counters the counts of runs of observed black/white/black/... values
 * @param rowOffset horizontal offset to start decoding from
 * @param patternType the set of patterns to use to decode -- sometimes different encodings
 * for the digits 0-9 are used, and this indicates the encodings for 0 to 9 that should
 * be used
 * @return horizontal offset of first pixel beyond the decoded digit
 * @return -1 if digit cannot be decoded
 */
+ (int)decodeDigit:(VZZXBitArray *)row counters:(VZZXIntArray *)counters rowOffset:(int)rowOffset patternType:(VZZX_UPC_EAN_PATTERNS)patternType error:(NSError **)error;

/**
 * Get the format of this decoder.
 *
 * @return The 1D format.
 */
- (VZZXBarcodeFormat)barcodeFormat;

/**
 * Subclasses override this to decode the portion of a barcode between the start
 * and end guard patterns.
 *
 * @param row row of black/white values to search
 * @param startRange start/end offset of start guard pattern
 * @param result NSMutableString to append decoded chars to
 * @return horizontal offset of first pixel after the "middle" that was decoded
 * @return -1 if decoding could not complete successfully
 */
- (int)decodeMiddle:(VZZXBitArray *)row startRange:(NSRange)startRange result:(NSMutableString *)result error:(NSError **)error;

@end
