//
//  HistoryBrowserViewController.m
//  CloudVideo
//
//  Created by issuser on 2017/4/11.
//  Copyright © 2017年 ChinaMobile. All rights reserved.
//

#import "PictureBrowserViewController.h"
#import "PictureCollectionViewCell.h"
#import <MWPhotoBrowser/MWPhotoBrowser.h>
#import "MultipleVideo.h"

@interface PictureBrowserViewController () <UICollectionViewDataSource, UICollectionViewDelegate, MWPhotoBrowserDelegate>
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonItemShare;
@property (weak, nonatomic) IBOutlet UIView *viewBrowser;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@end

@implementation PictureBrowserViewController {
    MWPhotoBrowser *_photoBrowser;
}

static NSString * const reuseIdentifier = @"BrowserCollectionViewCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    [self.collectionView registerClass:[PictureCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    [_labelTitle setText:MVLocalizedString(@"Picture_Browser_Title", @"图片浏览器")];
    [_barButtonItemShare setTitle:MVLocalizedString(@"Picture_Browser_Share", @"删除")]; //将之前的分享功能去子掉
    
    //使用参照了 http://www.cnblogs.com/dreamDeveloper/p/6055944.html
    _photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    [_photoBrowser setCurrentPhotoIndex:_index];
    [_photoBrowser setDisplayActionButton:NO];
    [_photoBrowser setEnableGrid:NO];
    [_photoBrowser setDisplayNavArrows:NO];
    [_photoBrowser setAlwaysShowControls:NO];
    [_photoBrowser setBackgroundColor:[UIColor whiteColor]]; //修改了源码，添加的方法
    [_photoBrowser.view setFrame:[_viewBrowser bounds]];
    [_viewBrowser addSubview:_photoBrowser.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_photoBrowser viewWillAppear:animated]; //修改了源码，添加的方法
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_photoBrowser viewDidAppear:animated]; //修改了源码，添加的方法
}

- (void)disableDelete
{
    [self.navigationItem setRightBarButtonItem:nil];
}

- (IBAction)share:(UIBarButtonItem *)sender //现在改为删除了
{
    if ([_array count]) {
        NSUInteger index = [_photoBrowser currentIndex];
        NSString *name = [_array objectAtIndex:index];
        [_array removeObjectAtIndex:index];
        [_collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_IMAGE object:nil];
        if (_localFile) {
            NSString *pathName = [NSString stringWithFormat:@"%@/%@", _path, name];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:pathName error:nil];
        }
        else {
            [[MultipleVideo shareInstance] removeNetworkImageObjects:@[[NSIndexPath indexPathForRow:index inSection:0]] isPrivate:_isPrivate];
        }
        index = (index < [_array count]) ? index : (index - 1);
        [_photoBrowser setCurrentPhotoIndex:index];
        [_photoBrowser reloadData];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_array count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PictureCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    if (_localFile) {
        NSString *pathName = [NSString stringWithFormat:@"%@/%@", _path, [_array objectAtIndex:indexPath.row]];
        [cell setPictureByURLString:pathName local:YES enableEdit:NO];
    }
    else {
        [cell setPictureByURLString:[_array objectAtIndex:indexPath.row] local:NO enableEdit:NO];
    }
    return cell;
}

#pragma mark <UICollectionViewDelegate>

#define Cell_Width 50
#define Cell_Height 50

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(Cell_Width, Cell_Height);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    CGRect frame = [collectionView frame];
    return UIEdgeInsetsMake(0, (frame.size.width - Cell_Width)/2, 0, (frame.size.width - Cell_Width)/2);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    //http://www.cnblogs.com/dreamDeveloper/p/6055944.html
//    MWPhotoBrowser *photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
//    [photoBrowser setCurrentPhotoIndex:indexPath.row];
//    [photoBrowser setDisplayActionButton:YES];
//    [photoBrowser setEnableGrid:YES];
//    [photoBrowser setDisplayNavArrows:YES];
//    [photoBrowser setAlwaysShowControls:YES];
//    [self.navigationController pushViewController:photoBrowser animated:YES];
    
    [_photoBrowser setCurrentPhotoIndex:indexPath.row];
    [self.collectionView scrollToItemAtIndexPath:indexPath
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:YES];
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return [_array count];
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    MWPhoto *photo = nil;
    if (_localFile) {
        NSString *pathName = [NSString stringWithFormat:@"%@/%@", _path, [_array objectAtIndex:index]];
        photo = [MWPhoto photoWithImage:[UIImage imageNamed:pathName]];
    }
    else {
        photo = [MWPhoto photoWithURL:[NSURL URLWithString:[_array objectAtIndex:index]]];
    }
    return photo;
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index
{
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:YES];
}

//网格加载缩略图时调用
- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index
{
    MWPhoto *photo = nil;
    if (_localFile) {
        NSString *pathName = [NSString stringWithFormat:@"%@/%@", _path, [_array objectAtIndex:index]];
        photo = [MWPhoto photoWithImage:[UIImage imageNamed:pathName]];
    }
    else {
        photo = [MWPhoto photoWithURL:[NSURL URLWithString:[_array objectAtIndex:index]]];
    }
    return photo;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
