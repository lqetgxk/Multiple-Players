//
//  OptionTableViewController.h
//  MultipleVideo
//
//  Created by issuser on 2017/4/26.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^BlockSelectedItem)(NSString *name, NSInteger index);


@interface OptionTableViewController : UITableViewController

@property (strong, nonatomic) NSArray *array;
@property (copy, nonatomic) BlockSelectedItem blockSelectedItem;

@end
