//
//  UIButton+EnlargeHitArea.m
//
//  Copyright © 2018 liuming. All rights reserved.
//

#import "UIButton+EnlargeHitArea.h"
#import "NSObject+MethodSwizzled.h"
#import <objc/runtime.h>

static void *enlargeEdgeInsetsKey = &enlargeEdgeInsetsKey;

@implementation UIButton (EnlargeHitArea)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originSEL = @selector(pointInside:withEvent:);
        SEL swizzleSEL = @selector(EnlargeHitArea_pointInside:withEvent:);
        [self methodSwizzlingWithOriginSEL:originSEL swizzledSEL:swizzleSEL];
    });
}

- (BOOL)EnlargeHitArea_pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (([self isKindOfClass: [UIButton class]]
         && !UIEdgeInsetsEqualToEdgeInsets(self.enlargeEdgeInsets, UIEdgeInsetsZero))
        && self.enabled && self.userInteractionEnabled
        && !self.hidden && self.alpha > .01f) {
        CGRect relativeFrame = self.bounds;
        CGRect hitFrame = UIEdgeInsetsInsetRect(relativeFrame, self.enlargeEdgeInsets);
        
        return CGRectContainsPoint(hitFrame, point);
    }
    return [self EnlargeHitArea_pointInside:point withEvent:event];
}

- (void)setEnlargeEdgeInsets:(UIEdgeInsets)enlargeEdgeInsets {
    NSValue *value = [NSValue value:&enlargeEdgeInsets withObjCType:@encode(UIEdgeInsets)];
    objc_setAssociatedObject(self, &enlargeEdgeInsetsKey, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIEdgeInsets)enlargeEdgeInsets {
    NSValue *value = objc_getAssociatedObject(self, &enlargeEdgeInsetsKey);
    if (value) {
        UIEdgeInsets edgeInsets;
        [value getValue:&edgeInsets];
        return edgeInsets;
    } else {
        return UIEdgeInsetsZero;
    }
}

@end
