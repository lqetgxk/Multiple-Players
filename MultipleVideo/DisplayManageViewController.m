//
//  DisplayManageViewController.m
//  MultipleVideo
//
//  Created by issuser on 2017/4/26.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import "DisplayManageViewController.h"
#import "OptionTableViewController.h"
#import "DisplayViewController.h"
#import "ScrollViewController.h"
#import "VideoTableViewController.h"
#import "ScrollViewController.h"
#import "MultipleVideo.h"
#import "UIViewController+BackButtonHandler.h"
#import "PictureCollectionViewController.h"
#import "AddPlayFileViewController.h"
#import "AppDelegate.h"

#define MAX_SPLIT_NUMBER 6 //最大分割数
#define SPLIT_LINE_SPACE 2.0f //分割线

@interface DisplayManageViewController () <UIPopoverPresentationControllerDelegate, DisplayViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *buttonTitle;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonItemSplit;
@property (weak, nonatomic) IBOutlet UIView *viewDisplay;
@end

@implementation DisplayManageViewController {
    NSArray *_arraySplit;
    NSInteger _splitNumber;
    BOOL _isLandscape;
    NSInteger _selectedIndex;
    DisplayViewController *_displayViews[MAX_SPLIT_NUMBER];
    NSInteger _fullScreenIndex; //小于0时表示没有窗口被放大
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_buttonTitle setTitle:MVLocalizedString(@"Display_Title", @"收藏分组") forState:UIControlStateNormal];
    _arraySplit = @[MVLocalizedString(@"Display_One_View", @"一视图"),
                    MVLocalizedString(@"Display_Two_View", @"二视图"),
                    MVLocalizedString(@"Display_Three_View", @"三视图"),
                    MVLocalizedString(@"Display_Four_View", @"四视图"),
                    MVLocalizedString(@"Display_Five_View", @"五视图"),
                    MVLocalizedString(@"Display_Six_View", @"六视图")];
    [[self.navigationItem backBarButtonItem] setTitle:MVLocalizedString(@"Home_Left_Back", @"返回")];
    _fullScreenIndex = -1;
    NSInteger splitNumber = 1;
    if (_group) { //表示从收藏组进入
        splitNumber = [[_group objectForKey:@"SplitNumber"] integerValue];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
            [self layoutDisplayViewsBySplitNumber:splitNumber landscape:NO];
            NSArray *informaitons = [_group objectForKey:@"Informations"];
            for (NSInteger i = 0; i < [informaitons count]; i++) {
                [_displayViews[i] setInformation:[informaitons objectAtIndex:i]];
            }
        });
    }
    else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
            [self layoutDisplayViewsBySplitNumber:splitNumber landscape:NO];
            if (_video) {
                [_displayViews[0] setURLString:[_video objectForKey:@"url"]
                                         local:(0 == [[_video objectForKey:@"type"] integerValue])
                                          type:YES
                                          name:[_video objectForKey:@"name"]];
            }
        });
    }
    [_barButtonItemSplit setTitle:[_arraySplit objectAtIndex:(splitNumber - 1)]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [((AppDelegate *)[UIApplication sharedApplication].delegate) setAllowRotation:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) { //禁用返回手势
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) { //恢复返回手势
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    [((AppDelegate *)[UIApplication sharedApplication].delegate) setAllowRotation:NO];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if ((UIDeviceOrientationLandscapeLeft == toInterfaceOrientation) ||
        (UIDeviceOrientationLandscapeRight == toInterfaceOrientation)) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self layoutDisplayViewsBySplitNumber:_splitNumber landscape:YES];
    }
    else {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        [self layoutDisplayViewsBySplitNumber:_splitNumber landscape:NO];
    }
}

- (void)interfaceOrientation:(UIInterfaceOrientation)orientation
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

- (BOOL)navigationShouldPopOnBackButton
{
    for (NSInteger i = 0; i < MAX_SPLIT_NUMBER; i++) {
        [_displayViews[i] stop];
    }
    return YES;
}

