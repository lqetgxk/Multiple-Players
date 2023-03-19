//
//  PictureCollectionViewCell.h
//  MultipleVideo
//
//  Created by issuser on 2017/4/28.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PictureCollectionViewCell : UICollectionViewCell

- (void)setPictureByURLString:(NSString *)urlString local:(BOOL)isLocal enableEdit:(BOOL)enableEdit;
- (void)setPictureAtImage:(UIImage *)image;
- (void)setPictureSelected:(BOOL)selected;

@end
