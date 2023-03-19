//
//  GroupTableViewController.h
//  MultipleVideo
//
//  Created by issuser on 2017/4/28.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupTableViewController : UITableViewController

@property (weak, nonatomic) NSArray *array;
@property (assign, nonatomic) BOOL enableEdit;
@property (assign, nonatomic) BOOL isPrivate; //是否是私有数据

- (void)addGroup;
- (void)renameGroups;
- (void)deleteSelectedGroups;

@end
