//
//  ScrollViewController.h
//  CloudVideo
//
//  Created by issuser on 2017/3/30.
//  Copyright © 2017年 ChinaMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ScrollViewController;

@protocol ScrollViewControllerDelegate
- (void)scrollViewController:(ScrollViewController *)scrollViewController didSelectViewControllerAtIndex:(NSUInteger)index;
@end


@interface ScrollViewController : UIViewController

/**
 是否支持UIViewController间的滑动切换，默认是YES。当和其它手势冲突时建议设置成NO，此时只能通过点击按钮切换
 */
@property (assign, nonatomic) BOOL supportSlidingGesture;

/**
 获取当前被选择的索引
 */
@property (assign, nonatomic, readonly) NSInteger selectedIndex;

/**
 获取当前被选择的视图控制器
 */
@property (weak, nonatomic, readonly) UIViewController *selectedViewController;

/**
 设置代理

 @param delegate 代理
 */
- (void)setScrollViewControllerDelegate:(id<ScrollViewControllerDelegate>)delegate;

/**
 设置显示的UIViewController数组及初始显示索引，[viewController title]将作为按钮名字

 @param viewControllers 视图控制器数组
 @param index 初始显示索引
 */
- (void)setViewControllers:(NSArray <__kindof UIViewController *> *)viewControllers selectedIndex:(NSUInteger)index;

/**
 设置按钮属性，如果全选默认时可以不调此方法，如果只设置部分为默认时则把对应的设置成nil

 @param height 高度，默认30.0f
 @param font 字体，默认是[UIFont systemFontOfSize:17]
 @param color 字体颜色，默认是黑色
 @param selectedColor 被选中时的颜色，默认是红色
 */
- (void)setButtonsHeight:(CGFloat)height font:(UIFont *)font color:(UIColor *)color selectedColor:(UIColor *)selectedColor;

/**
 获取对应索引的视图控制器
 
 @param index 索引
 @return 视图控制器
 */
- (UIViewController *)viewControllerAtIndex:(NSUInteger)index;

/**
 获取对应索引的标题按钮

 @param index 索引
 @return 标题按钮
 */
- (UIButton *)titleButtonAtIndex:(NSUInteger)index;

@end
