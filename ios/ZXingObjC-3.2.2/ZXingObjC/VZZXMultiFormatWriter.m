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
#import "VZZXErrors.h"
#import "VZZXMultiFormatWriter.h"

#if defined(VZZXINGOBJC_AZTEC) || !defined(VZZXINGOBJC_USE_SUBSPECS)
#import "VZZXAztecWriter.h"
#endif
#if defined(VZZXINGOBJC_ONED) || !defined(VZZXINGOBJC_USE_SUBSPECS)
#import "VZZXCodaBarWriter.h"
#import "VZZXCode39Writer.h"
#import "VZZXCode128Writer.h"
#import "VZZXEAN8Writer.h"
#import "VZZXEAN13Writer.h"
#import "VZZXITFWriter.h"
#import "VZZXUPCAWriter.h"
#import "VZZXUPCEWriter.h"
#endif
#if defined(VZZXINGOBJC_DATAMATRIX) || !defined(VZZXINGOBJC_USE_SUBSPECS)
#import "VZZXDataMatrixWriter.h"
#endif
#if defined(VZZXINGOBJC_PDF417) || !defined(VZZXINGOBJC_USE_SUBSPECS)
#import "VZZXPDF417Writer.h"
#endif
#if defined(VZZXINGOBJC_QRCODE) || !defined(VZZXINGOBJC_USE_SUBSPECS)
#import "VZZXQRCodeWriter.h"
#endif

@implementation VZZXMultiFormatWriter

+ (id)writer {
  return [[VZZXMultiFormatWriter alloc] init];
}

- (VZZXBitMatrix *)encode:(NSString *)contents format:(VZZXBarcodeFormat)format width:(int)width height:(int)height error:(NSError **)error {
  return [self encode:contents format:format width:width height:height hints:nil error:error];
}

- (VZZXBitMatrix *)encode:(NSString *)contents format:(VZZXBarcodeFormat)format width:(int)width height:(int)height hints:(VZZXEncodeHints *)hints error:(NSError **)error {
  id<VZZXWriter> writer;
  switch (format) {
#if defined(VZZXINGOBJC_ONED) || !defined(VZZXINGOBJC_USE_SUBSPECS)
    case kBarcodeFormatEan8:
      writer = [[VZZXEAN8Writer alloc] init];
      break;

    case kBarcodeFormatEan13:
      writer = [[VZZXEAN13Writer alloc] init];
      break;

    case kBarcodeFormatUPCA:
      writer = [[VZZXUPCAWriter alloc] init];
      break;

    case kBarcodeFormatUPCE:
      writer = [[VZZXUPCEWriter alloc] init];
      break;

    case kBarcodeFormatCode39:
      writer = [[VZZXCode39Writer alloc] init];
      break;

    case kBarcodeFormatCode128:
      writer = [[VZZXCode128Writer alloc] init];
      break;

    case kBarcodeFormatITF:
      writer = [[VZZXITFWriter alloc] init];
      break;

    case kBarcodeFormatCodabar:
        writer = [[VZZXCodaBarWriter alloc] init];
        break;
#endif

#if defined(VZZXINGOBJC_QRCODE) || !defined(VZZXINGOBJC_USE_SUBSPECS)
    case kBarcodeFormatQRCode:
        writer = [[VZZXQRCodeWriter alloc] init];
        break;
#endif

#if defined(VZZXINGOBJC_PDF417) || !defined(VZZXINGOBJC_USE_SUBSPECS)
    case kBarcodeFormatPDF417:
      writer = [[VZZXPDF417Writer alloc] init];
      break;
#endif

#if defined(VZZXINGOBJC_DATAMATRIX) || !defined(VZZXINGOBJC_USE_SUBSPECS)
    case kBarcodeFormatDataMatrix:
      writer = [[VZZXDataMatrixWriter alloc] init];
      break;
#endif

#if defined(VZZXINGOBJC_AZTEC) || !defined(VZZXINGOBJC_USE_SUBSPECS)
    case kBarcodeFormatAztec:
      writer = [[VZZXAztecWriter alloc] init];
      break;
#endif

    default:
      if (error) *error = [NSError errorWithDomain:VZZXErrorDomain code:VZZXWriterError userInfo:@{NSLocalizedDescriptionKey: @"No encoder available for format"}];
      return nil;
  }
  return [writer encode:contents format:format width:width height:height hints:hints error:error];
}

@end
