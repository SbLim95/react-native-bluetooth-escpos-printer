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

#import "VZZXAztecDecoder.h"
#import "VZZXAztecDetectorResult.h"
#import "VZZXBitMatrix.h"
#import "VZZXBoolArray.h"
#import "VZZXDecoderResult.h"
#import "VZZXErrors.h"
#import "VZZXGenericGF.h"
#import "VZZXIntArray.h"
#import "VZZXReedSolomonDecoder.h"
#import "VZZXByteArray.h"

typedef enum {
  VZZXAztecTableUpper = 0,
  VZZXAztecTableLower,
  VZZXAztecTableMixed,
  VZZXAztecTableDigit,
  VZZXAztecTablePunct,
  VZZXAztecTableBinary
} VZZXAztecTable;

static NSString *VZZX_AZTEC_UPPER_TABLE[] = {
  @"CTRL_PS", @" ", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P",
  @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"CTRL_LL", @"CTRL_ML", @"CTRL_DL", @"CTRL_BS"
};

static NSString *VZZX_AZTEC_LOWER_TABLE[] = {
  @"CTRL_PS", @" ", @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p",
  @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z", @"CTRL_US", @"CTRL_ML", @"CTRL_DL", @"CTRL_BS"
};

static NSString *VZZX_AZTEC_MIXED_TABLE[] = {
  @"CTRL_PS", @" ", @"\1", @"\2", @"\3", @"\4", @"\5", @"\6", @"\7", @"\b", @"\t", @"\n",
  @"\13", @"\f", @"\r", @"\33", @"\34", @"\35", @"\36", @"\37", @"@", @"\\", @"^", @"_",
  @"`", @"|", @"~", @"\177", @"CTRL_LL", @"CTRL_UL", @"CTRL_PL", @"CTRL_BS"
};

static NSString *VZZX_AZTEC_PUNCT_TABLE[] = {
  @"", @"\r", @"\r\n", @". ", @", ", @": ", @"!", @"\"", @"#", @"$", @"%", @"&", @"'", @"(", @")",
  @"*", @"+", @",", @"-", @".", @"/", @":", @";", @"<", @"=", @">", @"?", @"[", @"]", @"{", @"}", @"CTRL_UL"
};

static NSString *VZZX_AZTEC_DIGIT_TABLE[] = {
  @"CTRL_PS", @" ", @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @",", @".", @"CTRL_UL", @"CTRL_US"
};

@interface VZZXAztecDecoder ()

@property (nonatomic, strong) VZZXAztecDetectorResult *ddata;

@end

@implementation VZZXAztecDecoder

- (VZZXDecoderResult *)decode:(VZZXAztecDetectorResult *)detectorResult error:(NSError **)error {
  self.ddata = detectorResult;
  VZZXBitMatrix *matrix = [detectorResult bits];
  VZZXBoolArray *rawbits = [self extractBits:matrix];
  if (!rawbits) {
    if (error) *error = VZZXFormatErrorInstance();
    return nil;
  }

  VZZXBoolArray *correctedBits = [self correctBits:rawbits error:error];
  if (!correctedBits) {
    return nil;
  }
    NSMutableArray *rawBytes = [VZZXAztecDecoder convertBoolArrayToByteArray: correctedBits];
    NSString *result = [[self class] encodedData:correctedBits];
    
    NSUInteger rawBytesSize = [rawBytes count];
    VZZXByteArray *rawBytesReturned = [[VZZXByteArray alloc] initWithLength:(unsigned int)rawBytesSize];
    for (int i = 0; i < rawBytesSize; i++) {
        rawBytesReturned.array[i] = (int8_t)[rawBytes[i] intValue];
    }
    
    return [[VZZXDecoderResult alloc] initWithRawBytes:rawBytesReturned text:result byteSegments:nil ecLevel:nil];
}

+ (NSString *)highLevelDecode:(VZZXBoolArray *)correctedBits {
  return [self encodedData:correctedBits];
}

/**
 * Gets the string encoded in the aztec code bits
 *
 * @return the decoded string
 */
