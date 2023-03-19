//
//  VideoClipViewController.m
//  MultipleVideo
//
//  Created by issuser on 2017/8/6.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import "VideoClipViewController.h"
#import "PictureCollectionViewCell.h"
#import "SelectFileTableViewController.h"
#import "UIViewController+BackButtonHandler.h"
#import "MultipleVideo.h"
#import <AVFoundation/AVFoundation.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface VideoClipViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonItemSelectFile;
@property (weak, nonatomic) IBOutlet UIButton *buttonBeginTime;
@property (weak, nonatomic) IBOutlet UIButton *buttonEndTime;
@property (weak, nonatomic) IBOutlet UIButton *buttonClip;
@property (weak, nonatomic) IBOutlet UILabel *labelCurrentTime;
@property (weak, nonatomic) IBOutlet UILabel *labelTotalTime;
@property (weak, nonatomic) IBOutlet UILabel *labelBeginTime;
@property (weak, nonatomic) IBOutlet UILabel *labelEndTime;
@property (weak, nonatomic) IBOutlet UIView *viewDisplay;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewBegin;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewEnd;
@property (weak, nonatomic) IBOutlet UIView *viewToolbar;
@property (assign, nonatomic) BOOL isPause;
@end

@implementation VideoClipViewController {
    NSMutableArray *_array;
    AVURLAsset *_urlAsset;
    AVPlayer *_avPlayer;
    AVPlayerItem *_playerItem;
    AVPlayerLayer *_playerLayer;
    AVAssetImageGenerator *_imageGenerator;
    NSInteger _totalSeconds;
    NSInteger _currentSeconds;
    NSInteger _beginSeconds;
    NSInteger _endSeconds;
}

static NSString * const reuseIdentifier = @"ImageCollectionViewCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[self.navigationItem backBarButtonItem] setTitle:MVLocalizedString(@"Home_Left_Back", @"返回")];
    [_labelTitle setText:MVLocalizedString(@"VideoClip_Title", @"视频剪辑")];
    [_labelBeginTime setText:[NSString stringWithFormat:@"%@：00:00", MVLocalizedString(@"VideoClip_Begin_Time", @"开始时间")]];
    [_labelEndTime setText:[NSString stringWithFormat:@"%@：00:00", MVLocalizedString(@"VideoClip_End_Time", @"结束时间")]];
    [_buttonBeginTime setTitle:MVLocalizedString(@"VideoClip_Begin_Time", @"开始时间") forState:UIControlStateNormal];
    [_buttonEndTime setTitle:MVLocalizedString(@"VideoClip_End_Time", @"结束时间") forState:UIControlStateNormal];
    [_buttonClip setTitle:MVLocalizedString(@"VideoClip_Clip", @"剪辑") forState:UIControlStateNormal];
    _array = [[NSMutableArray alloc] init];
    [self.collectionView registerClass:[PictureCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    if (_video) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 100 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
            [self loadVideoInformation];
        });
        [_buttonClip setEnabled:NO];
        [_buttonClip setBackgroundColor:[UIColor lightGrayColor]];
        [_barButtonItemSelectFile setTitle:MVLocalizedString(@"VideoClip_Replace", @"更换")];
    }
    else {
        [_buttonBeginTime setEnabled:NO];
        [_buttonBeginTime setBackgroundColor:[UIColor lightGrayColor]];
        [_buttonClip setEnabled:NO];
        [_buttonClip setBackgroundColor:[UIColor lightGrayColor]];
        [_buttonEndTime setEnabled:NO];
        [_buttonEndTime setBackgroundColor:[UIColor lightGrayColor]];
        [_barButtonItemSelectFile setTitle:MVLocalizedString(@"VideoClip_Add", @"添加")];
    }
    UITapGestureRecognizer *oneTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneTapGestureRecognizer:)];
    [oneTapGestureRecognizer setNumberOfTouchesRequired:1]; //手指数
    [oneTapGestureRecognizer setNumberOfTapsRequired:1]; //触摸次数
    [_viewDisplay addGestureRecognizer:oneTapGestureRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enterLockScreenNotification:)
                                                 name:NOTIFICATION_LOCKSCREEN_ENTER
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(exitLockScreenNotification:)
                                                 name:NOTIFICATION_LOCKSCREEN_EXIT
                                               object:nil];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGRect frame = [self.viewToolbar frame];
    frame.size.height = kTabBarHeight;
    frame.origin.y = self.view.bounds.size.height - kTabBarHeight;
    [self.viewToolbar setFrame:frame];
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
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_LOCKSCREEN_ENTER object:nil];
}

