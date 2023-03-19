//
//  PrivatePasswordViewController.m
//  MultipleVideo
//
//  Created by issuser on 2017/5/6.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import "PrivatePasswordViewController.h"
#import "MultipleVideo.h"

@interface PrivatePasswordViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonItemSave;
@property (weak, nonatomic) IBOutlet UITextView *textViewDescribe;
@end

@implementation PrivatePasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_labelTitle setText:MVLocalizedString(@"Private_Introduce_Title", @"私密介绍")];
    [_barButtonItemSave setTitle:MVLocalizedString(@"Private_Introduce_Save", @"保存")];
    [[self.navigationItem backBarButtonItem] setTitle:MVLocalizedString(@"Home_Left_Back", @"返回")];
    if ([[MultipleVideo shareInstance] privateDescribe]) {
        [_textViewDescribe setText:[[MultipleVideo shareInstance] privateDescribe]];
    }
    else {
        [_textViewDescribe setText:MVLocalizedString(@"Private_Introduce_Content", @"介绍")];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

- (IBAction)save:(UIBarButtonItem *)sender
{
    [[MultipleVideo shareInstance] setPrivateDescribe:_textViewDescribe.text];
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
