//
//  AboutPrivateViewController.m
//  MultipleVideo
//
//  Created by issuser on 2017/6/12.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import "AboutPrivateViewController.h"
#import "MainNavigationController.h"
#import "MultipleVideo.h"

@interface AboutPrivateViewController ()
@property (weak, nonatomic) IBOutlet UIButton *buttonNext;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@end

@implementation AboutPrivateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[self.navigationItem backBarButtonItem] setTitle:MVLocalizedString(@"Home_Left_Back", @"返回")];
    [_labelTitle setText:MVLocalizedString(@"Guide_About_Private", @"关于私密")];
    [_textView setText:MVLocalizedString(@"Guide_About_Private_Introduce", @"介绍")];
    [_buttonNext setTitle:MVLocalizedString(@"Guide_Enter", @"进入") forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)enterHome:(UIButton *)sender
{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [[NSUserDefaults standardUserDefaults] setObject:version forKey:@"Version"];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainNavigationController *main = [storyboard instantiateViewControllerWithIdentifier:@"MainNavigationController"];
    [[self.view window] setRootViewController:main];
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
