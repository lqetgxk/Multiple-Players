//
//  SelectFileTableViewController.m
//  MultipleVideo
//
//  Created by issuser on 2017/8/8.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import "SelectFileTableViewController.h"
#import "VideoTableViewCell.h"
#import "MultipleVideo.h"

@interface SelectFileTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@end

@implementation SelectFileTableViewController {
    NSMutableArray *_array;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if (@available(iOS 15.0, *)) {
        [self.tableView setSectionHeaderTopPadding:0];
    }
    [[self.navigationItem backBarButtonItem] setTitle:MVLocalizedString(@"Home_Left_Back", @"返回")];
    [_labelTitle setText:MVLocalizedString(@"Select_Title", @"选择文件")];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    _array = [[NSMutableArray alloc] init];
    if (_isPrivate) {
        [self filterFileAtArray:[[MultipleVideo shareInstance] arrayForPrivateVideo]];
    }
    else {
        [self filterFileAtArray:[[MultipleVideo shareInstance] arrayForVideo]];
        if (1 == [[[MultipleVideo shareInstance] privatePublic] integerValue]) {
            [self filterFileAtArray:[[MultipleVideo shareInstance] arrayForPrivateVideo]];
        }
    }
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

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
        [cell setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        [cell setTintColor:[UIColor orangeColor]]; //设置编辑状态左侧勾选颜色
    }
    [cell setContentDictionary:[_array objectAtIndex:indexPath.row]];
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self blockSelectedFile]) {
        [self blockSelectedFile]([_array objectAtIndex:indexPath.row]);
        [self.navigationController popViewControllerAnimated:YES];
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
