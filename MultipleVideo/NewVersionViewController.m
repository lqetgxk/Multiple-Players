//
//  NewVersionViewController.m
//  MultipleVideo
//
//  Created by issuser on 2017/8/10.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import "NewVersionViewController.h"
#import "MainNavigationController.h"
#import "MultipleVideo.h"

@interface NewVersionViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *buttonNext;
@end

@implementation NewVersionViewController

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
    [_labelTitle setText:MVLocalizedString(@"Guide_New_Version", @"新版本")];
    [_textView setText:MVLocalizedString(@"Guide_Version_description", "描述")];
    [_buttonNext setTitle:MVLocalizedString(@"Guide_Know", @"知道了") forState:UIControlStateNormal];
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