- (void)layoutDisplayViewsBySplitNumber:(NSInteger)number landscape:(BOOL)isLandscape
{
    _splitNumber = number;
    _isLandscape = isLandscape;
    for (NSInteger i = 0; i < MAX_SPLIT_NUMBER; i++) {
        if ((i < _splitNumber) && (nil == _displayViews[i])) {
            _displayViews[i] = [[DisplayViewController alloc] initWithNibName:@"DisplayViewController" bundle:nil];
            [_displayViews[i] setIndex:i];
            [_displayViews[i] setDisplayViewControllerDelegate:self];
            [_displayViews[i] setIsPrivate:_isPrivate];
            [_viewDisplay addSubview:_displayViews[i].view];
        }
        [_displayViews[i] setHidden:(i >= _splitNumber)];
    }
    CGRect rect = [_viewDisplay bounds];
    if (0 <= _fullScreenIndex) {
        for (NSInteger i = 0; i < _splitNumber; i++) {
            if (i == _fullScreenIndex) {
                [_displayViews[i] setFrame:rect];
            }
            [_displayViews[i] setHidden:!(i == _fullScreenIndex)];
        }
        return;
    }
    switch (_splitNumber) {
        case 1: {
            [_displayViews[0] setFrame:rect];
        } break;
        case 2: {
            if (isLandscape) {
                CGFloat width = (rect.size.width - SPLIT_LINE_SPACE) / 2;
                [_displayViews[0] setFrame:CGRectMake(0, 0, width, rect.size.height)];
                [_displayViews[1] setFrame:CGRectMake(width + SPLIT_LINE_SPACE, 0, width, rect.size.height)];
            }
            else {
                CGFloat height = (rect.size.height - SPLIT_LINE_SPACE) / 2;
                [_displayViews[0] setFrame:CGRectMake(0, 0, rect.size.width, height)];
                [_displayViews[1] setFrame:CGRectMake(0, height + SPLIT_LINE_SPACE, rect.size.width, height)];
            }
        } break;
        case 3: {
            CGFloat width = (rect.size.width - SPLIT_LINE_SPACE) / 2;
            CGFloat height = (rect.size.height - SPLIT_LINE_SPACE) / 2;
            if (isLandscape) {
                [_displayViews[0] setFrame:CGRectMake(0, 0, width, height)];
                [_displayViews[1] setFrame:CGRectMake(0, height + SPLIT_LINE_SPACE, width, height)];
                [_displayViews[2] setFrame:CGRectMake(width + SPLIT_LINE_SPACE, 0, width, rect.size.height)];
            }
            else {
                [_displayViews[0] setFrame:CGRectMake(0, 0, width, height)];
                [_displayViews[1] setFrame:CGRectMake(width + SPLIT_LINE_SPACE, 0, width, height)];
                [_displayViews[2] setFrame:CGRectMake(0, height + SPLIT_LINE_SPACE, rect.size.width, height)];
            }
        } break;
        case 4: {
            CGFloat width = (rect.size.width - SPLIT_LINE_SPACE) / 2;
            CGFloat height = (rect.size.height - SPLIT_LINE_SPACE) / 2;
            [_displayViews[0] setFrame:CGRectMake(0, 0, width, height)];
            [_displayViews[1] setFrame:CGRectMake(width + SPLIT_LINE_SPACE, 0, width, height)];
            [_displayViews[2] setFrame:CGRectMake(0, height + SPLIT_LINE_SPACE, width, height)];
            [_displayViews[3] setFrame:CGRectMake(width + SPLIT_LINE_SPACE, height + SPLIT_LINE_SPACE, width, height)];
        } break;
        case 5: {
            if (isLandscape) {
                CGFloat width = (rect.size.width - 2 * SPLIT_LINE_SPACE) / 3;
                CGFloat height = (rect.size.height - SPLIT_LINE_SPACE) / 2;
                [_displayViews[0] setFrame:CGRectMake(0, 0, width, height)];
                [_displayViews[1] setFrame:CGRectMake(0, height + SPLIT_LINE_SPACE, width, height)];
                [_displayViews[2] setFrame:CGRectMake(width + SPLIT_LINE_SPACE, 0, width, rect.size.height)];
                [_displayViews[3] setFrame:CGRectMake((width + SPLIT_LINE_SPACE) * 2, 0, width, height)];
                [_displayViews[4] setFrame:CGRectMake((width + SPLIT_LINE_SPACE) * 2, height + SPLIT_LINE_SPACE, width, height)];
            }
            else {
                CGFloat width = (rect.size.width - SPLIT_LINE_SPACE) / 2;
                CGFloat height = (rect.size.height - 2 * SPLIT_LINE_SPACE) / 3;
                [_displayViews[0] setFrame:CGRectMake(0, 0, width, height)];
                [_displayViews[1] setFrame:CGRectMake(width + SPLIT_LINE_SPACE, 0, width, height)];
                [_displayViews[2] setFrame:CGRectMake(0, height + SPLIT_LINE_SPACE, rect.size.width, height)];
                [_displayViews[3] setFrame:CGRectMake(0, (height + SPLIT_LINE_SPACE) * 2, width, height)];
                [_displayViews[4] setFrame:CGRectMake(width + SPLIT_LINE_SPACE, (height + SPLIT_LINE_SPACE) * 2, width, height)];
            }
        } break;
        case 6: {
            if (isLandscape) {
                CGFloat width = (rect.size.width - 2 * SPLIT_LINE_SPACE) / 3;
                CGFloat height = (rect.size.height - SPLIT_LINE_SPACE) / 2;
                [_displayViews[0] setFrame:CGRectMake(0, 0, width, height)];
                [_displayViews[1] setFrame:CGRectMake(0, height + SPLIT_LINE_SPACE, width, height)];
                [_displayViews[2] setFrame:CGRectMake(width + SPLIT_LINE_SPACE, 0, width, height)];
                [_displayViews[3] setFrame:CGRectMake(width + SPLIT_LINE_SPACE, height + SPLIT_LINE_SPACE, width, height)];
                [_displayViews[4] setFrame:CGRectMake((width + SPLIT_LINE_SPACE) * 2, 0, width, height)];
                [_displayViews[5] setFrame:CGRectMake((width + SPLIT_LINE_SPACE) * 2, height + SPLIT_LINE_SPACE, width, height)];
            }
            else {
                CGFloat width = (rect.size.width - SPLIT_LINE_SPACE) / 2;
                CGFloat height = (rect.size.height - 3 * SPLIT_LINE_SPACE) / 4;
                [_displayViews[0] setFrame:CGRectMake(0, 0, width, height)];
                [_displayViews[1] setFrame:CGRectMake(width + SPLIT_LINE_SPACE, 0, width, height)];
                [_displayViews[2] setFrame:CGRectMake(0, height + SPLIT_LINE_SPACE, rect.size.width, height)];
                [_displayViews[3] setFrame:CGRectMake(0, (height + SPLIT_LINE_SPACE) * 2, rect.size.width, height)];
                [_displayViews[4] setFrame:CGRectMake(0, (height + SPLIT_LINE_SPACE) * 3, width, height)];
                [_displayViews[5] setFrame:CGRectMake(width + SPLIT_LINE_SPACE, (height + SPLIT_LINE_SPACE) * 3, width, height)];
            }
        } break;
        default: break;
    }
}

