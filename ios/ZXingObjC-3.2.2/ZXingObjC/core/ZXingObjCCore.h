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

#ifndef _VZZXINGOBJC_CORE_

#define _VZZXINGOBJC_CORE_

// Client
#import "VZZXCapture.h"
#import "VZZXCaptureDelegate.h"
#import "VZZXCGImageLuminanceSource.h"
#import "VZZXImage.h"

// Common
#import "VZZXBitArray.h"
#import "VZZXBitMatrix.h"
#import "VZZXBitSource.h"
#import "VZZXBoolArray.h"
#import "VZZXByteArray.h"
#import "VZZXCharacterSetECI.h"
#import "VZZXDecoderResult.h"
#import "VZZXDefaultGridSampler.h"
#import "VZZXDetectorResult.h"
#import "VZZXGenericGF.h"
#import "VZZXGlobalHistogramBinarizer.h"
#import "VZZXGridSampler.h"
#import "VZZXHybridBinarizer.h"
#import "VZZXIntArray.h"
#import "VZZXMathUtils.h"
#import "VZZXMonochromeRectangleDetector.h"
#import "VZZXPerspectiveTransform.h"
#import "VZZXReedSolomonDecoder.h"
#import "VZZXReedSolomonEncoder.h"
#import "VZZXStringUtils.h"
#import "VZZXWhiteRectangleDetector.h"

// Core
#import "VZZXBarcodeFormat.h"
#import "VZZXBinarizer.h"
#import "VZZXBinaryBitmap.h"
#import "VZZXByteMatrix.h"
#import "VZZXDecodeHints.h"
#import "VZZXDimension.h"
#import "VZZXEncodeHints.h"
#import "VZZXErrors.h"
#import "VZZXInvertedLuminanceSource.h"
#import "VZZXLuminanceSource.h"
#import "VZZXPlanarYUVLuminanceSource.h"
#import "VZZXReader.h"
#import "VZZXResult.h"
#import "VZZXResultMetadataType.h"
#import "VZZXResultPoint.h"
#import "VZZXResultPointCallback.h"
#import "VZZXRGBLuminanceSource.h"
#import "VZZXWriter.h"

// Multi
#import "VZZXByQuadrantReader.h"
#import "VZZXGenericMultipleBarcodeReader.h"
#import "VZZXMultipleBarcodeReader.h"

#endif
