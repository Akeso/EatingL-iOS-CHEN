//
//  NSObject+MethodSwizzled.h
//
//  Copyright © 2018年 liuming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (MethodSwizzled)

/**
 方法交换
 */
+ (BOOL)methodSwizzlingWithOriginSEL:(SEL)originSEL swizzledSEL:(SEL)swizzledSEL;

@end
