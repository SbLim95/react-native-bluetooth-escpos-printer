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
#import "VZZXProductParsedResult.h"
#import "VZZXProductResultParser.h"
#import "VZZXUPCEReader.h"

@implementation VZZXProductResultParser

// Treat all UPC and EAN variants as UPCs, in the sense that they are all product barcodes.
- (VZZXParsedResult *)parse:(VZZXResult *)result {
  VZZXBarcodeFormat format = [result barcodeFormat];
  if (!(format == kBarcodeFormatUPCA || format == kBarcodeFormatUPCE || format == kBarcodeFormatEan8 || format == kBarcodeFormatEan13)) {
    return nil;
  }
  NSString *rawText = [VZZXResultParser massagedText:result];
  if (![[self class] isStringOfDigits:rawText length:(unsigned int)[rawText length]]) {
    return nil;
  }
  // Not actually checking the checksum again here

  NSString *normalizedProductID;
  if (format == kBarcodeFormatUPCE && [rawText length] == 8) {
    normalizedProductID = [VZZXUPCEReader convertUPCEtoUPCA:rawText];
  } else {
    normalizedProductID = rawText;
  }
  return [VZZXProductParsedResult productParsedResultWithProductID:rawText normalizedProductID:normalizedProductID];
}

@end
