//
//  MultipleVideo.m
//  MultipleVideo
//
//  Created by issuser on 2017/4/26.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import "MultipleVideo.h"
#import <AVFoundation/AVFoundation.h>

@implementation MultipleVideo {
    NSMutableArray *_arrayForNetworkVideo;
    NSMutableArray *_arrayForNetworkImage;
    NSMutableArray *_arrayForPrivateNetworkVideo;
    NSMutableArray *_arrayForPrivateNetworkImage;
    NSMutableDictionary *_dictionaryForPlayTime;
}

+ (NSMutableDictionary *)informationOfVideoFileAtPath:(NSString *)path name:(NSString *)name
{
    NSString *pathName = [NSString stringWithFormat:@"%@/%@", path, name];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:@"0" forKey:@"type"];
    [dictionary setValue:path forKey:@"path"];
    [dictionary setValue:name forKey:@"name"];
    [dictionary setValue:pathName forKey:@"url"];
    unsigned long long size = [[[NSFileManager defaultManager] attributesOfItemAtPath:pathName error:nil] fileSize];
    [dictionary setValue:[NSNumber numberWithUnsignedLongLong:size] forKey:@"size"];
    
    NSRange range = [name rangeOfString:@"." options:NSBackwardsSearch];
    if (NSNotFound == range.location) {
        [dictionary setValue:[NSNumber numberWithInteger:0] forKey:@"duration"];
        [dictionary setValue:[UIImage imageNamed:@"benben"] forKey:@"thumbnails"];
        [dictionary setValue:[NSNumber numberWithInteger:0] forKey:@"width"];
        [dictionary setValue:[NSNumber numberWithInteger:0] forKey:@"height"];
        [dictionary setValue:[NSNumber numberWithBool:NO] forKey:@"apple"];
    }
    else {
        NSString *extension = [[name substringFromIndex:(range.location + 1)] lowercaseString];
        if ([extension isEqualToString:@"avi"] || [extension isEqualToString:@"mkv"] ||
            [extension isEqualToString:@"rmvb"] || [extension isEqualToString:@"wmv"]) {
            [dictionary setValue:[NSNumber numberWithInteger:0] forKey:@"duration"];
            [dictionary setValue:[UIImage imageNamed:@"benben"] forKey:@"thumbnails"];
            [dictionary setValue:[NSNumber numberWithInteger:0] forKey:@"width"];
            [dictionary setValue:[NSNumber numberWithInteger:0] forKey:@"height"];
            [dictionary setValue:[NSNumber numberWithBool:NO] forKey:@"apple"];
        }
        else {
            AVURLAsset *urlAsset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:pathName]];
            CMTime time = [urlAsset duration];
            [dictionary setValue:[NSNumber numberWithInteger:(time.value / time.timescale)] forKey:@"duration"];
            CMTime centreTime = CMTimeMakeWithEpoch(time.value / 2, time.timescale, time.epoch);
            AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:urlAsset];
            [imageGenerator setAppliesPreferredTrackTransform:YES];
            NSError *error = nil;
            CMTime actualTime;
            CGImageRef image = [imageGenerator copyCGImageAtTime:centreTime actualTime:&actualTime error:&error];
            if (error) {
                NSLog(@"%@", error);
                [dictionary setValue:[UIImage imageNamed:@"benben"] forKey:@"thumbnails"];
                [dictionary setValue:[NSNumber numberWithBool:NO] forKey:@"apple"];
            }
            else {
                [dictionary setValue:[[UIImage alloc] initWithCGImage:image] forKey:@"thumbnails"];
                [dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"apple"];
            }
            NSArray *tracks = [urlAsset tracksWithMediaType:AVMediaTypeVideo];
            if ([tracks count]) {
                AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
                [dictionary setValue:[NSNumber numberWithInteger:[videoTrack naturalSize].width] forKey:@"width"];
                [dictionary setValue:[NSNumber numberWithInteger:[videoTrack naturalSize].height] forKey:@"height"];
            }
            else {
                [dictionary setValue:[NSNumber numberWithInteger:0] forKey:@"width"];
                [dictionary setValue:[NSNumber numberWithInteger:0] forKey:@"height"];
            }
        }
    }
    return dictionary;
}

