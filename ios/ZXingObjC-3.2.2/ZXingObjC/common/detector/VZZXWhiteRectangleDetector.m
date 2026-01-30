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

#import "VZZXErrors.h"
#import "VZZXMathUtils.h"
#import "VZZXWhiteRectangleDetector.h"

@interface VZZXWhiteRectangleDetector ()

@property (nonatomic, strong, readonly) VZZXBitMatrix *image;
@property (nonatomic, assign, readonly) int height;
@property (nonatomic, assign, readonly) int width;
@property (nonatomic, assign, readonly) int leftInit;
@property (nonatomic, assign, readonly) int rightInit;
@property (nonatomic, assign, readonly) int downInit;
@property (nonatomic, assign, readonly) int upInit;

@end

const int VZZX_INIT_SIZE = 10;
const int VZZX_CORR = 1;

@implementation VZZXWhiteRectangleDetector

- (id)initWithImage:(VZZXBitMatrix *)image error:(NSError **)error {
  return [self initWithImage:image initSize:VZZX_INIT_SIZE x:image.width / 2 y:image.height / 2 error:error];
}

- (id)initWithImage:(VZZXBitMatrix *)image initSize:(int)initSize x:(int)x y:(int)y error:(NSError **)error {
  if (self = [super init]) {
    _image = image;
    _height = image.height;
    _width = image.width;
    int halfsize = initSize / 2;
    _leftInit = x - halfsize;
    _rightInit = x + halfsize;
    _upInit = y - halfsize;
    _downInit = y + halfsize;
    if (_upInit < 0 || _leftInit < 0 || _downInit >= _height || _rightInit >= _width) {
      if (error) *error = VZZXNotFoundErrorInstance();
      return nil;
    }
  }

  return self;
}

- (NSArray *)detectWithError:(NSError **)error {
  int left = self.leftInit;
  int right = self.rightInit;
  int up = self.upInit;
  int down = self.downInit;
  BOOL sizeExceeded = NO;
  BOOL aBlackPointFoundOnBorder = YES;
  BOOL atLeastOneBlackPointFoundOnBorder = NO;

  BOOL atLeastOneBlackPointFoundOnRight = NO;
  BOOL atLeastOneBlackPointFoundOnBottom = NO;
  BOOL atLeastOneBlackPointFoundOnLeft = NO;
  BOOL atLeastOneBlackPointFoundOnTop = NO;

  while (aBlackPointFoundOnBorder) {
    aBlackPointFoundOnBorder = NO;

    // .....
    // .   |
    // .....
    BOOL rightBorderNotWhite = YES;
    while ((rightBorderNotWhite || !atLeastOneBlackPointFoundOnRight) && right < self.width) {
      rightBorderNotWhite = [self containsBlackPoint:up b:down fixed:right horizontal:NO];
      if (rightBorderNotWhite) {
        right++;
        aBlackPointFoundOnBorder = YES;
        atLeastOneBlackPointFoundOnRight = YES;
      } else if (!atLeastOneBlackPointFoundOnRight) {
        right++;
      }
    }

    if (right >= self.width) {
      sizeExceeded = YES;
      break;
    }

    // .....
    // .   .
    // .___.
    BOOL bottomBorderNotWhite = YES;
    while ((bottomBorderNotWhite || !atLeastOneBlackPointFoundOnBottom) && down < self.height) {
      bottomBorderNotWhite = [self containsBlackPoint:left b:right fixed:down horizontal:YES];
      if (bottomBorderNotWhite) {
        down++;
        aBlackPointFoundOnBorder = YES;
        atLeastOneBlackPointFoundOnBottom = YES;
      } else if (!atLeastOneBlackPointFoundOnBottom) {
        down++;
      }
    }

    if (down >= self.height) {
      sizeExceeded = YES;
      break;
    }

    // .....
    // |   .
    // .....
    BOOL leftBorderNotWhite = YES;
    while ((leftBorderNotWhite || !atLeastOneBlackPointFoundOnLeft) && left >= 0) {
      leftBorderNotWhite = [self containsBlackPoint:up b:down fixed:left horizontal:NO];
      if (leftBorderNotWhite) {
        left--;
        aBlackPointFoundOnBorder = YES;
        atLeastOneBlackPointFoundOnLeft = YES;
      } else if (!atLeastOneBlackPointFoundOnLeft) {
        left--;
      }
    }

    if (left < 0) {
      sizeExceeded = YES;
      break;
    }

    // .___.
    // .   .
    // .....
    BOOL topBorderNotWhite = YES;
    while ((topBorderNotWhite  || !atLeastOneBlackPointFoundOnTop) && up >= 0) {
      topBorderNotWhite = [self containsBlackPoint:left b:right fixed:up horizontal:YES];
      if (topBorderNotWhite) {
        up--;
        aBlackPointFoundOnBorder = YES;
        atLeastOneBlackPointFoundOnTop = YES;
      } else if (!atLeastOneBlackPointFoundOnTop) {
        up--;
      }
    }

    if (up < 0) {
      sizeExceeded = YES;
      break;
    }

    if (aBlackPointFoundOnBorder) {
      atLeastOneBlackPointFoundOnBorder = YES;
    }
  }

  if (!sizeExceeded && atLeastOneBlackPointFoundOnBorder) {
    int maxSize = right - left;

    VZZXResultPoint *z = nil;
    for (int i = 1; i < maxSize; i++) {
      z = [self blackPointOnSegment:left aY:down - i bX:left + i bY:down];
      if (z != nil) {
        break;
      }
    }

    if (z == nil) {
      if (error) *error = VZZXNotFoundErrorInstance();
      return nil;
    }

    VZZXResultPoint *t = nil;
    for (int i = 1; i < maxSize; i++) {
      t = [self blackPointOnSegment:left aY:up + i bX:left + i bY:up];
      if (t != nil) {
        break;
      }
    }

    if (t == nil) {
      if (error) *error = VZZXNotFoundErrorInstance();
      return nil;
    }

    VZZXResultPoint *x = nil;
    for (int i = 1; i < maxSize; i++) {
      x = [self blackPointOnSegment:right aY:up + i bX:right - i bY:up];
      if (x != nil) {
        break;
      }
    }

    if (x == nil) {
      if (error) *error = VZZXNotFoundErrorInstance();
      return nil;
    }

    VZZXResultPoint *y = nil;
    for (int i = 1; i < maxSize; i++) {
      y = [self blackPointOnSegment:right aY:down - i bX:right - i bY:down];
      if (y != nil) {
        break;
      }
    }

    if (y == nil) {
      if (error) *error = VZZXNotFoundErrorInstance();
      return nil;
    }
    return [self centerEdges:y z:z x:x t:t];
  } else {
    if (error) *error = VZZXNotFoundErrorInstance();
    return nil;
  }
}