- (BOOL)navigationShouldPopOnBackButton
{
    [_avPlayer pause];
    [_playerItem removeObserver:self forKeyPath:@"status"];
    [_playerLayer removeFromSuperlayer];
    _isPause = YES;
    return YES;
}

- (void)oneTapGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (_isPause) {
        [_avPlayer play];
        _isPause = NO;
    }
    else {
        [_avPlayer pause];
        _isPause = YES;
    }
}

- (void)enterLockScreenNotification:(NSNotification *)notification
{
    if (NO == _isPause) {
        [_avPlayer pause];
    }
}

- (void)exitLockScreenNotification:(NSNotification *)notification
{
    if (NO == _isPause) {
        [_avPlayer play];
    }
}

- (void)loadVideoInformation
{
    [_buttonBeginTime setEnabled:YES];
    [_buttonBeginTime setBackgroundColor:[UIColor orangeColor]];
    [_buttonClip setEnabled:NO];
    [_buttonClip setBackgroundColor:[UIColor lightGrayColor]];
    [_buttonEndTime setEnabled:YES];
    [_buttonEndTime setBackgroundColor:[UIColor orangeColor]];
    
    _urlAsset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:[_video objectForKey:@"url"]]];
    _imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:_urlAsset];
    [_imageGenerator setAppliesPreferredTrackTransform:YES];
    CMTime time = [_urlAsset duration];
    CMTime timeBegin = CMTimeMakeWithEpoch(0, time.timescale, time.epoch), timeBeginActual;
    CMTime timeEnd = CMTimeMakeWithEpoch(time.value, time.timescale, time.epoch), timeEndActual;
    CGImageRef imageBegin = [_imageGenerator copyCGImageAtTime:timeBegin actualTime:&timeBeginActual error:nil];
    CGImageRef imageEnd = [_imageGenerator copyCGImageAtTime:timeEnd actualTime:&timeEndActual error:nil];
    
    [_array removeAllObjects];
    for (NSInteger i = 0, unit = time.value / 12; i < 12; i++) {
        CMTime cmtime = CMTimeMakeWithEpoch(i * unit, time.timescale, time.epoch);
        CGImageRef image = [_imageGenerator copyCGImageAtTime:cmtime actualTime:nil error:nil];
        if (image) {
            [_array addObject:[UIImage imageWithCGImage:image]];
        }
    }
    [self.collectionView reloadData];
    _totalSeconds = time.value / time.timescale;
    
    NSInteger seconds = time.value / time.timescale;
    [_labelTotalTime setText:[NSString stringWithFormat:@"%02ld:%02ld", seconds / 60, seconds % 60]];
    [_imageViewBegin setImage:[UIImage imageWithCGImage:imageBegin]];
    seconds = timeBeginActual.value / timeBeginActual.timescale;
    [_labelBeginTime setText:[NSString stringWithFormat:@"%@：%02ld:%02ld", MVLocalizedString(@"VideoClip_Begin_Time", @"开始时间"), seconds / 60, seconds % 60]];
    [_imageViewEnd setImage:[UIImage imageWithCGImage:imageEnd]];
    seconds = timeEndActual.value / timeEndActual.timescale;
    [_labelEndTime setText:[NSString stringWithFormat:@"%@：%02ld:%02ld", MVLocalizedString(@"VideoClip_End_Time", @"结束时间"), seconds / 60, seconds % 60]];
    
    NSURL *url = [NSURL fileURLWithPath:[_video objectForKey:@"url"]];
    _playerItem = [AVPlayerItem playerItemWithURL:url];
    [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    _avPlayer = [AVPlayer playerWithPlayerItem:_playerItem];
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_avPlayer];
    [_playerLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    [_playerLayer setFrame:[_viewDisplay bounds]];
    [_viewDisplay.layer addSublayer:_playerLayer];
    __weak typeof(self) weakSelf = self; //破解循环引用
    [_avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time){
        if ([weakSelf isPause]) {
            return ;
        }
        _currentSeconds = time.value / time.timescale;
        [weakSelf.labelCurrentTime setText:[NSString stringWithFormat:@"%02ld:%02ld", _currentSeconds / 60, _currentSeconds % 60]];
        CGFloat offset = _currentSeconds * ([_collectionView contentSize].width - [_collectionView bounds].size.width) / _totalSeconds;
        [weakSelf.collectionView setContentOffset:CGPointMake(offset, 0) animated:YES];
    }];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context
{
    if ([keyPath isEqualToString:@"status"]) {
        switch ([_playerItem status]) {
            case AVPlayerItemStatusReadyToPlay: {
                NSLog(@"AVPlayerItemStatusReadyToPlay");
                [_avPlayer play];
                _isPause = NO;
            } break;
            case AVPlayerItemStatusUnknown: {
                NSLog(@"AVPlayerItemStatusUnknown");
            } break;
            case AVPlayerItemStatusFailed: {
                NSLog(@"AVPlayerItemStatusFailed:%@", [_playerItem error]);
            } break;
            default: break;
        }
    }
}