+ (void)shakeAnimationForView:(UIView *)view
{
    CALayer *viewLayer = view.layer;
    CGPoint position = viewLayer.position;
    CGPoint left = CGPointMake(position.x - 10, position.y);
    CGPoint right = CGPointMake(position.x + 10, position.y);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setFromValue:[NSValue valueWithCGPoint:left]];
    [animation setToValue:[NSValue valueWithCGPoint:right]];
    [animation setAutoreverses:YES]; // 平滑结束
    [animation setDuration:0.08];
    [animation setRepeatCount:3];
    
    [viewLayer addAnimation:animation forKey:nil];
}

+ (MultipleVideo *)shareInstance
{
    static MultipleVideo *multipleVideo = nil;
    while (nil == multipleVideo) {
        multipleVideo = [[MultipleVideo alloc] init];
    }
    return multipleVideo;
}

- (id)init
{
    self = [super init];
    if (self) {
        _isRecordPlayTime = [[[NSUserDefaults standardUserDefaults] objectForKey:@"IsRecordPlayTime"] boolValue];
        _dictionaryForPlayTime = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"VideoLastTime"]];
        if (nil == _dictionaryForPlayTime) {
            _dictionaryForPlayTime = [[NSMutableDictionary alloc] init];
        }
        _password = [[NSUserDefaults standardUserDefaults] objectForKey:@"Password"];
        _privatePassword = [[NSUserDefaults standardUserDefaults] objectForKey:@"PrivatePassword"];
        _privateLock = [[NSUserDefaults standardUserDefaults] objectForKey:@"PrivateLock"];
        _privatePublic = [[NSUserDefaults standardUserDefaults] objectForKey:@"PrivatePublic"];
        _privateDescribe = [[NSUserDefaults standardUserDefaults] objectForKey:@"PrivateDescribe"];
        if (nil == _privatePassword) { //还没有设置过私有密码
            _privatePassword = @"";
        }
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        [self readInformationWithPath:path private:NO];
        NSString *privatePath = [NSString stringWithFormat:@"%@/Library/PrivateFiles", NSHomeDirectory()];
        BOOL isDirectory = NO;
        BOOL isExist = [fileManager fileExistsAtPath:privatePath isDirectory:&isDirectory];
        if ((NO == isExist) || (NO == isDirectory)) {
            [fileManager createDirectoryAtPath:privatePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        [self readInformationWithPath:privatePath private:YES];
        //NSLog(@"Private password is %@", _privatePassword);
        //NSLog(@"%@", path);
    }
    return self;
}

