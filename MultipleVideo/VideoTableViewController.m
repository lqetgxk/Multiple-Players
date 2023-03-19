//
//  VideoTableViewController.m
//  MultipleVideo
//
//  Created by issuser on 2017/4/27.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import "VideoTableViewController.h"
#import "VideoTableViewCell.h"
#import "DisplayManageViewController.h"
#import "SelectVideoViewController.h"
#import "VideoClipViewController.h"
#import "VideoComposeViewController.h"
#import "ApplePlayerViewController.h"
#import "MultipleVideo.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface VideoTableViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation VideoTableViewController {
    BOOL _adjustedFrame;
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
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    if (nil == [self blockSelectedIndexPath]) {
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToVideoEdit:)];
        [self.tableView addGestureRecognizer:longPressGesture];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoChangedNotification:) name:NOTIFICATION_VIDEO object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_adjustedFrame) {
        return;
    }
    _adjustedFrame = YES;
    CGRect frame = [self.view frame];
    if ([self blockSelectedIndexPath] || _isPrivate || _isSelected) {
        frame.size.height = [[UIScreen mainScreen] bounds].size.height - kNavigationHeight - ButtonsHeight - kBottomSafeAreaHeight;
    } else {
        frame.size.height = [[UIScreen mainScreen] bounds].size.height - kNavigationHeight - ButtonsHeight - kTabBarHeight;
    }
    [self.view setFrame:frame];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_VIDEO object:nil];
}

- (void)videoChangedNotification:(NSNotification *)notification
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

