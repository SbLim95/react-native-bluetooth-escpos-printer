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

@class VZZXBitMatrix, VZZXDetectorResult, VZZXWhiteRectangleDetector;

/**
 * Encapsulates logic that can detect a Data Matrix Code in an image, even if the Data Matrix Code
 * is rotated or skewed, or partially obscured.
 */
@interface VZZXDataMatrixDetector : NSObject

- (id)initWithImage:(VZZXBitMatrix *)image error:(NSError **)error;

/**
 * Detects a Data Matrix Code in an image.
 *
 * @return VZZXDetectorResult encapsulating results of detecting a Data Matrix Code or nil
 *  if no Data Matrix Code can be found
 */
- (VZZXDetectorResult *)detectWithError:(NSError **)error;

@end
