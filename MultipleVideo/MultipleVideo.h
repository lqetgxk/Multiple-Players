//
//  MultipleVideo.h
//  MultipleVideo
//
//  Created by issuser on 2017/4/26.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define NOTIFICATION_LANGUAGE_CHANGED @"LanguageChanged" //语言改变通知

#define MVLocalizedString(key, comment) [[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"appLanguage"]] ofType:@"lproj"]] localizedStringForKey:(key) value:@"" table:@"Language"]

#define kBottomSafeAreaHeight [UIApplication sharedApplication].windows.lastObject.safeAreaInsets.bottom //底部的安全距离
#define kTopSafeAreaHeight (0 == kBottomSafeAreaHeight ? 0 : 24) //顶部的安全距离
#define kStatusBarHeight (0 == kBottomSafeAreaHeight ? 20 : 44) //状态栏高度
#define kNavigationHeight (0 == kBottomSafeAreaHeight ? 64 : 88) //导航栏高度
#define kTabBarHeight (kBottomSafeAreaHeight + 49) //tabbar高度

#define ButtonsHeight 44.0f //滚动页顶按钮的高度

#define NOTIFICATION_VIDEO @"Video" //视频通知
#define NOTIFICATION_IMAGE @"Image" //图片通知
#define NOTIFICATION_GROUP @"Group" //保存组通知

#define NOTIFICATION_LOCKSCREEN_ENTER @"LockScreenEnter" //进入锁屏，需要输入密码
#define NOTIFICATION_LOCKSCREEN_EXIT  @"LockScreenExit" //退出锁屏

#define FILE_TYPE_INDEX @"TypeIndex" //0表示本地的，1表示网络的
#define FILE_TYPE_NAME  @"TypeName"
#define FILE_PATH       @"Path"
#define FILE_NAME       @"Name"


@interface MultipleVideo : NSObject

@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSMutableArray *arrayForVideo;
@property (strong, nonatomic) NSMutableArray *arrayForImage;
@property (strong, nonatomic) NSMutableArray *arrayForGroup;

@property (strong, nonatomic) NSString *privatePassword; //私有密码
@property (strong, nonatomic) NSNumber *privateLock; //私有密码锁定，0锁定，1解锁，2伪解锁
@property (strong, nonatomic) NSNumber *privatePublic; //私有文件公开，0不公开，1公开，2伪公开
@property (strong, nonatomic) NSString *privateDescribe; //私有管理描述
@property (strong, nonatomic) NSMutableArray *arrayForPrivateVideo;
@property (strong, nonatomic) NSMutableArray *arrayForPrivateImage;
@property (strong, nonatomic) NSMutableArray *arrayForPrivateGroup;

@property (assign, nonatomic) BOOL isRecordPlayTime;

/**
 获取视频文件信息 @{@"thumbnails":UIImage, @"duration":NSNumber, @"width":NSNumber, @"height":NSNumber,
                 @"size":NSNumber, @"path":NSString, @"name":NSString, @"url":NSStirng, @"type":NSString,
                 @"apple":NSNumber}
 
 @param path 路径
 @param name 名字
 @return 信息字典
 */
+ (NSMutableDictionary *)informationOfVideoFileAtPath:(NSString *)path name:(NSString *)name;

/**
 抖动动画
 
 @param view 需要抖动的控件
 */
+ (void)shakeAnimationForView:(UIView *)view;

/**
 共享实例
 
 @return 一个实例，每次调用返回的都是同一个
 */
+ (MultipleVideo *)shareInstance;

- (void)addArrayForGroupObject:(NSDictionary *)object isPrivate:(BOOL)isPrivate;
- (void)replaceObjectInArrayForGroupAtIndex:(NSUInteger)index withObject:(NSDictionary *)object isPrivate:(BOOL)isPrivate;
- (void)removeArrayForGroupObjects:(NSArray *)array isPrivate:(BOOL)isPrivate;

- (void)addNetworkVideoWithURLString:(NSString *)urlString displayName:(NSString *)name;
- (void)modifyNetworkVideoDisplayName:(NSString *)name AtIndex:(NSUInteger)index;
- (void)removeNetworkVideoObjects:(NSArray *)array isPrivate:(BOOL)isPrivate;
- (void)addNetworkImageWithURLString:(NSString *)urlString;
- (void)removeNetworkImageObjects:(NSArray *)array isPrivate:(BOOL)isPrivate;

- (void)moveVideoFilesFromPublicToPrivateWithIndexPaths:(NSArray *)array;
- (void)moveVideoFilesFromPrivateToPublicWithIndexPaths:(NSArray *)array;
- (void)moveImageFilesFromPublicToPrivateWithIndexPaths:(NSArray *)array;
- (void)moveImageFilesFromPrivateToPublicWithIndexPaths:(NSArray *)array;

- (void)recordVideoFile:(NSString *)fileName playTime:(NSTimeInterval)lastTime;
- (NSTimeInterval)lastTimeOfVideoFile:(NSString *)fileName;

@end
