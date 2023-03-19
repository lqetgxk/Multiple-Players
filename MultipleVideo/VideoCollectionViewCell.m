//
//  VideoCollectionViewCell.m
//  MultipleVideo
//
//  Created by issuser on 2017/6/19.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import "VideoCollectionViewCell.h"

@interface VideoCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageViewImage;
@property (weak, nonatomic) IBOutlet UILabel *labelInformation;
@end

@implementation VideoCollectionViewCell {
    PHCachingImageManager *_imageManager;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"VideoCollectionViewCell" owner:self options:nil];
        self = [array objectAtIndex:0];
        _imageManager = [[PHCachingImageManager alloc] init];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)updateContentWithPHAsset:(PHAsset *)asset
{
    [_imageManager requestImageForAsset:asset
                             targetSize:CGSizeMake(self.bounds.size.width, self.bounds.size.width)
                            contentMode:PHImageContentModeAspectFit options:nil
                          resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                              [_imageViewImage setImage:result];
    }];
    if (PHAssetMediaTypeVideo == [asset mediaType]) {
        NSInteger duration = [asset duration];
        [_labelInformation setText:[NSString stringWithFormat:@"%ld:%02ld", duration / 60, duration % 60]];
    }
}

@end
