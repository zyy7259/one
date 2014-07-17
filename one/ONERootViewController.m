//
//  ONERecommendViewController.m
//  one
//
//  Created by zyy on 14-7-13.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import "ONERootViewController.h"
#import "ONERecommendation.h"
#import "ONERecommendationManager.h"
#import "ONERecommendationBriefViewController.h"
#import "ONERecommendationDetailViewController.h"
#import "ONEDateHelper.h"

@interface ONERootViewController () <ONERecommendationDetailDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *recommendationsScrollView;
@property (weak, nonatomic) IBOutlet UIView *pullUpMenuView;
@property ONERecommendationManager *recommendationManager;
@property NSUInteger capacity;
@property NSMutableArray *recommendations;
@property NSMutableArray *viewControllers;
@property NSUInteger currentPage;
@property NSUInteger pageWidth;
@property ONEDateHelper *dateHelper;
@property CGFloat startPositionOfMainScrollView;

@end

@implementation ONERootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.recommendationManager = [ONERecommendationManager defaultManager];
    self.capacity = 3;
    self.recommendations = [NSMutableArray arrayWithCapacity:self.capacity];
    self.viewControllers = [NSMutableArray arrayWithCapacity:self.capacity];
    self.currentPage = 0;
    self.pageWidth = CGRectGetWidth(self.view.frame);
    self.dateHelper = [ONEDateHelper new];
    self.startPositionOfMainScrollView = -1;

    self.recommendationsScrollView.delegate = self;
    self.mainScrollView.delegate = self;
    [self updateScrollViewContentSize];
    
    // load the visible pages
    for (NSUInteger i = 0; i < self.capacity; i++) {
        [self loadPage:i];
    }
    
//    [self updateThemeColor];
}

- (void)updateScrollViewContentSize
{
    CGRect frame = self.view.frame;
    self.recommendationsScrollView.contentSize = CGSizeMake(CGRectGetWidth(frame) * self.capacity, CGRectGetHeight(frame));
    self.mainScrollView.contentSize = CGSizeMake(CGRectGetWidth(frame), CGRectGetHeight(frame) + 44);
    NSLog(@"%@", self.recommendationsScrollView.superview);
    NSLog(@"%@", NSStringFromCGSize(self.mainScrollView.contentSize));
}

// change the current theme color
- (void)updateThemeColor
{
    [self updateThemeColorWithPage:self.currentPage];
}

- (void)updateThemeColorWithPage:(NSUInteger)page
{
//    ONERecommendation *recommendation = self.recommendations[page];
    //    self.view.backgroundColor = recommendation.themeColor;
}

- (void)loadPage:(NSUInteger)page
{
    // load the corresponding recommendation, which will be used to init the viewControll
    // then add the controller's view to the scroll view
    
    ONERecommendationBriefViewController *viewController = nil;
    
    // if the target page not loaded, load it
    if (page == self.viewControllers.count) {
        
        // first check if need to update the scroll view's content size
        if (page == self.capacity) {
            // update capacity and scroll view
            self.capacity += 1;
            [self updateScrollViewContentSize];
        }
        
        // then load the corresponding Recommendation
        NSDateComponents *targetDateComponents = [self.dateHelper dateComponentsBeforeNDays:page];
        ONERecommendation *recommendation = [self.recommendationManager getRecommendationOfYear:targetDateComponents.year month:targetDateComponents.month day:targetDateComponents.day dataCompletionHandler:^(ONERecommendation *r) {
            // the recommendation (r) is returned from the server asynchronously
            // use r to update the corresponding view controller
            self.recommendations[page] = r;
            ONERecommendationBriefViewController *viewController = self.viewControllers[page];
            viewController.recommendation = r;
        } imageCompletionHandler:^(NSURL *location) {
            // 图片下载完成之后，将地址更新到recommendation，然后更新对应的view controller
            if (location != nil) {
                ONERecommendation *rL = self.recommendations[page];
                rL.imageUrl = location.path;
                ONERecommendationBriefViewController *bvcL = self.viewControllers[page];
                [bvcL updateRecommendationImage];
            }
        }];
        // at this time, the recommendation may be nil
        [self.recommendations addObject:recommendation];
        
        // the create the viewController
        viewController = [[ONERecommendationBriefViewController alloc] initWithRecommendation:recommendation];
        [self.viewControllers addObject:viewController];
    } else {
        viewController = self.viewControllers[page];
    }
    
    // In the end, add the controller's view to the scroll view
    if (viewController.view.superview == nil) {
        CGRect frame = self.recommendationsScrollView.frame;
        
        // leave out a margin
        NSUInteger margin = 0;
        NSUInteger barMargin = 0;  // 64 for views embedded in navagation
        frame.origin.x = CGRectGetWidth(frame) * page + margin;
        frame.origin.y = 0 + margin;
        frame.size.width -= 2 * margin;
        frame.size.height -= (barMargin + 2 * margin);
        viewController.view.frame = frame;
        
        [self addChildViewController:viewController];
        [self.recommendationsScrollView addSubview:viewController.view];
        [viewController didMoveToParentViewController:self];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.recommendationsScrollView]) {
        [self recommendationsScrollViewDidScroll];
    } else if ([scrollView isEqual:self.mainScrollView]) {
        if (self.startPositionOfMainScrollView < 0) {
            self.startPositionOfMainScrollView = self.mainScrollView.contentOffset.y;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.recommendationsScrollView]) {
        [self recommendationsScrollViewDidEndScrolling];
    } else if ([scrollView isEqual:self.mainScrollView]) {
        [self mainScrollViewDidEndScrolling];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([scrollView isEqual:self.mainScrollView] && decelerate == NO) {
        [self mainScrollViewDidEndScrolling];
    }
}

