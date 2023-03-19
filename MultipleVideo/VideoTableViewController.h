//
//  VideoTableViewController.h
//  MultipleVideo
//
//  Created by issuser on 2017/4/27.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^BlockSelectedIndexPath)(NSIndexPath *indexPath);


@interface VideoTableViewController : UITableViewController

@property (weak, nonatomic) NSArray *array;
@property (copy, nonatomic) BlockSelectedIndexPath blockSelectedIndexPath;
@property (assign, nonatomic) BOOL enableEdit;
@property (assign, nonatomic) BOOL isPrivate; //是否是私有数据
@property (assign, nonatomic) BOOL isSelected; //用从隐密文件进来选择文件的吗

- (void)openCamera:(UIButton *)sender;
- (void)addVideo:(UIButton *)sender;
- (void)renameVideos;
- (void)deleteSelectedVideos;
- (NSArray *)indexPathsForSelectedRows;
- (void)reloadData;

@end