- (void)readInformationWithPath:(NSString *)path private:(BOOL)isPrivate
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *arrayForFile = [[NSFileManager defaultManager] subpathsAtPath:path];
    NSMutableArray *videos = [[NSMutableArray alloc] init];
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (NSString *fileName in arrayForFile) {
        NSString *pathName = [NSString stringWithFormat:@"%@/%@", path, fileName];
        BOOL isDirectory = NO;
        BOOL isExist = [fileManager fileExistsAtPath:pathName isDirectory:&isDirectory];
        if ((NO == isExist) || isDirectory) {
            continue;
        }
        NSRange range = [fileName rangeOfString:@"." options:NSBackwardsSearch];
        if (NSNotFound == range.location) {
            [videos addObject:[MultipleVideo informationOfVideoFileAtPath:path name:fileName]];
        }
        else {
            NSString *extension = [[fileName substringFromIndex:(range.location + 1)] lowercaseString];
            if ([extension isEqualToString:@"png"] || [extension isEqualToString:@"jpg"] ||
                [extension isEqualToString:@"jpeg"] || [extension isEqualToString:@"gif"] ||
                [extension isEqualToString:@"bmp"]) {
                [images addObject:fileName];
            }
            else {
                //[videos addObject:fileName];
                [videos addObject:[MultipleVideo informationOfVideoFileAtPath:path name:fileName]];
            }
        }
    }
    
    NSMutableDictionary *localVideo = [[NSMutableDictionary alloc] init];
    [localVideo setValue:MVLocalizedString(@"Video_Local_File", @"本地视频") forKey:FILE_TYPE_NAME];
    [localVideo setValue:@"0" forKey:FILE_TYPE_INDEX];
    [localVideo setValue:path forKey:FILE_PATH];
    [localVideo setValue:videos forKey:FILE_NAME];
    NSMutableDictionary *networkVideo = [[NSMutableDictionary alloc] init];
    [networkVideo setValue:MVLocalizedString(@"Video_Network_File", @"网络视频") forKey:FILE_TYPE_NAME];
    [networkVideo setValue:@"1" forKey:FILE_TYPE_INDEX];
    [networkVideo setValue:path forKey:FILE_PATH];
    
    NSMutableDictionary *localImage = [[NSMutableDictionary alloc] init];
    [localImage setValue:MVLocalizedString(@"Picture_Local_File", @"本地图片") forKey:FILE_TYPE_NAME];
    [localImage setValue:@"0" forKey:FILE_TYPE_INDEX];
    [localImage setValue:path forKey:FILE_PATH];
    [localImage setValue:images forKey:FILE_NAME];
    NSMutableDictionary *networkImage = [[NSMutableDictionary alloc] init];
    [networkImage setValue:MVLocalizedString(@"Picture_Network_File", @"网络图片") forKey:FILE_TYPE_NAME];
    [networkImage setValue:@"1" forKey:FILE_TYPE_INDEX];
    [networkImage setValue:path forKey:FILE_PATH];
    
    if (isPrivate) {
        _arrayForPrivateGroup = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"PrivateGroups"]];
        if (nil == _arrayForPrivateGroup) {
            _arrayForPrivateGroup = [[NSMutableArray alloc] init];
        }
        _arrayForPrivateNetworkVideo = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"PrivateNetworkVideos"]];
        if (nil == _arrayForPrivateNetworkVideo) {
            _arrayForPrivateNetworkVideo = [[NSMutableArray alloc] init];
        }
        _arrayForPrivateNetworkImage = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"PrivateNetworkImages"]];
        if (nil == _arrayForPrivateNetworkImage) {
            _arrayForPrivateNetworkImage = [[NSMutableArray alloc] init];
        }
        
        [networkVideo setValue:_arrayForPrivateNetworkVideo forKey:FILE_NAME];
        _arrayForPrivateVideo = [[NSMutableArray alloc] init];
        [_arrayForPrivateVideo addObject:localVideo];
        [_arrayForPrivateVideo addObject:networkVideo];
        
        [networkImage setValue:_arrayForPrivateNetworkImage forKey:FILE_NAME];
        _arrayForPrivateImage = [[NSMutableArray alloc] init];
        [_arrayForPrivateImage addObject:localImage];
        [_arrayForPrivateImage addObject:networkImage];
    }
    else {
        _arrayForGroup = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"Groups"]];
        if (nil == _arrayForGroup) {
            _arrayForGroup = [[NSMutableArray alloc] init];
        }
        _arrayForNetworkVideo = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"NetworkVideos"]];
        if (nil == _arrayForNetworkVideo) {
            _arrayForNetworkVideo = [[NSMutableArray alloc] init];
        }
        _arrayForNetworkImage = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"NetworkImages"]];
        if (nil == _arrayForNetworkImage) {
            _arrayForNetworkImage = [[NSMutableArray alloc] init];
        }
        
        [networkVideo setValue:_arrayForNetworkVideo forKey:FILE_NAME];
        _arrayForVideo = [[NSMutableArray alloc] init];
        [_arrayForVideo addObject:localVideo];
        [_arrayForVideo addObject:networkVideo];
        
        [networkImage setValue:_arrayForNetworkImage forKey:FILE_NAME];
        _arrayForImage = [[NSMutableArray alloc] init];
        [_arrayForImage addObject:localImage];
        [_arrayForImage addObject:networkImage];
    }
}

- (void)setPassword:(NSString *)password
{
    _password = password;
    [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"Password"];
}

