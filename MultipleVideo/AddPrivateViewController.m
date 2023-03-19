//
//  AddPrivateViewController.m
//  MultipleVideo
//
//  Created by issuser on 2017/5/6.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import "AddPrivateViewController.h"
#import "VideoTableViewController.h"
#import "PictureCollectionViewController.h"
#import "ScrollViewController.h"
#import "MultipleVideo.h"

@interface AddPrivateViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonItemConfirm;
@end

@implementation AddPrivateViewController {
    ScrollViewController *_scrollViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_labelTitle setText:MVLocalizedString(@"Select_Title", @"选择文件")];
    [_barButtonItemConfirm setTitle:MVLocalizedString(@"Select_Confirm", @"确认")];
    [[self.navigationItem backBarButtonItem] setTitle:MVLocalizedString(@"Home_Left_Back", @"返回")];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)confirm:(UIBarButtonItem *)sender
{
    VideoTableViewController *video = (VideoTableViewController *)[_scrollViewController viewControllerAtIndex:0];
    NSArray *array = [video indexPathsForSelectedRows];
    if ([array count]) {
        [[MultipleVideo shareInstance] moveVideoFilesFromPublicToPrivateWithIndexPaths:array];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_VIDEO object:nil];
    }
    PictureCollectionViewController *picture = (PictureCollectionViewController *)[_scrollViewController viewControllerAtIndex:1];
    array = [picture indexPathsForSelectedRows];
    if ([array count]) {
        [[MultipleVideo shareInstance] moveImageFilesFromPublicToPrivateWithIndexPaths:array];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_IMAGE object:nil];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UIViewController *viewController = [segue destinationViewController];
    if ([viewController isKindOfClass:[ScrollViewController class]]){
        VideoTableViewController *video = [[VideoTableViewController alloc] initWithStyle:UITableViewStylePlain];
        [video setEnableEdit:YES];
        [video setIsSelected:YES];
        [video setTitle:MVLocalizedString(@"Video_Title", @"视频")];
        [video.tableView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        [video setArray:[[MultipleVideo shareInstance] arrayForVideo]];
        
        PictureCollectionViewController *picture = [self.storyboard instantiateViewControllerWithIdentifier:@"PictureCollectionViewController"];
        [picture setEnableEdit:YES];
        [picture setIsSelected:YES];
        [picture setTitle:MVLocalizedString(@"Picture_Title", @"图片")];
        [picture setArray:[[MultipleVideo shareInstance] arrayForImage]];
        
        _scrollViewController = (ScrollViewController *)viewController;
        [_scrollViewController setViewControllers:@[video, picture] selectedIndex:0];
        [_scrollViewController setButtonsHeight:44.0f font:nil color:nil selectedColor:[UIColor orangeColor]];
        [_scrollViewController setSupportSlidingGesture:YES];
    }
}

@end
