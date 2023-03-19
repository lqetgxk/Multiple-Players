//
//  SettingTableViewController.m
//  MultipleVideo
//
//  Created by issuser on 2017/4/26.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import "SettingTableViewController.h"
#import "PasswordViewController.h"
#import "PrivateViewController.h"
#import "VideoClipViewController.h"
#import "VideoComposeViewController.h"
#import "MultipleVideo.h"
#import <StoreKit/StoreKit.h>

@interface SettingTableViewController () <SKStoreProductViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UISwitch *switchPassword;
@property (weak, nonatomic) IBOutlet UILabel *labelPassword;
@property (weak, nonatomic) IBOutlet UISwitch *switchPlayRecord;
@property (weak, nonatomic) IBOutlet UILabel *labelPlayRecord;
@property (weak, nonatomic) IBOutlet UILabel *labelPrivate;
@property (weak, nonatomic) IBOutlet UILabel *labelVideoClip;
@property (weak, nonatomic) IBOutlet UILabel *labelVideoSynthesis;
@property (weak, nonatomic) IBOutlet UILabel *labelVideoPlay;
@property (weak, nonatomic) IBOutlet UILabel *labelVersionMark;
@property (weak, nonatomic) IBOutlet UILabel *labelVersion;
@property (weak, nonatomic) IBOutlet UILabel *labelLanguageMark;
@property (weak, nonatomic) IBOutlet UILabel *labelLanguage;
@property (weak, nonatomic) IBOutlet UILabel *labelGoToAppStore;
@end

@implementation SettingTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    NSDictionary *dictionary = [[NSBundle mainBundle] infoDictionary];
    [_labelVersion setText:[NSString stringWithFormat:@"%@", [dictionary objectForKey:@"CFBundleShortVersionString"]]];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"appLanguage"] isEqualToString:@"zh-Hans"]) {
        [_labelLanguage setText:MVLocalizedString(@"Setting_Chinese", @"中文")];
    }
    else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"appLanguage"] isEqualToString:@"en"]) {
        [_labelLanguage setText:MVLocalizedString(@"Setting_English", @"英文")];
    }
    else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"appLanguage"] isEqualToString:@"es"]) {
        [_labelLanguage setText:MVLocalizedString(@"Setting_Spanish", @"西班牙文")];
    }
    else {
        [_labelLanguage setText:MVLocalizedString(@"Setting_English", @"Base")];
    }
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [_switchPassword setOn:[[MultipleVideo shareInstance] password]];
    [_switchPlayRecord setOn:[[MultipleVideo shareInstance] isRecordPlayTime]];
    [self languageChangedNotification:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)languageChangedNotification:(NSNotification *)notification
{
    [_labelPassword setText:MVLocalizedString(@"Setting_Password_Lock", @"密码锁定")];
    [_labelPlayRecord setText:MVLocalizedString(@"Setting_Record_Play_Time", @"记录播放时间")];
    [_labelPrivate setText:MVLocalizedString(@"Setting_Private_Manage", @"私密管理")];
    [_labelVideoClip setText:MVLocalizedString(@"Setting_Video_Clip", @"视频剪辑")];
    [_labelVideoSynthesis setText:MVLocalizedString(@"Setting_Video_Synthesis", @"视频合成")];
    [_labelVideoPlay setText:MVLocalizedString(@"Setting_Video_Play", @"视频播放")];
    [_labelVersionMark setText:MVLocalizedString(@"Setting_Version", @"版本")];
    [_labelLanguageMark setText:MVLocalizedString(@"Setting_Language", @"选择语言")];
    [_labelGoToAppStore setText:MVLocalizedString(@"Setting_Go_AppStore", @"去应用商店评论")];
}

- (IBAction)setPassword:(UISwitch *)sender
{
    if ([sender isOn]) {
        PasswordViewController *viewController = [[PasswordViewController alloc] initWithNibName:@"PasswordViewController" bundle:nil];
        [viewController setBlockCancel:^{
            [sender setOn:NO];
        }];
        [self presentViewController:viewController animated:YES completion:nil];
    }
    else {
        [[MultipleVideo shareInstance] setPassword:nil];
    }
}

