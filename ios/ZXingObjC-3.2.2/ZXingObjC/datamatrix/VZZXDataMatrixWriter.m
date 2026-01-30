/*
 * Copyright 2013 ZXing authors
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
#import "VZZXByteMatrix.h"
#import "VZZXDataMatrixDefaultPlacement.h"
#import "VZZXDataMatrixErrorCorrection.h"
#import "VZZXDataMatrixHighLevelEncoder.h"
#import "VZZXDataMatrixSymbolInfo.h"
#import "VZZXDataMatrixWriter.h"
#import "VZZXDimension.h"
#import "VZZXEncodeHints.h"

@implementation VZZXDataMatrixWriter

- (VZZXBitMatrix *)encode:(NSString *)contents format:(VZZXBarcodeFormat)format width:(int)width height:(int)height error:(NSError **)error {
  return [self encode:contents format:format width:width height:height hints:nil error:error];
}

- (VZZXBitMatrix *)encode:(NSString *)contents format:(VZZXBarcodeFormat)format width:(int)width height:(int)height hints:(VZZXEncodeHints *)hints error:(NSError **)error {
  if (contents.length == 0) {
    [NSException raise:NSInvalidArgumentException format:@"Found empty contents"];
  }

  if (format != kBarcodeFormatDataMatrix) {
    [NSException raise:NSInvalidArgumentException format:@"Can only encode kBarcodeFormatDataMatrix"];
  }

  if (width < 0 || height < 0) {
    [NSException raise:NSInvalidArgumentException
                format:@"Requested dimensions are too small: %dx%d", width, height];
  }

  // Try to get force shape & min / max size
  VZZXDataMatrixSymbolShapeHint shape = VZZXDataMatrixSymbolShapeHintForceNone;
  VZZXDimension *minSize = nil;
  VZZXDimension *maxSize = nil;
  if (hints != nil) {
    shape = hints.dataMatrixShape;
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    VZZXDimension *requestedMinSize = hints.minSize;
#pragma GCC diagnostic pop
    if (requestedMinSize != nil) {
      minSize = requestedMinSize;
    }
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    VZZXDimension *requestedMaxSize = hints.maxSize;
#pragma GCC diagnostic pop
    if (requestedMaxSize != nil) {
      maxSize = requestedMaxSize;
    }
  }

  //1. step: Data encodation
  NSString *encoded = [VZZXDataMatrixHighLevelEncoder encodeHighLevel:contents shape:shape minSize:minSize maxSize:maxSize];

  VZZXDataMatrixSymbolInfo *symbolInfo = [VZZXDataMatrixSymbolInfo lookup:(int)encoded.length shape:shape minSize:minSize maxSize:maxSize fail:YES];

  //2. step: ECC generation
  NSString *codewords = [VZZXDataMatrixErrorCorrection encodeECC200:encoded symbolInfo:symbolInfo];

  //3. step: Module placement in Matrix
  VZZXDataMatrixDefaultPlacement *placement = [[VZZXDataMatrixDefaultPlacement alloc] initWithCodewords:codewords numcols:symbolInfo.symbolDataWidth numrows:symbolInfo.symbolDataHeight];
  [placement place];

  //4. step: low-level encoding
  return [self encodeLowLevel:placement symbolInfo:symbolInfo width:width height:height];
}

/**
 * Encode the given symbol info to a bit matrix.
 *
 * @param placement  The DataMatrix placement.
 * @param symbolInfo The symbol info to encode.
 * @return The bit matrix generated.
 */
- (VZZXBitMatrix *)encodeLowLevel:(VZZXDataMatrixDefaultPlacement *)placement symbolInfo:(VZZXDataMatrixSymbolInfo *)symbolInfo width:(int)width height:(int)height {
  int symbolWidth = symbolInfo.symbolDataWidth;
  int symbolHeight = symbolInfo.symbolDataHeight;

  VZZXByteMatrix *matrix = [[VZZXByteMatrix alloc] initWithWidth:symbolInfo.symbolWidth height:symbolInfo.symbolHeight];

  int matrixY = 0;

  for (int y = 0; y < symbolHeight; y++) {
    // Fill the top edge with alternate 0 / 1
    int matrixX;
    if ((y % symbolInfo.matrixHeight) == 0) {
      matrixX = 0;
      for (int x = 0; x < symbolInfo.symbolWidth; x++) {
        [matrix setX:matrixX y:matrixY boolValue:(x % 2) == 0];
        matrixX++;
      }
      matrixY++;
    }
    matrixX = 0;
    for (int x = 0; x < symbolWidth; x++) {
      // Fill the right edge with full 1
      if ((x % symbolInfo.matrixWidth) == 0) {
        [matrix setX:matrixX y:matrixY boolValue:YES];
        matrixX++;
      }
      [matrix setX:matrixX y:matrixY boolValue:[placement bitAtCol:x row:y]];
      matrixX++;
      // Fill the right edge with alternate 0 / 1
      if ((x % symbolInfo.matrixWidth) == symbolInfo.matrixWidth - 1) {
        [matrix setX:matrixX y:matrixY boolValue:(y % 2) == 0];
        matrixX++;
      }
    }
    matrixY++;
    // Fill the bottom edge with full 1
    if ((y % symbolInfo.matrixHeight) == symbolInfo.matrixHeight - 1) {
      matrixX = 0;
      for (int x = 0; x < symbolInfo.symbolWidth; x++) {
        [matrix setX:matrixX y:matrixY boolValue:YES];
        matrixX++;
      }
      matrixY++;
    }
  }

  return [self convertByteMatrixToBitMatrix:matrix width:width height:height];
}

/**
 * Convert the VZZXByteMatrix to VZZXBitMatrix.
 *
 * @param input The input matrix.
 * @return The output matrix.
 */
- (VZZXBitMatrix *)convertByteMatrixToBitMatrix:(VZZXByteMatrix *)input width:(int)width height:(int)height {
  int inputWidth = input.width;
  int inputHeight = input.height;
  int outputWidth = MAX(width, inputWidth);
  int outputHeight = MAX(height, inputHeight);

  int multiple = MIN(outputWidth / inputWidth, outputHeight / inputHeight);
  int leftPadding = (outputWidth - (inputWidth * multiple)) / 2;
  int topPadding = (outputHeight - (inputHeight * multiple)) / 2;

  VZZXBitMatrix *output = [[VZZXBitMatrix alloc] initWithWidth:outputWidth height:outputHeight];

  for (int inputY = 0, outputY = topPadding; inputY < inputHeight; inputY++, outputY += multiple) {
    for (int inputX = 0, outputX = leftPadding; inputX < inputWidth; inputX++, outputX += multiple) {
      if ([input getX:inputX y:inputY] == 1) {
        [output setRegionAtLeft:outputX top:outputY width:multiple height:multiple];
      }
    }
  }
  return output;
}

@end