- (VZZXResultPoint *)blackPointOnSegment:(float)aX aY:(float)aY bX:(float)bX bY:(float)bY {
  int dist = [VZZXMathUtils round:[VZZXMathUtils distance:aX aY:aY bX:bX bY:bY]];
  float xStep = (bX - aX) / dist;
  float yStep = (bY - aY) / dist;

  for (int i = 0; i < dist; i++) {
    int x = [VZZXMathUtils round:aX + i * xStep];
    int y = [VZZXMathUtils round:aY + i * yStep];
    if ([self.image getX:x y:y]) {
      return [[VZZXResultPoint alloc] initWithX:x y:y];
    }
  }

  return nil;
}

/**
 * recenters the points of a constant distance towards the center
 *
 * @param y bottom most point
 * @param z left most point
 * @param x right most point
 * @param t top most point
 * @return VZZXResultPoint array describing the corners of the rectangular
 *         region. The first and last points are opposed on the diagonal, as
 *         are the second and third. The first point will be the topmost
 *         point and the last, the bottommost. The second point will be
 *         leftmost and the third, the rightmost
 */
- (NSArray *)centerEdges:(VZZXResultPoint *)y z:(VZZXResultPoint *)z x:(VZZXResultPoint *)x t:(VZZXResultPoint *)t {
  //
  //       t            t
  //  z                      x
  //        x    OR    z
  //   y                    y
  //

  float yi = y.x;
  float yj = y.y;
  float zi = z.x;
  float zj = z.y;
  float xi = x.x;
  float xj = x.y;
  float ti = t.x;
  float tj = t.y;

  if (yi < self.width / 2.0f) {
    return @[[[VZZXResultPoint alloc] initWithX:ti - VZZX_CORR y:tj + VZZX_CORR],
             [[VZZXResultPoint alloc] initWithX:zi + VZZX_CORR y:zj + VZZX_CORR],
             [[VZZXResultPoint alloc] initWithX:xi - VZZX_CORR y:xj - VZZX_CORR],
             [[VZZXResultPoint alloc] initWithX:yi + VZZX_CORR y:yj - VZZX_CORR]];
  } else {
    return @[[[VZZXResultPoint alloc] initWithX:ti + VZZX_CORR y:tj + VZZX_CORR],
             [[VZZXResultPoint alloc] initWithX:zi + VZZX_CORR y:zj - VZZX_CORR],
             [[VZZXResultPoint alloc] initWithX:xi - VZZX_CORR y:xj + VZZX_CORR],
             [[VZZXResultPoint alloc] initWithX:yi - VZZX_CORR y:yj - VZZX_CORR]];
  }
}

/**
 * Determines whether a segment contains a black point
 *
 * @param a          min value of the scanned coordinate
 * @param b          max value of the scanned coordinate
 * @param fixed      value of fixed coordinate
 * @param horizontal set to true if scan must be horizontal, false if vertical
 * @return true if a black point has been found, else false.
 */
- (BOOL)containsBlackPoint:(int)a b:(int)b fixed:(int)fixed horizontal:(BOOL)horizontal {
  if (horizontal) {
    for (int x = a; x <= b; x++) {
      if ([self.image getX:x y:fixed]) {
        return YES;
      }
    }
  } else {
    for (int y = a; y <= b; y++) {
      if ([self.image getX:fixed y:y]) {
        return YES;
      }
    }
  }

  return NO;
}

@end
