//
//  ApplePlayerViewController.m
//  MultipleVideo
//
//  Created by issuser on 2017/8/9.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import "ApplePlayerViewController.h"
#import "UIViewController+BackButtonHandler.h"
#import "AppDelegate.h"
#import "VideoTableViewCell.h"
#import "MultipleVideo.h"
#import <AVFoundation/AVFoundation.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface ApplePlayerViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonItemFullScreen;
@property (weak, nonatomic) IBOutlet UIView *viewDisplay;
@property (weak, nonatomic) IBOutlet UIView *viewProgress;
@property (weak, nonatomic) IBOutlet UIView *viewVideoTop;
@property (weak, nonatomic) IBOutlet UIButton *buttonCancel;
@property (weak, nonatomic) IBOutlet UIView *viewVideoBottom;
@property (weak, nonatomic) IBOutlet UILabel *labelVideoName;
@property (weak, nonatomic) IBOutlet UILabel *labelVideoCurrentTime;
@property (weak, nonatomic) IBOutlet UILabel *labelCurrentTime;
@property (weak, nonatomic) IBOutlet UILabel *labelTotalTime;
@property (weak, nonatomic) IBOutlet UISlider *sliderVideoProgressBar;
@property (weak, nonatomic) IBOutlet UISlider *sliderProgressBar;
@property (weak, nonatomic) IBOutlet UILabel *labelVideoTotalTime;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) BOOL isPause;
@property (assign, nonatomic) NSInteger currentSeconds;
@end

