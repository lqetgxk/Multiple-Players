//
//  PictureViewController.m
//  MultipleVideo
//
//  Created by issuser on 2017/4/28.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import "PictureViewController.h"
#import "PictureCollectionViewController.h"
#import "MultipleVideo.h"

@interface PictureViewController ()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *viewToolbar;
@property (weak, nonatomic) IBOutlet UIButton *buttonDelete;
@property (weak, nonatomic) IBOutlet UIButton *buttonAlbum;
@property (weak, nonatomic) IBOutlet UIButton *buttonAdd;
@end

@implementation PictureViewController {
    PictureCollectionViewController *_pictureCollectionViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGRect frame = [self.viewToolbar frame];
    frame.size.height = kTabBarHeight;
    frame.origin.y = [self.view bounds].size.height - frame.size.height;
    [self.viewToolbar setFrame:frame];
    //[self.containerView setFrame:self.view.bounds];
    [_viewToolbar setHidden:YES];
    [self.view bringSubviewToFront:_viewToolbar];
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
    [_buttonAlbum setTitle:MVLocalizedString(@"Picture_To_Album", @"存入到相册") forState:UIControlStateNormal];
    [_buttonAdd setTitle:MVLocalizedString(@"Home_Add", @"添加") forState:UIControlStateNormal];
    for (NSMutableDictionary *dictionary in [[MultipleVideo shareInstance] arrayForImage]) {
        if (0 == [[dictionary objectForKey:FILE_TYPE_INDEX] integerValue]) {
            [dictionary setValue:MVLocalizedString(@"Picture_Local_File", @"本地图片") forKey:FILE_TYPE_NAME];
        }
        else if (1 == [[dictionary objectForKey:FILE_TYPE_INDEX] integerValue]) {
            [dictionary setValue:MVLocalizedString(@"Picture_Network_File", @"网络图片") forKey:FILE_TYPE_NAME];
        }
    }
    for (NSMutableDictionary *dictionary in [[MultipleVideo shareInstance] arrayForPrivateImage]) {
        if (0 == [[dictionary objectForKey:FILE_TYPE_INDEX] integerValue]) {
            [dictionary setValue:MVLocalizedString(@"Picture_Local_File", @"本地图片") forKey:FILE_TYPE_NAME];
        }
        else if (1 == [[dictionary objectForKey:FILE_TYPE_INDEX] integerValue]) {
            [dictionary setValue:MVLocalizedString(@"Picture_Network_File", @"网络图片") forKey:FILE_TYPE_NAME];
        }
    }
    if (notification) { //上面两个for块放外面的原因是可能还没有进这个界面就已经切换语言了的情况
        [_pictureCollectionViewController reloadData];
    }
}

- (void)setEnableEdit:(BOOL)enableEdit
{
    _enableEdit = enableEdit;
    [_pictureCollectionViewController setEnableEdit:enableEdit];
    [_viewToolbar setHidden:!enableEdit];
}

- (void)openCamera:(UIButton *)sender
{
    [_pictureCollectionViewController openCamera:sender];
}

- (IBAction)add:(UIButton *)sender
{
    [_pictureCollectionViewController addPicture:sender];
}

- (IBAction)saveToAlbum:(UIButton *)sender
{
    [_pictureCollectionViewController saveToAlbum];
}

- (IBAction)delete:(UIButton *)sender
{
    [_pictureCollectionViewController deleteSelectedPictures];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UIViewController *viewController = [segue destinationViewController];
    if ([viewController isKindOfClass:[PictureCollectionViewController class]]) {
        _pictureCollectionViewController = (PictureCollectionViewController *)viewController;
        [_pictureCollectionViewController setArray:[[MultipleVideo shareInstance] arrayForImage]];
    }
}

@end
