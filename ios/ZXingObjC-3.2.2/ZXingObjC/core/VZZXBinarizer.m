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

#import "VZZXBinarizer.h"

#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
#import <UIKit/UIKit.h>
#define VZZXBlack [[UIColor blackColor] CGColor]
#define VZZXWhite [[UIColor whiteColor] CGColor]
#else
#define VZZXBlack CGColorGetConstantColor(kCGColorBlack)
#define VZZXWhite CGColorGetConstantColor(kCGColorWhite)
#endif

@implementation VZZXBinarizer

- (id)initWithSource:(VZZXLuminanceSource *)source {
  if (self = [super init]) {
    _luminanceSource = source;
  }

  return self;
}

- (id)initWithLuminanceSource:(VZZXLuminanceSource *)source {
  return [self initWithSource:source];
}

+ (id)binarizerWithSource:(VZZXLuminanceSource *)source {
  return [[self alloc] initWithLuminanceSource:source];
}

- (VZZXBitArray *)blackRow:(int)y row:(VZZXBitArray *)row error:(NSError **)error {
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                               userInfo:nil];
}


- (VZZXBitMatrix *)blackMatrixWithError:(NSError **)error {
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                               userInfo:nil];
}

- (VZZXBinarizer *)createBinarizer:(VZZXLuminanceSource *)source {
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                               userInfo:nil];
}

- (CGImageRef)createImage CF_RETURNS_RETAINED {
  VZZXBitMatrix *matrix = [self blackMatrixWithError:nil];
  if (!matrix) {
    return nil;
  }
  VZZXLuminanceSource *source = [self luminanceSource];

  int width = source.width;
  int height = source.height;

  int bytesPerRow = ((width&0xf)>>4)<<4;

  CGColorSpaceRef gray = CGColorSpaceCreateDeviceGray();
  CGContextRef context = CGBitmapContextCreate (
                                                0,
                                                width,
                                                height,
                                                8,      // bits per component
                                                bytesPerRow,
                                                gray,
                                                kCGBitmapAlphaInfoMask & kCGImageAlphaNone);
  CGColorSpaceRelease(gray);

  CGRect r = CGRectZero;
  r.size.width = width;
  r.size.height = height;
  CGContextSetFillColorWithColor(context, VZZXBlack);
  CGContextFillRect(context, r);

  r.size.width = 1;
  r.size.height = 1;

  CGContextSetFillColorWithColor(context, VZZXWhite);
  for (int y=0; y<height; y++) {
    r.origin.y = height-1-y;
    for (int x=0; x<width; x++) {
      if (![matrix getX:x y:y]) {
        r.origin.x = x;
        CGContextFillRect(context, r);
      }
    }
  }

  CGImageRef binary = CGBitmapContextCreateImage(context);

  CGContextRelease(context);

  return binary;
}

- (int)width {
  return self.luminanceSource.width;
}

- (int)height {
  return self.luminanceSource.height;
}

@end
