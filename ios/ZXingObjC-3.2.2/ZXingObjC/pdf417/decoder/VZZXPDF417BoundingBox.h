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

@class VZZXBitMatrix, VZZXResultPoint;

@interface VZZXPDF417BoundingBox : NSObject

@property (nonatomic, assign, readonly) int minX;
@property (nonatomic, assign, readonly) int maxX;
@property (nonatomic, assign, readonly) int minY;
@property (nonatomic, assign, readonly) int maxY;
@property (nonatomic, strong, readonly) VZZXResultPoint *topLeft;
@property (nonatomic, strong, readonly) VZZXResultPoint *topRight;
@property (nonatomic, strong, readonly) VZZXResultPoint *bottomLeft;
@property (nonatomic, strong, readonly) VZZXResultPoint *bottomRight;

- (id)initWithImage:(VZZXBitMatrix *)image topLeft:(VZZXResultPoint *)topLeft bottomLeft:(VZZXResultPoint *)bottomLeft
           topRight:(VZZXResultPoint *)topRight bottomRight:(VZZXResultPoint *)bottomRight;
- (id)initWithBoundingBox:(VZZXPDF417BoundingBox *)boundingBox;

+ (VZZXPDF417BoundingBox *)mergeLeftBox:(VZZXPDF417BoundingBox *)leftBox rightBox:(VZZXPDF417BoundingBox *)rightBox;
- (VZZXPDF417BoundingBox *)addMissingRows:(int)missingStartRows missingEndRows:(int)missingEndRows isLeft:(BOOL)isLeft;

@end
