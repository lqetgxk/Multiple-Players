//
//  ScrollViewController.m
//  CloudVideo
//
//  Created by issuser on 2017/3/30.
//  Copyright © 2017年 ChinaMobile. All rights reserved.
//

#import "ScrollViewController.h"

#define BUTTONS_SPACE 8.0f //按钮之间的间隔

@interface ScrollViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) NSArray *viewControllers;
@property (strong, nonatomic) NSMutableArray *buttons;
@end

@implementation ScrollViewController {
    id<ScrollViewControllerDelegate> _scrollViewControllerDelegate;
    UIScrollView *_titleScrollView;
    UIView *_markLine;
    UIScrollView *_contentScrollView;
    NSUInteger _selectedIndex;
    CGFloat _titleHeight;
    UIFont *_titleFont;
    UIColor *_titleColor;
    UIColor *_titleSelectedColor;
    UIButton *_selectedButton;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _titleHeight = 30.0f;
        _titleFont = [UIFont systemFontOfSize:17];
        _titleColor = [UIColor darkTextColor];
        _titleSelectedColor = [UIColor redColor];
        _supportSlidingGesture = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_labelTitle setText:[self title]];
    if (0 == [_viewControllers count]) {
        return;
    }
    
    CGFloat titleViewHeight = _titleHeight + 1.0f;
    _contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                        titleViewHeight,
                                                                        CGRectGetWidth([self.view bounds]),
                                                                        CGRectGetHeight([self.view bounds]) - titleViewHeight)];
    CGFloat yOffset = CGRectGetMaxY([[self.navigationController navigationBar] frame]) + titleViewHeight;
    [_contentScrollView setContentSize:CGSizeMake(CGRectGetWidth([self.view bounds]) * [_viewControllers count],
                                                  CGRectGetHeight([self.view bounds]) - yOffset)];
    [_contentScrollView setContentOffset:CGPointMake(CGRectGetWidth([self.view bounds]) * _selectedIndex, 0)];
    [_contentScrollView setDelegate:self];
    [_contentScrollView setBounces:NO];
    [_contentScrollView setShowsHorizontalScrollIndicator:NO];
    [_contentScrollView setScrollsToTop:NO];
    [_contentScrollView setScrollEnabled:_supportSlidingGesture];
    [self.view addSubview:_contentScrollView];
    
    _titleScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY([[self.navigationController navigationBar] frame]), CGRectGetWidth([self.view bounds]), titleViewHeight)];
    [_titleScrollView setBounces:NO];
    [_titleScrollView setShowsHorizontalScrollIndicator:NO];
    [_titleScrollView setScrollsToTop:NO];
    [self.view addSubview:_titleScrollView];
    
    CGFloat xButton = 0.5f * BUTTONS_SPACE;
    _buttons = [[NSMutableArray alloc] initWithCapacity:[_viewControllers count]];
    for (NSUInteger i = 0; i < [_viewControllers count]; i++) {
        UIViewController *viewController = [_viewControllers objectAtIndex:i];
        [viewController.view setFrame:CGRectMake(CGRectGetWidth([_contentScrollView bounds]) * i,
                                                 0,
                                                 CGRectGetWidth([_contentScrollView bounds]),
                                                 CGRectGetHeight([_contentScrollView bounds]))];
        [_contentScrollView addSubview:[viewController view]];
        [self addChildViewController:viewController];
        [viewController didMoveToParentViewController:self];
        
        CGFloat width = CGRectGetWidth([_titleScrollView bounds]) / [_viewControllers count] - BUTTONS_SPACE;
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(xButton, 0, width, _titleHeight)];
        [button addTarget:self action:@selector(pressedTitleButton:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:[viewController title] forState:UIControlStateNormal];
        [button.titleLabel setFont:_titleFont];
        [button setTitleColor:(i == _selectedIndex ? _titleSelectedColor : _titleColor) forState:UIControlStateNormal];
        [button setTag:i];
        [_titleScrollView addSubview:button];
        if (i == _selectedIndex) {
            _selectedButton = button;
        }
        xButton += width + BUTTONS_SPACE;
        [_buttons addObject:button];
    }

    CGFloat width =  CGRectGetWidth([_selectedButton frame]) + BUTTONS_SPACE;
    _markLine = [[UIView alloc] initWithFrame:CGRectMake(width * _selectedIndex, CGRectGetMaxY([_selectedButton frame]), width, 1.0f)];
    [_markLine setBackgroundColor:_titleSelectedColor];
    [_titleScrollView addSubview:_markLine];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pressedTitleButton:(UIButton *)sender
{
    if ([sender tag] != _selectedIndex) {
        [sender setTitleColor:_titleSelectedColor forState:UIControlStateNormal];
        [_selectedButton setTitleColor:_titleColor forState:UIControlStateNormal];
        _selectedButton = sender;
        _selectedIndex = [sender tag];
        [_contentScrollView scrollRectToVisible:CGRectMake(CGRectGetWidth([_contentScrollView bounds]) * _selectedIndex,
                                                           _contentScrollView.contentOffset.y,
                                                           CGRectGetWidth([_contentScrollView bounds]),
                                                           CGRectGetHeight([_contentScrollView bounds]))
                                       animated:YES];
        [_scrollViewControllerDelegate scrollViewController:self didSelectViewControllerAtIndex:_selectedIndex];
    }
}

