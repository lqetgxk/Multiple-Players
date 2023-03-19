//
//  DisplayViewController.m
//  MultipleVideo
//
//  Created by issuser on 2017/4/27.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import "DisplayViewController.h"
#import "MultipleVideo.h"
#import <IJKMediaFramework/IJKMediaFramework.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface DisplayViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *viewTop;
@property (weak, nonatomic) IBOutlet UIButton *buttonClose;
@property (weak, nonatomic) IBOutlet UIButton *buttonFullScreen;
@property (weak, nonatomic) IBOutlet UIButton *buttonTransform;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIView *viewBottom;
@property (weak, nonatomic) IBOutlet UILabel *labelPlayTime;
@property (weak, nonatomic) IBOutlet UILabel *labelTotalTime;
@property (weak, nonatomic) IBOutlet UISlider *sliderProgressBar;
@property (weak, nonatomic) IBOutlet UIButton *buttonAdd;
@property (weak, nonatomic) IBOutlet UIButton *buttonPlay;
@property (weak, nonatomic) IBOutlet UIButton *buttonVoice;
@property (weak, nonatomic) IBOutlet UIButton *buttonCapture;
@property (retain, nonatomic) id<IJKMediaPlayback> player;
@end

@implementation DisplayViewController {
    id<DisplayViewControllerDelegate> _delegate;
    NSTimer *_timer;
    NSString *_urlString;
    NSString *_displayName;
    BOOL _isLocal;
    BOOL _isVideo;
    BOOL _isHidden;
    BOOL _dragging;
    MBProgressHUD *_progressHUD;
    UIScrollView *_scrolleView;
    UIView *_viewVideo;
    UIImageView *_imageViewImage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _scrolleView = [[UIScrollView alloc] initWithFrame:[self.view bounds]];
    [_scrolleView setDelegate:self];
    [_scrolleView setMaximumZoomScale:10];
    [_scrolleView setMinimumZoomScale:1];
    [_scrolleView setShowsVerticalScrollIndicator:NO];
    [_scrolleView setShowsHorizontalScrollIndicator:NO];
    [self.view addSubview:_scrolleView];
    [self.view sendSubviewToBack:_scrolleView];
    
    _viewVideo = [[UIView alloc] initWithFrame:CGRectZero];
    [_scrolleView addSubview:_viewVideo];
    
    _imageViewImage = [[UIImageView alloc] initWithFrame:CGRectZero];
    [_imageViewImage setContentMode:UIViewContentModeScaleAspectFit];
    [_scrolleView addSubview:_imageViewImage];
    
    //手势参考 http://www.cnblogs.com/xiaofeixiang/p/4584175.html
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
    
    [_sliderProgressBar setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
    [_sliderProgressBar setThumbImage:[UIImage imageNamed:@"slider_drag"] forState:UIControlStateHighlighted];
    [_sliderProgressBar setMinimumTrackTintColor:[UIColor orangeColor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enterLockScreenNotification:)
                                                 name:NOTIFICATION_LOCKSCREEN_ENTER
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(exitLockScreenNotification:)
                                                 name:NOTIFICATION_LOCKSCREEN_EXIT
                                               object:nil];
    
    _isHidden = YES;
    [_viewTop setHidden:YES];
    [_viewBottom setHidden:YES];
    [_viewVideo setHidden:YES];
    [_imageViewImage setHidden:YES];
    
    _progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_progressHUD];
    [_progressHUD setMode:MBProgressHUDModeText];
    [_progressHUD setAnimationType:MBProgressHUDAnimationFade];
    [_progressHUD setOpaque:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self setPlayer:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_LOCKSCREEN_ENTER object:nil];
}

- (void)oneTapGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (_urlString) {
        _isHidden = !_isHidden;
        [_viewTop setHidden:_isHidden];
        [_viewBottom setHidden:!_isVideo || _isHidden];
    }
}

- (void)twoTapGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (_isVideo) {
        [self playSwitch:_buttonPlay];
    }
}

