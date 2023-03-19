//
//  PictureCollectionViewController.m
//  MultipleVideo
//
//  Created by issuser on 2017/4/28.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import "PictureCollectionViewController.h"
#import "PictureCollectionViewCell.h"
#import "PictureBrowserViewController.h"
#import "MultipleVideo.h"

@interface PictureCollectionViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation PictureCollectionViewController {
    NSUInteger _numberInLine;
    NSMutableArray *_selectedPictures;
    BOOL _adjustedFrame;
}

static NSString * const reuseIdentifier = @"PictureCollectionViewCell";
static NSString * const headerViewIdentifier = @"PictureCollectionViewHead";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[PictureCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    [self.collectionView registerClass:[UICollectionReusableView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:headerViewIdentifier];
    // Do any additional setup after loading the view.
    _numberInLine = 3;
    _selectedPictures = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pictureChangedNotification:) name:NOTIFICATION_IMAGE object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        frame.size.height = [[UIScreen mainScreen] bounds].size.height - kNavigationHeight - kTabBarHeight;
    }
    [self.view setFrame:frame];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)dealloc
{
    if (nil == [self blockSelectedIndexPath]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_IMAGE object:nil];
    }
}

- (void)pictureChangedNotification:(NSNotification *)notification
{
    [self.collectionView reloadData];
}

- (void)setEnableEdit:(BOOL)enableEdit
{
    CGRect frame = [self.view frame];
    if (enableEdit) {
        if ([self blockSelectedIndexPath] || _isPrivate || _isSelected) {
            frame.size.height = [[UIScreen mainScreen] bounds].size.height - kNavigationHeight - ButtonsHeight - kTabBarHeight;
        } else {
            frame.size.height = [[UIScreen mainScreen] bounds].size.height - kNavigationHeight - kTabBarHeight;
        }
    } else {
        if ([self blockSelectedIndexPath] || _isPrivate || _isSelected) {
            frame.size.height = [[UIScreen mainScreen] bounds].size.height - kNavigationHeight - ButtonsHeight - kBottomSafeAreaHeight;
        } else {
            frame.size.height = [[UIScreen mainScreen] bounds].size.height - kNavigationHeight - kTabBarHeight;
        }
    }
    [self.view setFrame:frame];
    _enableEdit = enableEdit;
    if (!_enableEdit) {
        [_selectedPictures removeAllObjects];
    }
    [self.collectionView reloadData];
}

