//
//  VideoCollectionViewCell.h
//  MultipleVideo
//
//  Created by issuser on 2017/6/19.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface VideoCollectionViewCell : UICollectionViewCell

- (void)updateContentWithPHAsset:(PHAsset *)asset;

@end