- (void)recommendationsScrollViewDidScroll
{
    // update theme color when more than 30% of the previous/next page is visible
    NSInteger startPosition = self.currentPage * self.pageWidth;
    NSInteger currentPosition = self.recommendationsScrollView.contentOffset.x;
    if (abs((int)(startPosition - currentPosition)) >= self.pageWidth / 2) {
        NSUInteger page = self.currentPage + (startPosition < currentPosition ? 1 : -1);
        [self updateThemeColorWithPage:page];
    }
}

- (void)recommendationsScrollViewDidEndScrolling
{
    // switch page when more than 50% of the previous/next page is visible
    NSUInteger page = floor((self.recommendationsScrollView.contentOffset.x - self.pageWidth / 2) / self.pageWidth) + 1;
    self.currentPage = page;
    
    [self updateThemeColor];
    
    [self loadPage:page];
    [self loadPage:page + 1];
}

- (void)mainScrollViewDidEndScrolling
{
    CGFloat endPositionOfMainScrollView = self.mainScrollView.contentOffset.y;
    NSLog(@"%f %f", self.startPositionOfMainScrollView, endPositionOfMainScrollView);
    CGFloat height = CGRectGetHeight(self.pullUpMenuView.frame);
    CGFloat threshold = height / 2;
    CGPoint contentOffset;
    CGFloat startPosition;
    if (endPositionOfMainScrollView > self.startPositionOfMainScrollView) {
        // 向上拉
        if (endPositionOfMainScrollView >= threshold) {
            // 拉过一半，显示菜单
            contentOffset = CGPointMake(0, height);
            startPosition = height;
        } else {
            // 没有拉过一半，不显示菜单
            contentOffset = CGPointMake(0, 0);
            startPosition = 0;
        }
    } else {
        // 向下拉
        if (endPositionOfMainScrollView <= threshold) {
            // 拉过一半，显示菜单
            contentOffset = CGPointMake(0, 0);
            startPosition = 0;
        } else {
            // 没有拉过一半，不显示菜单
            contentOffset = CGPointMake(0, height);
            startPosition = height;
        }
    }
    [self.mainScrollView setContentOffset:contentOffset animated:YES];
    self.startPositionOfMainScrollView = startPosition;
}

// tap gesture recognizer
- (IBAction)viewDidTapped:(UITapGestureRecognizer *)sender {
    ONERecommendationDetailViewController *detailController = [[ONERecommendationDetailViewController alloc] initWithRecommendation:self.recommendations[self.currentPage]];
    detailController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    detailController.delegate = self;
    [self presentViewController:detailController animated:YES completion:nil];
}

- (void)ONERecommendationDetailViewControllerDidFinishDisplay:(ONERecommendationDetailViewController *)recommendationDetailController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