- (IBAction)setBeginTime:(UIButton *)sender
{
    _beginSeconds = _currentSeconds;
    CMTime time = [_urlAsset duration];
    CMTime timeBegin = CMTimeMakeWithEpoch(time.timescale * _beginSeconds, time.timescale, time.epoch), timeBeginActual;
    CGImageRef imageBegin = [_imageGenerator copyCGImageAtTime:timeBegin actualTime:&timeBeginActual error:nil];
    [_imageViewBegin setImage:[UIImage imageWithCGImage:imageBegin]];
    NSInteger seconds = timeBeginActual.value / timeBeginActual.timescale;
    [_labelBeginTime setText:[NSString stringWithFormat:@"%@：%02ld:%02ld",  MVLocalizedString(@"VideoClip_Begin_Time", @"开始时间"), seconds / 60, seconds % 60]];
    if (_beginSeconds == _endSeconds) {
        [_buttonBeginTime setEnabled:YES];
        [_buttonBeginTime setBackgroundColor:[UIColor orangeColor]];
        [_buttonClip setEnabled:NO];
        [_buttonClip setBackgroundColor:[UIColor lightGrayColor]];
        [_buttonEndTime setEnabled:YES];
        [_buttonEndTime setBackgroundColor:[UIColor orangeColor]];
    }
    else {
        [_buttonBeginTime setEnabled:YES];
        [_buttonBeginTime setBackgroundColor:[UIColor orangeColor]];
        [_buttonClip setEnabled:YES];
        [_buttonClip setBackgroundColor:[UIColor orangeColor]];
        [_buttonEndTime setEnabled:YES];
        [_buttonEndTime setBackgroundColor:[UIColor orangeColor]];
    }
}

