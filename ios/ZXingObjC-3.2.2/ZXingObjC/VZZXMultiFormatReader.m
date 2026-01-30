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

#import "VZZXBinaryBitmap.h"
#import "VZZXDecodeHints.h"
#import "VZZXErrors.h"
#import "VZZXMultiFormatReader.h"
#import "VZZXResult.h"

#if defined(VZZXINGOBJC_AZTEC) || !defined(VZZXINGOBJC_USE_SUBSPECS)
#import "VZZXAztecReader.h"
#endif
#if defined(VZZXINGOBJC_DATAMATRIX) || !defined(VZZXINGOBJC_USE_SUBSPECS)
#import "VZZXDataMatrixReader.h"
#endif
#if defined(VZZXINGOBJC_MAXICODE) || !defined(VZZXINGOBJC_USE_SUBSPECS)
#import "VZZXMaxiCodeReader.h"
#endif
#if defined(VZZXINGOBJC_ONED) || !defined(VZZXINGOBJC_USE_SUBSPECS)
#import "VZZXMultiFormatOneDReader.h"
#endif
#if defined(VZZXINGOBJC_PDF417) || !defined(VZZXINGOBJC_USE_SUBSPECS)
#import "VZZXPDF417Reader.h"
#endif
#if defined(VZZXINGOBJC_QRCODE) || !defined(VZZXINGOBJC_USE_SUBSPECS)
#import "VZZXQRCodeReader.h"
#endif

@interface VZZXMultiFormatReader ()

@property (nonatomic, strong, readonly) NSMutableArray *readers;

@end

@implementation VZZXMultiFormatReader

- (id)init {
  if (self = [super init]) {
    _readers = [NSMutableArray array];
  }

  return self;
}

+ (id)reader {
  return [[VZZXMultiFormatReader alloc] init];
}

/**
 * This version of decode honors the intent of Reader.decode(BinaryBitmap) in that it
 * passes null as a hint to the decoders. However, that makes it inefficient to call repeatedly.
 * Use setHints() followed by decodeWithState() for continuous scan applications.
 *
 * @param image The pixel data to decode
 * @return The contents of the image or nil if any errors occurred
 */
- (VZZXResult *)decode:(VZZXBinaryBitmap *)image error:(NSError **)error {
  self.hints = nil;
  return [self decodeInternal:image error:error];
}

/**
 * Decode an image using the hints provided. Does not honor existing state.
 *
 * @param image The pixel data to decode
 * @param hints The hints to use, clearing the previous state.
 * @return The contents of the image or nil if any errors occurred
 */
- (VZZXResult *)decode:(VZZXBinaryBitmap *)image hints:(VZZXDecodeHints *)hints error:(NSError **)error {
  self.hints = hints;
  return [self decodeInternal:image error:error];
}

- (VZZXResult *)decodeWithState:(VZZXBinaryBitmap *)image error:(NSError **)error {
  if (self.readers == nil) {
    self.hints = nil;
  }
  return [self decodeInternal:image error:error];
}

/**
 * This method adds state to the MultiFormatReader. By setting the hints once, subsequent calls
 * to decodeWithState(image) can reuse the same set of readers without reallocating memory. This
 * is important for performance in continuous scan clients.
 *
 * @param hints The set of hints to use for subsequent calls to decode(image)
 */
