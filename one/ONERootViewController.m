//
//  ONERecommendViewController.m
//  one
//
//  Created by zyy on 14-7-13.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import "ONERootViewController.h"
#import "ONEResourceManager.h"
#import "ONEDateHelper.h"
#import "ONEAnimationHelper.h"
#import "ONERecommendation.h"
#import "ONERecommendationManager.h"
#import "ONERecommendationBriefViewController.h"
#import "ONERecommendationDetailViewController.h"
#import "ONERecommendationCollectionViewController.h"
#import "ONEShareViewController.h"

@interface ONERootViewController () <ONERecommendationBriefDelegate, ONERecommendationDetailDelegate, ONERecommendationCollectionDelegate, ONEShareDelegate>

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
@property NSMutableSet *recommendationCollection;

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

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

# pragma mark 初始化

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.recommendationManager = [ONERecommendationManager sharedManager];
    self.capacity = 3;
    self.recommendations = [NSMutableArray arrayWithCapacity:self.capacity];
    self.viewControllers = [NSMutableArray arrayWithCapacity:self.capacity];
    self.currentPage = 0;
    self.pageWidth = CGRectGetWidth(self.view.frame);
    self.dateHelper = [ONEDateHelper sharedDateHelper];
    
    self.recommendationCollection = [NSMutableSet set];

    self.recommendationsScrollView.delegate = self;
    self.mainScrollView.delegate = self;
    
    [self updateScrollViewContentSize];
    
    // load the visible pages
    for (NSUInteger i = 0; i < self.capacity; i++) {
        [self loadPage:i];
    }
    
    // 初始化按钮
    [self connectButtons];
    
    // 读取存储在本地的收藏列表
    self.recommendationCollection = [NSMutableSet setWithArray:[self.recommendationManager readRecommendationCollectionFromFile]];
    // 读取收藏列表之后，更新页面
    [self updateViewAppearance];
}

- (void)updateScrollViewContentSize
{
    CGRect frame = self.view.frame;
    self.recommendationsScrollView.contentSize = CGSizeMake(CGRectGetWidth(frame) * self.capacity, CGRectGetHeight(frame));
    self.mainScrollView.contentSize = CGSizeMake(CGRectGetWidth(frame), CGRectGetHeight(frame) + 44);
}