- (IBAction)setEndTime:(UIButton *)sender
{
    _endSeconds = _currentSeconds;
    CMTime time = [_urlAsset duration];
    CMTime timeEnd = CMTimeMakeWithEpoch(time.timescale * _endSeconds, time.timescale, time.epoch), timeEndActual;
    CGImageRef imageEnd = [_imageGenerator copyCGImageAtTime:timeEnd actualTime:&timeEndActual error:nil];
    [_imageViewEnd setImage:[UIImage imageWithCGImage:imageEnd]];
    NSInteger seconds = timeEndActual.value / timeEndActual.timescale;
    [_labelEndTime setText:[NSString stringWithFormat:@"%@：%02ld:%02ld", MVLocalizedString(@"VideoClip_End_Time", @"结束时间"), seconds / 60, seconds % 60]];
    if (_beginSeconds == _endSeconds) {
        [_buttonBeginTime setEnabled:YES];
        [_buttonBeginTime setBackgroundColor:[UIColor orangeColor]];
        [_buttonClip setEnabled:NO];
        [_buttonClip setBackgroundColor:[UIColor lightGrayColor]];
        [_buttonEndTime setEnabled:YES];
        [_buttonEndTime setBackgroundColor:[UIColor orangeColor]];
    }
    else {
        [_buttonBeginTime setEnabled:YES];
        [_buttonBeginTime setBackgroundColor:[UIColor orangeColor]];
        [_buttonClip setEnabled:YES];
        [_buttonClip setBackgroundColor:[UIColor orangeColor]];
        [_buttonEndTime setEnabled:YES];
        [_buttonEndTime setBackgroundColor:[UIColor orangeColor]];
    }
}

- (IBAction)clip:(UIButton *)sender
{
    [_buttonBeginTime setEnabled:NO];
    [_buttonBeginTime setBackgroundColor:[UIColor lightGrayColor]];
    [_buttonClip setEnabled:NO];
    [_buttonClip setBackgroundColor:[UIColor lightGrayColor]];
    [_buttonEndTime setEnabled:NO];
    [_buttonEndTime setBackgroundColor:[UIColor lightGrayColor]];
    MBProgressHUD *progressHUD = [MBProgressHUD showHUDAddedTo:[self view] animated:YES];
    [progressHUD setMode:MBProgressHUDModeIndeterminate];
    [progressHUD setLabelText:MVLocalizedString(@"VideoClip_Editing", @"正在剪辑")];
    if (_beginSeconds > _endSeconds) { //调整顺序
        NSInteger temp = _beginSeconds;
        _beginSeconds = _endSeconds;
        _endSeconds = temp;
    }
    
    //http://www.jianshu.com/p/5433143cccd8 参照了这里的源码
    AVAssetTrack *assetVideoTrack = nil;
    AVAssetTrack *assetAudioTrack = nil;
    if ([[_urlAsset tracksWithMediaType:AVMediaTypeVideo] count]) {
        assetVideoTrack = [_urlAsset tracksWithMediaType:AVMediaTypeVideo][0];
    }
    if ([[_urlAsset tracksWithMediaType:AVMediaTypeAudio] count]) {
        assetAudioTrack = [_urlAsset tracksWithMediaType:AVMediaTypeAudio][0];
    }
    CMTime time = [_urlAsset duration];
    CMTime timeBegin = CMTimeMakeWithEpoch(time.timescale * _beginSeconds, time.timescale, time.epoch);
    CMTime timeDuration = CMTimeMakeWithEpoch(time.timescale * (_endSeconds - _beginSeconds), time.timescale, time.epoch);
    NSError *error = nil;
    AVMutableComposition *mutableComposition = [AVMutableComposition composition];
    if(assetVideoTrack) {
        AVMutableCompositionTrack *compositionVideoTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                                           preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionVideoTrack insertTimeRange:CMTimeRangeMake(timeBegin, timeDuration)
                                       ofTrack:assetVideoTrack
                                        atTime:kCMTimeZero
                                         error:&error];
        if (error) {
            NSLog(@"AssetVideoTrack:%@", error);
        }
    }
    if(assetAudioTrack) {
        AVMutableCompositionTrack *compositionAudioTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                           preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionAudioTrack insertTimeRange:CMTimeRangeMake(timeBegin, timeDuration)
                                       ofTrack:assetAudioTrack
                                        atTime:kCMTimeZero
                                         error:&error];
        if (error) {
            NSLog(@"AssetAudioTrack:%@", error);
        }
    }
    
    NSArray *arrayForTypes = nil;
    if (_isPrivate) {
        arrayForTypes = [[MultipleVideo shareInstance] arrayForPrivateVideo];
    }
    else {
        arrayForTypes = [[MultipleVideo shareInstance] arrayForVideo];
    }
    NSMutableDictionary *localVideo = nil;
    for (NSMutableDictionary *dictionary in  arrayForTypes) {
        if (0 == [[dictionary objectForKey:FILE_TYPE_INDEX] integerValue]) { //本地视频
            localVideo = dictionary;
            break;
        }
    }
    NSString *path = [localVideo objectForKey:FILE_PATH];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *name = [NSString stringWithFormat:@"%@.mov", [formatter stringFromDate:[NSDate date]]];
    NSURL *outputURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", path, name]];
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:mutableComposition
                                                                           presetName:AVAssetExportPreset1920x1080];
    [exportSession setOutputFileType:AVFileTypeQuickTimeMovie];
    [exportSession setOutputURL:outputURL];
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch ([exportSession status]) {
            case AVAssetExportSessionStatusCompleted: {
                NSMutableArray *videos = [localVideo objectForKey:FILE_NAME];
                [videos addObject:[MultipleVideo informationOfVideoFileAtPath:path name:name]];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_VIDEO object:nil];
                [progressHUD setLabelText:MVLocalizedString(@"VideoClip_Succeed", @"成功")];
            } break;
            case AVAssetExportSessionStatusFailed: {
                [progressHUD setLabelText:MVLocalizedString(@"VideoClip_Failed", @"失败")];
                NSLog(@"Failed:%@", [exportSession error]);
            } break;
            case AVAssetExportSessionStatusCancelled: {
                [progressHUD setLabelText:MVLocalizedString(@"VideoClip_Failed", @"失败")];
                NSLog(@"Canceled:%@", [exportSession error]);
            } break;
            default: break;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1000 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
            [progressHUD hide:YES];
            [_buttonBeginTime setEnabled:YES];
            [_buttonBeginTime setBackgroundColor:[UIColor orangeColor]];
            [_buttonClip setEnabled:NO];
            [_buttonClip setBackgroundColor:[UIColor lightGrayColor]];
            [_buttonEndTime setEnabled:YES];
            [_buttonEndTime setBackgroundColor:[UIColor orangeColor]];
        });
    }];
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
    [cell setPictureAtImage:[_array objectAtIndex:indexPath.row]];
    return cell;
}

