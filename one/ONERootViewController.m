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

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property ONERecommendationManager *recommendationManager;
@property NSUInteger capacity;
@property NSMutableArray *recommendations;
@property NSMutableArray *viewControllers;
@property NSUInteger currentPage;
@property NSUInteger pageWidth;
@property ONEDateHelper *dateHelper;

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
    
    self.recommendationManager = [ONERecommendationManager new];
    self.capacity = 3;
    self.recommendations = [NSMutableArray arrayWithCapacity:self.capacity];
    self.viewControllers = [NSMutableArray arrayWithCapacity:self.capacity];
    self.currentPage = 0;
    self.pageWidth = CGRectGetWidth(self.scrollView.frame);
    self.dateHelper = [ONEDateHelper new];

    self.scrollView.delegate = self;
    [self updateScrollViewContentSize];
    
    // load the visible pages
    for (NSUInteger i = 0; i < self.capacity; i++) {
        [self loadPage:i];
    }
    
    //    [self makeNavifationBarTransparent];
    [self updateThemeColor];
}

- (void)updateScrollViewContentSize
{
    CGRect frame = self.scrollView.frame;
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(frame) * self.capacity, CGRectGetHeight(frame));
}

- (void)makeNavifationBarTransparent
{
    // Make Navigation Bar Transparent
    UINavigationBar *bar = self.navigationController.navigationBar;
    [bar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    bar.shadowImage = [UIImage new];
    bar.translucent = YES;
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
    ONERecommendationBriefViewController *viewController = nil;
    
    if (page == self.viewControllers.count) {
        // first update capacity and scroll view
        self.capacity += 1;
        [self updateScrollViewContentSize];
        
        // then load the corresponding Recommendation
        NSDateComponents *dc = [self.dateHelper dateComponentsBeforeNDays:page];
        ONERecommendation *recommendation = [self.recommendationManager getRecommendationOfYear:dc.year month:dc.month day:dc.day];
        [self.recommendations addObject:recommendation];
        
        // the create the viewController
        viewController = [[ONERecommendationBriefViewController alloc] initWithRecommendation:recommendation];
        [self.viewControllers addObject:viewController];
    } else {
        viewController = self.viewControllers[page];
    }
    
    // In the end, add the controller's view to the scroll view
    if (viewController.view.superview == nil) {
        CGRect frame = self.scrollView.frame;
        
        // leave out a margin
        NSUInteger margin = 0;
        NSUInteger barMargin = 0;  // 64 for views embedded in navagation
        frame.origin.x = CGRectGetWidth(frame) * page + margin;
        frame.origin.y = 0 + margin;
        frame.size.width -= 2 * margin;
        frame.size.height -= (barMargin + 2 * margin);
        viewController.view.frame = frame;
        
        [self addChildViewController:viewController];
        [self.scrollView addSubview:viewController.view];
        [viewController didMoveToParentViewController:self];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // update theme color when more than 30% of the previous/next page is visible
    NSInteger startPosition = self.currentPage * self.pageWidth;
    NSInteger currentPosition = self.scrollView.contentOffset.x;
    if (abs((int)(startPosition - currentPosition)) >= self.pageWidth / 2) {
        NSUInteger page = self.currentPage + (startPosition < currentPosition ? 1 : -1);
        [self updateThemeColorWithPage:page];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // switch page when more than 50% of the previous/next page is visible
    NSUInteger page = floor((self.scrollView.contentOffset.x - self.pageWidth / 2) / self.pageWidth) + 1;
    self.currentPage = page;
    
    [self updateThemeColor];
    
    [self loadPage:page];
    [self loadPage:page + 1];
}

// gesture recognizers
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