- (IBAction)saveGroup:(UIButton *)sender
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateTime = [formatter stringFromDate:[NSDate date]];
    NSString *displayName = [NSString stringWithFormat:@"%@_%.0f", [_barButtonItemSplit title],
                             [[NSDate date] timeIntervalSince1970] * 1000];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[NSNumber numberWithInteger:_splitNumber] forKey:@"SplitNumber"];
    [dictionary setValue:[_barButtonItemSplit title] forKey:@"Split"];
    [dictionary setValue:dateTime forKey:@"DateTime"];
    [dictionary setValue:displayName forKey:@"DisplayName"];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < _splitNumber; i++) {
        [array addObject:[_displayViews[i] information]];
    }
    [dictionary setObject:array forKey:@"Informations"];
    [[MultipleVideo shareInstance] addArrayForGroupObject:dictionary isPrivate:_isPrivate];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GROUP object:nil];
}

- (IBAction)selectSplitNumber:(UIBarButtonItem *)sender
{
    //http://www.qingpingshan.com/rjbc/ios/210950.html
    OptionTableViewController *viewController = [[OptionTableViewController alloc] initWithStyle:UITableViewStylePlain];
    [viewController setArray:_arraySplit];
    [viewController setPreferredContentSize:CGSizeMake(140, [_arraySplit count] * 44 - 1)];
    [viewController setBlockSelectedItem:^(NSString *name, NSInteger index) {
        [_barButtonItemSplit setTitle:name];
        [self layoutDisplayViewsBySplitNumber:(index + 1) landscape:NO];
    }];
    [viewController.view setBackgroundColor:[UIColor darkGrayColor]];
    [viewController setModalPresentationStyle:UIModalPresentationPopover];
    [viewController.popoverPresentationController setBarButtonItem:sender];
//    [viewController.popoverPresentationController setSourceView:sender];
//    [viewController.popoverPresentationController setSourceRect:[sender bounds]];
    [viewController.popoverPresentationController setPermittedArrowDirections:UIPopoverArrowDirectionAny];
    [viewController.popoverPresentationController setBackgroundColor:[UIColor darkGrayColor]];
    [viewController.popoverPresentationController setDelegate:self];
    [self presentViewController:viewController animated:YES completion:nil];
}

#pragma mark - DisplayViewControllerDelegate

