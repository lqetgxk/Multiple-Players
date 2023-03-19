//
//  PictureCollectionViewCell.m
//  MultipleVideo
//
//  Created by issuser on 2017/4/28.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import "PictureCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface PictureCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageViewPicture;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewSelected;
@end

@implementation PictureCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"PictureCollectionViewCell" owner:self options:nil];
        self = [array objectAtIndex:0];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)setPictureSelected:(BOOL)selected
{
    [_imageViewSelected setImage:[UIImage imageNamed:(selected ? @"PictureSelectedOn" : @"PictureSelectedOff")]];
}

- (void)setPictureByURLString:(NSString *)urlString local:(BOOL)isLocal enableEdit:(BOOL)enableEdit
{
    if (isLocal) {
        [_imageViewPicture setImage:[UIImage imageNamed:urlString]];
    }
    else {
        [_imageViewPicture sd_setImageWithURL:[NSURL URLWithString:urlString]
                             placeholderImage:[UIImage imageNamed:@"benben"]];
    }
    [_imageViewSelected setHidden:!enableEdit];
}

- (void)setPictureAtImage:(UIImage *)image
{
    [_imageViewPicture setImage:image];
    [_imageViewSelected setHidden:YES];
}

@end
