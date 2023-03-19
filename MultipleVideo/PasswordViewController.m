//
//  PasswordViewController.m
//  MultipleVideo
//
//  Created by issuser on 2017/4/30.
//  Copyright © 2017年 lsq. All rights reserved.
//

#import "PasswordViewController.h"
#import "MultipleVideo.h"

@interface PasswordViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIButton *buttonCancel;
@property (weak, nonatomic) IBOutlet UIView *viewPassword;
@property (weak, nonatomic) IBOutlet UIView *viewDot1;
@property (weak, nonatomic) IBOutlet UIView *viewDot2;
@property (weak, nonatomic) IBOutlet UIView *viewDot3;
@property (weak, nonatomic) IBOutlet UIView *viewDot4;
@property (weak, nonatomic) IBOutlet UIView *viewDot5;
@property (weak, nonatomic) IBOutlet UIView *viewDot6;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPassword;
@property (weak, nonatomic) IBOutlet UILabel *labelTip;
@end

@implementation PasswordViewController {
    NSString *_password;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_viewPassword.layer setBorderWidth:1];
    [_viewPassword.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [_textFieldPassword becomeFirstResponder];
    [_viewDot1 setHidden:YES];
    [_viewDot2 setHidden:YES];
    [_viewDot3 setHidden:YES];
    [_viewDot4 setHidden:YES];
    [_viewDot5 setHidden:YES];
    [_viewDot6 setHidden:YES];
    if (nil == [self blockCancel]) {
        [_buttonCancel setHidden:YES];
        [_labelTitle setText:MVLocalizedString(@"Password_Title", @"密码锁定")];
    }
    else {
        [_labelTitle setText:MVLocalizedString(@"Password_Set", @"设置密码")];
        [_buttonCancel setTitle:MVLocalizedString(@"Password_Cancel", @"取消") forState:UIControlStateNormal];
    }
    [_labelTip setText:MVLocalizedString(@"Password_Hint1", @"请输入密码")];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(UIButton *)sender
{
    [self blockCancel]();
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string length]) {
        if (6 <= [[textField text] length]) {
            return NO;
        }
        else {
            switch ([textField.text length]) {
                case 5: [_viewDot6 setHidden:NO]; break;
                case 4: [_viewDot5 setHidden:NO]; break;
                case 3: [_viewDot4 setHidden:NO]; break;
                case 2: [_viewDot3 setHidden:NO]; break;
                case 1: [_viewDot2 setHidden:NO]; break;
                case 0: [_viewDot1 setHidden:NO]; break;
                default: break;
            }
            if (5 == [textField.text length]) {
                dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, 300 * NSEC_PER_MSEC);
                dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                    if ([self blockCancel]) {
                        if (nil == _password) {
                            _password = [[_textFieldPassword text] copy];
                            [_labelTip setTextColor:[UIColor blackColor]];
                            [_labelTip setText:MVLocalizedString(@"Password_Hint2", @"请再次输入密码")];
                        }
                        else {
                            if ([[_textFieldPassword text] isEqualToString:_password]) {
                                [_labelTip setTextColor:[UIColor blackColor]];
                                [_labelTip setText:MVLocalizedString(@"Password_Hint4", @"设置密码成功")];
                                [[MultipleVideo shareInstance] setPassword:_password];
                                [self dismissViewControllerAnimated:YES completion:nil];
                                return ;
                            }
                            else {
                                [_labelTip setText:MVLocalizedString(@"Password_Hint3", @"两次输入密码不一致，请重新设置")];
                                [_labelTip setTextColor:[UIColor redColor]];
                                [MultipleVideo shakeAnimationForView:_labelTip];
                                _password = nil;
                            }
                        }
                        [_textFieldPassword setText:@""];
                    }
                    else {
                        if ([[_textFieldPassword text] isEqualToString:[[MultipleVideo shareInstance] password]]) {
                            [_labelTip setTextColor:[UIColor blackColor]];
                            [_labelTip setText:MVLocalizedString(@"Password_Hint6", @"密码正确")];
                            [self dismissViewControllerAnimated:YES completion:^{
                                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOCKSCREEN_EXIT object:nil];
                            }];
                            return ;
                        }
                        else {
                            [_labelTip setText:MVLocalizedString(@"Password_Hint5", @"密码错误，请重新输入")];
                            [_labelTip setTextColor:[UIColor redColor]];
                            [MultipleVideo shakeAnimationForView:_labelTip];
                            [_textFieldPassword setText:@""];
                        }
                    }
                    [_viewDot1 setHidden:YES];
                    [_viewDot2 setHidden:YES];
                    [_viewDot3 setHidden:YES];
                    [_viewDot4 setHidden:YES];
                    [_viewDot5 setHidden:YES];
                    [_viewDot6 setHidden:YES];
                });
            }
        }
    }
    else {
        switch ([textField.text length]) {
            case 6: [_viewDot6 setHidden:YES]; break;
            case 5: [_viewDot5 setHidden:YES]; break;
            case 4: [_viewDot4 setHidden:YES]; break;
            case 3: [_viewDot3 setHidden:YES]; break;
            case 2: [_viewDot2 setHidden:YES]; break;
            case 1: [_viewDot1 setHidden:YES]; break;
            default: break;
        }
    }
    return YES;
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
