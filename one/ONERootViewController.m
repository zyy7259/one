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
#import "ONERecommendationCollectionViewController.h"
#import "ONEDateHelper.h"

@interface ONERootViewController () <ONERecommendationBriefViewControllerDelegate, ONERecommendationDetailDelegate, ONEREcommendationDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *recommendationsScrollView;
@property (weak, nonatomic) IBOutlet UIView *pullUpMenuView;
@property (weak, nonatomic) IBOutlet UIButton *settingButton;
@property (weak, nonatomic) IBOutlet UIButton *collectButton;
@property (weak, nonatomic) IBOutlet UIButton *viewCollectButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property ONERecommendationManager *recommendationManager;
@property NSUInteger capacity;
@property NSMutableArray *recommendations;
@property NSMutableArray *viewControllers;
@property NSUInteger currentPage;
@property NSUInteger pageWidth;
@property ONEDateHelper *dateHelper;
@property CGFloat startPositionOfMainScrollView;
@property NSMutableSet *recommendationCollection;
@property NSMutableDictionary *recommendationCollectFlag;

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
    self.dateHelper = [ONEDateHelper defaultDateHelper];
    self.startPositionOfMainScrollView = 0;
    
    self.recommendationCollection = [NSMutableSet set];
    self.recommendationCollectFlag = [NSMutableDictionary dictionary];

    self.recommendationsScrollView.delegate = self;
    self.mainScrollView.delegate = self;
    [self updateScrollViewContentSize];
    
    // load the visible pages
    for (NSUInteger i = 0; i < self.capacity; i++) {
        [self loadPage:i];
    }
    
    // 初始化按钮
    [self initButtons];
    
    // 读取存储在本地的收藏列表
    self.recommendationCollection = [NSMutableSet setWithArray:[self.recommendationManager readRecommendationCollectionFromFile]];
    // 更新收藏按钮的状态
    [self updateCollectButtonState];
    
//    [self updateThemeColor];
}

- (void)updateScrollViewContentSize
{
    CGRect frame = self.view.frame;
    self.recommendationsScrollView.contentSize = CGSizeMake(CGRectGetWidth(frame) * self.capacity, CGRectGetHeight(frame));
    self.mainScrollView.contentSize = CGSizeMake(CGRectGetWidth(frame), CGRectGetHeight(frame) + 44);
}

- (void)initButtons
{
    [self.collectButton addTarget:self action:@selector(collectButtonTapped) forControlEvents:UIControlEventTouchUpInside];
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
            // update r's weekday
            r.weekday = targetDateComponents.weekday;
            // update delegate
            r.delegate = self;
            // save r
            self.recommendations[page] = r;
            // use r to update the corresponding view controller
            ONERecommendationBriefViewController *viewController = self.viewControllers[page];
            viewController.recommendation = r;
        } imageCompletionHandler:^(NSURL *location) {
            // 图片下载完成之后，将地址更新到recommendation，然后更新对应的view controller
            if (location != nil) {
                ONERecommendation *r = self.recommendations[page];
                r.imageUrl = location.path;
                ONERecommendationBriefViewController *vc = self.viewControllers[page];
                [vc updateRecommendationImage];
            }
        }];
        // at this time, the recommendation may be nil
        if (recommendation == nil) {
            [self.recommendations addObject:[NSNull null]];
        } else {
            recommendation.delegate = self;
            [self.recommendations addObject:recommendation];
        }
        
        // then create the viewController
        viewController = [[ONERecommendationBriefViewController alloc] initWithRecommendation:recommendation];
        viewController.delegate = self;
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
    
    // 切换页面之后，更新页面状态
    [self updateThemeColor];
    [self updateCollectButtonState];
    
    [self loadPage:page];
    [self loadPage:page + 1];
}

