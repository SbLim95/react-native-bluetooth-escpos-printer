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

#import "VZZXBitMatrix.h"
#import "VZZXByteArray.h"
#import "VZZXEncodeHints.h"
#import "VZZXPDF417.h"
#import "VZZXPDF417BarcodeMatrix.h"
#import "VZZXPDF417Dimensions.h"
#import "VZZXPDF417Writer.h"

/**
 * default white space (margin) around the code
 */
const int VZZX_PDF417_WHITE_SPACE = 30;

@implementation VZZXPDF417Writer

- (VZZXBitMatrix *)encode:(NSString *)contents format:(VZZXBarcodeFormat)format width:(int)width height:(int)height
                  hints:(VZZXEncodeHints *)hints error:(NSError **)error {
  if (format != kBarcodeFormatPDF417) {
    [NSException raise:NSInvalidArgumentException format:@"Can only encode PDF_417, but got %d", format];
  }

  VZZXPDF417 *encoder = [[VZZXPDF417 alloc] init];
  int margin = VZZX_PDF417_WHITE_SPACE;

  if (hints != nil) {
    encoder.compact = hints.pdf417Compact;
    encoder.compaction = hints.pdf417Compaction;
    if (hints.pdf417Dimensions != nil) {
      VZZXPDF417Dimensions *dimensions = hints.pdf417Dimensions;
      [encoder setDimensionsWithMaxCols:dimensions.maxCols
                                minCols:dimensions.minCols
                                maxRows:dimensions.maxRows
                                minRows:dimensions.minRows];
    }
    if (hints.margin) {
      margin = [hints.margin intValue];
    }
    if (hints.encoding > 0) {
      encoder.encoding = hints.encoding;
    }
  }

  return [self bitMatrixFromEncoder:encoder contents:contents width:width height:height margin:margin error:error];
}

- (VZZXBitMatrix *)encode:(NSString *)contents format:(VZZXBarcodeFormat)format width:(int)width height:(int)height error:(NSError **)error {
  return [self encode:contents format:format width:width height:height hints:nil error:error];
}

/**
 * Takes encoder, accounts for width/height, and retrieves bit matrix
 */
- (VZZXBitMatrix *)bitMatrixFromEncoder:(VZZXPDF417 *)encoder
                             contents:(NSString *)contents
                                width:(int)width
                               height:(int)height
                               margin:(int)margin
                                error:(NSError **)error {
  int errorCorrectionLevel = 2;
  if (![encoder generateBarcodeLogic:contents errorCorrectionLevel:errorCorrectionLevel error:error]) {
    return nil;
  }

  int lineThickness = 2;
  int aspectRatio = 4;
  NSArray *originalScale = [[encoder barcodeMatrix] scaledMatrixWithXScale:lineThickness yScale:aspectRatio * lineThickness];
  BOOL rotated = NO;
  if ((height > width) ^ ([(VZZXByteArray *)originalScale[0] length] < [originalScale count])) {
    originalScale = [self rotateArray:originalScale];
    rotated = YES;
  }

  int scaleX = width / [(VZZXByteArray *)originalScale[0] length];
  int scaleY = height / [originalScale count];

  int scale;
  if (scaleX < scaleY) {
    scale = scaleX;
  } else {
    scale = scaleY;
  }

  if (scale > 1) {
    NSArray *scaledMatrix =
      [[encoder barcodeMatrix] scaledMatrixWithXScale:scale * lineThickness yScale:scale * aspectRatio * lineThickness];
    if (rotated) {
      scaledMatrix = [self rotateArray:scaledMatrix];
    }
    return [self bitMatrixFrombitArray:scaledMatrix margin:margin];
  }
  return [self bitMatrixFrombitArray:originalScale margin:margin];
}

/**
 * This takes an array holding the values of the PDF 417
 *
 * @param input a byte array of information with 0 is black, and 1 is white
 * @param margin border around the barcode
 * @return BitMatrix of the input
 */
- (VZZXBitMatrix *)bitMatrixFrombitArray:(NSArray *)input margin:(int)margin {
  // Creates the bitmatrix with extra space for whtespace
  VZZXBitMatrix *output = [[VZZXBitMatrix alloc] initWithWidth:[(VZZXByteArray *)input[0] length] + 2 * margin height:(int)[input count] + 2 * margin];
  [output clear];
  for (int y = 0, yOutput = output.height - margin; y < [input count]; y++, yOutput--) {
    for (int x = 0; x < [(VZZXByteArray *)input[0] length]; x++) {
      // Zero is white in the bytematrix
      if ([(VZZXByteArray *)input[y] array][x] == 1) {
        [output setX:x + margin y:yOutput];
      }
    }
  }
  return output;
}

/**
 * Takes and rotates the it 90 degrees
 */
- (NSArray *)rotateArray:(NSArray *)bitarray {
  NSMutableArray *temp = [NSMutableArray array];
  for (int i = 0; i < [(VZZXByteArray *)bitarray[0] length]; i++) {
    [temp addObject:[[VZZXByteArray alloc] initWithLength:(unsigned int)[bitarray count]]];
  }

  for (int ii = 0; ii < [bitarray count]; ii++) {
    // This makes the direction consistent on screen when rotating the
    // screen;
    int inverseii = (int)[bitarray count] - ii - 1;
    for (int jj = 0; jj < [(VZZXByteArray *)bitarray[0] length]; jj++) {
      VZZXByteArray *b = temp[jj];
      b.array[inverseii] = [(VZZXByteArray *)bitarray[ii] array][jj];
    }
  }
  return temp;
}

@end