- (void)horizontalSwipeGestureRecognizer:(UISwipeGestureRecognizer *)gestureRecognizer
{
    static int STEP = 10;
    if (nil == _player) {
        return;
    }
    [_progressHUD show:YES];
    if (UISwipeGestureRecognizerDirectionRight == [gestureRecognizer direction]) { //前进
        NSTimeInterval second = [_player currentPlaybackTime] + STEP;
        if ([_player duration] < second) {
            int offset = (int)([_player duration] - [_player currentPlaybackTime]);
            [_progressHUD setLabelText:[NSString stringWithFormat:@"%@ %d %@", MVLocalizedString(@"Display_Forward", @"前进"), offset, MVLocalizedString(@"Display_Second", @"秒")]];
            second = [_player duration] - 1;
        }
        else {
            [_progressHUD setLabelText:[NSString stringWithFormat:@"%@ %d %@", MVLocalizedString(@"Display_Forward", @"前进"), STEP, MVLocalizedString(@"Display_Second", @"秒")]];
        }
        [self.player setCurrentPlaybackTime:second];
    }
    else if (UISwipeGestureRecognizerDirectionLeft == [gestureRecognizer direction]) { //后退
        NSTimeInterval second = [_player currentPlaybackTime] - STEP;
        if (0 > second) {
            int offset = (int)[_player currentPlaybackTime];
            [_progressHUD setLabelText:[NSString stringWithFormat:@"%@ %d %@", MVLocalizedString(@"Display_Back", @"后退"), offset, MVLocalizedString(@"Display_Second", @"秒")]];
            second = 0;
        }
        else {
            [_progressHUD setLabelText:[NSString stringWithFormat:@"%@ %d %@", MVLocalizedString(@"Display_Back", @"后退"), STEP, MVLocalizedString(@"Display_Second", @"秒")]];
        }
        [self.player setCurrentPlaybackTime:second];
    }
    [_progressHUD hide:YES afterDelay:0.5];
}

- (void)enterLockScreenNotification:(NSNotification *)notification
{
    if (_isVideo && _urlString && (0 == [_buttonPlay tag])) {
        [_player pause];
    }
}

- (void)exitLockScreenNotification:(NSNotification *)notification
{
    if (_isVideo && _urlString && (0 == [_buttonPlay tag])) {
        [_player play];
    }
}

- (void)refreshProgressBar:(NSTimer *)sender
{
    if (_dragging) {
        return;
    }
    NSTimeInterval duration = [_player duration];
    if (0 >= duration) {
        return;
    }
    [_sliderProgressBar setMaximumValue:duration];
    [_sliderProgressBar setMinimumValue:0];
    [_labelTotalTime setText:[NSString stringWithFormat:@"%02d:%02d", (int)(duration / 60), (int)duration % 60]];
    NSTimeInterval currentTime = [_player currentPlaybackTime];
    [_labelPlayTime setText:[NSString stringWithFormat:@"%02d:%02d", (int)currentTime / 60, (int)currentTime % 60]];
    [_sliderProgressBar setValue:currentTime];
}

- (void)loadStateDidChange:(NSNotification*)notification
{
    IJKMPMovieLoadState loadState = _player.loadState;
    if (0 != (loadState & IJKMPMovieLoadStatePlaythroughOK)) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStatePlaythroughOK: %d\n", (int)loadState);
    }
    else if (0 != (loadState & IJKMPMovieLoadStateStalled)) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d\n", (int)loadState);
    }
    else {
        NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
    }
}

