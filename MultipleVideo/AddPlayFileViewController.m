//
//  AddPlayFileViewController.m
//  MultipleVideo
//
//  Created by issuser on 2018/1/27.
//  Copyright © 2018年 lsq. All rights reserved.
//

#import "AddPlayFileViewController.h"
#import "ScrollViewController.h"
#import "MultipleVideo.h"

@interface AddPlayFileViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@end

@implementation AddPlayFileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.labelTitle setText:MVLocalizedString(@"Select_Title", @"选择文件")];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UIViewController *viewController = [segue destinationViewController];
    if ([viewController isKindOfClass:[ScrollViewController class]]) {
        ScrollViewController *scrollViewController = (ScrollViewController *)viewController;
        [scrollViewController setViewControllers:_arrayForViewController selectedIndex:0];
        [scrollViewController setButtonsHeight:44.0f font:nil color:nil selectedColor:[UIColor orangeColor]];
        [scrollViewController setSupportSlidingGesture:YES];
    }
}

@end