#pragma mark UICollectionViewDelegate

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    CGRect frame = [collectionView frame];
    return UIEdgeInsetsMake(0, frame.size.width/2, 0, frame.size.width/2);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.collectionView scrollToItemAtIndexPath:indexPath
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_avPlayer pause];
    _isPause = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_isPause) {
        CGFloat offset = [scrollView contentOffset].x;
        _currentSeconds = _totalSeconds * offset / ([scrollView contentSize].width - [scrollView bounds].size.width);
        [_labelCurrentTime setText:[NSString stringWithFormat:@"%02ld:%02ld", _currentSeconds / 60, _currentSeconds % 60]];
        CMTime time = [_urlAsset duration];
        [_avPlayer seekToTime:CMTimeMake(_currentSeconds * time.timescale, time.timescale)];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UIViewController *viewController = [segue destinationViewController];
    if ([viewController isKindOfClass:[SelectFileTableViewController class]]) {
        [_avPlayer pause];
        [(SelectFileTableViewController *)viewController setIsPrivate:_isPrivate];
        [(SelectFileTableViewController *)viewController setBlockSelectedFile:^(NSDictionary *information) {
            [self setVideo:information];
            [_avPlayer pause];
            [_playerItem removeObserver:self forKeyPath:@"status"];
            [_playerLayer removeFromSuperlayer];
            [_barButtonItemSelectFile setTitle:MVLocalizedString(@"VideoClip_Replace", @"更换")];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 100 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
                [self loadVideoInformation];
            });
        }];
    }
}

@end