- (void)moviePlayBackStateDidChange:(NSNotification*)notification
{
    switch (_player.playbackState) {
        case IJKMPMoviePlaybackStateStopped: {
            NSLog(@"moviePlayBackDidFinish: IJKMPMoviePlaybackStateStopped");
        } break;
        case IJKMPMoviePlaybackStatePlaying: {
            NSLog(@"moviePlayBackDidFinish: IJKMPMoviePlaybackStatePlaying");
            if (nil == _timer) {
                _timer = [NSTimer scheduledTimerWithTimeInterval:0.4
                                                          target:self
                                                        selector:@selector(refreshProgressBar:)
                                                        userInfo:nil
                                                         repeats:YES];
                NSTimeInterval lastTime = [[MultipleVideo shareInstance] lastTimeOfVideoFile:_displayName], duration = [_player duration];
                if ((2 < lastTime) && (duration > lastTime)) {
                    lastTime -= 2;
                    [self.player setCurrentPlaybackTime:lastTime];
                }
            }
        } break;
        case IJKMPMoviePlaybackStatePaused: {
            NSLog(@"moviePlayBackDidFinish: IJKMPMoviePlaybackStatePaused");
        } break;
        case IJKMPMoviePlaybackStateInterrupted: {
            NSLog(@"moviePlayBackDidFinish: IJKMPMoviePlaybackStateInterrupted");
        } break;
        case IJKMPMoviePlaybackStateSeekingForward: {
            NSLog(@"moviePlayBackDidFinish: IJKMPMoviePlaybackStateSeekingForward");
        } break;
        case IJKMPMoviePlaybackStateSeekingBackward: {
            NSLog(@"moviePlayBackDidFinish: IJKMPMoviePlaybackStateSeekingBackward");
        } break;
        default: NSLog(@"moviePlayBackDidFinish: unknown : %d", (int)_player.playbackState); break;
    }
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification
{
    int reason = [[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    switch (reason) {
        case IJKMPMovieFinishReasonPlaybackEnded: {
            NSLog(@"moviePlayBackDidFinish: IJKMPMovieFinishReasonPlaybackEnded");
            [_player play]; //循环播放
            //[self close:nil];
        } break;
        case IJKMPMovieFinishReasonUserExited: {
            NSLog(@"moviePlayBackDidFinish: IJKMPMovieFinishReasonUserExited");
        } break;
        case IJKMPMovieFinishReasonPlaybackError: {
            NSLog(@"moviePlayBackDidFinish: IJKMPMovieFinishReasonPlaybackError");
        } break;
        default: NSLog(@"moviePlayBackDidFinish: unknown : %d", reason); break;
    }
}

- (void)setPlayer:(id<IJKMediaPlayback>)player
{
    if (_player) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                                      object:_player];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                                      object:_player];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                                      object:_player];
        [[_player view] removeFromSuperview];
    }
    _player = player;
    if (_player) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loadStateDidChange:)
                                                     name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                                   object:_player];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayBackStateDidChange:)
                                                     name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                                   object:_player];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayBackDidFinish:)
                                                     name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                                   object:_player];
        [_player.view setFrame:[_viewVideo bounds]];
        [_player.view setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        [_player setScalingMode:IJKMPMovieScalingModeAspectFit];
        [_player setShouldAutoplay:YES];
        [_viewVideo setAutoresizesSubviews:YES];
        [_viewVideo addSubview:[_player view]];
    }
}