- (void)openCamera:(UIButton *)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker.view setBackgroundColor:[UIColor clearColor]];
    [imagePicker setAllowsEditing:NO];
    [imagePicker setDelegate:self];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)addPicture:(UIButton *)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:MVLocalizedString(@"Picture_Import_Photo", @"导入照片")
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:MVLocalizedString(@"Picture_Album", @"从相册中选择")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        [imagePicker.view setBackgroundColor:[UIColor clearColor]];
        //[imagePicker setAllowsEditing:YES];
        [imagePicker setDelegate:self];
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [self presentViewController:imagePicker animated:YES completion:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:MVLocalizedString(@"Picture_Alert_Title2", @"添加网络图片")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:MVLocalizedString(@"Picture_Alert_Title2", @"网络图片")
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField setPlaceholder:MVLocalizedString(@"Picture_Alert_Message2", @"请输入一个图片URL地址")];
    }];
    [alert addAction:[UIAlertAction actionWithTitle:MVLocalizedString(@"Home_Alert_Cancel", @"取消")
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:MVLocalizedString(@"Home_Alert_OK", @"确定")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
            UITextField *textField = [[alert textFields] firstObject];
            if ([[textField text] length]) {
                [[MultipleVideo shareInstance] addNetworkImageWithURLString:[textField text]];
                [self.collectionView reloadData];
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

- (void)deleteSelectedPictures
{
    if ([_selectedPictures count]) {
        NSString *title = [NSString stringWithFormat:@"%lu %@", [_selectedPictures count], MVLocalizedString(@"Picture_Alert_Title1", @"张图片")];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:MVLocalizedString(@"Picture_Alert_Message1", @"您确定要删除这些图片吗")
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:MVLocalizedString(@"Home_Alert_Cancel", @"取消")
                                                  style:UIAlertActionStyleCancel
                                                handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:MVLocalizedString(@"Home_Alert_OK", @"确定")
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            NSMutableArray *localPictures = [[NSMutableArray alloc] init];
            NSMutableArray *networkPictures = [[NSMutableArray alloc] init];
            for (NSIndexPath *indexPath in _selectedPictures) {
                NSDictionary *dictionary = [_array objectAtIndex:indexPath.section];
                NSArray *array = [dictionary objectForKey:FILE_NAME];
                if (0 == [[dictionary objectForKey:FILE_TYPE_INDEX] integerValue]) {
                    NSString *path = [dictionary objectForKey:FILE_PATH];
                    NSString *name = [array objectAtIndex:indexPath.row];
                    NSString *pathName = [NSString stringWithFormat:@"%@/%@", path, name];
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    [fileManager removeItemAtPath:pathName error:nil];
                    [localPictures addObject:name];
                }
                else {
                    [networkPictures addObject:[array objectAtIndex:indexPath.row]];
                }
            }
            [_selectedPictures removeAllObjects];
            for (NSDictionary *dictionary in _array) {
                if (0 == [[dictionary objectForKey:FILE_TYPE_INDEX] integerValue]) {
                    if ([localPictures count]) {
                        NSMutableArray *array = [dictionary objectForKey:FILE_NAME];
                        [array removeObjectsInArray:localPictures];
                    }
                }
                else {
                    if ([networkPictures count]) {
                        [[MultipleVideo shareInstance] removeNetworkImageObjects:networkPictures isPrivate:_isPrivate];
                    }
                }
            }
            [self.collectionView reloadData];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)saveToAlbum
{
    if ([_selectedPictures count]) {
        for (NSIndexPath *indexPath in _selectedPictures) {
            NSDictionary *dictionary = [_array objectAtIndex:indexPath.section];
            NSArray *array = [dictionary objectForKey:FILE_NAME];
            if (0 == [[dictionary objectForKey:FILE_TYPE_INDEX] integerValue]) { //本地图片
                NSString *urlString = [NSString stringWithFormat:@"%@/%@", [dictionary objectForKey:FILE_PATH], [array objectAtIndex:indexPath.row]];
                UIImageWriteToSavedPhotosAlbum([UIImage imageNamed:urlString], nil, nil, nil);
            }
            else { //网络图片
                NSURL *url = [NSURL URLWithString:[array objectAtIndex:indexPath.row]];
                NSData *imageData = [NSData dataWithContentsOfURL:url];
                UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:imageData], nil, nil, nil);
            }
        }
    }
}

- (NSArray *)indexPathsForSelectedRows
{
    return _selectedPictures;
}

- (void)reloadData
{
    [self.collectionView reloadData];
}

- (void)selectSection:(UIButton *)sender
{
    NSInteger number = [self.collectionView numberOfItemsInSection:sender.tag];
    for (NSInteger i = 0; i < number; i++) {
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:sender.tag]];
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        if (indexPath && ![_selectedPictures containsObject:indexPath]) {
            [_selectedPictures addObject:indexPath];
        }
    }
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[sender tag]]];
}

