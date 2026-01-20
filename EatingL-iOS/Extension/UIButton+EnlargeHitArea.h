//
//  UIButton+EnlargeHitArea.h
//
//  Copyright © 2018 liuming. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (EnlargeHitArea)

/// 扩大点击相应区域.
/// - Note: 传入参数均为负值 {-10, -10, -10, -10}.
@property(nonatomic, assign) UIEdgeInsets enlargeEdgeInsets;

@end

NS_ASSUME_NONNULL_END
