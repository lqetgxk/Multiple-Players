//
//  PictureBrowserViewController.h
//  CloudVideo
//
//  Created by issuser on 2017/4/11.
//  Copyright © 2017年 ChinaMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PictureBrowserViewController : UIViewController

@property (assign, nonatomic) BOOL localFile;
@property (assign, nonatomic) BOOL isPrivate; //是否是私有数据
@property (copy, nonatomic) NSString *path;
@property (weak, nonatomic) NSMutableArray *array;
@property (assign, nonatomic) NSUInteger index;

- (void)disableDelete;

@end
