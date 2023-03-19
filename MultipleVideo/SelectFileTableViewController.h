//
//  SelectFileTableViewController.h
//  MultipleVideo
//
//  Created by issuser on 2017/8/8.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^BlockSelectedFile)(NSDictionary *information);


@interface SelectFileTableViewController : UITableViewController

@property (assign, nonatomic) BOOL isPrivate; //是否是私有数据
@property (copy, nonatomic) BlockSelectedFile blockSelectedFile;

@end
