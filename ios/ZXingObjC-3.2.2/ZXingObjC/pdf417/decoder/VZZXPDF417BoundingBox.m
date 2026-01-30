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

#import "VZZXBitMatrix.h"
#import "VZZXPDF417BoundingBox.h"
#import "VZZXResultPoint.h"

@interface VZZXPDF417BoundingBox ()

@property (nonatomic, strong, readonly) VZZXBitMatrix *image;
@property (nonatomic, assign) int minX;
@property (nonatomic, assign) int maxX;
@property (nonatomic, assign) int minY;
@property (nonatomic, assign) int maxY;

@end

@implementation VZZXPDF417BoundingBox

- (id)initWithImage:(VZZXBitMatrix *)image topLeft:(VZZXResultPoint *)topLeft bottomLeft:(VZZXResultPoint *)bottomLeft
           topRight:(VZZXResultPoint *)topRight bottomRight:(VZZXResultPoint *)bottomRight {
  if ((!topLeft && !topRight) || (!bottomLeft && !bottomRight) ||
      (topLeft && !bottomLeft) || (topRight && !bottomRight)) {
    return nil;
  }

  self = [super init];
  if (self) {
    _image = image;
    _topLeft = topLeft;
    _bottomLeft = bottomLeft;
    _topRight = topRight;
    _bottomRight = bottomRight;
    [self calculateMinMaxValues];
  }

  return self;
}

- (id)initWithBoundingBox:(VZZXPDF417BoundingBox *)boundingBox {
  return [self initWithImage:boundingBox.image topLeft:boundingBox.topLeft bottomLeft:boundingBox.bottomLeft
                    topRight:boundingBox.topRight bottomRight:boundingBox.bottomRight];
}

+ (VZZXPDF417BoundingBox *)mergeLeftBox:(VZZXPDF417BoundingBox *)leftBox rightBox:(VZZXPDF417BoundingBox *)rightBox {
  if (!leftBox) {
    return rightBox;
  }
  if (!rightBox) {
    return leftBox;
  }
  return [[self alloc] initWithImage:leftBox.image topLeft:leftBox.topLeft bottomLeft:leftBox.bottomLeft
                            topRight:rightBox.topRight bottomRight:rightBox.bottomRight];
}

- (VZZXPDF417BoundingBox *)addMissingRows:(int)missingStartRows missingEndRows:(int)missingEndRows isLeft:(BOOL)isLeft {
  VZZXResultPoint *newTopLeft = self.topLeft;
  VZZXResultPoint *newBottomLeft = self.bottomLeft;
  VZZXResultPoint *newTopRight = self.topRight;
  VZZXResultPoint *newBottomRight = self.bottomRight;

  if (missingStartRows > 0) {
    VZZXResultPoint *top = isLeft ? self.topLeft : self.topRight;
    int newMinY = (int) top.y - missingStartRows;
    if (newMinY < 0) {
      newMinY = 0;
    }
    // TODO use existing points to better interpolate the new x positions
    VZZXResultPoint *newTop = [[VZZXResultPoint alloc] initWithX:top.x y:newMinY];
    if (isLeft) {
      newTopLeft = newTop;
    } else {
      newTopRight = newTop;
    }
  }

  if (missingEndRows > 0) {
    VZZXResultPoint *bottom = isLeft ? self.bottomLeft : self.bottomRight;
    int newMaxY = (int) bottom.y + missingEndRows;
    if (newMaxY >= self.image.height) {
      newMaxY = self.image.height - 1;
    }
    // TODO use existing points to better interpolate the new x positions
    VZZXResultPoint *newBottom = [[VZZXResultPoint alloc] initWithX:bottom.x y:newMaxY];
    if (isLeft) {
      newBottomLeft = newBottom;
    } else {
      newBottomRight = newBottom;
    }
  }
  [self calculateMinMaxValues];
  return [[VZZXPDF417BoundingBox alloc] initWithImage:self.image topLeft:newTopLeft bottomLeft:newBottomLeft topRight:newTopRight bottomRight:newBottomRight];
}

- (void)calculateMinMaxValues {
  if (!self.topLeft) {
    _topLeft = [[VZZXResultPoint alloc] initWithX:0 y:self.topRight.y];
    _bottomLeft = [[VZZXResultPoint alloc] initWithX:0 y:self.bottomRight.y];
  } else if (!self.topRight) {
    _topRight = [[VZZXResultPoint alloc] initWithX:self.image.width - 1 y:self.topLeft.y];
    _bottomRight = [[VZZXResultPoint alloc] initWithX:self.image.width - 1 y:self.bottomLeft.y];
  }

  self.minX = (int) MIN(self.topLeft.x, self.bottomLeft.x);
  self.maxX = (int) MAX(self.topRight.x, self.bottomRight.x);
  self.minY = (int) MIN(self.topLeft.y, self.topRight.y);
  self.maxY = (int) MAX(self.bottomLeft.y, self.bottomRight.y);
}

/*
- (void)setTopRight:(VZZXResultPoint *)topRight {
  _topRight = topRight;
  [self calculateMinMaxValues];
}

- (void)setBottomRight:(VZZXResultPoint *)bottomRight {
  _bottomRight = bottomRight;
  [self calculateMinMaxValues];
}
*/

@end