- (void)addFileAtIndex:(NSInteger)index displayViewController:(DisplayViewController *)sender
{
    [self interfaceOrientation:UIInterfaceOrientationPortrait]; //强制转换为坚屏
    VideoTableViewController *video = [[VideoTableViewController alloc] initWithStyle:UITableViewStylePlain];
    [video setTitle:MVLocalizedString(@"Video_Title", @"视频")];
    //[video.tableView setSeparatorInset:UIEdgeInsetsZero];
    [video setBlockSelectedIndexPath:^(NSIndexPath *indexPath) {
        NSArray *array = _isPrivate ? [[MultipleVideo shareInstance] arrayForPrivateVideo] : [[MultipleVideo shareInstance] arrayForVideo];
        NSDictionary *dictionary = [array objectAtIndex:indexPath.section];
        NSArray *files = [dictionary objectForKey:FILE_NAME];
        NSInteger rowIndex = indexPath.row;
        if ([files count] <= rowIndex) { //私有公开的情况
            rowIndex -= [files count];
            dictionary = [[[MultipleVideo shareInstance] arrayForPrivateVideo] objectAtIndex:indexPath.section];
            files = [dictionary objectForKey:FILE_NAME];
        }
        NSDictionary *information = [files objectAtIndex:rowIndex];
        [sender setURLString:[information objectForKey:@"url"]
                       local:(0 == [[information objectForKey:@"type"] integerValue])
                        type:YES
                        name:[information objectForKey:@"name"]];
    }];
    [video.tableView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    PictureCollectionViewController *picture = [self.storyboard instantiateViewControllerWithIdentifier:@"PictureCollectionViewController"];
    [picture setTitle:MVLocalizedString(@"Picture_Title", @"图片")];
    [picture setBlockSelectedIndexPath:^(NSIndexPath *indexPath) {
        NSArray *array = _isPrivate ? [[MultipleVideo shareInstance] arrayForPrivateImage] : [[MultipleVideo shareInstance] arrayForImage];
        NSDictionary *dictionary = [array objectAtIndex:indexPath.section];
        NSArray *files = [dictionary objectForKey:FILE_NAME];
        NSInteger rowIndex = indexPath.row;
        if ([files count] <= rowIndex) { //私有公开的情况
            rowIndex -= [files count];
            dictionary = [[[MultipleVideo shareInstance] arrayForPrivateImage] objectAtIndex:indexPath.section];
            files = [dictionary objectForKey:FILE_NAME];
        }
        if (0 == [[dictionary objectForKey:FILE_TYPE_INDEX] integerValue]) {
            NSString *name = [files objectAtIndex:rowIndex];
            NSString *urlString = [NSString stringWithFormat:@"%@/%@", [dictionary objectForKey:FILE_PATH], name];
            [sender setURLString:urlString local:YES type:NO name:@"benben"];
        }
        else {
            [sender setURLString:[files objectAtIndex:rowIndex] local:NO type:NO name:@"benben"];
        }
    }];
    
    if (_isPrivate) {
        [video setIsPrivate:_isPrivate];
        [video setArray:[[MultipleVideo shareInstance] arrayForPrivateVideo]];
        [picture setIsPrivate:_isPrivate];
        [picture setArray:[[MultipleVideo shareInstance] arrayForPrivateImage]];
    }
    else {
        [video setArray:[[MultipleVideo shareInstance] arrayForVideo]];
        [picture setArray:[[MultipleVideo shareInstance] arrayForImage]];
    }
    
    AddPlayFileViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddPlayFileViewController"];
    [viewController setArrayForViewController:@[video, picture]];
    [self.navigationController pushViewController:viewController animated:YES];
    
//    ScrollViewController *scrollViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectFile"];
//    [scrollViewController setTitle:MVLocalizedString(@"Select_Title", @"选择文件")];
//    [scrollViewController setViewControllers:@[video, picture] selectedIndex:0];
//    [scrollViewController setButtonsHeight:44.0f font:nil color:nil selectedColor:[UIColor orangeColor]];
//    [scrollViewController setSupportSlidingGesture:YES];
//    [self.navigationController pushViewController:scrollViewController animated:YES];
}

- (void)fullScreenAtIndex:(NSInteger)index fullScreen:(BOOL)isFullScreen displayViewController:(DisplayViewController *)sender
{
    _fullScreenIndex = isFullScreen ? index : -1;
    [self layoutDisplayViewsBySplitNumber:_splitNumber landscape:_isLandscape];
}

#pragma mark - UIPopoverPresentationControllerDelegate

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller traitCollection:(UITraitCollection *)traitCollection
{
    return UIModalPresentationNone;
}

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    return YES; //NO是表示点弹出视图外面不会退出
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
