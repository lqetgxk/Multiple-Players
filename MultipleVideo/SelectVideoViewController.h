//
//  SelectVideoViewController.h
//  MultipleVideo
//
//  Created by issuser on 2017/6/19.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^BlockSelectedFile)(NSString *pathName);


@interface SelectVideoViewController : UIViewController

@property (copy, nonatomic) BlockSelectedFile blockSelectedFile;

@end
