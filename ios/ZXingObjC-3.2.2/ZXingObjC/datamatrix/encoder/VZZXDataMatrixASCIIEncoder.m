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

#import "VZZXDataMatrixASCIIEncoder.h"
#import "VZZXDataMatrixEncoderContext.h"
#import "VZZXDataMatrixHighLevelEncoder.h"

@implementation VZZXDataMatrixASCIIEncoder

- (int)encodingMode {
  return [VZZXDataMatrixHighLevelEncoder asciiEncodation];
}

- (void)encode:(VZZXDataMatrixEncoderContext *)context {
  //step B
  int n = [VZZXDataMatrixHighLevelEncoder determineConsecutiveDigitCount:context.message startpos:context.pos];
  if (n >= 2) {
    [context writeCodeword:[self encodeASCIIDigits:[context.message characterAtIndex:context.pos]
                                            digit2:[context.message characterAtIndex:context.pos + 1]]];
    context.pos += 2;
  } else {
    unichar c = [context currentChar];
    int newMode = [VZZXDataMatrixHighLevelEncoder lookAheadTest:context.message startpos:context.pos currentMode:[self encodingMode]];
    if (newMode != [self encodingMode]) {
      if (newMode == [VZZXDataMatrixHighLevelEncoder base256Encodation]) {
        [context writeCodeword:[VZZXDataMatrixHighLevelEncoder latchToBase256]];
        [context signalEncoderChange:[VZZXDataMatrixHighLevelEncoder base256Encodation]];
        return;
      } else if (newMode == [VZZXDataMatrixHighLevelEncoder c40Encodation]) {
        [context writeCodeword:[VZZXDataMatrixHighLevelEncoder latchToC40]];
        [context signalEncoderChange:[VZZXDataMatrixHighLevelEncoder c40Encodation]];
        return;
      } else if (newMode == [VZZXDataMatrixHighLevelEncoder x12Encodation]) {
        [context writeCodeword:[VZZXDataMatrixHighLevelEncoder latchToAnsiX12]];
        [context signalEncoderChange:[VZZXDataMatrixHighLevelEncoder x12Encodation]];
      } else if (newMode == [VZZXDataMatrixHighLevelEncoder textEncodation]) {
        [context writeCodeword:[VZZXDataMatrixHighLevelEncoder latchToText]];
        [context signalEncoderChange:[VZZXDataMatrixHighLevelEncoder textEncodation]];
      } else if (newMode == [VZZXDataMatrixHighLevelEncoder edifactEncodation]) {
        [context writeCodeword:[VZZXDataMatrixHighLevelEncoder latchToEdifact]];
        [context signalEncoderChange:[VZZXDataMatrixHighLevelEncoder edifactEncodation]];
      } else {
        @throw [NSException exceptionWithName:@"IllegalStateException" reason:@"Illegal mode" userInfo:nil];
      }
    } else if ([VZZXDataMatrixHighLevelEncoder isExtendedASCII:c]) {
      [context writeCodeword:[VZZXDataMatrixHighLevelEncoder upperShift]];
      [context writeCodeword:(unichar)(c - 128 + 1)];
      context.pos++;
    } else {
      [context writeCodeword:(unichar)(c + 1)];
      context.pos++;
    }
  }
}

- (unichar)encodeASCIIDigits:(unichar)digit1 digit2:(unichar)digit2 {
  if ([VZZXDataMatrixHighLevelEncoder isDigit:digit1] && [VZZXDataMatrixHighLevelEncoder isDigit:digit2]) {
    int num = (digit1 - 48) * 10 + (digit2 - 48);
    return (unichar) (num + 130);
  }
  @throw [NSException exceptionWithName:NSInvalidArgumentException
                                 reason:[NSString stringWithFormat:@"not digits: %C %C", digit1, digit2]
                               userInfo:nil];
}

@end
