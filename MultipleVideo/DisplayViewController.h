//
//  DisplayViewController.h
//  MultipleVideo
//
//  Created by issuser on 2017/4/27.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DisplayViewController;

@protocol DisplayViewControllerDelegate
- (void)addFileAtIndex:(NSInteger)index displayViewController:(DisplayViewController *)sender;
- (void)fullScreenAtIndex:(NSInteger)index fullScreen:(BOOL)isFullScreen displayViewController:(DisplayViewController *)sender;
@end


@interface DisplayViewController : UIViewController

@property (assign, nonatomic) NSInteger index;
@property (weak, nonatomic) NSDictionary *information;
@property (assign, nonatomic) BOOL isPrivate; //是否是私有数据

- (void)setDisplayViewControllerDelegate:(id<DisplayViewControllerDelegate>)delegate;
- (void)setFrame:(CGRect)frame;
- (void)setHidden:(BOOL)isHidden;
- (void)setURLString:(NSString *)urlString local:(BOOL)isLocal type:(BOOL)isVideo name:(NSString *)name;
- (void)play;
- (void)pause;
- (void)stop;
- (BOOL)isPlayVideo; //放的视频返回YES，放的图片返回NO

@end
