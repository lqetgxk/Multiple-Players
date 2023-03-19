//
//  VideoViewController.m
//  MultipleVideo
//
//  Created by issuser on 2017/4/26.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import "VideoViewController.h"
#import "ScrollViewController.h"
#import "VideoTableViewController.h"
#import "GroupTableViewController.h"
#import "MultipleVideo.h"

@interface VideoViewController ()
@property (weak, nonatomic) IBOutlet UIView *viewToolbar;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *buttonDelete;
@property (weak, nonatomic) IBOutlet UIButton *buttonRename;
@property (weak, nonatomic) IBOutlet UIButton *buttonAdd;
@end

@implementation VideoViewController {
    ScrollViewController *_scrollViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGRect frame = [self.viewToolbar frame];
    frame.size.height = kTabBarHeight;
    frame.origin.y = [[UIScreen mainScreen] bounds].size.height - frame.size.height;
    [self.viewToolbar setFrame:frame];
    [self.containerView setFrame:self.view.bounds];
    [_viewToolbar setHidden:YES];
    [self languageChangedNotification:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageChangedNotification:) name:NOTIFICATION_LANGUAGE_CHANGED object:nil];
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
    [_buttonDelete setTitle:MVLocalizedString(@"Home_Delete", @"删除") forState:UIControlStateNormal];
    [_buttonRename setTitle:MVLocalizedString(@"Home_Rename", @"重命名") forState:UIControlStateNormal];
    [_buttonAdd setTitle:MVLocalizedString(@"Home_Add", @"添加") forState:UIControlStateNormal];
    if (notification) {
        UIButton *buttonVideo = [_scrollViewController titleButtonAtIndex:0];
        [buttonVideo setTitle:MVLocalizedString(@"Video_Title", @"视频") forState:UIControlStateNormal];
        UIButton *buttonGroup = [_scrollViewController titleButtonAtIndex:1];
        [buttonGroup setTitle:MVLocalizedString(@"Gruop_Title", @"收藏组") forState:UIControlStateNormal];
        for (NSMutableDictionary *dictionary in [[MultipleVideo shareInstance] arrayForVideo]) {
            if (0 == [[dictionary objectForKey:FILE_TYPE_INDEX] integerValue]) {
                [dictionary setValue:MVLocalizedString(@"Video_Local_File", @"本地视频") forKey:FILE_TYPE_NAME];
            }
            else if (1 == [[dictionary objectForKey:FILE_TYPE_INDEX] integerValue]) {
                [dictionary setValue:MVLocalizedString(@"Video_Network_File", @"网络视频") forKey:FILE_TYPE_NAME];
            }
        }
        for (NSMutableDictionary *dictionary in [[MultipleVideo shareInstance] arrayForPrivateVideo]) {
            if (0 == [[dictionary objectForKey:FILE_TYPE_INDEX] integerValue]) {
                [dictionary setValue:MVLocalizedString(@"Video_Local_File", @"本地视频") forKey:FILE_TYPE_NAME];
            }
            else if (1 == [[dictionary objectForKey:FILE_TYPE_INDEX] integerValue]) {
                [dictionary setValue:MVLocalizedString(@"Video_Network_File", @"网络视频") forKey:FILE_TYPE_NAME];
            }
        }
        [(VideoTableViewController *)[_scrollViewController viewControllerAtIndex:0] reloadData];
    }
}

- (void)setEnableEdit:(BOOL)enableEdit
{
    _enableEdit = enableEdit;
    [(VideoTableViewController *)[_scrollViewController viewControllerAtIndex:0] setEnableEdit:_enableEdit];
    [(GroupTableViewController *)[_scrollViewController viewControllerAtIndex:1] setEnableEdit:_enableEdit];
    [_viewToolbar setHidden:!enableEdit];
}

- (void)openCamera:(UIButton *)sender
{
    [(VideoTableViewController *)[_scrollViewController viewControllerAtIndex:0] openCamera:sender];
}

- (IBAction)add:(UIButton *)sender
{
    UIViewController *viewController = [_scrollViewController selectedViewController];
    if ([viewController isKindOfClass:[VideoTableViewController class]]) {
        [(VideoTableViewController *)viewController addVideo:sender];
    }
    else if ([viewController isKindOfClass:[GroupTableViewController class]]) {
        [(GroupTableViewController *)viewController addGroup];
    }
}

- (IBAction)rename:(UIButton *)sender
{
    UIViewController *viewController = [_scrollViewController selectedViewController];
    if ([viewController isKindOfClass:[VideoTableViewController class]]) {
        [(VideoTableViewController *)viewController renameVideos];
    }
    else if ([viewController isKindOfClass:[GroupTableViewController class]]) {
        [(GroupTableViewController *)viewController renameGroups];
    }
}

- (IBAction)delete:(UIButton *)sender
{
    UIViewController *viewController = [_scrollViewController selectedViewController];
    if ([viewController isKindOfClass:[VideoTableViewController class]]) {
        [(VideoTableViewController *)viewController deleteSelectedVideos];
    }
    else if ([viewController isKindOfClass:[GroupTableViewController class]]) {
        [(GroupTableViewController *)viewController deleteSelectedGroups];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UIViewController *viewController = [segue destinationViewController];
    if ([viewController isKindOfClass:[ScrollViewController class]]) {
        _scrollViewController = (ScrollViewController *)viewController;
        VideoTableViewController *video = [[VideoTableViewController alloc] initWithStyle:UITableViewStylePlain];
        [video setTitle:MVLocalizedString(@"Video_Title", @"视频")];
        //[video.tableView setSeparatorInset:UIEdgeInsetsZero];
        [video.tableView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        [video setArray:[[MultipleVideo shareInstance] arrayForVideo]];
        
        GroupTableViewController *group = [[GroupTableViewController alloc] initWithStyle:UITableViewStylePlain];
        [group setTitle:MVLocalizedString(@"Gruop_Title", @"收藏组")];
        //[image.tableView setSeparatorInset:UIEdgeInsetsZero];
        [group.tableView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        [group setArray:[[MultipleVideo shareInstance] arrayForGroup]];
        
        [_scrollViewController setViewControllers:@[video, group] selectedIndex:0];
        [_scrollViewController setButtonsHeight:ButtonsHeight font:nil color:nil selectedColor:[UIColor orangeColor]];
        [_scrollViewController setSupportSlidingGesture:YES];
    }
}

@end