- (NSInteger)selectedIndex
{
    return _selectedIndex;
}

- (UIViewController *)selectedViewController
{
    return [_viewControllers objectAtIndex:_selectedIndex];
}

- (void)setScrollViewControllerDelegate:(id<ScrollViewControllerDelegate>)delegate
{
    _scrollViewControllerDelegate = delegate;
}

- (void)setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers selectedIndex:(NSUInteger)index
{
    [self setViewControllers:viewControllers];
    _selectedIndex = index;
}

- (void)setButtonsHeight:(CGFloat)height font:(UIFont *)font color:(UIColor *)color selectedColor:(UIColor *)selectedColor
{
    _titleHeight = height;
    if (font) {
        _titleFont = font;
    }
    if (color) {
        _titleColor = color;
    }
    if (selectedColor) {
        _titleSelectedColor = selectedColor;
    }
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    return [_viewControllers objectAtIndex:index];
}

- (UIButton *)titleButtonAtIndex:(NSUInteger)index
{
    return [_buttons objectAtIndex:index];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _contentScrollView) {
        CGFloat markLine_x = CGRectGetMinX([_selectedButton frame]) - BUTTONS_SPACE / 2;
        CGFloat markLine_y = CGRectGetMinY([_markLine frame]);
        CGFloat markLine_width = CGRectGetWidth([_selectedButton frame]) + BUTTONS_SPACE;
        CGFloat markLine_height = CGRectGetHeight([_markLine frame]);
        
        CGFloat contentOffset_x = scrollView.contentOffset.x;
        CGFloat contentView_width = CGRectGetWidth([scrollView bounds]);
        
        CGFloat contentViewMoveLength = _selectedIndex * contentView_width - contentOffset_x;
        CGFloat markLineMoveLength = contentViewMoveLength / contentView_width * markLine_width;
        markLine_x -= markLineMoveLength;
        
        [_markLine setFrame:CGRectMake(markLine_x, markLine_y, markLine_width, markLine_height)];
        [_titleScrollView scrollRectToVisible:[_markLine frame] animated:NO];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (scrollView == _contentScrollView) {
        CGFloat contentViewMoveLength = targetContentOffset->x - CGRectGetWidth([scrollView bounds]) * _selectedIndex;
        if (- CGRectGetWidth([scrollView bounds]) / 3 > contentViewMoveLength) { //左移
            _selectedIndex--;
            [_scrollViewControllerDelegate scrollViewController:self didSelectViewControllerAtIndex:_selectedIndex];
        }
        else if (CGRectGetWidth([scrollView bounds]) / 3 < contentViewMoveLength) { //右移
            _selectedIndex++;
            [_scrollViewControllerDelegate scrollViewController:self didSelectViewControllerAtIndex:_selectedIndex];
        }
        if (2.0f <= fabs(velocity.x)) {
            targetContentOffset->x = CGRectGetWidth([scrollView bounds]) * _selectedIndex;
        }
        else {
            targetContentOffset->x = scrollView.contentOffset.x;
            [scrollView setContentOffset:CGPointMake(CGRectGetWidth([scrollView bounds]) * _selectedIndex, scrollView.contentOffset.y) animated:true];
        }
        if ([_selectedButton tag] != _selectedIndex) {
            [_selectedButton setTitleColor:_titleColor forState:UIControlStateNormal];
            _selectedButton = [_buttons objectAtIndex:_selectedIndex];
            [_selectedButton setTitleColor:_titleSelectedColor forState:UIControlStateNormal];
        }
    }
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