- (void)connectButtons
{
    [self.collectButton addTarget:self action:@selector(collectButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.shareButton addTarget:self action:@selector(shareButtonTapped) forControlEvents:UIControlEventTouchUpInside];
}

- (void)updateViewAppearance
{
    // 更新主题颜色
    [self updateThemeColor];
    // 更新收藏状态
    [self syncCollectButtonAndCorrespondingRecommendationState];
}

- (void)loadPage:(NSUInteger)page
{
    ONERecommendationBriefViewController *viewController = nil;
    
    // 如果page所代表的页面没有加载，加载它
    if (page == self.viewControllers.count) {
        
        // 如果capacity不够了，更新它和scrollView的contentSize
        if (page == self.capacity) {
            self.capacity += 1;
            [self updateScrollViewContentSize];
        }
        
        // then create the viewController
        viewController = [ONERecommendationBriefViewController instanceWithDateComponents:[self.dateHelper dateComponentsBeforeNDays:page]];
        viewController.delegate = self;
        [self.viewControllers addObject:viewController];
    } else {
        viewController = self.viewControllers[page];
    }
    
    // 如果viewController的view没有在view tree上，把它加载到scrollView的view tree上
    if (viewController.view.superview == nil) {
        CGRect frame = self.recommendationsScrollView.frame;
        // 页面留白
        NSUInteger margin = 0;
        // 如果使用navigationController，上方多空64
        NSUInteger barMargin = 0;
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    static BOOL firstTime = YES;
    if (firstTime) {
        firstTime = NO;
        [self disappearLoading];
    }
}

- (void)disappearLoading
{
    UIImageView *loadingView = [[UIImageView alloc] initWithImage:[ONEResourceManager sharedManager].onelifeImage];
    CGRect frame = self.view.frame;
    loadingView.frame = frame;
    [self.view addSubview:loadingView];
    
    frame = CGRectMake(-frame.size.width/2.0, -frame.size.height/2.0, frame.size.width * 2, frame.size.height * 2);
    [UIView animateWithDuration:0.75
                     animations:^{
                         loadingView.frame = frame;
                         loadingView.alpha = 0.1;
                     } completion:^(BOOL finished) {
                         [loadingView removeFromSuperview];
                     }];
}

# pragma mark 主题颜色

// 更换主题颜色
- (void)updateThemeColor
{
    [self updateThemeColorWithPage:self.currentPage];
}
// 更换到指定页码的主题颜色
- (void)updateThemeColorWithPage:(NSUInteger)page
{
    //    ONERecommendation *recommendation = self.recommendations[page];
    //    self.view.backgroundColor = recommendation.themeColor;
}

# pragma mark 左滑、右滑、上滑、下滑

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

# pragma mark 左右滑动，切换页面和主题颜色

// 左右滑动进行中，可能需要提前切换主题颜色
- (void)recommendationsScrollViewDidScroll
{
    // 当前/后页超过30%的内容被显示时，切换主题颜色
    NSInteger startPosition = self.currentPage * self.pageWidth;
    NSInteger currentPosition = self.recommendationsScrollView.contentOffset.x;
    if (abs((int)(startPosition - currentPosition)) >= self.pageWidth / 2) {
        NSUInteger page = self.currentPage + (startPosition < currentPosition ? 1 : -1);
        [self updateThemeColorWithPage:page];
    }
}

// 左右滑动结束后，可能需要切换页面
- (void)recommendationsScrollViewDidEndScrolling
{
    // 停止滑动后，如果前/后页超过50%的内容被显示，切换页面
    NSUInteger page = floor((self.recommendationsScrollView.contentOffset.x - self.pageWidth / 2) / self.pageWidth) + 1;
    self.currentPage = page;
    
    // 切换页面之后，更新页面状态
    [self updateViewAppearance];
    
    // 切换页面之后，预加载可能会显示的页面
    [self loadPage:page];
    [self loadPage:page + 1];
}

# pragma mark 上下滑动，显示/隐藏菜单

// 上下滑动结束后，可能需要显示/隐藏菜单
- (void)mainScrollViewDidEndScrolling
{
    static CGFloat lastPosition = 0;
    
    CGFloat startPosition = lastPosition;
    CGFloat endPosition = self.mainScrollView.contentOffset.y;
    CGFloat height = CGRectGetHeight(self.pullUpMenuView.frame);
    CGFloat threshold = height / 2;
    
    if (endPosition > startPosition) {
        // 向上拉
        if (endPosition >= threshold) {
            // 拉过一半，显示菜单，同时禁止浏览其它推荐
            endPosition = height;
            [self showPullUpMenu];
        } else {
            // 没有拉过一半，不显示菜单
            endPosition = 0;
            [self hidePullUpMenu];
        }
    } else {
        // 向下拉
        if (endPosition <= threshold) {
            // 拉过一半，隐藏菜单，同时可以浏览其它推荐
            endPosition = 0;
            [self hidePullUpMenu];
        } else {
            // 没有拉过一半，不隐藏菜单
            endPosition = height;
            [self showPullUpMenu];
        }
    }
    lastPosition = endPosition;
}

# pragma mark - 简单页、详情页、图片页和菜单之间的切换

// 简单页被点击了，切换到对应的详情页面
- (void)ONERecommendationBriefViewIntroTapped
{
    // 如果菜单显示中，隐藏之；否则加载recommendation的详情页
    if ([self pullUpMenuShown]) {
        [self hidePullUpMenu];
    } else {
        // 首先改变当前页面状态表明被用户点击到了
        ONERecommendationBriefViewController *briefVc = self.viewControllers[self.currentPage];
        [briefVc shadowIntroView];
        // 初始化详情页
        ONERecommendationDetailViewController *detailVC = [[ONERecommendationDetailViewController alloc] initWithRecommendation:briefVc.recommendation];
        detailVC.delegate = self;
        // 使用动画切换到详情页
        detailVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:detailVC animated:YES completion:nil];
        // TODO 自定义动画
        //        [[ONEAnimationHelper sharedAnimationHelper] pushViewController:detailController toViewController:self];
    }
}

// 详情页想要关闭时，此方法来执行具体的关闭操作，切换回简单页
- (void)ONERecommendationDetailViewControllerDidFinishDisplay:(ONERecommendationDetailViewController *)recommendationDetailController
{
    // 首先恢复简单页，取消用户点击状态
    ONERecommendationBriefViewController *vc = self.viewControllers[self.currentPage];
    [vc deshadowIntroView];
    // 然后切换回简单页
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 图片被点击了，切换到完整图片页面
- (void)ONERecommendationBriefViewImageTapped
{
    // 如果菜单显示中，隐藏之；否则加载完整的图片
    if ([self pullUpMenuShown]) {
        [self hidePullUpMenu];
    } else {
        // TODO load whole image
    }
}

// 判断菜单是否显示
- (BOOL)pullUpMenuShown
{
    return self.mainScrollView.contentOffset.y > 0;
}

// 显示菜单
- (void)showPullUpMenu
{
    // 菜单显示时，不能左右滑动
    [self.mainScrollView setContentOffset:CGPointMake(0, CGRectGetHeight(self.pullUpMenuView.frame)) animated:YES];
    self.recommendationsScrollView.scrollEnabled = NO;
}

// 隐藏菜单
- (void)hidePullUpMenu
{
    // 菜单隐藏后，可以左右滑动
    [self.mainScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    self.recommendationsScrollView.scrollEnabled = YES;
}

# pragma mark 收藏

// 更新collectButton和对应的Recommendation的收藏状态
- (void)syncCollectButtonAndCorrespondingRecommendationState
{
    // bVC的r是从服务器或者本地读取的，不包含是否被选中的信息，只能从收藏列表来判断是否被收藏
    ONERecommendationBriefViewController *bVC = self.viewControllers[self.currentPage];
    ONERecommendation *r =  bVC.recommendation;
    self.collectButton.selected = [self.recommendationCollection containsObject:r];
    // 然后更新r的状态，用于详情页同步按钮状态
    if (r != nil) {
        r.collected = self.collectButton.selected;
    }
}

// 点击收藏/取消收藏按钮，首先更新collectButton状态，然后更新当前recommendation的状态，然后将r加入收藏列表或者从收藏列表删除
- (void)collectButtonTapped
{
    self.collectButton.selected = !self.collectButton.selected;
    ONERecommendationBriefViewController *bVC = self.viewControllers[self.currentPage];
    ONERecommendation *r = bVC.recommendation;
    r.collected = self.collectButton.selected;
    if (r.collected) {
        [self addRecommendationToCollection:r];
    } else {
        [self removeRecommendationFromCollection:r];
    }
}

// 详情页点击了收藏按钮，首先更新collectButton的状态，然后将recommendation加入收藏列表
- (void)ONERecommendationDetailViewControllerDidCollectRecommendation:(ONERecommendation *)recommendation
{
    self.collectButton.selected = YES;
    [self addRecommendationToCollection:recommendation];
}

// 详情页点击了取消收藏按钮，首先更新collectButton的状态，然后将recommendation从收藏列表删除
- (void)ONERecommendationDetailViewControllerDidDecollectRecommendation:(ONERecommendation *)recommendation
{
    self.collectButton.selected = NO;
    [self removeRecommendationFromCollection:recommendation];
}

// 收藏列表页点击了删除收藏按钮，将recommendation从收藏列表删除
- (void)ONERecommendationCollectionViewControllerDidDeleteRecommendation:(ONERecommendation *)recommendation
{
    [self removeRecommendationFromCollection:recommendation];
}

// 将recommendation加入收藏列表，并将收藏列表写入本地文件
- (void)addRecommendationToCollection:(ONERecommendation *)recommendation
{
    // TODO 将收藏列表用 Array 来实现，加入收藏时要先判断是否已经存在
    [self.recommendationCollection addObject:recommendation];
    [self saveRecommendationCollectionToLocal];
}

// 将recommendation从收藏列表删除，并将收藏列表写入本地文件
- (void)removeRecommendationFromCollection:(ONERecommendation *)recommendation
{
    [self.recommendationCollection removeObject:recommendation];
    [self saveRecommendationCollectionToLocal];
}

// 将收藏列表写入本地文件
- (void)saveRecommendationCollectionToLocal
{
    [self.recommendationManager writeRecommendationCollectionToFile:self.recommendationCollection.allObjects];
}

# pragma mark - 分享

// 点击分享按钮，弹出分享界面
- (void)shareButtonTapped
{
    ONERecommendationBriefViewController *bVC = self.viewControllers[self.currentPage];
    ONERecommendation *r = bVC.recommendation;
    [[ONEShareViewController sharedShareViewControllerWithDelegate:self] shareRecommendation:r];
}

// 隐藏分享界面之后，如果有额外操作，请在这里进行
- (void)ONEShareViewControllerDidFinishDisplay:(ONEShareViewController *)recommendationShareViewController
{
}

# pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    UIViewController *vc = segue.destinationViewController;
    
    if ([vc isKindOfClass:[UINavigationController class]]) {
        
        UINavigationController *navigationController = (UINavigationController *)vc;
        UIViewController *viewController = navigationController.viewControllers[0];
        
        // 如果是切换到收藏列表页面，传递收藏列表数据
        if ([viewController isKindOfClass:[ONERecommendationCollectionViewController class]]) {
            ONERecommendationCollectionViewController *collectionController = (ONERecommendationCollectionViewController *)viewController;
            collectionController.delegate = self;
            collectionController.recommendationCollection = [NSMutableArray arrayWithArray:self.recommendationCollection.allObjects];
        }
    }
    
}

// 从收藏列表页面返回，读取并更新收藏列表数据
- (void)unwindFromRecommendationCollection:(UIStoryboardSegue *)sender
{
    ONERecommendationCollectionViewController *collectionController = sender.sourceViewController;
    // 从收藏列表回来之后，首先更新收藏列表数据
    self.recommendationCollection = [NSMutableSet setWithArray:collectionController.recommendationCollection];
    // 隐藏菜单
    [self hidePullUpMenu];
    // 当前项的收藏状态可能发生改变，更新收藏按钮状态
    [self syncCollectButtonAndCorrespondingRecommendationState];
}

// 从设置页面返回，隐藏菜单
- (void)unwindFromSetting:(UIStoryboardSegue *)sender
{
    [self hidePullUpMenu];
}

# pragma mark 内存不足

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
