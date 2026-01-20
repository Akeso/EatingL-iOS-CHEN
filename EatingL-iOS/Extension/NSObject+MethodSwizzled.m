//
//  NSObject+MethodSwizzled.m
//
//  Copyright © 2018年 liuming. All rights reserved.
//

#import "NSObject+MethodSwizzled.h"
#import <objc/runtime.h>

@implementation NSObject (MethodSwizzled)

+ (BOOL)methodSwizzlingWithOriginSEL:(SEL)originSEL swizzledSEL:(SEL)swizzledSEL {
    Class class = [self class];
    
    Method originMethod = class_getInstanceMethod(class, originSEL);
    Method swizzleMethod = class_getInstanceMethod(class, swizzledSEL);
    if (!originMethod || !swizzleMethod) return NO;
    
    BOOL isAdd = class_addMethod(class, originSEL,
                                 method_getImplementation(swizzleMethod),
                                 method_getTypeEncoding(swizzleMethod));
    if (isAdd) {
        class_replaceMethod(class, swizzledSEL,
                            method_getImplementation(originMethod),
                            method_getTypeEncoding(originMethod));
    } else {
        method_exchangeImplementations(originMethod, swizzleMethod);
    }
    
    return YES;
}

@end
