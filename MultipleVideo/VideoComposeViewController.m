//
//  VideoComposeViewController.m
//  MultipleVideo
//
//  Created by issuser on 2017/8/6.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import "VideoComposeViewController.h"
#import "SelectFileTableViewController.h"
#import "UIViewController+BackButtonHandler.h"
#import "VideoTableViewCell.h"
#import "MultipleVideo.h"
#import <AVFoundation/AVFoundation.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface VideoComposeViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIButton *buttonAdd;
@property (weak, nonatomic) IBOutlet UIView *viewDisplay;
@property (weak, nonatomic) IBOutlet UILabel *labelCurrentTime;
@property (weak, nonatomic) IBOutlet UILabel *labelTotalTime;
@property (weak, nonatomic) IBOutlet UISlider *sliderProgressBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *buttonCompose;
@property (weak, nonatomic) IBOutlet UIView *viewToolbar;
@property (assign, nonatomic) BOOL isPause;
@end

@implementation VideoComposeViewController {
    NSMutableArray *_array;
    AVPlayer *_avPlayer;
    AVURLAsset *_urlAsset;
    AVPlayerItem *_playerItem;
    AVPlayerLayer *_playerLayer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[self.navigationItem backBarButtonItem] setTitle:MVLocalizedString(@"Home_Left_Back", @"返回")];
    [_labelTitle setText:MVLocalizedString(@"VideoSynthesis_Title", @"视频合成")];
    [_buttonAdd setTitle:MVLocalizedString(@"VideoSynthesis_Add", @"添加") forState:UIControlStateNormal];
    [_buttonCompose setTitle:MVLocalizedString(@"VideoSynthesis_Synthesis", @"合成") forState:UIControlStateNormal];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.tableView setAllowsSelectionDuringEditing:YES];
    [self.tableView setEditing:YES animated:YES];
    [_sliderProgressBar setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
    [_sliderProgressBar setThumbImage:[UIImage imageNamed:@"slider_drag"] forState:UIControlStateHighlighted];
    [_sliderProgressBar setMinimumTrackTintColor:[UIColor orangeColor]];
    [_sliderProgressBar setEnabled:NO];
    _array = [[NSMutableArray alloc] init];
    if (_video) {
        [_array addObject:_video];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 100 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
            [self playVideo:_video];
        });
    }
    [_buttonCompose setEnabled:NO];
    [_buttonCompose setBackgroundColor:[UIColor lightGrayColor]];
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
    if ((NO == _isPause) && _video) {
        [_avPlayer play];
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

- (void)playVideo:(NSDictionary *)information
{
    [self setVideo:information];
    NSString *pathName = [_video objectForKey:@"url"];
    _urlAsset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:pathName]];
    CMTime time = [_urlAsset duration];
    NSInteger totalSeconds = time.value / time.timescale;
    [_sliderProgressBar setMinimumValue:0];
    [_sliderProgressBar setMaximumValue:totalSeconds];
    [_sliderProgressBar setValue:0 animated:YES];
    [_sliderProgressBar setEnabled:YES];
    [_labelTotalTime setText:[NSString stringWithFormat:@"%02ld:%02ld", totalSeconds / 60, totalSeconds % 60]];
    
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
        NSInteger currentSeconds = time.value / time.timescale;
        [weakSelf.labelCurrentTime setText:[NSString stringWithFormat:@"%02ld:%02ld", currentSeconds / 60, currentSeconds % 60]];
        [weakSelf.sliderProgressBar setValue:currentSeconds animated:YES];
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

- (void)stopPlay
{
    [_avPlayer pause];
    [_playerItem removeObserver:self forKeyPath:@"status"];
    [_playerLayer removeFromSuperlayer];
    _avPlayer = nil;
    _playerItem = nil;
    _playerLayer = nil;
    [_labelCurrentTime setText:@"00:00"];
    [_labelTotalTime setText:@"00:00"];
    [_sliderProgressBar setValue:0 animated:YES];
    [_sliderProgressBar setEnabled:NO];
}

- (IBAction)dragProgressBarBegin:(UISlider *)sender
{
    if (NO == _isPause) {
        [_avPlayer pause];
    }
}

- (IBAction)dragProgressBar:(UISlider *)sender
{
    NSInteger seconds = [sender value];
    [_labelCurrentTime setText:[NSString stringWithFormat:@"%02ld:%02ld", seconds / 60, seconds % 60]];
    CMTime time = [_urlAsset duration];
    [_avPlayer seekToTime:CMTimeMake(seconds * time.timescale, time.timescale)];
}

