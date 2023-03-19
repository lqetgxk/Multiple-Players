//
//  PrivateTableViewController.m
//  MultipleVideo
//
//  Created by issuser on 2017/5/6.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import "PrivateTableViewController.h"
#import "MultipleVideo.h"

@interface PrivateTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UISwitch *switchLock;
@property (weak, nonatomic) IBOutlet UISwitch *switchPublic;
@property (weak, nonatomic) IBOutlet UILabel *labelPasswordLock;
@property (weak, nonatomic) IBOutlet UILabel *labelSetPassword;
@property (weak, nonatomic) IBOutlet UILabel *labelPublicAll;
@end

@implementation PrivateTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [_labelTitle setText:MVLocalizedString(@"Private_Setting_Title", @"私密设置")];
    [_labelPasswordLock setText:MVLocalizedString(@"Private_Setting_Password_Lock", @"密码锁定")];
    [_labelSetPassword setText:MVLocalizedString(@"Private_Setting_Set_Password", @"设置密码")];
    [_labelPublicAll setText:MVLocalizedString(@"Private_Setting_Public_All", @"对外公开")];
    [[self.navigationItem backBarButtonItem] setTitle:MVLocalizedString(@"Home_Left_Back", @"返回")];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToSetPassword:)];
    [longPressGesture setMinimumPressDuration:3.0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    [cell addGestureRecognizer:longPressGesture];
    [_switchLock setOn:(0 == [[[MultipleVideo shareInstance] privateLock] integerValue])];
    [_switchPublic setOn:!(0 == [[[MultipleVideo shareInstance] privatePublic] integerValue])];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)longPressToSetPassword:(UILongPressGestureRecognizer *)gesture
{
    if (UIGestureRecognizerStateBegan == [gesture state]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:MVLocalizedString(@"Private_Setting_Alert_Title1", @"设置密码")
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            [textField setPlaceholder:MVLocalizedString(@"Private_Setting_Alert_Message1", @"请输入密码")];
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
            [[MultipleVideo shareInstance] setPrivatePassword:[textField text]];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (IBAction)passwordLock:(UISwitch *)sender
{
    if (![sender isOn]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:MVLocalizedString(@"Private_Setting_Alert_Title2", @"密码")
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            [textField setPlaceholder:MVLocalizedString(@"Private_Setting_Alert_Message1", @"请输入密码")];
            [textField setSecureTextEntry:YES];
            [textField setReturnKeyType:UIReturnKeyDone];
        }];
        [alert addAction:[UIAlertAction actionWithTitle:MVLocalizedString(@"Home_Alert_Cancel", @"取消")
                                                  style:UIAlertActionStyleCancel
                                                handler:^(UIAlertAction * _Nonnull action) {
            [sender setOn:YES];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:MVLocalizedString(@"Home_Alert_OK", @"确定")
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            UITextField *textField = [[alert textFields] firstObject];
            if ([[[MultipleVideo shareInstance] privatePassword] isEqualToString:textField.text]) {
                [[MultipleVideo shareInstance] setPrivateLock:[NSNumber numberWithInteger:1]];
            }
            else {
                [[MultipleVideo shareInstance] setPrivateLock:[NSNumber numberWithInteger:2]];
            }
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        [[MultipleVideo shareInstance] setPrivateLock:[NSNumber numberWithInteger:0]];
    }
}

- (IBAction)public:(UISwitch *)sender
{
    if ([sender isOn]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:MVLocalizedString(@"Private_Setting_Alert_Title2", @"密码")
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            [textField setPlaceholder:MVLocalizedString(@"Private_Setting_Alert_Message1", @"请输入密码")];
            [textField setSecureTextEntry:YES];
            [textField setReturnKeyType:UIReturnKeyDone];
        }];
        [alert addAction:[UIAlertAction actionWithTitle:MVLocalizedString(@"Home_Alert_Cancel", @"取消")
                                                  style:UIAlertActionStyleCancel
                                                handler:^(UIAlertAction * _Nonnull action) {
            [sender setOn:NO];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:MVLocalizedString(@"Home_Alert_OK", @"确定")
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            UITextField *textField = [[alert textFields] firstObject];
            if ([[[MultipleVideo shareInstance] privatePassword] isEqualToString:textField.text]) {
                [[MultipleVideo shareInstance] setPrivatePublic:[NSNumber numberWithInteger:1]];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_VIDEO object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_IMAGE object:nil];
            }
            else {
                [[MultipleVideo shareInstance] setPrivatePublic:[NSNumber numberWithInteger:2]];
            }
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        [[MultipleVideo shareInstance] setPrivatePublic:[NSNumber numberWithInteger:0]];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_VIDEO object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_IMAGE object:nil];
    }
}

#pragma mark - Table view data source
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 12;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ((0 == indexPath.section) && (1 == indexPath.row)) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:MVLocalizedString(@"Private_Setting_Alert_Title1", @"设置密码")
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            [textField setPlaceholder:MVLocalizedString(@"Private_Setting_Alert_Message1", @"请输入密码")];
            [textField setSecureTextEntry:YES];
            [textField setReturnKeyType:UIReturnKeyNext];
        }];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            [textField setSecureTextEntry:YES];
            [textField setPlaceholder:MVLocalizedString(@"Private_Setting_Alert_Message2", @"请再次输入密码")];
            [textField setReturnKeyType:UIReturnKeyDone];
        }];
        [alert addAction:[UIAlertAction actionWithTitle:MVLocalizedString(@"Home_Alert_Cancel", @"取消")
                                                  style:UIAlertActionStyleCancel
                                                handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:MVLocalizedString(@"Home_Alert_OK", @"确定")
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            UITextField *textField0 = [[alert textFields] firstObject];
            UITextField *textField1 = [[alert textFields] lastObject];
            if ([[textField0 text] length] && [textField0.text isEqualToString:textField1.text]) {
                //伪装密码，不做任务处理
            }
            else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:MVLocalizedString(@"Private_Setting_Alert_Title3", @"失败")
                                                                               message:MVLocalizedString(@"Private_Setting_Alert_Message3", @"两次输入不一致或都为空,请重新输入")
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:MVLocalizedString(@"Home_Alert_Know", @"好")
                                                          style:UIAlertActionStyleCancel
                                                        handler:nil]];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