- (IBAction)setPlayRecord:(UISwitch *)sender
{
    [[MultipleVideo shareInstance] setIsRecordPlayTime:[sender isOn]];
}

#pragma mark - SKStoreProductViewControllerDelegate

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}
 */

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ((2 == indexPath.section) && (0 == indexPath.row)) { //选择语言
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:MVLocalizedString(@"Setting_Select_Language", @"选择语言")
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:MVLocalizedString(@"Setting_Chinese", @"中文")
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            [_labelLanguage setText:MVLocalizedString(@"Setting_Chinese", @"中文")];
            if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"appLanguage"] isEqualToString:@"zh-Hans"]) {
                [[NSUserDefaults standardUserDefaults] setObject:@"zh-Hans" forKey:@"appLanguage"];
                [self languageChangedNotification:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LANGUAGE_CHANGED
                                                                    object:nil
                                                                  userInfo:nil];
            }
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:MVLocalizedString(@"Setting_English", @"英文")
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            [_labelLanguage setText:MVLocalizedString(@"Setting_English", @"英文")];
            if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"appLanguage"] isEqualToString:@"en"]) {
                [[NSUserDefaults standardUserDefaults] setObject:@"en" forKey:@"appLanguage"];
                [self languageChangedNotification:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LANGUAGE_CHANGED
                                                                    object:nil
                                                                  userInfo:nil];
            }
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:MVLocalizedString(@"Home_Alert_Cancel", @"取消")
                                                  style:UIAlertActionStyleCancel handler:nil]];
        UIPopoverPresentationController *popoverPresentationController = [alert popoverPresentationController];
        if (popoverPresentationController) { //iPad 时会走下面，如果没有下面就会崩溃
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [popoverPresentationController setSourceView:cell];
            [popoverPresentationController setSourceRect:[cell bounds]];
            [popoverPresentationController setPermittedArrowDirections:UIPopoverArrowDirectionAny];
        }
        [self presentViewController:alert animated:YES completion:nil];
    }
    else if ((2 == indexPath.section) && (2 == indexPath.row)) { //去评论
        SKStoreProductViewController *viewController = [[SKStoreProductViewController alloc] init];
        [viewController setDelegate:self];
        [viewController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier:@"1249206872"}
                                  completionBlock:^(BOOL result, NSError * _Nullable error) {
                                      if (error) {
                                          NSLog(@"%@", error);
                                      }
                                      else {
                                          [self presentViewController:viewController animated:YES completion:nil];
                                      }
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 12;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"PrivateFile"] && (0 == [[[MultipleVideo shareInstance] privateLock] integerValue])) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:MVLocalizedString(@"Setting_Alert_Title", @"密码")
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            [textField setPlaceholder:MVLocalizedString(@"Setting_Alert_Message", @"请输入密码")];
            [textField setSecureTextEntry:YES];
            [textField setReturnKeyType:UIReturnKeyDone];
        }];
        [alert addAction:[UIAlertAction actionWithTitle:MVLocalizedString(@"Home_Alert_Cancel", @"取消")
                                                  style:UIAlertActionStyleCancel
                                                handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:MVLocalizedString(@"Home_Alert_OK", @"确定")
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            UITextField *textField = [[alert textFields] firstObject];
            PrivateViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PrivateViewController"];
            [viewController setIsCorrect:[[[MultipleVideo shareInstance] privatePassword] isEqualToString:textField.text]];
            [self.navigationController pushViewController:viewController animated:YES];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return NO;
    }
    return YES;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UIViewController *viewController = [segue destinationViewController];
    if ([viewController isKindOfClass:[PrivateViewController class]]) {
        [(PrivateViewController *)viewController setIsCorrect:1 == [[[MultipleVideo shareInstance] privateLock] integerValue]];
    }
}

@end
