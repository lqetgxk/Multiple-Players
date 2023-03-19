//
//  VideoTableViewCell.h
//  MultipleVideo
//
//  Created by issuser on 2017/5/26.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoTableViewCell : UITableViewCell

- (void)setContentDictionary:(NSDictionary *)dictionary;
- (void)setContentForGroupDictionary:(NSDictionary *)dictionary;

@end
