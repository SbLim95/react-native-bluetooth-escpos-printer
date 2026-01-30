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

@class VZZXIntArray, VZZXModulusGF;

@interface VZZXModulusPoly : NSObject

- (id)initWithField:(VZZXModulusGF *)field coefficients:(VZZXIntArray *)coefficients;
- (int)degree;
- (BOOL)zero;
- (int)coefficient:(int)degree;
- (int)evaluateAt:(int)a;
- (VZZXModulusPoly *)add:(VZZXModulusPoly *)other;
- (VZZXModulusPoly *)subtract:(VZZXModulusPoly *)other;
- (VZZXModulusPoly *)multiply:(VZZXModulusPoly *)other;
- (VZZXModulusPoly *)negative;
- (VZZXModulusPoly *)multiplyScalar:(int)scalar;
- (VZZXModulusPoly *)multiplyByMonomial:(int)degree coefficient:(int)coefficient;
- (NSArray *)divide:(VZZXModulusPoly *)other;

@end