- (void)openCamera:(UIButton *)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        if (NO == [availableMediaTypes containsObject:(NSString *)kUTTypeMovie]) { //不支持视频录制
            return ;
        }
    }
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker.view setBackgroundColor:[UIColor clearColor]];
    [imagePicker setDelegate:self];
    //[imagePicker setAllowsEditing:YES];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [imagePicker setCameraDevice:UIImagePickerControllerCameraDeviceRear]; //设置后置摄像头还是前置摄像头
    [imagePicker setMediaTypes:@[(NSString *)kUTTypeMovie]];
    [imagePicker setVideoQuality:UIImagePickerControllerQualityTypeHigh];
    [imagePicker setCameraCaptureMode:UIImagePickerControllerCameraCaptureModeVideo];
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)addVideo:(UIButton *)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:MVLocalizedString(@"Video_Import_Video", @"导入视频")
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:MVLocalizedString(@"Picture_Album", @"从相册中选择")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        SelectVideoViewController *viewController = [[SelectVideoViewController alloc] initWithNibName:@"SelectVideoViewController" bundle:nil];
        [viewController setBlockSelectedFile:^(NSString *pathName){
            NSDictionary *dictionaryForLocal = nil;
            for (NSDictionary *dictionary in _array) {
                if (0 == [[dictionary objectForKey:FILE_TYPE_INDEX] integerValue]) {
                    dictionaryForLocal = dictionary;
                    break;
                }
            }
            NSString *path = [dictionaryForLocal objectForKey:FILE_PATH];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *name = [NSString stringWithFormat:@"%@.mov", [formatter stringFromDate:[NSDate date]]];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSError *error = nil;
            if ([fileManager copyItemAtPath:pathName
                                     toPath:[NSString stringWithFormat:@"%@/%@", path, name]
                                      error:&error]) {
                NSMutableArray *localVideos = [dictionaryForLocal objectForKey:FILE_NAME];
                [localVideos addObject:[MultipleVideo informationOfVideoFileAtPath:path name:name]];
            }
            else {
                NSLog(@"%@", error);
            }
            [self.tableView reloadData];
        }];
        [self presentViewController:viewController animated:YES completion:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:MVLocalizedString(@"Video_Alert_Title3", @"添加网络视频")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:MVLocalizedString(@"Video_Alert_Title3", @"网络视频")
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            [textField setPlaceholder:MVLocalizedString(@"Video_Alert_Message3", @"请输入一个视频的URL地址")];
            [textField setReturnKeyType:UIReturnKeyNext];
        }];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            [textField setPlaceholder:MVLocalizedString(@"Video_Alert_Message4", @"请输入一个别名，用于显示")];
        }];
        [alert addAction:[UIAlertAction actionWithTitle:MVLocalizedString(@"Home_Alert_Cancel", @"取消")
                                                  style:UIAlertActionStyleCancel
                                                handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:MVLocalizedString(@"Home_Alert_OK", @"确定")
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            UITextField *textField0 = [[alert textFields] firstObject];
            UITextField *textField1 = [[alert textFields] lastObject];
            if ([[textField0 text] length] && [[textField1 text] length]) {
                [[MultipleVideo shareInstance] addNetworkVideoWithURLString:[textField0 text]
                                                                displayName:[textField1 text]];
                [self.tableView reloadData];
            }
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:MVLocalizedString(@"Home_Alert_Cancel", @"取消")
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    UIPopoverPresentationController *popoverPresentationController = [alert popoverPresentationController];
    if (popoverPresentationController) { //iPad 时会走下面，如果没有下面就会崩溃
        [popoverPresentationController setSourceView:sender];
        [popoverPresentationController setSourceRect:[sender bounds]];
        [popoverPresentationController setPermittedArrowDirections:UIPopoverArrowDirectionAny];
    }
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)renameVideos
{
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    if ([selectedRows count]) {
        UIAlertController *alert = nil;
        NSIndexPath *indexPath = [selectedRows firstObject];
        NSDictionary *dictionary = [_array objectAtIndex:indexPath.section];
        NSMutableArray *files = [dictionary objectForKey:FILE_NAME];
        NSDictionary *information = [files objectAtIndex:indexPath.row];
        alert = [UIAlertController alertControllerWithTitle:[information objectForKey:@"name"]
                                                    message:nil
                                             preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            [textField setPlaceholder:MVLocalizedString(@"Video_Alert_Message2", @"请输入新的名字")];
            [textField setText:[information objectForKey:@"name"]];
        }];
        [alert addAction:[UIAlertAction actionWithTitle:MVLocalizedString(@"Home_Alert_Cancel", @"取消")
                                                  style:UIAlertActionStyleCancel
                                                handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:MVLocalizedString(@"Home_Alert_OK", @"确定")
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            UITextField *textField = [[alert textFields] firstObject];
            if (0 == [[textField text] length]) {
                return ;
            }
            if ([[dictionary objectForKey:FILE_TYPE_INDEX] integerValue]) { //网络视频
                [[MultipleVideo shareInstance] modifyNetworkVideoDisplayName:[textField text] AtIndex:indexPath.row];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                if ([[self.tableView indexPathsForSelectedRows] count]) {
                    [self renameVideos];
                }
            }
            else { //本地视频
                NSString *path = [information objectForKey:@"path"];
                NSString *name = [information objectForKey:@"name"];
                NSString *newPathName = [NSString stringWithFormat:@"%@/%@", path, [textField text]];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                if ([fileManager moveItemAtPath:[information objectForKey:@"url"] toPath:newPathName error:nil]) {
                    [information setValue:[textField text] forKey:@"name"];
                    [information setValue:newPathName forKey:@"url"];
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                                          withRowAnimation:UITableViewRowAnimationAutomatic];
                    if ([[self.tableView indexPathsForSelectedRows] count]) {
                        [self renameVideos];
                    }
                }
                else {
                    NSLog(@"Rename %@ to %@ fail!", name, [textField text]);
                }
            }
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)deleteSelectedVideos
{
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    if ([selectedRows count]) {
        NSString *title = [NSString stringWithFormat:@"%lu %@", [selectedRows count], MVLocalizedString(@"Video_Alert_Title1", @"个视频")];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:MVLocalizedString(@"Video_Alert_Message1", @"您确定要删除这些视频吗")
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:MVLocalizedString(@"Home_Alert_Cancel", @"取消")
                                                  style:UIAlertActionStyleCancel
                                                handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:MVLocalizedString(@"Home_Alert_OK", @"确定")
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            NSMutableArray *localVideos = [[NSMutableArray alloc] init];
            NSMutableArray *networkVideos = [[NSMutableArray alloc] init];
            for (NSIndexPath *indexPath in selectedRows) {
                NSDictionary *dictionary = [_array objectAtIndex:indexPath.section];
                NSArray *array = [dictionary objectForKey:FILE_NAME];
                NSDictionary *information = [array objectAtIndex:indexPath.row];
                if (0 == [[dictionary objectForKey:FILE_TYPE_INDEX] integerValue]) {
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    [fileManager removeItemAtPath:[information objectForKey:@"url"] error:nil];
                    [localVideos addObject:information];
                }
                else {
                    [networkVideos addObject:information];
                }
            }
            for (NSDictionary *dictionary in _array) {
                if (0 == [[dictionary objectForKey:FILE_TYPE_INDEX] integerValue]) {
                    if (([localVideos count])) {
                        NSMutableArray *array = [dictionary objectForKey:FILE_NAME];
                        [array removeObjectsInArray:localVideos];
                    }
                }
                else {
                    if ([networkVideos count]) {
                        [[MultipleVideo shareInstance] removeNetworkVideoObjects:networkVideos isPrivate:_isPrivate];
                    }
                }
            }
            [self.tableView reloadData];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (NSArray *)indexPathsForSelectedRows
{
    return [self.tableView indexPathsForSelectedRows];
}

- (void)reloadData
{
    [self.tableView reloadData];
}

- (void)longPressToVideoEdit:(UILongPressGestureRecognizer *)gesture
{
    if ((UIGestureRecognizerStateBegan != [gesture state]) || _enableEdit) {
        return;
    }
    CGPoint point = [gesture locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    if (nil == indexPath) {
        return;
    }
    NSInteger rowIndex = indexPath.row;
    NSDictionary *dictionary = [_array objectAtIndex:indexPath.section];
    NSArray *array = [dictionary objectForKey:FILE_NAME];
    if ([array count] <= rowIndex) { //私有公开的情况
        rowIndex -= [array count];
        dictionary = [[[MultipleVideo shareInstance] arrayForPrivateVideo] objectAtIndex:indexPath.section];
        array = [dictionary objectForKey:FILE_NAME];
    }
    NSDictionary *information = [array objectAtIndex:rowIndex];
    if (NO == [[information objectForKey:@"apple"] boolValue]) {
        return;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[information objectForKey:@"name"]
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:MVLocalizedString(@"Video_Play_This_Video", @"视频播放")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                ApplePlayerViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ApplePlayerViewController"];
                                                [viewController setIsPrivate:_isPrivate];
                                                [viewController setVideo:information];
                                                [self.navigationController pushViewController:viewController animated:YES];
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:MVLocalizedString(@"Video_Video_Clip", @"视频剪辑")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                VideoClipViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"VideoClipViewController"];
                                                [viewController setIsPrivate:_isPrivate];
                                                [viewController setVideo:information];
                                                [self.navigationController pushViewController:viewController animated:YES];
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:MVLocalizedString(@"Video_Video_Synthesis", @"视频合成")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                VideoComposeViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"VideoComposeViewController"];
                                                [viewController setIsPrivate:_isPrivate];
                                                [viewController setVideo:information];
                                                [self.navigationController pushViewController:viewController animated:YES];
                                            }]];
    NSString *videoURL = [information objectForKey:@"url"];
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoURL) && (NO == _isPrivate)) {
        [alert addAction:[UIAlertAction actionWithTitle:MVLocalizedString(@"Video_Save_To_Album", @"保存到相册")
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    UISaveVideoAtPathToSavedPhotosAlbum(videoURL, nil, nil, nil);
                                                }]];
    }
    [alert addAction:[UIAlertAction actionWithTitle:MVLocalizedString(@"Home_Alert_Cancel", @"取消")
                                              style:UIAlertActionStyleCancel handler:nil]];
    UIPopoverPresentationController *popoverPresentationController = [alert popoverPresentationController];
    if (popoverPresentationController) { //iPad 时会走下面，如果没有下面就会崩溃
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [popoverPresentationController setSourceView:cell];
        [popoverPresentationController setSourceRect:[cell bounds]];
        [popoverPresentationController setPermittedArrowDirections:UIPopoverArrowDirectionAny];
    }
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSDictionary *dictionaryForLocal = nil;
    for (NSDictionary *dictionary in _array) {
        if (0 == [[dictionary objectForKey:FILE_TYPE_INDEX] integerValue]) {
            dictionaryForLocal = dictionary;
            break;
        }
    }
    NSString *path = [dictionaryForLocal objectForKey:FILE_PATH];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *name = [NSString stringWithFormat:@"%@.mov", [formatter stringFromDate:[NSDate date]]];
    NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];//视频路径
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if ([fileManager moveItemAtPath:[url path] toPath:[NSString stringWithFormat:@"%@/%@", path, name] error:&error]) {
        NSMutableArray *localVideos = [dictionaryForLocal objectForKey:FILE_NAME];
        [localVideos addObject:[MultipleVideo informationOfVideoFileAtPath:path name:name]];
    }
    else {
        NSLog(@"%@", error);
    }
    [self.tableView reloadData];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_array count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *dictionary = [_array objectAtIndex:section];
    NSArray *files = [dictionary objectForKey:FILE_NAME];
    NSInteger count = [files count];
    if (!_isPrivate && (1 == [[[MultipleVideo shareInstance] privatePublic] integerValue])) {
        dictionary = [[[MultipleVideo shareInstance] arrayForPrivateVideo] objectAtIndex:section];
        files = [dictionary objectForKey:FILE_NAME];
        count += [files count];
    }
    return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *dictionary = [_array objectAtIndex:section];
    NSArray *files = [dictionary objectForKey:FILE_NAME];
    NSInteger count = [files count];
    if (!_isPrivate && (1 == [[[MultipleVideo shareInstance] privatePublic] integerValue])) {
        dictionary = [[[MultipleVideo shareInstance] arrayForPrivateVideo] objectAtIndex:section];
        files = [dictionary objectForKey:FILE_NAME];
        count += [files count];
    }
    return (0 < count) ? [dictionary objectForKey:FILE_TYPE_NAME] : nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VideoTableViewCell"];
    if (nil == cell) {
        cell = [[VideoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"VideoTableViewCell"];
        [cell setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        [cell setTintColor:[UIColor orangeColor]]; //设置编辑状态左侧勾选颜色
        if (nil == [self blockSelectedIndexPath]) {
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
    }
    NSInteger rowIndex = indexPath.row;
    NSDictionary *dictionary = [_array objectAtIndex:indexPath.section];
    NSArray *array = [dictionary objectForKey:FILE_NAME];
    if ([array count] <= rowIndex) { //私有公开的情况
        rowIndex -= [array count];
        dictionary = [[[MultipleVideo shareInstance] arrayForPrivateVideo] objectAtIndex:indexPath.section];
        array = [dictionary objectForKey:FILE_NAME];
    }
    [cell setContentDictionary:[array objectAtIndex:rowIndex]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 61;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self blockSelectedIndexPath]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
        [self blockSelectedIndexPath](indexPath);
    }
    else {
        if (!_enableEdit) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            DisplayManageViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"DisplayManageViewController"];
            NSInteger rowIndex = indexPath.row;
            NSDictionary *dictionary = [_array objectAtIndex:indexPath.section];
            NSArray *array = [dictionary objectForKey:FILE_NAME];
            if ([array count] <= rowIndex) { //私有公开的情况
                rowIndex -= [array count];
                dictionary = [[[MultipleVideo shareInstance] arrayForPrivateVideo] objectAtIndex:indexPath.section];
                array = [dictionary objectForKey:FILE_NAME];
            }
            [viewController setVideo:[array objectAtIndex:rowIndex]];
            [viewController setIsPrivate:_isPrivate];
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    NSDictionary *dictionary = [_array objectAtIndex:indexPath.section];
    NSArray *files = [dictionary objectForKey:FILE_NAME];
    return indexPath.row < [files count];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
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

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
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
