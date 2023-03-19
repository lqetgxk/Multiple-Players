//
//  GuideNavigationController.m
//  MultipleVideo
//
//  Created by issuser on 2017/6/12.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import "GuideNavigationController.h"
#import "MultipleVideo.h"

@interface GuideNavigationController ()

@end

@implementation GuideNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[self.navigationItem backBarButtonItem] setTitle:MVLocalizedString(@"Home_Left_Back", @"返回")];
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
