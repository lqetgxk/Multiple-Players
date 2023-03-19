//
//  AppDelegate.m
//  MultipleVideo
//
//  Created by issuser on 2017/4/26.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import "AppDelegate.h"
#import "PasswordViewController.h"
#import "GuideNavigationController.h"
#import "NewVersionViewController.h"
#import "MultipleVideo.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"appLanguage"]) { //获取当前系统语言，判断首次应该使用哪个语言文件
        NSArray *languages = [NSLocale preferredLanguages];
        NSString *language = [languages objectAtIndex:0];
        if ([language hasPrefix:@"zh-Hans"]) {//开头匹配
            [[NSUserDefaults standardUserDefaults] setObject:@"zh-Hans" forKey:@"appLanguage"];
        }
        else if ([language hasPrefix:@"en"]) {
            [[NSUserDefaults standardUserDefaults] setObject:@"en" forKey:@"appLanguage"];
        }
        else {
            [[NSUserDefaults standardUserDefaults] setObject:@"Base" forKey:@"appLanguage"];
        }
    }
    
    //升级后的初次启动时进入引导页
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"Version"] isEqualToString:version]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Guide" bundle:nil];
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Version"]) { //更新版本
            NewVersionViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"NewVersionViewController"];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
            [_window setRootViewController:navigationController];
        }
        else { //第一次安装
            GuideNavigationController *guide = [storyboard instantiateViewControllerWithIdentifier:@"GuideNavigationController"];
            [_window setRootViewController:guide];
        }
        //[[NSUserDefaults standardUserDefaults] setObject:version forKey:@"Version"]; //在引导页点进入的时候会设置
    }
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if ([[MultipleVideo shareInstance] password]) {
        PasswordViewController *viewController = [[PasswordViewController alloc] initWithNibName:@"PasswordViewController" bundle:nil];
        [self.window.rootViewController presentViewController:viewController animated:NO completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOCKSCREEN_ENTER object:nil];
        }];
    }
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    //指定某一个界面支持横屏的方法参照网址 http://blog.csdn.net/littleSun_zheng/article/details/50748698
    return _allowRotation ? UIInterfaceOrientationMaskAll : UIInterfaceOrientationMaskPortrait;
}


@end