+ (NSString *)encodedData:(VZZXBoolArray *)correctedBits {
  int endIndex = (int)correctedBits.length;
  VZZXAztecTable latchTable = VZZXAztecTableUpper; // table most recently latched to
  VZZXAztecTable shiftTable = VZZXAztecTableUpper; // table to use for the next read
  NSMutableString *result = [NSMutableString stringWithCapacity:20];
  int index = 0;
  while (index < endIndex) {
    if (shiftTable == VZZXAztecTableBinary) {
      if (endIndex - index < 5) {
        break;
      }
      int length = [self readCode:correctedBits startIndex:index length:5];
      index += 5;
      if (length == 0) {
        if (endIndex - index < 11) {
          break;
        }

        length = [self readCode:correctedBits startIndex:index length:11] + 31;
        index += 11;
      }
      for (int charCount = 0; charCount < length; charCount++) {
        if (endIndex - index < 8) {
          index = endIndex;  // Force outer loop to exit
          break;
        }

        int code = [self readCode:correctedBits startIndex:index length:8];
        [result appendFormat:@"%C", (unichar)code];
        index += 8;
      }
      // Go back to whatever mode we had been in
      shiftTable = latchTable;
    } else {
      int size = shiftTable == VZZXAztecTableDigit ? 4 : 5;
      if (endIndex - index < size) {
        break;
      }
      int code = [self readCode:correctedBits startIndex:index length:size];
      index += size;
      NSString *str = [self character:shiftTable code:code];
      if ([str hasPrefix:@"CTRL_"]) {
        // Table changes
        shiftTable = [self table:[str characterAtIndex:5]];
        if ([str characterAtIndex:6] == 'L') {
          latchTable = shiftTable;
        }
      } else {
        [result appendString:str];
        // Go back to whatever mode we had been in
        shiftTable = latchTable;
      }
    }
  }
  return [NSString stringWithString:result];
}

/**
 * gets the table corresponding to the char passed
 */
+ (VZZXAztecTable)table:(unichar)t {
  switch (t) {
    case 'L':
      return VZZXAztecTableLower;
    case 'P':
      return VZZXAztecTablePunct;
    case 'M':
      return VZZXAztecTableMixed;
    case 'D':
      return VZZXAztecTableDigit;
    case 'B':
      return VZZXAztecTableBinary;
    case 'U':
    default:
      return VZZXAztecTableUpper;
  }
}

/**
 * Gets the character (or string) corresponding to the passed code in the given table
 *
 * @param table the table used
 * @param code the code of the character
 */
+ (NSString *)character:(VZZXAztecTable)table code:(int)code {
  switch (table) {
    case VZZXAztecTableUpper:
      return VZZX_AZTEC_UPPER_TABLE[code];
    case VZZXAztecTableLower:
      return VZZX_AZTEC_LOWER_TABLE[code];
    case VZZXAztecTableMixed:
      return VZZX_AZTEC_MIXED_TABLE[code];
    case VZZXAztecTablePunct:
      return VZZX_AZTEC_PUNCT_TABLE[code];
    case VZZXAztecTableDigit:
      return VZZX_AZTEC_DIGIT_TABLE[code];
    default:
      // Should not reach here.
      @throw [NSException exceptionWithName:@"IllegalStateException" reason:@"Bad table" userInfo:nil];
  }
}

/**
 * <p>Performs RS error correction on an array of bits.</p>
 *
 * @return the number of corrected bits, or 0 if the input contains too many errors
 */
- (VZZXBoolArray *)correctBits:(VZZXBoolArray *)rawbits error:(NSError **)error {
  VZZXGenericGF *gf;
  int codewordSize;

  if ([self.ddata nbLayers] <= 2) {
    codewordSize = 6;
    gf = [VZZXGenericGF AztecData6];
  } else if ([self.ddata nbLayers] <= 8) {
    codewordSize = 8;
    gf = [VZZXGenericGF AztecData8];
  } else if ([self.ddata nbLayers] <= 22) {
    codewordSize = 10;
    gf = [VZZXGenericGF AztecData10];
  } else {
    codewordSize = 12;
    gf = [VZZXGenericGF AztecData12];
  }

  int numDataCodewords = [self.ddata nbDatablocks];
  int numCodewords = rawbits.length / codewordSize;
  if (numCodewords < numDataCodewords) {
    if (error) *error = VZZXFormatErrorInstance();
    return 0;
  }
  int offset = rawbits.length % codewordSize;
  int numECCodewords = numCodewords - numDataCodewords;

  VZZXIntArray *dataWords = [[VZZXIntArray alloc] initWithLength:numCodewords];
  for (int i = 0; i < numCodewords; i++, offset += codewordSize) {
    dataWords.array[i] = [[self class] readCode:rawbits startIndex:offset length:codewordSize];
  }

  VZZXReedSolomonDecoder *rsDecoder = [[VZZXReedSolomonDecoder alloc] initWithField:gf];
  NSError *decodeError = nil;
  if (![rsDecoder decode:dataWords twoS:numECCodewords error:&decodeError]) {
    if (decodeError.code == VZZXReedSolomonError) {
      if (error) *error = VZZXFormatErrorInstance();
    } else {
      if (error) *error = decodeError;
    }
    return 0;
  }

  // Now perform the unstuffing operation.
  // First, count how many bits are going to be thrown out as stuffing
  int mask = (1 << codewordSize) - 1;
  int stuffedBits = 0;
  for (int i = 0; i < numDataCodewords; i++) {
    int32_t dataWord = dataWords.array[i];
    if (dataWord == 0 || dataWord == mask) {
      if (error) *error = VZZXFormatErrorInstance();
      return 0;
    } else if (dataWord == 1 || dataWord == mask - 1) {
      stuffedBits++;
    }
  }

  // Now, actually unpack the bits and remove the stuffing
  VZZXBoolArray *correctedBits = [[VZZXBoolArray alloc] initWithLength:numDataCodewords * codewordSize - stuffedBits];
  int index = 0;
  for (int i = 0; i < numDataCodewords; i++) {
    int dataWord = dataWords.array[i];
    if (dataWord == 1 || dataWord == mask - 1) {
      // next codewordSize-1 bits are all zeros or all ones
      memset(correctedBits.array + index * sizeof(BOOL), dataWord > 1, codewordSize - 1);
      index += codewordSize - 1;
    } else {
      for (int bit = codewordSize - 1; bit >= 0; --bit) {
        correctedBits.array[index++] = (dataWord & (1 << bit)) != 0;
      }
    }
  }
  return correctedBits;
}