- (void)setPrivatePassword:(NSString *)privatePassword
{
    _privatePassword = privatePassword;
    [[NSUserDefaults standardUserDefaults] setObject:privatePassword forKey:@"PrivatePassword"];
}

- (void)setPrivateLock:(NSNumber *)privateLock
{
    _privateLock = privateLock;
    [[NSUserDefaults standardUserDefaults] setObject:privateLock forKey:@"PrivateLock"];
}

- (void)setPrivatePublic:(NSNumber *)privatePublic
{
    _privatePublic = privatePublic;
    [[NSUserDefaults standardUserDefaults] setObject:privatePublic forKey:@"PrivatePublic"];
}

- (void)setPrivateDescribe:(NSString *)privateDescribe
{
    _privateDescribe = privateDescribe;
    [[NSUserDefaults standardUserDefaults] setObject:privateDescribe forKey:@"PrivateDescribe"];
}

- (void)setIsRecordPlayTime:(BOOL)isRecordPlayTime
{
    _isRecordPlayTime = isRecordPlayTime;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:isRecordPlayTime] forKey:@"IsRecordPlayTime"];
    if (NO == _isRecordPlayTime) {
        [_dictionaryForPlayTime removeAllObjects];
        [[NSUserDefaults standardUserDefaults] setObject:_dictionaryForPlayTime forKey:@"VideoLastTime"];
    }
}

- (void)addArrayForGroupObject:(NSDictionary *)object isPrivate:(BOOL)isPrivate
{
    if (isPrivate) {
        [_arrayForPrivateGroup addObject:object];
        [[NSUserDefaults standardUserDefaults] setObject:_arrayForPrivateGroup forKey:@"PrivateGroups"];
    }
    else {
        [_arrayForGroup addObject:object];
        [[NSUserDefaults standardUserDefaults] setObject:_arrayForGroup forKey:@"Groups"];
    }
}

- (void)replaceObjectInArrayForGroupAtIndex:(NSUInteger)index withObject:(NSDictionary *)object isPrivate:(BOOL)isPrivate
{
    if (isPrivate) {
        [_arrayForPrivateGroup replaceObjectAtIndex:index withObject:object];
        [[NSUserDefaults standardUserDefaults] setObject:_arrayForPrivateGroup forKey:@"PrivateGroups"];
    }
    else {
        [_arrayForGroup replaceObjectAtIndex:index withObject:object];
        [[NSUserDefaults standardUserDefaults] setObject:_arrayForGroup forKey:@"Groups"];
    }
}

- (void)removeArrayForGroupObjects:(NSArray *)array isPrivate:(BOOL)isPrivate;
{
    if (isPrivate) {
        [_arrayForPrivateGroup removeObjectsInArray:array];
        [[NSUserDefaults standardUserDefaults] setObject:_arrayForPrivateGroup forKey:@"PrivateGroups"];
    }
    else {
        [_arrayForGroup removeObjectsInArray:array];
        [[NSUserDefaults standardUserDefaults] setObject:_arrayForGroup forKey:@"Groups"];
    }
}

- (void)addNetworkVideoWithURLString:(NSString *)urlString displayName:(NSString *)name
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDictionary *dictionary = @{@"url":urlString,
                                 @"name":name,
                                 @"type":@"1",
                                 @"datetime":[formatter stringFromDate:[NSDate date]]};
    [_arrayForNetworkVideo addObject:dictionary];
    [[NSUserDefaults standardUserDefaults] setObject:_arrayForNetworkVideo forKey:@"NetworkVideos"];
}

- (void)modifyNetworkVideoDisplayName:(NSString *)name AtIndex:(NSUInteger)index
{
    NSDictionary *old = [_arrayForNetworkVideo objectAtIndex:index];
    NSDictionary *dictionary = @{@"url":[old objectForKey:@"url"],
                                 @"name":name,
                                 @"type":@"1",
                                 @"datetime":[old objectForKey:@"datetime"]};
    [_arrayForNetworkVideo replaceObjectAtIndex:index withObject:dictionary];
    [[NSUserDefaults standardUserDefaults] setObject:_arrayForNetworkVideo forKey:@"NetworkVideos"];
}

