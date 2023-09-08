//
//  WebViewController.m
//  MultipleVideo
//
//  Created by 罗胜强 on 2023/9/8.
//  Copyright © 2023 lsq. All rights reserved.
//

#import "WebViewController.h"
#import "MultipleVideo.h"
#import <WebKit/WebKit.h>

@interface WebViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet WKWebView *webView;
@end

@implementation WebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.labelTitle setText:MVLocalizedString(@"FileImportMethod_Title", @"标题")];
    NSString *filename = [[NSBundle mainBundle] pathForResource:MVLocalizedString(@"FileImportMethod_html", @"文档") ofType:nil];
    [self.webView loadHTMLString:[NSString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:nil] baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
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