/**
 * Gets the array of bits from an Aztec Code matrix
 *
 * @return the size of the array of bits
 */
- (VZZXBoolArray *)extractBits:(VZZXBitMatrix *)matrix {
  BOOL compact = self.ddata.isCompact;
  int layers = self.ddata.nbLayers;
  int baseMatrixSize = compact ? 11 + layers * 4 : 14 + layers * 4; // not including alignment lines
  VZZXIntArray *alignmentMap = [[VZZXIntArray alloc] initWithLength:baseMatrixSize];
  VZZXBoolArray *rawbits = [[VZZXBoolArray alloc] initWithLength:[self totalBitsInLayer:layers compact:compact]];

  if (compact) {
    for (int i = 0; i < alignmentMap.length; i++) {
      alignmentMap.array[i] = i;
    }
  } else {
    int matrixSize = baseMatrixSize + 1 + 2 * ((baseMatrixSize / 2 - 1) / 15);
    int origCenter = baseMatrixSize / 2;
    int center = matrixSize / 2;
    for (int i = 0; i < origCenter; i++) {
      int newOffset = i + i / 15;
      alignmentMap.array[origCenter - i - 1] = (int32_t)(center - newOffset - 1);
      alignmentMap.array[origCenter + i] = (int32_t)(center + newOffset + 1);
    }
  }
  for (int i = 0, rowOffset = 0; i < layers; i++) {
    int rowSize = compact ? (layers - i) * 4 + 9 : (layers - i) * 4 + 12;
    // The top-left most point of this layer is <low, low> (not including alignment lines)
    int low = i * 2;
    // The bottom-right most point of this layer is <high, high> (not including alignment lines)
    int high = baseMatrixSize - 1 - low;
    // We pull bits from the two 2 x rowSize columns and two rowSize x 2 rows
    for (int j = 0; j < rowSize; j++) {
      int columnOffset = j * 2;
      for (int k = 0; k < 2; k++) {
        // left column
        rawbits.array[rowOffset + columnOffset + k] =
          [matrix getX:alignmentMap.array[low + k] y:alignmentMap.array[low + j]];
        // bottom row
        rawbits.array[rowOffset + 2 * rowSize + columnOffset + k] =
          [matrix getX:alignmentMap.array[low + j] y:alignmentMap.array[high - k]];
        // right column
        rawbits.array[rowOffset + 4 * rowSize + columnOffset + k] =
          [matrix getX:alignmentMap.array[high - k] y:alignmentMap.array[high - j]];
        // top row
        rawbits.array[rowOffset + 6 * rowSize + columnOffset + k] =
          [matrix getX:alignmentMap.array[high - j] y:alignmentMap.array[low + k]];
      }
    }
    rowOffset += rowSize * 8;
  }
  return rawbits;
}

/**
 * Reads a code of given length and at given index in an array of bits
 */
+ (int)readCode:(VZZXBoolArray *)rawbits startIndex:(int)startIndex length:(int)length {
  int res = 0;
  for (int i = startIndex; i < startIndex + length; i++) {
    res <<= 1;
    if (rawbits.array[i]) {
      res |= 0x01;
    }
  }
  return res;
}

/**
 * Reads a code of length 8 in an array of bits, padding with zeros
 */
+ (int) readByte:(VZZXBoolArray *) rawbits startIndex:(int) startIndex {
    int n = rawbits.length - startIndex;
    if (n >= 8) {
        return (int) [self readCode:rawbits startIndex:startIndex length:8];
    }
    return (int) ([self readCode:rawbits startIndex:startIndex length:n] << (8 - n));
}

/**
 * Packs a bit array into bytes, most significant bit first
 */
+ (NSMutableArray *) convertBoolArrayToByteArray:(VZZXBoolArray *) boolArr {
    NSMutableArray *byteArr = [[NSMutableArray alloc] init];
    int byteArrLength = (boolArr.length + 7) / 8;
    for (int i = 0; i < byteArrLength; i++) {
        int code = [self readByte:boolArr startIndex:8 * i];
        [byteArr addObject:@(code)];
    }
    return byteArr;
}

- (int)totalBitsInLayer:(int)layers compact:(BOOL)compact {
  return ((compact ? 88 : 112) + 16 * layers) * layers;
}

@end
