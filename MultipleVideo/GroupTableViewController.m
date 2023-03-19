//
//  GroupTableViewController.m
//  MultipleVideo
//
//  Created by issuser on 2017/4/28.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import "GroupTableViewController.h"
#import "DisplayManageViewController.h"
#import "VideoTableViewCell.h"
#import "MultipleVideo.h"

@interface GroupTableViewController ()

@end

@implementation GroupTableViewController {
    BOOL _adjustedFrame;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveGroupNotification:) name:NOTIFICATION_GROUP object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_adjustedFrame) {
        return;
    }
    _adjustedFrame = YES;
    CGRect frame = [self.view frame];
    if (_isPrivate) {
        frame.size.height = [[UIScreen mainScreen] bounds].size.height - kNavigationHeight - ButtonsHeight - kBottomSafeAreaHeight;
    } else {
        frame.size.height = [[UIScreen mainScreen] bounds].size.height - kNavigationHeight - ButtonsHeight - kTabBarHeight;
    }
    [self.view setFrame:frame];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_GROUP object:nil];
}

- (void)saveGroupNotification:(NSNotification *)notification
{
    [self.tableView reloadData];
}

- (void)setEnableEdit:(BOOL)enableEdit
{
    CGRect frame = [self.view frame];
    if (enableEdit) {
        frame.size.height = [[UIScreen mainScreen] bounds].size.height - kNavigationHeight - ButtonsHeight - kTabBarHeight;
    } else {
        frame.size.height = [[UIScreen mainScreen] bounds].size.height - kNavigationHeight - ButtonsHeight - (_isPrivate ? kBottomSafeAreaHeight : kTabBarHeight);
    }
    [self.view setFrame:frame];
    _enableEdit = enableEdit;
    [self.tableView setEditing:_enableEdit animated:YES];
}

- (void)addGroup
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DisplayManageViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"DisplayManageViewController"];
    [viewController setIsPrivate:_isPrivate];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)renameGroups
{
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    if ([selectedRows count]) {
        NSIndexPath *indexPath = [selectedRows firstObject];
        NSDictionary *item = [_array objectAtIndex:indexPath.row];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[item objectForKey:@"DisplayName"]
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            [textField setPlaceholder:MVLocalizedString(@"Video_Alert_Message2", @"请输入新的显示名字")];
            [textField setReturnKeyType:UIReturnKeyDone];
        }];
        [alert addAction:[UIAlertAction actionWithTitle:MVLocalizedString(@"Home_Alert_Cancel", @"取消") style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:MVLocalizedString(@"Home_Alert_OK", @"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UITextField *textField = [[alert textFields] firstObject];
            if (0 == [[textField text] length]) {
                return ;
            }
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:item];
            [dictionary setValue:[textField text] forKey:@"DisplayName"];
            [[MultipleVideo shareInstance] replaceObjectInArrayForGroupAtIndex:indexPath.row
                                                                    withObject:dictionary
                                                                     isPrivate:_isPrivate];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            if ([[self.tableView indexPathsForSelectedRows] count]) {
                [self renameGroups];
            }
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)deleteSelectedGroups
{
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    if ([selectedRows count]) {
        NSString *title = [NSString stringWithFormat:@"%lu个组", [selectedRows count]];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:@"您确定要删除这些组吗"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:MVLocalizedString(@"Home_Alert_Cancel", @"取消") style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:MVLocalizedString(@"Home_Alert_OK", @"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSMutableArray *groups = [[NSMutableArray alloc] init];
            for (NSIndexPath *indexPath in selectedRows) {
                [groups addObject:[_array objectAtIndex:indexPath.row]];
            }
            if ([groups count]) {
                [[MultipleVideo shareInstance] removeArrayForGroupObjects:groups isPrivate:_isPrivate];
            }
            [self.tableView reloadData];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_array count] ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupCell"];
    if (nil == cell) {
        cell = [[VideoTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"GroupCell"];
        [cell setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        [cell setTintColor:[UIColor orangeColor]]; //设置编辑状态左侧勾选颜色
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    [cell setContentForGroupDictionary:[_array objectAtIndex:indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 61;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_enableEdit) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DisplayManageViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"DisplayManageViewController"];
        [viewController setIsPrivate:_isPrivate];
        [viewController setGroup:[_array objectAtIndex:indexPath.row]];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert ;
}

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
