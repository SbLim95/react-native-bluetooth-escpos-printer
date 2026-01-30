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

@class VZZXBitArray, VZZXByteArray, VZZXEncodeHints, VZZXQRCode, VZZXQRCodeErrorCorrectionLevel, VZZXQRCodeMode, VZZXQRCodeVersion;

extern const NSStringEncoding VZZX_DEFAULT_BYTE_MODE_ENCODING;

@interface VZZXQRCodeEncoder : NSObject

/**
 * Encode "bytes" with the error correction level "ecLevel". The encoding mode will be chosen
 * internally by chooseMode:. On success, store the result in "qrCode".
 *
 * We recommend you to use QRCode.EC_LEVEL_L (the lowest level) for
 * "getECLevel" since our primary use is to show QR code on desktop screens. We don't need very
 * strong error correction for this purpose.
 *
 * Note that there is no way to encode bytes in MODE_KANJI. We might want to add EncodeWithMode()
 * with which clients can specify the encoding mode. For now, we don't need the functionality.
 */
+ (VZZXQRCode *)encode:(NSString *)content ecLevel:(VZZXQRCodeErrorCorrectionLevel *)ecLevel error:(NSError **)error;

+ (VZZXQRCode *)encode:(NSString *)content ecLevel:(VZZXQRCodeErrorCorrectionLevel *)ecLevel hints:(VZZXEncodeHints *)hints error:(NSError **)error;

/**
 * Return the code point of the table used in alphanumeric mode or
 * -1 if there is no corresponding code in the table.
 */
+ (int)alphanumericCode:(int)code;

/**
 * Terminate bits as described in 8.4.8 and 8.4.9 of JISX0510:2004 (p.24).
 */
+ (BOOL)terminateBits:(int)numDataBytes bits:(VZZXBitArray *)bits error:(NSError **)error;

/**
 * Get number of data bytes and number of error correction bytes for block id "blockID". Store
 * the result in "numDataBytesInBlock", and "numECBytesInBlock". See table 12 in 8.5.1 of
 * JISX0510:2004 (p.30)
 */
+ (BOOL)numDataBytesAndNumECBytesForBlockID:(int)numTotalBytes numDataBytes:(int)numDataBytes numRSBlocks:(int)numRSBlocks blockID:(int)blockID numDataBytesInBlock:(int[])numDataBytesInBlock numECBytesInBlock:(int[])numECBytesInBlock error:(NSError **)error;

/**
 * Interleave "bits" with corresponding error correction bytes. On success, store the result in
 * "result". The interleave rule is complicated. See 8.6 of JISX0510:2004 (p.37) for details.
 */
+ (VZZXBitArray *)interleaveWithECBytes:(VZZXBitArray *)bits numTotalBytes:(int)numTotalBytes numDataBytes:(int)numDataBytes numRSBlocks:(int)numRSBlocks error:(NSError **)error;

+ (VZZXByteArray *)generateECBytes:(VZZXByteArray *)dataBytes numEcBytesInBlock:(int)numEcBytesInBlock;

/**
 * Append mode info. On success, store the result in "bits".
 */
+ (void)appendModeInfo:(VZZXQRCodeMode *)mode bits:(VZZXBitArray *)bits;

/**
 * Append length info. On success, store the result in "bits".
 */
+ (BOOL)appendLengthInfo:(int)numLetters version:(VZZXQRCodeVersion *)version mode:(VZZXQRCodeMode *)mode bits:(VZZXBitArray *)bits error:(NSError **)error;

/**
 * Append "bytes" in "mode" mode (encoding) into "bits". On success, store the result in "bits".
 */
+ (BOOL)appendBytes:(NSString *)content mode:(VZZXQRCodeMode *)mode bits:(VZZXBitArray *)bits encoding:(NSStringEncoding)encoding error:(NSError **)error;

+ (void)appendNumericBytes:(NSString *)content bits:(VZZXBitArray *)bits;

+ (BOOL)appendAlphanumericBytes:(NSString *)content bits:(VZZXBitArray *)bits error:(NSError **)error;

+ (void)append8BitBytes:(NSString *)content bits:(VZZXBitArray *)bits encoding:(NSStringEncoding)encoding;

+ (BOOL)appendKanjiBytes:(NSString *)content bits:(VZZXBitArray *)bits error:(NSError **)error;

@end
