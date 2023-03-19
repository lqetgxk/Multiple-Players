//
//  MainTabBarController.m
//  MultipleVideo
//
//  Created by issuser on 2017/4/26.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import "MainTabBarController.h"
#import "VideoViewController.h"
#import "PictureViewController.h"
#import "SettingTableViewController.h"
#import "PasswordViewController.h"
#import "MultipleVideo.h"

@interface MainTabBarController () <UITabBarControllerDelegate, UIPopoverPresentationControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *barButtonItemCamera;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *barButtonItemEditEnable;
@end

@implementation MainTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //[[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
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
    [[UITabBar appearance] setShadowImage:[UIImage new]];
    [[UITabBar appearance] setBackgroundImage:[UIImage new]];
    [self setDelegate:self];
    [self languageChangedNotification:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageChangedNotification:) name:NOTIFICATION_LANGUAGE_CHANGED object:nil];
    
    if ([[MultipleVideo shareInstance] password]) {
        PasswordViewController *viewController = [[PasswordViewController alloc] initWithNibName:@"PasswordViewController" bundle:nil];
        [self presentViewController:viewController animated:NO completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_LANGUAGE_CHANGED object:nil];
}

- (void)languageChangedNotification:(NSNotification *)notification
{
    [_labelTitle setText:MVLocalizedString(@"Video_Title", @"视频")];
    [_barButtonItemCamera setTitle:MVLocalizedString(@"Video_Record", @"录相")];
    UIViewController *viewController = [self selectedViewController];
    if ([viewController isKindOfClass:[VideoViewController class]]) {
        [_labelTitle setText:MVLocalizedString(@"Video_Title", @"视频")];
        [_barButtonItemCamera setTitle:MVLocalizedString(@"Video_Record", @"录相")];
    }
    else if ([viewController isKindOfClass:[PictureViewController class]]) {
        [_labelTitle setText:MVLocalizedString(@"Picture_Title", @"图片")];
        [_barButtonItemCamera setTitle:MVLocalizedString(@"Picture_Photo", @"照相")];
    }
    else if ([viewController isKindOfClass:[SettingTableViewController class]]) {
        [_labelTitle setText:MVLocalizedString(@"Setting_Title", @"设置")];
    }
    if (0 == [_barButtonItemEditEnable tag]) {
        [_barButtonItemEditEnable setTitle:MVLocalizedString(@"Home_Right_Enable", @"编辑")];
    }
    else {
        [_barButtonItemEditEnable setTitle:MVLocalizedString(@"Home_Right_Disable", @"取消")];
    }
    for (UIViewController *viewController in [self childViewControllers]) {
        if ([viewController isKindOfClass:[VideoViewController class]]) {
            [viewController.tabBarItem setTitle:MVLocalizedString(@"Video_Title", @"视频")];
        }
        else if ([viewController isKindOfClass:[PictureViewController class]]) {
            [viewController.tabBarItem setTitle:MVLocalizedString(@"Picture_Title", @"图片")];
        }
        else if ([viewController isKindOfClass:[SettingTableViewController class]]) {
            [viewController.tabBarItem setTitle:MVLocalizedString(@"Setting_Title", @"设置")];
        }
    }
    [[self.navigationItem backBarButtonItem] setTitle:MVLocalizedString(@"Home_Left_Back", @"返回")];
}

- (IBAction)openCamera:(UIBarButtonItem *)sender
{
    [self.selectedViewController openCamera:sender];
}

- (IBAction)editEnable:(UIBarButtonItem *)sender
{
    if ([sender tag]) {
        [sender setTag:0];
        [_barButtonItemEditEnable setTitle:MVLocalizedString(@"Home_Right_Enable", @"编辑")];
        [self.tabBar setHidden:NO];
        [self.selectedViewController setEnableEdit:NO];
    }
    else {
        [sender setTag:1];
        [_barButtonItemEditEnable setTitle:MVLocalizedString(@"Home_Right_Disable", @"取消")];
        [self.tabBar setHidden:YES];
        [self.selectedViewController setEnableEdit:YES];
    }
}

#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[VideoViewController class]]) {
        [_labelTitle setText:MVLocalizedString(@"Video_Title", @"视频")];
        [_barButtonItemCamera setTitle:MVLocalizedString(@"Video_Record", @"录相")];
        [self.navigationItem setLeftBarButtonItem:_barButtonItemCamera];
        [self.navigationItem setRightBarButtonItem:_barButtonItemEditEnable];
    }
    else if ([viewController isKindOfClass:[PictureViewController class]]) {
        [_labelTitle setText:MVLocalizedString(@"Picture_Title", @"图片")];
        [_barButtonItemCamera setTitle:MVLocalizedString(@"Picture_Photo", @"照相")];
        [self.navigationItem setLeftBarButtonItem:_barButtonItemCamera];
        [self.navigationItem setRightBarButtonItem:_barButtonItemEditEnable];
    }
    else if ([viewController isKindOfClass:[SettingTableViewController class]]) {
        [_labelTitle setText:MVLocalizedString(@"Setting_Title", @"设置")];
        [self.navigationItem setLeftBarButtonItem:nil];
        [self.navigationItem setRightBarButtonItem:nil];
    }
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
