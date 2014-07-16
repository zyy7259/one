//
//  ONERecommendViewController.m
//  one
//
//  Created by zyy on 14-7-13.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import "ONERootViewController.h"
#import "ONERecommendation.h"
#import "ONERecommendationBriefViewController.h"
#import "ONERecommendationDetailViewController.h"
#import "ONESessionDelegate.h"

@interface ONERootViewController () <ONERecommendationDetailDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property NSMutableArray *recommendations;
@property NSMutableArray *viewControllers;

@property NSUInteger currentPage;
@property NSUInteger pageWidth;

@property NSCalendar *gregorian;
@property NSCalendarUnit calendarUnits;
@property NSDateComponents *todayComponents;

@property ONESessionDelegate *sessionDelegate;

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
    
//    [self makeNavifationBarTransparent];
    
    // load recommendations data
    [self loadRecommendations];
    
    // set recommendScrollView
    NSUInteger count = self.recommendations.count;
    CGRect frame = self.scrollView.frame;
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(frame) * count, CGRectGetHeight(frame));
    self.scrollView.delegate = self;
    
    // view controllers are created lazily
    // in the meantime, load the array with placeholders which will be replaced on demand
    self.viewControllers = [NSMutableArray array];
    for (NSUInteger i = 0; i < count; i++) {
        [self.viewControllers addObject:[NSNull null]];
    }
    
    self.currentPage = 0;
    self.pageWidth = CGRectGetWidth(self.scrollView.frame);
    
    // pages are created on demand
    // load the visible page
    // load the page on either side to avoid flashes when the user start scrolling
    [self loadRecommendationAtPage:0];
    [self loadRecommendationAtPage:1];
    
    [self updateThemeColor];
}

- (void)makeNavifationBarTransparent
{
    // Make Navigation Bar Transparent
    UINavigationBar *bar = self.navigationController.navigationBar;
    [bar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    bar.shadowImage = [UIImage new];
    bar.translucent = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadRecommendations
{
    [self initDateComponents];
    
    self.recommendations = [NSMutableArray array];
    
    [self loadLocalRecommendations];
    
    if (self.recommendations.count == 0) {
        [self pullTodayRecommendation];
    } else {
        // Date components of the last recommendation
        ONERecommendation *lastRecommendation = self.recommendations.lastObject;
        NSDateComponents *lastComponents = lastRecommendation.dateComponents;
        
        // if two set of date components doesn't equal with each other, pull today's recommendation
        if (lastComponents.day != self.todayComponents.day
            || lastComponents.month != self.todayComponents.month
            || lastComponents.year != self.todayComponents.year) {
            [self pullTodayRecommendation];
        }
    }
}

- (void)initDateComponents
{
    // Date components of today
    NSDate *today = [NSDate date];
    self.gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    self.calendarUnits = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    self.todayComponents = [self.gregorian components:self.calendarUnits fromDate:today];
}

- (void)loadLocalRecommendations
{
    BOOL debug = YES;
    if (debug) {
        [self loadFakeLocalRecommendations];
    }
}

- (void)loadFakeLocalRecommendations
{
    NSDateComponents *oneDay = [NSDateComponents new];
    oneDay.day = -1;
    
    NSDate *date1 = [self.gregorian dateByAddingComponents:oneDay toDate:[NSDate date] options:0];
    NSDateComponents *dateComponents1 = [self.gregorian components:self.calendarUnits fromDate:date1];
    NSString *title1 = @"title1";
    NSString *briefPicUrl1 = @"http://www.emenpiao.com/UpLoadFile/ImageStore/ArticleImages/28c9132b-8ad9-4a00-aaeb-fd57f77e269c.jpg";
    NSString *description1 = @"description1";
    UIColor *themeColor1 = [UIColor colorWithRed:255 green:0 blue:0 alpha:0.2];
    ONERecommendation *recommendation1 = [ONERecommendation recommendationWithDateComponents:dateComponents1 title:title1 briefPicUrl:briefPicUrl1 description:description1 themeColor:themeColor1];
    [self.recommendations addObject:recommendation1];
    
    NSDate *date2 = [self.gregorian dateByAddingComponents:oneDay toDate:date1 options:0];
    NSDateComponents *dateComponents2 = [self.gregorian components:self.calendarUnits fromDate:date2];
    NSString *title2 = @"title2";
    NSString *briefPicUrl2 = @"http://www.hzylgh.org/uploadPic/2008_06/20113816253.jpg";
    NSString *description2 = @"description2";
    UIColor *themeColor2 = [UIColor colorWithRed:0 green:255 blue:0 alpha:0.2];
    ONERecommendation *recommendation2 = [ONERecommendation recommendationWithDateComponents:dateComponents2 title:title2 briefPicUrl:briefPicUrl2 description:description2 themeColor:themeColor2];
    [self.recommendations addObject:recommendation2];
    
    NSDate *date3 = [self.gregorian dateByAddingComponents:oneDay toDate:date2 options:0];
    NSDateComponents *dateComponents3 = [self.gregorian components:self.calendarUnits fromDate:date3];
    NSString *title3 = @"title3";
    NSString *briefPicUrl3 = @"http://wj-expo.wjimg.cn/upload_files/article/67/11_20110224140240_bukt1.jpg";
    NSString *description3 = @"description3";
    UIColor *themeColor3 = [UIColor colorWithRed:0 green:0 blue:255 alpha:0.2];
    ONERecommendation *recommendation3 = [ONERecommendation recommendationWithDateComponents:dateComponents3 title:title3 briefPicUrl:briefPicUrl3 description:description3 themeColor:themeColor3];
    [self.recommendations addObject:recommendation3];
}

- (void)pullTodayRecommendation
{
    if (self.sessionDelegate == nil) {
        self.sessionDelegate = [ONESessionDelegate new];
    }
    [self.sessionDelegate startTaskWithUrl:@"http://localhost:3000/" completionHandler:^(NSData *data) {
        NSLog(@"DATA:\n%@\nEND DATA\n", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }];
}

- (void)loadRecommendationAtPage:(NSUInteger)page
{
    if (page >= self.recommendations.count) {
        return;
    }
    
    // replace the placeholder if necessary
    ONERecommendationBriefViewController *viewController = self.viewControllers[page];
    if ((NSNull *)viewController == [NSNull null]) {
        viewController = [[ONERecommendationBriefViewController alloc] initWithRecommendation:self.recommendations[page]];
        self.viewControllers[page] = viewController;
    }
    
    // add the controller's view to the scroll view
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
    
    // load the visible page and the page on either side of it (to avoid flashes when the user start scrolling)
    [self loadRecommendationAtPage:page - 1];
    [self loadRecommendationAtPage:page];
    [self loadRecommendationAtPage:page + 1];
}

// change the current theme color
- (void)updateThemeColor
{
    [self updateThemeColorWithPage:self.currentPage];
}

- (void)updateThemeColorWithPage:(NSUInteger)page
{
    ONERecommendation *recommendation = self.recommendations[page];
    self.view.backgroundColor = recommendation.themeColor;
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
