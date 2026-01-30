/*
 * Copyright 2014 ZXing authors
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

#ifndef _VZZXINGOBJC_ONED_

#define _VZZXINGOBJC_ONED_

// OneD

#import "VZZXAbstractExpandedDecoder.h"
#import "VZZXAbstractRSSReader.h"
#import "VZZXCodaBarReader.h"
#import "VZZXCodaBarWriter.h"
#import "VZZXCode128Reader.h"
#import "VZZXCode128Writer.h"
#import "VZZXCode39Reader.h"
#import "VZZXCode39Writer.h"
#import "VZZXCode93Reader.h"
#import "VZZXEAN13Reader.h"
#import "VZZXEAN13Writer.h"
#import "VZZXEAN8Reader.h"
#import "VZZXEAN8Writer.h"
#import "VZZXITFReader.h"
#import "VZZXITFWriter.h"
#import "VZZXMultiFormatOneDReader.h"
#import "VZZXMultiFormatUPCEANReader.h"
#import "VZZXOneDimensionalCodeWriter.h"
#import "VZZXOneDReader.h"
#import "VZZXRSS14Reader.h"
#import "VZZXRSSDataCharacter.h"
#import "VZZXRSSExpandedReader.h"
#import "VZZXRSSFinderPattern.h"
#import "VZZXRSSUtils.h"
#import "VZZXUPCAReader.h"
#import "VZZXUPCAWriter.h"
#import "VZZXUPCEANReader.h"
#import "VZZXUPCEANWriter.h"
#import "VZZXUPCEReader.h"
#import "VZZXUPCEWriter.h"

// Result Parsers

#import "VZZXAddressBookAUResultParser.h"
#import "VZZXAddressBookDoCoMoResultParser.h"
#import "VZZXAddressBookParsedResult.h"
#import "VZZXBizcardResultParser.h"
#import "VZZXBookmarkDoCoMoResultParser.h"
#import "VZZXCalendarParsedResult.h"
#import "VZZXEmailAddressParsedResult.h"
#import "VZZXEmailAddressResultParser.h"
#import "VZZXEmailDoCoMoResultParser.h"
#import "VZZXExpandedProductParsedResult.h"
#import "VZZXExpandedProductResultParser.h"
#import "VZZXGeoParsedResult.h"
#import "VZZXGeoResultParser.h"
#import "VZZXISBNParsedResult.h"
#import "VZZXISBNResultParser.h"
#import "VZZXParsedResult.h"
#import "VZZXParsedResultType.h"
#import "VZZXProductParsedResult.h"
#import "VZZXProductResultParser.h"
#import "VZZXResultParser.h"
#import "VZZXSMSMMSResultParser.h"
#import "VZZXSMSParsedResult.h"
#import "VZZXSMSTOMMSTOResultParser.h"
#import "VZZXSMTPResultParser.h"
#import "VZZXTelParsedResult.h"
#import "VZZXTelResultParser.h"
#import "VZZXTextParsedResult.h"
#import "VZZXURIParsedResult.h"
#import "VZZXURIResultParser.h"
#import "VZZXURLTOResultParser.h"
#import "VZZXVCardResultParser.h"
#import "VZZXVEventResultParser.h"
#import "VZZXVINParsedResult.h"
#import "VZZXVINResultParser.h"
#import "VZZXWifiParsedResult.h"
#import "VZZXWifiResultParser.h"

#endif