- (void)removeNetworkVideoObjects:(NSArray *)array isPrivate:(BOOL)isPrivate
{
    if (isPrivate) {
        [_arrayForPrivateNetworkVideo removeObjectsInArray:array];
        [[NSUserDefaults standardUserDefaults] setObject:_arrayForPrivateNetworkVideo forKey:@"PrivateNetworkVideos"];
    }
    else {
        [_arrayForNetworkVideo removeObjectsInArray:array];
        [[NSUserDefaults standardUserDefaults] setObject:_arrayForNetworkVideo forKey:@"NetworkVideos"];
    }
}

- (void)addNetworkImageWithURLString:(NSString *)urlString
{
    [_arrayForNetworkImage addObject:urlString];
    [[NSUserDefaults standardUserDefaults] setObject:_arrayForNetworkImage forKey:@"NetworkImages"];
}

- (void)removeNetworkImageObjects:(NSArray *)array isPrivate:(BOOL)isPrivate
{
    if (isPrivate) {
        [_arrayForPrivateNetworkImage removeObjectsInArray:array];
        [[NSUserDefaults standardUserDefaults] setObject:_arrayForPrivateNetworkImage forKey:@"PrivateNetworkImages"];
    }
    else {
        [_arrayForNetworkImage removeObjectsInArray:array];
        [[NSUserDefaults standardUserDefaults] setObject:_arrayForNetworkImage forKey:@"NetworkImages"];
    }
}

