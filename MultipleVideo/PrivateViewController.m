//
//  PrivateViewController.m
//  MultipleVideo
//
//  Created by issuser on 2017/5/6.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import "PrivateViewController.h"
#import "VideoTableViewController.h"
#import "GroupTableViewController.h"
#import "PictureCollectionViewController.h"
#import "AddPrivateViewController.h"
#import "ScrollViewController.h"
#import "MultipleVideo.h"

@interface PrivateViewController () <ScrollViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonItemEditEnable;
@property (weak, nonatomic) IBOutlet UIView *viewToolbar;
@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (weak, nonatomic) IBOutlet UIButton *buttonDelete;
@property (weak, nonatomic) IBOutlet UIButton *buttonMoveOut;
@property (weak, nonatomic) IBOutlet UIButton *buttonAdd;
@end

@implementation PrivateViewController {
    ScrollViewController *_scrollViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGRect frame = [self.viewToolbar frame];
    frame.size.height = kTabBarHeight;
    frame.origin.y = [self.view bounds].size.height - frame.size.height;
    [self.viewToolbar setFrame:frame];
    [self.viewContainer setFrame:self.view.bounds];
    [_labelTitle setText:MVLocalizedString(@"Private_File_Title", @"私密文件")];
    [_barButtonItemEditEnable setTitle:MVLocalizedString(@"Home_Right_Enable", @"编辑")];
    [_buttonDelete setTitle:MVLocalizedString(@"Home_Delete", @"删除") forState:UIControlStateNormal];
    [_buttonMoveOut setTitle:MVLocalizedString(@"Home_Move_Out", @"移出") forState:UIControlStateNormal];
    [_buttonAdd setTitle:MVLocalizedString(@"Home_Add", @"添加") forState:UIControlStateNormal];
    [[self.navigationItem backBarButtonItem] setTitle:MVLocalizedString(@"Home_Left_Back", @"返回")];
    [_viewToolbar setHidden:YES];
    if (NO == _isCorrect) {
        [self.navigationItem setRightBarButtonItem:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)editEnable:(UIBarButtonItem *)sender
{
    if ([sender tag]) {
        [sender setTag:0];
        [sender setTitle:MVLocalizedString(@"Home_Right_Enable", @"编辑")];
        [(VideoTableViewController *)[_scrollViewController viewControllerAtIndex:0] setEnableEdit:NO];
        [(PictureCollectionViewController *)[_scrollViewController viewControllerAtIndex:1] setEnableEdit:NO];
        [(GroupTableViewController *)[_scrollViewController viewControllerAtIndex:2] setEnableEdit:NO];
        [_viewToolbar setHidden:YES];
    }
    else {
        [sender setTag:1];
        [sender setTitle:MVLocalizedString(@"Home_Right_Disable", @"取消")];
        [(VideoTableViewController *)[_scrollViewController viewControllerAtIndex:0] setEnableEdit:YES];
        [(PictureCollectionViewController *)[_scrollViewController viewControllerAtIndex:1] setEnableEdit:YES];
        [(GroupTableViewController *)[_scrollViewController viewControllerAtIndex:2] setEnableEdit:YES];
        [_viewToolbar setHidden:NO];
    }
}

- (IBAction)delete:(UIButton *)sender
{
    UIViewController *viewController = [_scrollViewController selectedViewController];
    if ([viewController isKindOfClass:[VideoTableViewController class]]) {
        [(VideoTableViewController *)viewController deleteSelectedVideos];
    }
    else if ([viewController isKindOfClass:[PictureCollectionViewController class]]) {
        [(PictureCollectionViewController *)viewController deleteSelectedPictures];
    }
    else if ([viewController isKindOfClass:[GroupTableViewController class]]) {
        [(GroupTableViewController *)viewController deleteSelectedGroups];
    }
}

- (IBAction)moveOut:(UIButton *)sender
{
    if (2 == [sender tag]) {
        GroupTableViewController *group = (GroupTableViewController *)[_scrollViewController viewControllerAtIndex:2];
        [group renameGroups];
    }
    else {
        VideoTableViewController *video = (VideoTableViewController *)[_scrollViewController viewControllerAtIndex:0];
        NSArray *array = [video indexPathsForSelectedRows];
        if ([array count]) {
            [[MultipleVideo shareInstance] moveVideoFilesFromPrivateToPublicWithIndexPaths:array];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_VIDEO object:nil];
        }
        PictureCollectionViewController *picture = (PictureCollectionViewController *)[_scrollViewController viewControllerAtIndex:1];
        array = [picture indexPathsForSelectedRows];
        if ([array count]) {
            [[MultipleVideo shareInstance] moveImageFilesFromPrivateToPublicWithIndexPaths:array];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_IMAGE object:nil];
        }
    }
}

- (IBAction)add:(UIButton *)sender
{
    UIViewController *viewController = [_scrollViewController selectedViewController];
    if ([viewController isKindOfClass:[GroupTableViewController class]]) {
        [(GroupTableViewController *)viewController addGroup];
    }
    else {
        AddPrivateViewController *addPrivateViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddPrivateViewController"];
        [self.navigationController pushViewController:addPrivateViewController animated:YES];
    }
}

#pragma mark - ScrollViewControllerDelegate

- (void)scrollViewController:(ScrollViewController *)scrollViewController didSelectViewControllerAtIndex:(NSUInteger)index
{
    [_buttonMoveOut setTitle:(2 == index ?
                              MVLocalizedString(@"Home_Rename", @"重命名") :
                              MVLocalizedString(@"Home_Move_Out", @"移出"))
                    forState:UIControlStateNormal];
    [_buttonMoveOut setTag:index];
}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    return ![identifier isEqualToString:@"SelectPrivateFile"];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UIViewController *viewController = [segue destinationViewController];
    if ([viewController isKindOfClass:[ScrollViewController class]]) {
        VideoTableViewController *video = [[VideoTableViewController alloc] initWithStyle:UITableViewStylePlain];
        [video setTitle:MVLocalizedString(@"Video_Title", @"视频")];
        [video.tableView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        [video setIsPrivate:YES];
        [video setArray:_isCorrect ? [[MultipleVideo shareInstance] arrayForPrivateVideo] : nil];
        
        PictureCollectionViewController *picture = [self.storyboard instantiateViewControllerWithIdentifier:@"PictureCollectionViewController"];
        [picture setTitle:MVLocalizedString(@"Picture_Title", @"图片")];
        [picture setIsPrivate:YES];
        [picture setArray:_isCorrect ? [[MultipleVideo shareInstance] arrayForPrivateImage] : nil];
        
        GroupTableViewController *group = [[GroupTableViewController alloc] initWithStyle:UITableViewStylePlain];
        [group setTitle:MVLocalizedString(@"Gruop_Title", @"收藏组")];
        [group.tableView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        [group setIsPrivate:YES];
        [group setArray:_isCorrect ? [[MultipleVideo shareInstance] arrayForPrivateGroup] : nil];
        
        _scrollViewController= (ScrollViewController *)viewController;
        [_scrollViewController setViewControllers:@[video, picture, group] selectedIndex:0];
        [_scrollViewController setButtonsHeight:ButtonsHeight font:nil color:nil selectedColor:[UIColor orangeColor]];
        [_scrollViewController setSupportSlidingGesture:YES];
        [_scrollViewController setScrollViewControllerDelegate:self];
    }
}

@end