@implementation ApplePlayerViewController {
    NSMutableArray *_array;
    AVPlayer *_avPlayer;
    AVURLAsset *_urlAsset;
    AVPlayerItem *_playerItem;
    AVPlayerLayer *_playerLayer;
    CGRect _viewDisplayFrame;
    BOOL _allowShow;
    MBProgressHUD *_progressHUD;
    UIScrollView *_scrolleView;
    UIView *_viewVideo;
    CGFloat _beginTouchX;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        [self.viewDisplay setFrame:CGRectMake(0, 0, screenSize.width, screenSize.width * 9 / 16)];
        [self.viewProgress setFrame:CGRectMake(0, [self.viewDisplay frame].size.height, screenSize.width, [self.viewProgress frame].size.height)];
        CGFloat y = CGRectGetMaxY([self.viewProgress frame]);
        [self.tableView setFrame:CGRectMake(0, y, screenSize.width, screenSize.height - y - kNavigationHeight - kBottomSafeAreaHeight)];
        _viewDisplayFrame = [_viewDisplay frame];
    });
    
    [_labelTitle setText:MVLocalizedString(@"VideoPlay_Title", @"视频播放")];
    [_buttonItemFullScreen setTitle:MVLocalizedString(@"VideoPlay_Full_Screen", @"全屏")];
    [_buttonCancel setTitle:MVLocalizedString(@"VideoPlay_Normal_Screen", @"取消") forState:UIControlStateNormal];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [_sliderProgressBar setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
    [_sliderProgressBar setThumbImage:[UIImage imageNamed:@"slider_drag"] forState:UIControlStateHighlighted];
    [_sliderProgressBar setMinimumTrackTintColor:[UIColor orangeColor]];
    [_sliderProgressBar setEnabled:NO];
    [_sliderVideoProgressBar setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
    [_sliderVideoProgressBar setThumbImage:[UIImage imageNamed:@"slider_drag"] forState:UIControlStateHighlighted];
    [_sliderVideoProgressBar setMinimumTrackTintColor:[UIColor orangeColor]];
    [_sliderVideoProgressBar setEnabled:NO];
    
    _scrolleView = [[UIScrollView alloc] initWithFrame:[self.viewDisplay bounds]];
    [_scrolleView setDelegate:self];
    [_scrolleView setMaximumZoomScale:10];
    [_scrolleView setMinimumZoomScale:1];
    [_scrolleView setShowsVerticalScrollIndicator:NO];
    [_scrolleView setShowsHorizontalScrollIndicator:NO];
    [self.viewDisplay addSubview:_scrolleView];
    [self.viewDisplay sendSubviewToBack:_scrolleView];
    
    _viewVideo = [[UIView alloc] initWithFrame:[self.viewDisplay bounds]];
    [_scrolleView addSubview:_viewVideo];
    
    UITapGestureRecognizer *oneTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneTapGestureRecognizer:)];
    [oneTapGestureRecognizer setNumberOfTouchesRequired:1]; //手指数
    [oneTapGestureRecognizer setNumberOfTapsRequired:1]; //触摸次数
    [_scrolleView addGestureRecognizer:oneTapGestureRecognizer]; //工具样的显示与隐藏
    
    UITapGestureRecognizer *twoTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(twoTapGestureRecognizer:)];
    [twoTapGestureRecognizer setNumberOfTouchesRequired:1];
    [twoTapGestureRecognizer setNumberOfTapsRequired:2];
    [_scrolleView addGestureRecognizer:twoTapGestureRecognizer]; //视频的暂停与播放

    UISwipeGestureRecognizer *leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(horizontalSwipeGestureRecognizer:)];
    [leftSwipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [_scrolleView addGestureRecognizer:leftSwipeGestureRecognizer]; //视频的前进
    UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(horizontalSwipeGestureRecognizer:)];
    [rightSwipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [_scrolleView addGestureRecognizer:rightSwipeGestureRecognizer]; //视频的后退
    
    _array = [[NSMutableArray alloc] init];
    if (_isPrivate) {
        [self filterFileAtArray:[[MultipleVideo shareInstance] arrayForPrivateVideo]];
        if (_video) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
                [self resetDisplayView];
                [self playVideo:_video];
            });
        }
    } else {
        [self filterFileAtArray:[[MultipleVideo shareInstance] arrayForVideo]];
        if (1 == [[[MultipleVideo shareInstance] privatePublic] integerValue]) {
            [self filterFileAtArray:[[MultipleVideo shareInstance] arrayForPrivateVideo]];
        }
        if (_video) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
                [self resetDisplayView];
                [self playVideo:_video];
            });
        }
    }
    [self.view bringSubviewToFront:_viewDisplay];
    [_viewVideoTop setHidden:YES];
    [_viewVideoBottom setHidden:YES];
    
    _progressHUD = [[MBProgressHUD alloc] initWithView:self.viewDisplay];
    [self.viewDisplay addSubview:_progressHUD];
    [_progressHUD setMode:MBProgressHUDModeText];
    [_progressHUD setAnimationType:MBProgressHUDAnimationFade];
    [_progressHUD setOpaque:NO];
    
    //暂停不住，不知道为什么
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterLockScreenNotification:) name:NOTIFICATION_LOCKSCREEN_ENTER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitLockScreenNotification:) name:NOTIFICATION_LOCKSCREEN_EXIT object:nil];
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
    if ([_array count] && _video) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_array indexOfObject:_video] inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_LOCKSCREEN_ENTER object:nil];
}

- (void)resetDisplayView
{
    [_scrolleView setZoomScale:1 animated:YES];
    [_scrolleView setFrame:[self.viewDisplay bounds]];
    [_scrolleView setContentOffset:CGPointMake(0, 0) animated:YES];
    [_scrolleView setContentSize:CGSizeMake([self.viewDisplay bounds].size.width, [self.viewDisplay bounds].size.height)];
    [_viewVideo setFrame:[self.viewDisplay bounds]];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if ((UIDeviceOrientationLandscapeLeft == toInterfaceOrientation) ||
        (UIDeviceOrientationLandscapeRight == toInterfaceOrientation)) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [_viewDisplay setFrame:[self.view bounds]];
        [_playerLayer setFrame:[_viewDisplay bounds]];
        CGRect frame = [_viewVideoTop frame];
        frame.origin.y = 0;
        [_viewVideoTop setFrame:frame];
        frame = [_viewVideoBottom frame];
        frame.origin.y = self.view.bounds.size.height - frame.size.height - kBottomSafeAreaHeight;
        [_viewVideoBottom setFrame:frame];
        [_buttonCancel setHidden:YES];
        _allowShow = YES;
    }
    else {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        [_viewDisplay setFrame:_viewDisplayFrame];
        [_playerLayer setFrame:[_viewDisplay bounds]];
        [_viewVideoTop setHidden:YES];
        [_viewVideoBottom setHidden:YES];
        [_buttonCancel setHidden:NO];
        _allowShow = NO;
    }
    [self resetDisplayView];
}

