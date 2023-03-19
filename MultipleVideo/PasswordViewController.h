//
//  PasswordViewController.h
//  MultipleVideo
//
//  Created by issuser on 2017/4/30.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^BlockCancel)();


@interface PasswordViewController : UIViewController

@property (copy, nonatomic) BlockCancel blockCancel;

@end