- (void)mainScrollViewDidEndScrolling
{
    CGFloat startPosition = self.startPositionOfMainScrollView;
    CGFloat endPosition = self.mainScrollView.contentOffset.y;
    CGFloat height = CGRectGetHeight(self.pullUpMenuView.frame);
    CGFloat threshold = height / 2;
    
    if (endPosition > startPosition) {
        // 向上拉
        if (endPosition >= threshold) {
            // 拉过一半，显示菜单，同时禁止浏览其它推荐
            startPosition = height;
            [self showPullUpMenu];
        } else {
            // 没有拉过一半，不显示菜单
            startPosition = 0;
            [self hidePullUpMenu];
        }
    } else {
        // 向下拉
        if (endPosition <= threshold) {
            // 拉过一半，隐藏菜单，同时可以浏览其它推荐
            startPosition = 0;
            [self hidePullUpMenu];
        } else {
            // 没有拉过一半，不隐藏菜单
            startPosition = height;
            [self showPullUpMenu];
        }
    }
    self.startPositionOfMainScrollView = startPosition;
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

// tap gesture recognizer

- (void)ONERecommendationBriefViewIntroTapped
{
    if (self.mainScrollView.contentOffset.y > 0) {
        [self hidePullUpMenu];
    } else {
        ONERecommendationDetailViewController *detailController = [[ONERecommendationDetailViewController alloc] initWithRecommendation:self.recommendations[self.currentPage]];
        detailController.delegate = self;
        [self presentViewController:detailController animated:YES completion:nil];
    }
}

- (void)ONERecommendationBriefViewImageTapped
{
    if (self.mainScrollView.contentOffset.y > 0) {
        [self hidePullUpMenu];
    } else {
        // TODO load initial image
    }
}

- (void)ONERecommendationDetailViewControllerDidFinishDisplay:(ONERecommendationDetailViewController *)recommendationDetailController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showPullUpMenu
{
    [self.mainScrollView setContentOffset:CGPointMake(0, CGRectGetHeight(self.pullUpMenuView.frame)) animated:YES];
    self.recommendationsScrollView.scrollEnabled = NO;
}

- (void)hidePullUpMenu
{
    [self.mainScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    self.recommendationsScrollView.scrollEnabled = YES;
}

// collect

- (void)updateCollectButtonState
{
    ONERecommendation *recommendation = self.recommendations[self.currentPage];
    self.collectButton.selected = [self.recommendationCollection containsObject:recommendation];
    if (recommendation != nil && (NSNull *)recommendation != [NSNull null] && recommendation.collected != self.collectButton.selected) {
        recommendation.collected = self.collectButton.selected;
    }
}

- (void)collectButtonTapped
{
    self.collectButton.selected = !self.collectButton.selected;
    ONERecommendation *recommendation = self.recommendations[self.currentPage];
    [recommendation updateCollected:self.collectButton.selected];
    return;
}

- (void)ONERecommendationDidCollect:(ONERecommendation *)recommendation
{
    self.collectButton.selected = YES;
    [self.recommendationCollection addObject:recommendation];
    [self saveRecommendationCollection];
}

- (void)ONERecommendationDidDecollect:(ONERecommendation *)recommendation
{
    self.collectButton.selected = NO;
    [self.recommendationCollection removeObject:recommendation];
    [self saveRecommendationCollection];
}

- (void)saveRecommendationCollection
{
    [self.recommendationManager writeRecommendationCollectionToFile:self.recommendationCollection.allObjects];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UINavigationController *navigationController = [segue destinationViewController];
    UIViewController *viewController = navigationController.viewControllers[0];
    
    if ([viewController isKindOfClass:[ONERecommendationCollectionViewController class]]) {
        ONERecommendationCollectionViewController *collectionController = (ONERecommendationCollectionViewController *)viewController;
        collectionController.recommendationCollection = [NSMutableArray arrayWithArray:self.recommendationCollection.allObjects];
    }
}

- (void)unwindFromRecommendationCollection:(UIStoryboardSegue *)sender
{
    ONERecommendationCollectionViewController *collectionController = sender.sourceViewController;
    self.recommendationCollection = [NSMutableSet setWithArray:collectionController.recommendationCollection];
    // 从收藏列表回来之后，收藏状态可能发生改变，更新收藏按钮状态
    [self updateCollectButtonState];
}

- (void)unwindFromSetting:(UIStoryboardSegue *)sender
{
}

@end