- (IBAction)close:(UIButton *)sender
{
    if (_isVideo) {
        if (_player) {
            NSTimeInterval lastTime = [_player currentPlaybackTime];
            [[MultipleVideo shareInstance] recordVideoFile:_displayName playTime:lastTime];
        }
        [_timer invalidate];
        _timer = nil;
        [_player shutdown];
        [self setPlayer:nil];
        [_buttonVoice setTag:0];
        [_buttonVoice setImage:[UIImage imageNamed:@"mute"] forState:UIControlStateNormal];
        [_buttonPlay setTag:0];
        [_buttonPlay setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        [_labelPlayTime setText:@"00:00"];
        [_labelTotalTime setText:@"00:00"];
        [_sliderProgressBar setValue:0];
    }
    [_viewTop setHidden:YES];
    [_viewBottom setHidden:YES];
    [_viewVideo setHidden:YES];
    [_imageViewImage setHidden:YES];
    [_buttonAdd setHidden:NO];
    _urlString = nil;
    _isHidden = YES;
    if ([_buttonFullScreen tag]) {
        [self fullScreen:_buttonFullScreen];
    }
    [_scrolleView setZoomScale:1 animated:YES];
}

- (IBAction)fullScreen:(UIButton *)sender
{
    if (0 == sender.tag) {
        [sender setTag:1];
        [sender setImage:[UIImage imageNamed:@"minimize"] forState:UIControlStateNormal];
        [_delegate fullScreenAtIndex:_index fullScreen:YES displayViewController:self];
    }
    else {
        [sender setTag:0];
        [sender setImage:[UIImage imageNamed:@"maximize"] forState:UIControlStateNormal];
        [_delegate fullScreenAtIndex:_index fullScreen:NO displayViewController:self];
    }
}

- (IBAction)transformWindow:(UIButton *)sender
{
    if ([sender tag]) {
        [sender setTag:0];
        [_viewVideo setTransform:CGAffineTransformMakeRotation(0)];
    }
    else {
        [sender setTag:1];
        [_viewVideo setTransform:CGAffineTransformMakeRotation(M_PI_2)];
    }
    //[[_viewVideo superview] layoutIfNeeded];
    [_viewVideo setFrame:[self.view bounds]];
}

- (IBAction)add:(UIButton *)sender
{
    [_delegate addFileAtIndex:_index displayViewController:self];
}

- (IBAction)dragProgressBarBegin:(UISlider *)sender
{
    _dragging = YES;
}

- (IBAction)dragProgressBar:(UISlider *)sender
{
    if ([_player duration]) {
        NSTimeInterval currentTime = [sender value];
        [_labelPlayTime setText:[NSString stringWithFormat:@"%02d:%02d", (int)currentTime / 60, (int)currentTime % 60]];
        [self.player setCurrentPlaybackTime:currentTime];
    }
}

- (IBAction)dragProgressBarEnd:(UISlider *)sender
{
    _dragging = NO;
}

- (IBAction)voiceSwitch:(UIButton *)sender
{
    if (0 == [sender tag]) {
        [_player setPlaybackVolume:0];
        [sender setTag:1];
        [sender setImage:[UIImage imageNamed:@"voice"] forState:UIControlStateNormal];
    }
    else {
        [_player setPlaybackVolume:1];
        [sender setTag:0];
        [sender setImage:[UIImage imageNamed:@"mute"] forState:UIControlStateNormal];
    }
}

- (IBAction)playSwitch:(UIButton *)sender
{
    if (0 == [sender tag]) {
        [_player pause];
        [sender setTag:1];
        [sender setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }
    else {
        [_player play];
        [sender setTag:0];
        [sender setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    }
}

- (IBAction)capture:(UIButton *)sender
{
    if ((nil == _urlString) || !_isVideo) {
        return;
    }
    NSArray *images = nil;
    if (_isPrivate) {
        images = [[MultipleVideo shareInstance] arrayForPrivateImage];
    }
    else {
        images = [[MultipleVideo shareInstance] arrayForImage];
    }
    NSDictionary *dictionaryForPicture = nil;
    for (NSDictionary *dictionary in images) {
        if (0 == [[dictionary objectForKey:FILE_TYPE_INDEX] integerValue]) {
            dictionaryForPicture = dictionary;
            break;
        }
    }
    NSString *path = [dictionaryForPicture objectForKey:FILE_PATH];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *name = [NSString stringWithFormat:@"%@_%.0f.png", [formatter stringFromDate:[NSDate date]],
                      [[NSDate date] timeIntervalSince1970] * 1000];
    if ([_player saveVideoSnapshotAt:[NSString stringWithFormat:@"%@/%@", path, name]]) {
        NSMutableArray *array = [dictionaryForPicture objectForKey:FILE_NAME];
        [array addObject:name];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_IMAGE object:nil];
    }
    else {
        NSLog(@"Save video snapshot at %@ fail!", name);
    }
}

- (void)setInformation:(NSDictionary *)information
{
    NSString *urlString = [information objectForKey:@"URLString"];
    if (nil == urlString) {
        return;
    }
    NSString *displayName = [information objectForKey:@"DisplayName"];
    NSNumber *isLocal = [information objectForKey:@"IsLocal"];
    NSNumber *isVideo = [information objectForKey:@"IsVideo"];
    if ([isLocal boolValue]) {
        NSArray *array = [urlString componentsSeparatedByString:@"/"];
        if (2 < [array count]) {
            NSString *where = [array objectAtIndex:([array count] - 2)];
            if ([where isEqualToString:@"Documents"]) { //公有文件
                NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
                urlString = [NSString stringWithFormat:@"%@/%@", path, [array lastObject]];
            }
            else if ([where isEqualToString:@"PrivateFiles"]) { //私有文件
                if ((NO == _isPrivate) && (1 != [[[MultipleVideo shareInstance] privatePublic] integerValue])) {
                    return; //从首页进来，但是又被关闭了对外公开功能，此时不能再打开这个文件
                }
                else {
                    NSString *privatePath = [NSString stringWithFormat:@"%@/Library/PrivateFiles", NSHomeDirectory()];
                    urlString = [NSString stringWithFormat:@"%@/%@", privatePath, [array lastObject]];
                }
            }
            else {
                return;
            }
        }
        else {
            return;
        }
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isDirectory = NO;
        BOOL isExist = [fileManager fileExistsAtPath:urlString isDirectory:&isDirectory];
        if ((NO == isExist) || isDirectory) {
            return;
        }
    }
    if (urlString) {
        [self setURLString:urlString local:[isLocal boolValue] type:[isVideo boolValue] name:displayName];
    }
}

- (NSDictionary *)information
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:_displayName forKey:@"DisplayName"];
    [dictionary setValue:_urlString forKey:@"URLString"];
    [dictionary setValue:[NSNumber numberWithBool:_isLocal] forKey:@"IsLocal"];
    [dictionary setValue:[NSNumber numberWithBool:_isVideo] forKey:@"IsVideo"];
    return dictionary;
}

