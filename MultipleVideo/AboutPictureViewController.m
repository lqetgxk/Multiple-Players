//
//  AboutPictureViewController.m
//  MultipleVideo
//
//  Created by issuser on 2017/6/12.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import "AboutPictureViewController.h"
#import "MultipleVideo.h"

@interface AboutPictureViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *buttonNextPage;
@end

@implementation AboutPictureViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[self.navigationItem backBarButtonItem] setTitle:MVLocalizedString(@"Home_Left_Back", @"返回")];
    [_labelTitle setText:MVLocalizedString(@"Guide_About_Picture", @"关于图片")];
    [_textView setText:MVLocalizedString(@"Guide_About_Picture_Introduce", @"介绍")];
    [_buttonNextPage setTitle:MVLocalizedString(@"Guide_Next_Page", @"下一页") forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
