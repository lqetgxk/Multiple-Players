//
//  UIViewController+BackButtonHandler.h
//  MultipleVideo
//
//  参考网址 http://www.jianshu.com/p/25fd027916fa
//  Created by issuser on 2017/4/28.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BackButtonHandlerProtocol <NSObject>

@optional

/**
 重写下面的方法以拦截导航栏返回按钮点击事件

 @return YES则弹出，NO则不弹出
 */
-(BOOL)navigationShouldPopOnBackButton;

@end


@interface UIViewController (BackButtonHandler) <BackButtonHandlerProtocol>

@end