- (void)setHints:(VZZXDecodeHints *)hints {
  _hints = hints;

  BOOL tryHarder = hints != nil && hints.tryHarder;
  [self.readers removeAllObjects];
  if (hints != nil) {
    BOOL addZXOneDReader = [hints containsFormat:kBarcodeFormatUPCA] ||
      [hints containsFormat:kBarcodeFormatUPCE] ||
      [hints containsFormat:kBarcodeFormatEan13] ||
      [hints containsFormat:kBarcodeFormatEan8] ||
      [hints containsFormat:kBarcodeFormatCodabar] ||
      [hints containsFormat:kBarcodeFormatCode39] ||
      [hints containsFormat:kBarcodeFormatCode93] ||
      [hints containsFormat:kBarcodeFormatCode128] ||
      [hints containsFormat:kBarcodeFormatITF] ||
      [hints containsFormat:kBarcodeFormatRSS14] ||
      [hints containsFormat:kBarcodeFormatRSSExpanded];
    if (addZXOneDReader && !tryHarder) {
#if defined(VZZXINGOBJC_ONED) || !defined(VZZXINGOBJC_USE_SUBSPECS)
      [self.readers addObject:[[VZZXMultiFormatOneDReader alloc] initWithHints:hints]];
#endif
    }
#if defined(VZZXINGOBJC_QRCODE) || !defined(VZZXINGOBJC_USE_SUBSPECS)
    if ([hints containsFormat:kBarcodeFormatQRCode]) {
      [self.readers addObject:[[VZZXQRCodeReader alloc] init]];
    }
#endif
#if defined(VZZXINGOBJC_DATAMATRIX) || !defined(VZZXINGOBJC_USE_SUBSPECS)
    if ([hints containsFormat:kBarcodeFormatDataMatrix]) {
      [self.readers addObject:[[VZZXDataMatrixReader alloc] init]];
    }
#endif
#if defined(VZZXINGOBJC_AZTEC) || !defined(VZZXINGOBJC_USE_SUBSPECS)
    if ([hints containsFormat:kBarcodeFormatAztec]) {
      [self.readers addObject:[[VZZXAztecReader alloc] init]];
    }
#endif
#if defined(VZZXINGOBJC_PDF417) || !defined(VZZXINGOBJC_USE_SUBSPECS)
    if ([hints containsFormat:kBarcodeFormatPDF417]) {
      [self.readers addObject:[[VZZXPDF417Reader alloc] init]];
    }
#endif
#if defined(VZZXINGOBJC_MAXICODE) || !defined(VZZXINGOBJC_USE_SUBSPECS)
    if ([hints containsFormat:kBarcodeFormatMaxiCode]) {
      [self.readers addObject:[[VZZXMaxiCodeReader alloc] init]];
    }
#endif
#if defined(VZZXINGOBJC_ONED) || !defined(VZZXINGOBJC_USE_SUBSPECS)
    if (addZXOneDReader && tryHarder) {
      [self.readers addObject:[[VZZXMultiFormatOneDReader alloc] initWithHints:hints]];
    }
#endif
  }
  if ([self.readers count] == 0) {
    if (!tryHarder) {
#if defined(VZZXINGOBJC_ONED) || !defined(VZZXINGOBJC_USE_SUBSPECS)
      [self.readers addObject:[[VZZXMultiFormatOneDReader alloc] initWithHints:hints]];
#endif
    }
#if defined(VZZXINGOBJC_QRCODE) || !defined(VZZXINGOBJC_USE_SUBSPECS)
    [self.readers addObject:[[VZZXQRCodeReader alloc] init]];
#endif
#if defined(VZZXINGOBJC_DATAMATRIX) || !defined(VZZXINGOBJC_USE_SUBSPECS)
    [self.readers addObject:[[VZZXDataMatrixReader alloc] init]];
#endif
#if defined(VZZXINGOBJC_AZTEC) || !defined(VZZXINGOBJC_USE_SUBSPECS)
    [self.readers addObject:[[VZZXAztecReader alloc] init]];
#endif
#if defined(VZZXINGOBJC_PDF417) || !defined(VZZXINGOBJC_USE_SUBSPECS)
    [self.readers addObject:[[VZZXPDF417Reader alloc] init]];
#endif
#if defined(VZZXINGOBJC_MAXICODE) || !defined(VZZXINGOBJC_USE_SUBSPECS)
    [self.readers addObject:[[VZZXMaxiCodeReader alloc] init]];
#endif
    if (tryHarder) {
#if defined(VZZXINGOBJC_ONED) || !defined(VZZXINGOBJC_USE_SUBSPECS)
      [self.readers addObject:[[VZZXMultiFormatOneDReader alloc] initWithHints:hints]];
#endif
    }
  }
}

- (void)reset {
  if (self.readers != nil) {
    for (id<VZZXReader> reader in self.readers) {
      [reader reset];
    }
  }
}

- (VZZXResult *)decodeInternal:(VZZXBinaryBitmap *)image error:(NSError **)error {
  if (self.readers != nil) {
    for (id<VZZXReader> reader in self.readers) {
      VZZXResult *result = [reader decode:image hints:self.hints error:nil];
      if (result) {
        return result;
      }
    }
  }

  if (error) *error = VZZXNotFoundErrorInstance();
  return nil;
}

@end
