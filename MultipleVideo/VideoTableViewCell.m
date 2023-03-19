//
//  VideoTableViewCell.m
//  MultipleVideo
//
//  Created by issuser on 2017/5/26.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import "VideoTableViewCell.h"

@interface VideoTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *thumbnails;
@property (weak, nonatomic) IBOutlet UILabel *LabelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelDetail;
@end

@implementation VideoTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"VideoTableViewCell" owner:self options:nil];
        self = [array objectAtIndex:0];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setContentDictionary:(NSDictionary *)dictionary
{
    [_LabelTitle setText:[dictionary objectForKey:@"name"]];
    if (0 == [[dictionary objectForKey:@"type"] integerValue]) { //本地视频
        [_thumbnails setImage:[dictionary objectForKey:@"thumbnails"]];
        NSString *resolution = [NSString stringWithFormat:@"%@x%@", [dictionary objectForKey:@"width"],
                                [dictionary objectForKey:@"height"]];
        NSInteger second = [[dictionary objectForKey:@"duration"] integerValue];
        NSString *time = [NSString stringWithFormat:@"%ld:%02ld", second / 60, second % 60];
        double size = [[dictionary objectForKey:@"size"] doubleValue];
        NSString *stringSize = [NSString stringWithFormat:@"%0.0fB", size];
        if (size > 1000 * 1000 * 1000) { //G
            stringSize = [NSString stringWithFormat:@"%0.1fG", size / (1000 * 1000 * 1000)];
        }
        else if (size > 1000 * 1000) { //M
            stringSize = [NSString stringWithFormat:@"%0.1fM", size / (1000 * 1000)];
        }
        else if (size > 1000) { //K
            stringSize = [NSString stringWithFormat:@"%0.1fK", size / 1000];
        }
        [_labelDetail setText:[NSString stringWithFormat:@"%@  %@  %@", resolution, time, stringSize]];
    }
    else if (1 == [[dictionary objectForKey:@"type"] integerValue]) { //网络视频
        [_thumbnails setImage:[UIImage imageNamed:@"benben"]];
        [_labelDetail setText:[dictionary objectForKey:@"DateTime"]];
    }
}

- (void)setContentForGroupDictionary:(NSDictionary *)dictionary
{
    [_thumbnails setImage:[UIImage imageNamed:@"group"]];
    [_LabelTitle setText:[dictionary objectForKey:@"DisplayName"]];
    [_labelDetail setText:[NSString stringWithFormat:@"%@  %@", [dictionary objectForKey:@"DateTime"],
                           [dictionary objectForKey:@"Split"]]];
}

@end
