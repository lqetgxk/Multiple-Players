//
//  VideoClipViewController.h
//  MultipleVideo
//
//  Created by issuser on 2017/8/6.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoClipViewController : UIViewController

@property (assign, nonatomic) BOOL isPrivate; //是否是私有数据
@property (strong, nonatomic) NSDictionary *video;

@end
