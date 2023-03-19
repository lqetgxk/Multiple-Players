//
//  SelectVideoViewController.m
//  MultipleVideo
//
//  Created by issuser on 2017/6/19.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import "SelectVideoViewController.h"
#import "VideoCollectionViewCell.h"
#import "MultipleVideo.h"
#import <Photos/Photos.h>

@interface SelectVideoViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIButton *buttonCancel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) PHFetchResult *assetFetchResult;
@end

@implementation SelectVideoViewController {
    NSUInteger _numberInLine;
}

static NSString * const reuseIdentifier = @"VideoTableViewCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_labelTitle setText:MVLocalizedString(@"Video_Alert_Title1", @"视频")];
    [_buttonCancel setTitle:MVLocalizedString(@"Home_Alert_Cancel", @"取消") forState:UIControlStateNormal];
    
    [self.collectionView registerClass:[VideoCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    _numberInLine = 3;
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus]; //判断是否有访问权限
    if (PHAuthorizationStatusNotDetermined == status) { //还没有去做选择
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (PHAuthorizationStatusAuthorized == status) { //已经授权
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self loadAlbumsData];
                });
            }
            else{ //做一个没有授权的提示
                NSLog(@"No right!");
            }
        }];
    }
    else if (PHAuthorizationStatusAuthorized == status){ //已经授权
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadAlbumsData];
        });
    }
    else if ((PHAuthorizationStatusRestricted == status) || (PHAuthorizationStatusDenied == status)){ //拒绝访问
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:MVLocalizedString(@"Video_Alert_Title5", @"没有权限")
                                                                           message:MVLocalizedString(@"Video_Alert_Message5", @"需要设置")
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:MVLocalizedString(@"Home_Alert_Know", @"知道了")
                                                      style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        });
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadAlbumsData
{
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                          subtype:PHAssetCollectionSubtypeSmartAlbumVideos
                                                                          options:nil];
    for (PHCollection *collection in smartAlbums) {
        PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
        if ([collection isKindOfClass:[PHCollection class]] &&
            (PHAssetCollectionSubtypeSmartAlbumVideos == [assetCollection assetCollectionSubtype])) {
            [self setAssetFetchResult:[PHAsset fetchAssetsInAssetCollection:assetCollection options:nil]];
        }
    }
    [_collectionView reloadData];
}

- (IBAction)cancel:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_assetFetchResult count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VideoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                                                              forIndexPath:indexPath];
    [cell updateContentWithPHAsset:[_assetFetchResult objectAtIndex:indexPath.row]];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat space = [(UICollectionViewFlowLayout *)collectionViewLayout minimumInteritemSpacing] * (_numberInLine - 1);
    CGFloat width = ([collectionView bounds].size.width - space) / _numberInLine;
    CGFloat height = width;
    return CGSizeMake(width, height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PHAsset *asset = [_assetFetchResult objectAtIndex:indexPath.row];
    if (PHAssetMediaTypeVideo == [asset mediaType]) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            AVURLAsset *urlAsset = (AVURLAsset *)asset;
            NSString *filePath = [[urlAsset URL] absoluteString];
            if (8 < [filePath length]) {
                NSString *videoPath = [filePath substringFromIndex:8];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self blockSelectedFile](videoPath);
                    [self dismissViewControllerAnimated:YES completion:nil];
                });
            }
        }];
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