- (void)moveVideoFilesFromPublicToPrivateWithIndexPaths:(NSArray *)array
{
    NSMutableArray *localVideos = [[NSMutableArray alloc] init];
    NSMutableArray *networkVideos = [[NSMutableArray alloc] init];
    for (NSIndexPath *indexPath in array) {
        NSDictionary *dictionary = [_arrayForVideo objectAtIndex:indexPath.section];
        if (0 == [[dictionary objectForKey:FILE_TYPE_INDEX] integerValue]) { //本地
            NSMutableArray *files = [dictionary objectForKey:FILE_NAME];
            NSDictionary *information = [files objectAtIndex:indexPath.row];
            for (NSDictionary *dic in _arrayForPrivateVideo) {
                if (0 == [[dic objectForKey:FILE_TYPE_INDEX] integerValue]) {
                    NSString *privatePath = [dic objectForKey:FILE_PATH];
                    NSString *privatePathName = [NSString stringWithFormat:@"%@/%@", privatePath, [information objectForKey:@"name"]];
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    NSError *error = nil;
                    if ([fileManager moveItemAtPath:[information objectForKey:@"url"] toPath:privatePathName error:&error]) {
                        [information setValue:privatePathName forKey:@"url"];
                        NSMutableArray *privateFiles = [dic objectForKey:FILE_NAME];
                        [privateFiles addObject:information];
                        [localVideos addObject:information];
                    }
                    else {
                        NSLog(@"%@", error);
                    }
                }
            }
        }
        else if (1 == [[dictionary objectForKey:FILE_TYPE_INDEX] integerValue]) { //网络
            NSDictionary *object = [_arrayForNetworkVideo objectAtIndex:indexPath.row];
            [_arrayForPrivateNetworkVideo addObject:object];
            [networkVideos addObject:object];
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:_arrayForPrivateNetworkVideo forKey:@"PrivateNetworkVideos"];
    for (NSDictionary *dictionary in _arrayForVideo) {
        if (0 == [[dictionary objectForKey:FILE_TYPE_INDEX] integerValue]) {
            if (([localVideos count])) {
                NSMutableArray *array = [dictionary objectForKey:FILE_NAME];
                [array removeObjectsInArray:localVideos];
            }
        }
        else {
            for (NSDictionary *information in networkVideos) {
                [_arrayForNetworkVideo removeObject:information];
            }
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:_arrayForNetworkVideo forKey:@"NetworkVideos"];
}

- (void)moveVideoFilesFromPrivateToPublicWithIndexPaths:(NSArray *)array
{
    NSMutableArray *localVideos = [[NSMutableArray alloc] init];
    NSMutableArray *networkVideos = [[NSMutableArray alloc] init];
    for (NSIndexPath *indexPath in array) {
        NSDictionary *dictionary = [_arrayForPrivateVideo objectAtIndex:indexPath.section];
        if (0 == [[dictionary objectForKey:FILE_TYPE_INDEX] integerValue]) { //本地
            NSMutableArray *privateFiles = [dictionary objectForKey:FILE_NAME];
            NSDictionary *information = [privateFiles objectAtIndex:indexPath.row];
            for (NSDictionary *dic in _arrayForVideo) {
                if (0 == [[dic objectForKey:FILE_TYPE_INDEX] integerValue]) {
                    NSString *path = [dic objectForKey:FILE_PATH];
                    NSString *pathName = [NSString stringWithFormat:@"%@/%@", path, [information objectForKey:@"name"]];
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    NSError *error = nil;
                    if ([fileManager moveItemAtPath:[information objectForKey:@"url"] toPath:pathName error:&error]) {
                        [information setValue:pathName forKey:@"url"];
                        NSMutableArray *files = [dic objectForKey:FILE_NAME];
                        [files addObject:information];
                        [localVideos addObject:information];
                    }
                    else {
                        NSLog(@"%@", error);
                    }
                }
            }
        }
        else if (1 == [[dictionary objectForKey:FILE_TYPE_INDEX] integerValue]) { //网络
            NSDictionary *object = [_arrayForPrivateNetworkVideo objectAtIndex:indexPath.row];
            [_arrayForNetworkVideo addObject:object];
            [networkVideos addObject:object];
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:_arrayForNetworkVideo forKey:@"NetworkVideos"];
    for (NSDictionary *dictionary in _arrayForPrivateVideo) {
        if (0 == [[dictionary objectForKey:FILE_TYPE_INDEX] integerValue]) {
            if (([localVideos count])) {
                NSMutableArray *array = [dictionary objectForKey:FILE_NAME];
                [array removeObjectsInArray:localVideos];
            }
        }
        else {
            for (NSDictionary *information in networkVideos) {
                [_arrayForPrivateNetworkVideo removeObject:information];
            }
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:_arrayForPrivateNetworkVideo forKey:@"PrivateNetworkVideos"];
}

- (void)moveImageFilesFromPublicToPrivateWithIndexPaths:(NSArray *)array
{
    NSMutableArray *localImages = [[NSMutableArray alloc] init];
    NSMutableArray *networkImages = [[NSMutableArray alloc] init];
    for (NSIndexPath *indexPath in array) {
        NSDictionary *dictionary = [_arrayForImage objectAtIndex:indexPath.section];
        if (0 == [[dictionary objectForKey:FILE_TYPE_INDEX] integerValue]) { //本地
            NSMutableArray *files = [dictionary objectForKey:FILE_NAME];
            NSString *path = [dictionary objectForKey:FILE_PATH];
            NSString *name = [files objectAtIndex:indexPath.row];
            NSString *pathName = [NSString stringWithFormat:@"%@/%@", path, name];
            for (NSDictionary *dic in _arrayForPrivateImage) {
                if (0 == [[dic objectForKey:FILE_TYPE_INDEX] integerValue]) {
                    NSString *privatePath = [dic objectForKey:FILE_PATH];
                    NSString *privatePathName = [NSString stringWithFormat:@"%@/%@", privatePath, name];
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    NSError *error = nil;
                    if ([fileManager moveItemAtPath:pathName toPath:privatePathName error:&error]) {
                        NSMutableArray *privateFiles = [dic objectForKey:FILE_NAME];
                        [privateFiles addObject:name];
                        [localImages addObject:name];
                    }
                    else {
                        NSLog(@"%@", error);
                    }
                }
            }
        }
        else if (1 == [[dictionary objectForKey:FILE_TYPE_INDEX] integerValue]) { //网络
            NSDictionary *object = [_arrayForNetworkImage objectAtIndex:indexPath.row];
            [_arrayForPrivateNetworkImage addObject:object];
            [networkImages addObject:object];
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:_arrayForPrivateNetworkImage forKey:@"PrivateNetworkImages"];
    for (NSDictionary *dictionary in _arrayForImage) {
        if (0 == [[dictionary objectForKey:FILE_TYPE_INDEX] integerValue]) {
            if (([localImages count])) {
                NSMutableArray *array = [dictionary objectForKey:FILE_NAME];
                [array removeObjectsInArray:localImages];
            }
        }
        else {
            for (NSDictionary *information in networkImages) {
                [_arrayForNetworkImage removeObject:information];
            }
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:_arrayForNetworkImage forKey:@"NetworkImages"];
}

- (void)moveImageFilesFromPrivateToPublicWithIndexPaths:(NSArray *)array
{
    NSMutableArray *localImages = [[NSMutableArray alloc] init];
    NSMutableArray *networkImages = [[NSMutableArray alloc] init];
    for (NSIndexPath *indexPath in array) {
        NSDictionary *dictionary = [_arrayForPrivateImage objectAtIndex:indexPath.section];
        if (0 == [[dictionary objectForKey:FILE_TYPE_INDEX] integerValue]) { //本地
            NSMutableArray *privateFiles = [dictionary objectForKey:FILE_NAME];
            NSString *privatePath = [dictionary objectForKey:FILE_PATH];
            NSString *name = [privateFiles objectAtIndex:indexPath.row];
            NSString *privatePathName = [NSString stringWithFormat:@"%@/%@", privatePath, name];
            for (NSDictionary *dic in _arrayForImage) {
                if (0 == [[dic objectForKey:FILE_TYPE_INDEX] integerValue]) {
                    NSString *path = [dic objectForKey:FILE_PATH];
                    NSString *pathName = [NSString stringWithFormat:@"%@/%@", path, name];
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    NSError *error = nil;
                    if ([fileManager moveItemAtPath:privatePathName toPath:pathName error:&error]) {
                        NSMutableArray *files = [dic objectForKey:FILE_NAME];
                        [files addObject:name];
                        [localImages addObject:name];
                    }
                    else {
                        NSLog(@"%@", error);
                    }
                }
            }
        }
        else if (1 == [[dictionary objectForKey:FILE_TYPE_INDEX] integerValue]) { //网络
            NSDictionary *object = [_arrayForPrivateNetworkImage objectAtIndex:indexPath.row];
            [_arrayForNetworkImage addObject:object];
            [networkImages addObject:object];
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:_arrayForNetworkImage forKey:@"NetworkImages"];
    for (NSDictionary *dictionary in _arrayForPrivateImage) {
        if (0 == [[dictionary objectForKey:FILE_TYPE_INDEX] integerValue]) {
            if (([localImages count])) {
                NSMutableArray *array = [dictionary objectForKey:FILE_NAME];
                [array removeObjectsInArray:localImages];
            }
        }
        else {
            for (NSDictionary *information in networkImages) {
                [_arrayForPrivateNetworkImage removeObject:information];
            }
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:_arrayForPrivateNetworkImage forKey:@"PrivateNetworkImages"];
}

- (NSDictionary *)informationOfFileAtPathName:(NSString *)pathName
{
    NSDictionary *info = nil;
    return info;
}

- (void)recordVideoFile:(NSString *)fileName playTime:(NSTimeInterval)lastTime
{
    if (_isRecordPlayTime) {
        [_dictionaryForPlayTime setValue:[NSNumber numberWithDouble:lastTime] forKey:fileName];
        [[NSUserDefaults standardUserDefaults] setObject:_dictionaryForPlayTime forKey:@"VideoLastTime"];
    }
}

- (NSTimeInterval)lastTimeOfVideoFile:(NSString *)fileName
{
    NSTimeInterval lastTime = 0;
    if (_isRecordPlayTime) {
        lastTime = [[_dictionaryForPlayTime objectForKey:fileName] doubleValue];
    }
    return lastTime;
}

@end
