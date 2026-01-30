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

#import "VZZXByteArray.h"
#import "VZZXQRCodeDataBlock.h"
#import "VZZXQRCodeErrorCorrectionLevel.h"
#import "VZZXQRCodeVersion.h"

@implementation VZZXQRCodeDataBlock

- (id)initWithNumDataCodewords:(int)numDataCodewords codewords:(VZZXByteArray *)codewords {
  if (self = [super init]) {
    _numDataCodewords = numDataCodewords;
    _codewords = codewords;
  }

  return self;
}

+ (NSArray *)dataBlocks:(VZZXByteArray *)rawCodewords version:(VZZXQRCodeVersion *)version ecLevel:(VZZXQRCodeErrorCorrectionLevel *)ecLevel {
  if (rawCodewords.length != version.totalCodewords) {
    [NSException raise:NSInvalidArgumentException format:@"Invalid codewords count"];
  }

  // Figure out the number and size of data blocks used by this version and
  // error correction level
  VZZXQRCodeECBlocks *ecBlocks = [version ecBlocksForLevel:ecLevel];

  // First count the total number of data blocks
  int totalBlocks = 0;
  NSArray *ecBlockArray = ecBlocks.ecBlocks;
  for (VZZXQRCodeECB *ecBlock in ecBlockArray) {
    totalBlocks += ecBlock.count;
  }

  // Now establish DataBlocks of the appropriate size and number of data codewords
  NSMutableArray *result = [NSMutableArray arrayWithCapacity:totalBlocks];
  for (VZZXQRCodeECB *ecBlock in ecBlockArray) {
    for (int i = 0; i < ecBlock.count; i++) {
      int numDataCodewords = ecBlock.dataCodewords;
      int numBlockCodewords = ecBlocks.ecCodewordsPerBlock + numDataCodewords;
      [result addObject:[[VZZXQRCodeDataBlock alloc] initWithNumDataCodewords:numDataCodewords codewords:[[VZZXByteArray alloc] initWithLength:numBlockCodewords]]];
    }
  }

  // All blocks have the same amount of data, except that the last n
  // (where n may be 0) have 1 more byte. Figure out where these start.
  int shorterBlocksTotalCodewords = [(VZZXQRCodeDataBlock *)result[0] codewords].length;
  int longerBlocksStartAt = (int)[result count] - 1;
  while (longerBlocksStartAt >= 0) {
    int numCodewords = [(VZZXQRCodeDataBlock *)result[longerBlocksStartAt] codewords].length;
    if (numCodewords == shorterBlocksTotalCodewords) {
      break;
    }
    longerBlocksStartAt--;
  }
  longerBlocksStartAt++;

  int shorterBlocksNumDataCodewords = shorterBlocksTotalCodewords - ecBlocks.ecCodewordsPerBlock;
  // The last elements of result may be 1 element longer;
  // first fill out as many elements as all of them have
  int rawCodewordsOffset = 0;
  int numResultBlocks = (int)[result count];
  for (int i = 0; i < shorterBlocksNumDataCodewords; i++) {
    for (int j = 0; j < numResultBlocks; j++) {
      [(VZZXQRCodeDataBlock *)result[j] codewords].array[i] = rawCodewords.array[rawCodewordsOffset++];
    }
  }
  // Fill out the last data block in the longer ones
  for (int j = longerBlocksStartAt; j < numResultBlocks; j++) {
    [(VZZXQRCodeDataBlock *)result[j] codewords].array[shorterBlocksNumDataCodewords] = rawCodewords.array[rawCodewordsOffset++];
  }
  // Now add in error correction blocks
  int max = (int)[(VZZXQRCodeDataBlock *)result[0] codewords].length;
  for (int i = shorterBlocksNumDataCodewords; i < max; i++) {
    for (int j = 0; j < numResultBlocks; j++) {
      int iOffset = j < longerBlocksStartAt ? i : i + 1;
      [(VZZXQRCodeDataBlock *)result[j] codewords].array[iOffset] = rawCodewords.array[rawCodewordsOffset++];
    }
  }

  return result;
}

@end
