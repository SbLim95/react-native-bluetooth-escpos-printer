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

@class VZZXBitMatrix, VZZXIntArray, VZZXQRCodeECB, VZZXQRCodeECBlocks, VZZXQRCodeErrorCorrectionLevel;

/**
 * See ISO 18004:2006 Annex D
 */
@interface VZZXQRCodeVersion : NSObject

@property (nonatomic, assign, readonly) int versionNumber;
@property (nonatomic, strong, readonly) VZZXIntArray *alignmentPatternCenters;
@property (nonatomic, strong, readonly) NSArray *ecBlocks;
@property (nonatomic, assign, readonly) int totalCodewords;
@property (nonatomic, assign, readonly) int dimensionForVersion;

- (VZZXQRCodeECBlocks *)ecBlocksForLevel:(VZZXQRCodeErrorCorrectionLevel *)ecLevel;
+ (VZZXQRCodeVersion *)provisionalVersionForDimension:(int)dimension;
+ (VZZXQRCodeVersion *)versionForNumber:(int)versionNumber;
+ (VZZXQRCodeVersion *)decodeVersionInformation:(int)versionBits;
- (VZZXBitMatrix *)buildFunctionPattern;

@end

/**
 * Encapsulates a set of error-correction blocks in one symbol version. Most versions will
 * use blocks of differing sizes within one version, so, this encapsulates the parameters for
 * each set of blocks. It also holds the number of error-correction codewords per block since it
 * will be the same across all blocks within one version.
 */
@interface VZZXQRCodeECBlocks : NSObject

@property (nonatomic, assign, readonly) int ecCodewordsPerBlock;
@property (nonatomic, assign, readonly) int numBlocks;
@property (nonatomic, assign, readonly) int totalECCodewords;
@property (nonatomic, strong, readonly) NSArray *ecBlocks;

- (id)initWithEcCodewordsPerBlock:(int)ecCodewordsPerBlock ecBlocks:(VZZXQRCodeECB *)ecBlocks;
- (id)initWithEcCodewordsPerBlock:(int)ecCodewordsPerBlock ecBlocks1:(VZZXQRCodeECB *)ecBlocks1 ecBlocks2:(VZZXQRCodeECB *)ecBlocks2;
+ (VZZXQRCodeECBlocks *)ecBlocksWithEcCodewordsPerBlock:(int)ecCodewordsPerBlock ecBlocks:(VZZXQRCodeECB *)ecBlocks;
+ (VZZXQRCodeECBlocks *)ecBlocksWithEcCodewordsPerBlock:(int)ecCodewordsPerBlock ecBlocks1:(VZZXQRCodeECB *)ecBlocks1 ecBlocks2:(VZZXQRCodeECB *)ecBlocks2;

@end

/**
 * Encapsualtes the parameters for one error-correction block in one symbol version.
 * This includes the number of data codewords, and the number of times a block with these
 * parameters is used consecutively in the QR code version's format.
 */
@interface VZZXQRCodeECB : NSObject

@property (nonatomic, assign, readonly) int count;
@property (nonatomic, assign, readonly) int dataCodewords;

- (id)initWithCount:(int)count dataCodewords:(int)dataCodewords;
+ (VZZXQRCodeECB *)ecbWithCount:(int)count dataCodewords:(int)dataCodewords;

@end