//解决从相册导入相片时有些竖着照片导入后就变成横着的问题
- (UIImage *)fixOrientation:(UIImage *)aImage
{
    if (UIImageOrientationUp == aImage.imageOrientation) { // No-op if the orientation is already correct
        return aImage;
    }
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored: {
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
        } break;
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored: {
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
        } break;
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored: {
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
        } break;
        default: break;
    }
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored: {
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
        } break;
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored: {
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
        } break;
        default: break;
    }
    // Now we draw the underlying CGImage into a new context, applying the transform calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored: CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage); break;
        default: CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage); break;
    }
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
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
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *name = [NSString stringWithFormat:@"%@_%.0f.png", [formatter stringFromDate:[NSDate date]],
                      [[NSDate date] timeIntervalSince1970] * 1000];
    UIImage *image = [info objectForKey:([picker allowsEditing] ? @"UIImagePickerControllerEditedImage" : @"UIImagePickerControllerOriginalImage")];
    image = [self fixOrientation:image];
    NSData *pngData = UIImagePNGRepresentation(image);
    [pngData writeToFile:[NSString stringWithFormat:@"%@/%@", path, name] atomically:YES];
    NSMutableArray *array = [dictionaryForLocal objectForKey:FILE_NAME];
    [array addObject:name];
    [self.collectionView reloadData];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [_array count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSDictionary *dictionary = [_array objectAtIndex:section];
    NSArray *files = [dictionary objectForKey:FILE_NAME];
    NSInteger count = [files count];
    if (!_isPrivate && (1 == [[[MultipleVideo shareInstance] privatePublic] integerValue])) {
        dictionary = [[[MultipleVideo shareInstance] arrayForPrivateImage] objectAtIndex:section];
        files = [dictionary objectForKey:FILE_NAME];
        count += [files count];
    }
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PictureCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    NSInteger rowIndex = indexPath.row;
    BOOL enableEdit = _enableEdit;
    NSDictionary *dictionary = [_array objectAtIndex:indexPath.section];
    NSArray *array = [dictionary objectForKey:FILE_NAME];
    if (enableEdit && ([array count] > indexPath.row)) {
        [cell setPictureSelected:[_selectedPictures containsObject:indexPath]];
    }
    if ([array count] <= rowIndex) { //私有公开的情况
        rowIndex -= [array count];
        dictionary = [[[MultipleVideo shareInstance] arrayForPrivateImage] objectAtIndex:indexPath.section];
        array = [dictionary objectForKey:FILE_NAME];
        enableEdit = NO; //私有公开时不能在首页进行删除
    }
    if (0 == [[dictionary objectForKey:FILE_TYPE_INDEX] integerValue]) { //本地图片
        NSString *urlString = [NSString stringWithFormat:@"%@/%@", [dictionary objectForKey:FILE_PATH], [array objectAtIndex:rowIndex]];
        [cell setPictureByURLString:urlString local:YES enableEdit:enableEdit];
    }
    else { //网络图片
        [cell setPictureByURLString:[array objectAtIndex:rowIndex] local:NO enableEdit:enableEdit];
    }
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat space = [(UICollectionViewFlowLayout *)collectionViewLayout minimumInteritemSpacing] * (_numberInLine - 1);
    CGFloat width = ([collectionView bounds].size.width - space) / _numberInLine;
    CGFloat height = width;
    return CGSizeMake(width, height);
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableView = nil;
    NSDictionary *dictionary = [_array objectAtIndex:indexPath.section];
    NSArray *files = [dictionary objectForKey:FILE_NAME];
    NSInteger count = [files count];
    if (!_isPrivate && (1 == [[[MultipleVideo shareInstance] privatePublic] integerValue])) {
        dictionary = [[[MultipleVideo shareInstance] arrayForPrivateImage] objectAtIndex:indexPath.section];
        files = [dictionary objectForKey:FILE_NAME];
        count += [files count];
    }
    if (count) {
        if ([kind isEqualToString:UICollectionElementKindSectionHeader]) { //头
            reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                              withReuseIdentifier:headerViewIdentifier
                                                                     forIndexPath:indexPath];
            UILabel *label = [[reusableView subviews] firstObject];
            if (nil == label) {
                CGRect frame = [reusableView bounds];
                frame.origin.x = 16;
                frame.size.width -= frame.origin.x * 2;
                label = [[UILabel alloc]initWithFrame:frame];
                [reusableView addSubview:label];
            }
            [label setText:[dictionary objectForKey:FILE_TYPE_NAME]];
//            if (1 < [[reusableView subviews] count]) {
//                UIButton *button = [[reusableView subviews] lastObject];
//                [button setTag:[indexPath section]];
//                [button setHidden:!_enableEdit];
//            }
//            else if (_enableEdit) {
//                CGRect frame = [reusableView bounds];
//                frame.origin.x = frame.size.width - 100;
//                frame.size.width = 100;
//                UIButton *button = [[UIButton alloc] initWithFrame:frame];
//                [button setTitle:@"选择所有" forState:UIControlStateNormal];
//                [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
//                [button.titleLabel setTextAlignment:NSTextAlignmentRight];
//                [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
//                [button addTarget:self action:@selector(selectSection:) forControlEvents:UIControlEventTouchUpInside];
//                [button setTag:[indexPath section]];
//                [reusableView addSubview:button];
//            }
        }
        else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) { //脚
            
        }
    }
    return reusableView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self blockSelectedIndexPath]) {
        [self blockSelectedIndexPath](indexPath);
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        if (_enableEdit) {
            NSDictionary *dictionary = [_array objectAtIndex:indexPath.section];
            NSArray *array = [dictionary objectForKey:FILE_NAME];
            if ([array count] <= indexPath.row) { //私有公开时不能在首页进行删除
                return ;
            }
            if ([_selectedPictures containsObject:indexPath]) {
                [_selectedPictures removeObject:indexPath];
                [(PictureCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath] setPictureSelected:NO];
            }
            else {
                [_selectedPictures addObject:indexPath];
                [(PictureCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath] setPictureSelected:YES];
            }
        }
        else {
            PictureBrowserViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PictureBrowserViewController"];
            NSInteger rowIndex = indexPath.row;
            NSDictionary *dictionary = [_array objectAtIndex:indexPath.section];
            NSArray *array = [dictionary objectForKey:FILE_NAME];
            if ([array count] <= rowIndex) { //私有公开时不能在首页进行删除
                rowIndex -= [array count];
                dictionary = [[[MultipleVideo shareInstance] arrayForPrivateImage] objectAtIndex:indexPath.section];
                [viewController disableDelete];
            }
            [viewController setIsPrivate:_isPrivate];
            [viewController setLocalFile:(0 == [[dictionary objectForKey:FILE_TYPE_INDEX] integerValue])];
            [viewController setPath:[dictionary objectForKey:FILE_PATH]];
            [viewController setArray:[dictionary objectForKey:FILE_NAME]];
            [viewController setIndex:rowIndex];
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    NSDictionary *dictionary = [_array objectAtIndex:section];
    NSArray *files = [dictionary objectForKey:FILE_NAME];
    return CGSizeMake([collectionView bounds].size.width, [files count] ? 30 : 0);
}

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