- (void)setDisplayViewControllerDelegate:(id<DisplayViewControllerDelegate>)delegate
{
    _delegate = delegate;
}

- (void)setFrame:(CGRect)frame
{
    [self.view setFrame:frame];
    [_scrolleView setZoomScale:1 animated:YES];
    [_scrolleView setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [_scrolleView setContentOffset:CGPointMake(0, 0) animated:YES];
    [_scrolleView setContentSize:CGSizeMake(frame.size.width, frame.size.height)];
    [_viewVideo setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [_imageViewImage setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    CGRect sliderFrame = [_sliderProgressBar frame];
    sliderFrame.origin.x = CGRectGetMaxX([_labelPlayTime frame]) + 6;
    sliderFrame.size.width = CGRectGetMinX([_labelTotalTime frame]) - 6 - sliderFrame.origin.x;
    [_sliderProgressBar setFrame:sliderFrame];
    CGRect titleFrme = [_labelTitle frame];
    titleFrme.origin.x = CGRectGetMaxX([_buttonClose frame]) + 6;
    titleFrme.size.width = CGRectGetMinX([_buttonFullScreen frame]) - 6 - titleFrme.origin.x;
    [_labelTitle setFrame:titleFrme];
}

- (void)setHidden:(BOOL)isHidden
{
    [self.view setHidden:isHidden];
}

- (void)setURLString:(NSString *)urlString local:(BOOL)isLocal type:(BOOL)isVideo name:(NSString *)name
{
    _urlString = urlString;
    _isLocal = isLocal;
    _isVideo = isVideo;
    _displayName = name;
    if (isVideo) {
        [_labelTitle setText:name];
        [_imageViewImage setHidden:YES];
        [_viewVideo setHidden:NO];
        //NSString *urlString = @"http://vf1.mtime.cn/Video/2012/04/23/mp4/120423212602431929.mp4";
        IJKFFOptions *options = [IJKFFOptions optionsByDefault];
        [options setFormatOptionIntValue:500 forKey:@"analyzeduration"];
        [self setPlayer:[[IJKFFMoviePlayerController alloc] initWithContentURLString:urlString withOptions:options]];
        [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_SILENT]; //不输出那些烦人的日志，查看源码后才知放这里才有效
        [_player prepareToPlay];
    }
    else {
        [_labelTitle setText:@""];
        [_viewVideo setHidden:YES];
        [_viewBottom setHidden:YES];
        [_imageViewImage setHidden:NO];
        if (isLocal) {
            [_imageViewImage setImage:[UIImage imageNamed:urlString]];
        }
        else {
            [_imageViewImage sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:name]];
        }
    }
    [_buttonTransform setHidden:!isVideo];
    [_buttonCapture setHidden:!isVideo];
    [_buttonVoice setHidden:!isVideo];
    [_buttonAdd setHidden:YES];
}

- (void)play
{
    [self playSwitch:_buttonPlay];
}

- (void)pause
{
    [self playSwitch:_buttonPlay];
}

- (void)stop
{
    [self close:nil];
}

- (BOOL)isPlayVideo
{
    return _isVideo && _urlString;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _isVideo ? _viewVideo : _imageViewImage;
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
