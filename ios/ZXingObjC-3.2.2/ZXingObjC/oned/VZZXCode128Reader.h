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

#import "VZZXOneDReader.h"

extern const int VZZX_CODE128_CODE_PATTERNS[][7];

extern const int VZZX_CODE128_CODE_START_B;
extern const int VZZX_CODE128_CODE_START_C;
extern const int VZZX_CODE128_CODE_CODE_B;
extern const int VZZX_CODE128_CODE_CODE_C;
extern const int VZZX_CODE128_CODE_STOP;

extern const int VZZX_CODE128_CODE_FNC_1;
extern const int VZZX_CODE128_CODE_FNC_2;
extern const int VZZX_CODE128_CODE_FNC_3;
extern const int VZZX_CODE128_CODE_FNC_4_A;
extern const int VZZX_CODE128_CODE_FNC_4_B;

@class VZZXDecodeHints, VZZXResult;

/**
 * Decodes Code 128 barcodes.
 */
@interface VZZXCode128Reader : VZZXOneDReader

@end