- (BOOL)navigationShouldPopOnBackButton
{
    [_avPlayer pause];
    [_playerItem removeObserver:self forKeyPath:@"status"];
    [_playerLayer removeFromSuperlayer];
    _isPause = YES;
    return YES;
}

- (void)filterFileAtArray:(NSArray *)array
{
    for (NSDictionary *dictionary in array) {
        if (0 == [[dictionary objectForKey:FILE_TYPE_INDEX] integerValue]) { //本地视频
            NSArray *videos = [dictionary objectForKey:FILE_NAME];
            for (NSDictionary *information in videos) {
                if ([[information objectForKey:@"apple"] boolValue]) {
                    [_array addObject:information];
                }
            }
            break;
        }
    }
}

- (void)oneTapGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (NO == _allowShow) {
        [self pauseOrPlay];
        return;
    }
    BOOL isHidden = [_viewVideoTop isHidden];
    [_viewVideoTop setHidden:!isHidden];
    [_viewVideoBottom setHidden:!isHidden];
}

- (void)twoTapGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (_allowShow) {
        [self pauseOrPlay];
    }
}

- (void)horizontalSwipeGestureRecognizer:(UISwipeGestureRecognizer *)gestureRecognizer
{
    static int STEP = 10;
    if (nil == _avPlayer) {
        return;
    }
    [_progressHUD show:YES];
    CMTime time = [_urlAsset duration];
    if (UISwipeGestureRecognizerDirectionRight == [gestureRecognizer direction]) { //前进
        NSInteger totalSeconds = time.value / time.timescale;
        NSTimeInterval seconds = _currentSeconds + STEP;
        if (totalSeconds < seconds) {
            int offset = (int)(totalSeconds - _currentSeconds);
            [_progressHUD setLabelText:[NSString stringWithFormat:@"%@ %d %@", MVLocalizedString(@"Display_Forward", @"前进"), offset, MVLocalizedString(@"Display_Second", @"秒")]];
            seconds = totalSeconds - 1;
        }
        else {
            [_progressHUD setLabelText:[NSString stringWithFormat:@"%@ %d %@", MVLocalizedString(@"Display_Forward", @"前进"), STEP, MVLocalizedString(@"Display_Second", @"秒")]];
        }
        [_avPlayer seekToTime:CMTimeMake(seconds * time.timescale, time.timescale)];
    }
    else if (UISwipeGestureRecognizerDirectionLeft == [gestureRecognizer direction]) { //后退
        NSTimeInterval seconds = _currentSeconds - STEP;
        if (0 > seconds) {
            [_progressHUD setLabelText:[NSString stringWithFormat:@"%@ %ld %@", MVLocalizedString(@"Display_Back", @"后退"), (long)_currentSeconds, MVLocalizedString(@"Display_Second", @"秒")]];
            seconds = 0;
        }
        else {
            [_progressHUD setLabelText:[NSString stringWithFormat:@"%@ %d %@", MVLocalizedString(@"Display_Back", @"后退"), STEP, MVLocalizedString(@"Display_Second", @"秒")]];
        }
        [_avPlayer seekToTime:CMTimeMake(seconds * time.timescale, time.timescale)];
    }
    [_progressHUD hide:YES afterDelay:0.5];
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
    [_labelVideoName setText:[_video objectForKey:@"name"]];
    _urlAsset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:pathName]];
    CMTime time = [_urlAsset duration];
    NSInteger totalSeconds = time.value / time.timescale;
    [_sliderProgressBar setMinimumValue:0];
    [_sliderProgressBar setMaximumValue:totalSeconds];
    [_sliderProgressBar setValue:0 animated:YES];
    [_sliderProgressBar setEnabled:YES];
    [_sliderVideoProgressBar setMinimumValue:0];
    [_sliderVideoProgressBar setMaximumValue:totalSeconds];
    [_sliderVideoProgressBar setValue:0 animated:YES];
    [_sliderVideoProgressBar setEnabled:YES];
    [_labelTotalTime setText:[NSString stringWithFormat:@"%02ld:%02ld", totalSeconds / 60, totalSeconds % 60]];
    [_labelVideoTotalTime setText:[NSString stringWithFormat:@"%02ld:%02ld", totalSeconds / 60, totalSeconds % 60]];
    
    NSURL *url = [NSURL fileURLWithPath:[_video objectForKey:@"url"]];
    _playerItem = [AVPlayerItem playerItemWithURL:url];
    [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    _avPlayer = [AVPlayer playerWithPlayerItem:_playerItem];
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_avPlayer];
    [_playerLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    [_playerLayer setFrame:[_viewVideo bounds]];
    [_viewVideo.layer addSublayer:_playerLayer];
    __weak typeof(self) weakSelf = self; //破解循环引用
    [_avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time){
        [weakSelf setCurrentSeconds:time.value / time.timescale];
        [weakSelf.labelCurrentTime setText:[NSString stringWithFormat:@"%02ld:%02ld", weakSelf.currentSeconds / 60, weakSelf.currentSeconds % 60]];
        [weakSelf.labelVideoCurrentTime setText:[NSString stringWithFormat:@"%02ld:%02ld", weakSelf.currentSeconds / 60, weakSelf.currentSeconds % 60]];
        [weakSelf.sliderProgressBar setValue:weakSelf.currentSeconds animated:YES];
        [weakSelf.sliderVideoProgressBar setValue:weakSelf.currentSeconds animated:YES];
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
    [_labelVideoName setText:@""];
    [_labelCurrentTime setText:@"00:00"];
    [_labelVideoCurrentTime setText:@"00:00"];
    [_labelTotalTime setText:@"00:00"];
    [_labelVideoTotalTime setText:@"00:00"];
    [_sliderProgressBar setValue:0 animated:YES];
    [_sliderProgressBar setEnabled:NO];
    [_sliderVideoProgressBar setValue:0 animated:YES];
    [_sliderVideoProgressBar setEnabled:NO];
    [self setCurrentSeconds:0];
}

- (IBAction)cancelFullScreen:(UIButton *)sender
{
    _allowShow = NO;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [_viewVideoTop setHidden:YES];
    [_viewVideoBottom setHidden:YES];
    [UIView animateWithDuration:0.3 animations:^{
        [_viewDisplay setFrame:_viewDisplayFrame];
        [self resetDisplayView];
        [_playerLayer setFrame:[_viewVideo bounds]];
        CGRect frame = [_viewVideoTop frame];
        frame.origin.y = 0;
        [_viewVideoTop setFrame:frame];
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)fullScreen:(UIBarButtonItem *)sender
{
    _allowShow = YES;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [UIView animateWithDuration:0.3 animations:^{
        [_viewDisplay setFrame:[self.view bounds]];
        [self resetDisplayView];
        [_playerLayer setFrame:[_viewVideo bounds]];
        CGRect frame = [_viewVideoTop frame];
        frame.origin.y = 20 + kTopSafeAreaHeight;
        [_viewVideoTop setFrame:frame];
        frame = [_viewVideoBottom frame];
        frame.origin.y = self.view.bounds.size.height - frame.size.height - kBottomSafeAreaHeight;
        [_viewVideoBottom setFrame:frame];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)pauseOrPlay
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
    [_labelVideoCurrentTime setText:[NSString stringWithFormat:@"%02ld:%02ld", seconds / 60, seconds % 60]];
    CMTime time = [_urlAsset duration];
    [_avPlayer seekToTime:CMTimeMake(seconds * time.timescale, time.timescale)];
}

- (IBAction)dragProgressBarEnd:(UISlider *)sender
{
    if (NO == _isPause) {
        [_avPlayer play];
    }
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
    if (NO == [_video isEqual:[_array objectAtIndex:indexPath.row]]) {
        [self stopPlay];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
            [self resetDisplayView];
            [self playVideo:[_array objectAtIndex:indexPath.row]];
        });
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _viewVideo;
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
