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

#import <Foundation/Foundation.h>

#ifndef _VZZXINGOBJC_

#define _VZZXINGOBJC_

#import "ZXingObjCCore.h"

#if defined(VZZXINGOBJC_AZTEC) || !defined(VZZXINGOBJC_USE_SUBSPECS)
#import "ZXingObjCAztec.h"
#endif
#if defined(VZZXINGOBJC_DATAMATRIX) || !defined(VZZXINGOBJC_USE_SUBSPECS)
#import "ZXingObjCDataMatrix.h"
#endif
#if defined(VZZXINGOBJC_MAXICODE) || !defined(VZZXINGOBJC_USE_SUBSPECS)
#import "ZXingObjCMaxiCode.h"
#endif
#if defined(VZZXINGOBJC_ONED) || !defined(VZZXINGOBJC_USE_SUBSPECS)
#import "ZXingObjCOneD.h"
#endif
#if defined(VZZXINGOBJC_PDF417) || !defined(VZZXINGOBJC_USE_SUBSPECS)
#import "ZXingObjCPDF417.h"
#endif
#if defined(VZZXINGOBJC_QRCODE) || !defined(VZZXINGOBJC_USE_SUBSPECS)
#import "ZXingObjCQRCode.h"
#endif

#import "VZZXMultiFormatReader.h"
#import "VZZXMultiFormatWriter.h"

#endif
