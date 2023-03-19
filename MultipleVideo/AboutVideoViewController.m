//
//  AboutVideoViewController.m
//  MultipleVideo
//
//  Created by issuser on 2017/6/12.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import "AboutVideoViewController.h"
#import "MultipleVideo.h"

@interface AboutVideoViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *buttonNextPage;
@end

@implementation AboutVideoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        [appearance configureWithOpaqueBackground];
        [appearance setBackgroundColor:[UIColor orangeColor]];
        [self.navigationController.navigationBar setStandardAppearance:appearance];
        [self.navigationController.navigationBar setScrollEdgeAppearance:[self.navigationController.navigationBar standardAppearance]];
    }
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor orangeColor]];
    [[UITabBar appearance] setTintColor:[UIColor orangeColor]];
    
    [[self.navigationItem backBarButtonItem] setTitle:MVLocalizedString(@"Home_Left_Back", @"返回")];
    [_labelTitle setText:MVLocalizedString(@"Guide_About_Video", @"关于视频")];
    [_textView setText:MVLocalizedString(@"Guide_About_Video_Introduce", @"介绍")];
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