- (IBAction)dragProgressBarEnd:(UISlider *)sender
{
    if (NO == _isPause) {
        [_avPlayer play];
    }
}

- (IBAction)compose:(UIButton *)sender
{
    [_buttonCompose setEnabled:NO];
    [_buttonCompose setBackgroundColor:[UIColor lightGrayColor]];
    MBProgressHUD *progressHUD = [MBProgressHUD showHUDAddedTo:[self view] animated:YES];
    [progressHUD setMode:MBProgressHUDModeIndeterminate];
    [progressHUD setLabelText:MVLocalizedString(@"VideoSynthesis_Compositing", @"正在合成")];
    
    NSError *error = nil;
    AVMutableComposition* mutableComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *compositionVideoTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                                       preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *compositionAudioTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                       preferredTrackID:kCMPersistentTrackID_Invalid];
    Float64 tmpDuration =0.0f;
    for (NSDictionary *information in _array) {
        NSURL *url = [NSURL fileURLWithPath:[information objectForKey:@"url"]];
        AVURLAsset *urlAsset = [[AVURLAsset alloc]initWithURL:url options:nil];
        AVAssetTrack *assetVideoTrack = [urlAsset tracksWithMediaType:AVMediaTypeVideo][0];
        AVAssetTrack *assetAudioTrack = [urlAsset tracksWithMediaType:AVMediaTypeAudio][0];
        CMTimeRange timeRangeVideo = CMTimeRangeMake(kCMTimeZero,[urlAsset duration]);
        [compositionVideoTrack insertTimeRange:timeRangeVideo
                                       ofTrack:assetVideoTrack
                                        atTime:CMTimeMakeWithSeconds(tmpDuration, 0)
                                         error:&error];
        [compositionAudioTrack insertTimeRange:timeRangeVideo
                                       ofTrack:assetAudioTrack
                                        atTime:CMTimeMakeWithSeconds(tmpDuration, 0)
                                         error:&error];
        tmpDuration += CMTimeGetSeconds(urlAsset.duration);
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
                [progressHUD setLabelText:MVLocalizedString(@"VideoSynthesis_Succeed", @"成功")];
            } break;
            case AVAssetExportSessionStatusFailed: {
                [progressHUD setLabelText:MVLocalizedString(@"VideoSynthesis_Failed", @"失败")];
                NSLog(@"Failed:%@", [exportSession error]);
            } break;
            case AVAssetExportSessionStatusCancelled: {
                [progressHUD setLabelText:MVLocalizedString(@"VideoSynthesis_Failed", @"失败")];
                NSLog(@"Canceled:%@", [exportSession error]);
            } break;
            default: break;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1000 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
            [progressHUD hide:YES];
        });
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VideoTableViewCell"];
    if (nil == cell) {
        cell = [[VideoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"VideoTableViewCell"];
    }
    [cell setContentDictionary:[_array objectAtIndex:indexPath.row]];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 61;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (NO == [_video isEqual:[_array objectAtIndex:indexPath.row]]) {
        [self stopPlay];
        [self playVideo:[_array objectAtIndex:indexPath.row]];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return MVLocalizedString(@"VideoSynthesis_Delete", @"删除");
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        if ([_video isEqual:[_array objectAtIndex:indexPath.row]]) {
            [self stopPlay];
            [self setVideo:nil];
        }
        [tableView beginUpdates];
        [_array removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
        if (2 > [_array count]) {
            [_buttonCompose setEnabled:NO];
            [_buttonCompose setBackgroundColor:[UIColor lightGrayColor]];
        }
        else {
            [_buttonCompose setEnabled:YES];
            [_buttonCompose setBackgroundColor:[UIColor orangeColor]];
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [_array exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
    if (1 < [_array count]) {
        [_buttonCompose setEnabled:YES];
        [_buttonCompose setBackgroundColor:[UIColor orangeColor]];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
 // Return NO if you do not want the item to be re-orderable.
    return YES;
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
            if ([_array containsObject:information]) {
                return ;
            }
            [_array addObject:information];
            if (1 < [_array count]) {
                [_buttonCompose setEnabled:YES];
                [_buttonCompose setBackgroundColor:[UIColor orangeColor]];
            }
            [self.tableView reloadData];
        }];
    }
}

@end
