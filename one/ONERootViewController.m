//
//  ONERecommendViewController.m
//  one
//
//  Created by zyy on 14-7-13.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import "ONERootViewController.h"
#import "ONEImageManager.h"
#import "ONEDateUtils.h"
#import "ONEAnimationHelper.h"
#import "ONEViewUtils.h"
#import "ONERecommendation.h"
#import "ONERecommendationManager.h"
#import "ONERecommendationBriefViewController.h"
#import "ONERecommendationDetailViewController.h"
#import "ONERecommendationCollectionViewController.h"
#import "ONERecommendationImageViewController.h"
#import "ONEShareViewController.h"

@interface ONERootViewController () <ONERecommendationBriefDelegate, ONERecommendationCollectionDelegate, ONERecommendationImageDelegate, ONEShareDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *recommendationsScrollView;
@property (weak, nonatomic) IBOutlet UIView *pullUpMenuView;
@property (weak, nonatomic) IBOutlet UIButton *settingButton;
@property (weak, nonatomic) IBOutlet UIButton *collectButton;
@property (weak, nonatomic) IBOutlet UIButton *viewCollectButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekdayLabel;
@property (weak, nonatomic) IBOutlet UIView *likesView;
@property (weak, nonatomic) IBOutlet UIButton *likesButton;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UIButton *goToFirstButton;
@property ONERecommendationManager *recommendationManager;
@property NSMutableArray *recommendations;
@property NSMutableArray *viewControllers;
@property NSUInteger lastPage;
@property NSUInteger currentPage;
@property NSUInteger pageWidth;
@property ONEDateUtils *dateHelper;
@property NSMutableArray *recommendationCollection;

@end

typedef void (^CompletionHandler)();

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
    [self setNeedsStatusBarAppearanceUpdate];
    // Do any additional setup after loading the view.
    
    self.recommendationManager = [ONERecommendationManager sharedManager];
    self.recommendations = [NSMutableArray array];
    self.viewControllers = [NSMutableArray array];
    self.lastPage = 0;
    self.currentPage = 0;
    self.pageWidth = CGRectGetWidth(self.view.frame);
    self.dateHelper = [ONEDateUtils sharedDateHelper];
    self.recommendationCollection = [NSMutableArray array];
    self.recommendationsScrollView.delegate = self;
    self.mainScrollView.delegate = self;
    
    // 初始化按钮
    [self connectButtons];
    // 更新mainScrollView的contentSize
    CGRect frame = self.view.frame;
    self.mainScrollView.contentSize = CGSizeMake(CGRectGetWidth(frame), CGRectGetHeight(frame) + CGRectGetHeight(self.pullUpMenuView.frame));
    // 预加载页面
    for (NSUInteger i = 0; i < 2; i++) {
        [self loadPage:i];
    }
    // 读取存储在本地的收藏列表
    self.recommendationCollection = [self.recommendationManager readRecommendationCollectionFromFile];
    // 读取收藏列表之后，更新页面，需要根据收藏状态更新按钮状态
    [self updateInterface];
    // 使loading页渐渐消失
    [self disappearLoading:nil];
}

- (void)disappearLoading:(CompletionHandler)handler
{
    UIImageView *loadingView = [[UIImageView alloc] initWithImage:[ONEImageManager sharedManager].onelifeImage];
    CGRect frame = self.view.frame;
    loadingView.frame = frame;
    [self.view addSubview:loadingView];
    
    frame = CGRectMake(-frame.size.width/2.0, -frame.size.height/2.0, frame.size.width * 2, frame.size.height * 2);
    [UIView animateWithDuration:3.0
                     animations:^{
                         loadingView.frame = frame;
                         loadingView.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [loadingView removeFromSuperview];
                         if (handler != nil) {
                             handler();
                         }
                     }];
}

- (void)connectButtons
{
    [self.collectButton addTarget:self action:@selector(collectButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.shareButton addTarget:self action:@selector(shareButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.likesButton addTarget:self action:@selector(likesButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.goToFirstButton addTarget:self action:@selector(goToFirstButtonTapped) forControlEvents:UIControlEventTouchUpInside];
}

- (void)loadPage:(NSUInteger)page
{
    // 如果page所代表的页面没有加载，加载之
    if (page == self.viewControllers.count) {
        // 首先更新scrollView的contentSize
        CGSize size = self.recommendationsScrollView.contentSize;
        size.width += self.recommendationsScrollView.frame.size.width;
        self.recommendationsScrollView.contentSize = size;
        
        // 创建新的viewController
        ONERecommendationBriefViewController *viewController = [ONERecommendationBriefViewController instanceWithDateComponents:[self.dateHelper dateComponentsBeforeNDays:page]];
        viewController.delegate = self;
        [self.viewControllers addObject:viewController];
        
        // 计算viewController的view的frame
        CGRect frame = self.recommendationsScrollView.frame;
        frame.origin.x = CGRectGetWidth(frame) * page;
        frame.origin.y = 0;
        viewController.view.frame = frame;
        // 将viewController的view加载到scrollView的view tree上
        [self addChildViewController:viewController];
        [self.recommendationsScrollView addSubview:viewController.view];
        [viewController didMoveToParentViewController:self];
        
        // 如果是当前正在显示的页面，启动自动更新
        if (page == self.currentPage) {
            [viewController startAutoUpdate];
        }
    }
}

- (void)updateInterface
{
    // 更新主题颜色
    [self updateThemeColor];
    // 更新收藏状态
    [self syncCollectButtonAndCorrespondingRecommendationState];
    // 更新date
    [self updateDate];
    // 更新返回首页的按钮
    if (self.currentPage == 0) {
        self.goToFirstButton.hidden = YES;
    } else {
        self.goToFirstButton.hidden = NO;
    }
    // 更新likes
    NSInteger likes = 0;
    ONERecommendationBriefViewController *bVC = self.viewControllers[self.currentPage];
    if (bVC != nil) {
        likes = bVC.recommendation.likes;
        if ([bVC canInteract]) {
            self.mainScrollView.scrollEnabled = YES;
        } else {
            self.mainScrollView.scrollEnabled = NO;
        }
    }
    [self updateLikes:likes];
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
}

// 展示日期信息，不管是否有recommendation的数据，日期总是可以显示
- (void)updateDate
{
    static NSDateComponents *lastDateComponents;
    
    NSDateComponents *dateComponents = [self.dateHelper dateComponentsBeforeNDays:self.currentPage];
    // 使用动画更新dayLabel
    // 首先获取要显示的text
    NSString *dayText = [@(dateComponents.day) stringValue];
    if (dateComponents.day < 10) {
        dayText = [@"0" stringByAppendingString:dayText];
    }
    // 动画
    if (lastDateComponents != nil) {
        UILabel *newDayLabel = [ONEViewUtils deepLabelCopy:self.dayLabel];
        [newDayLabel removeFromSuperview];
        newDayLabel.text = dayText;
        NSInteger option = UIViewAnimationOptionTransitionCrossDissolve;
        if (self.lastPage < self.currentPage) {
            // 显示的是下一页
            option = UIViewAnimationOptionTransitionFlipFromRight;
        } else if (self.lastPage > self.currentPage) {
            // 显示的是上一页
            option = UIViewAnimationOptionTransitionFlipFromLeft;
        }
        [UIView transitionFromView:self.dayLabel toView:newDayLabel duration:0.8 options:option completion:nil];
        self.dayLabel = newDayLabel;
    } else {
        self.dayLabel.text = dayText;
    }
    self.monthLabel.text = [[ONEDateUtils sharedDateHelper] briefStringOfMonth:dateComponents.month];
    self.weekdayLabel.text = [[ONEDateUtils sharedDateHelper] stringOfWeekday:dateComponents.weekday];
    lastDateComponents = dateComponents;
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
    if (decelerate == NO) {
        if ([scrollView isEqual:self.recommendationsScrollView]) {
        } else if ([scrollView isEqual:self.mainScrollView]) {
            [self mainScrollViewDidEndScrolling];
        }
    }
}

# pragma mark 左右滑动，切换页面和主题颜色

// 左右滑动进行中，可能需要提前切换主题颜色
- (void)recommendationsScrollViewDidScroll
{
    // 当前/后页超过30%的内容被显示时，切换主题颜色
    NSInteger startPosition = self.currentPage * self.pageWidth;
    NSInteger currentPosition = self.recommendationsScrollView.contentOffset.x;
    if (abs((int)(startPosition - currentPosition)) >= self.pageWidth / 3.0) {
        NSUInteger page = self.currentPage + (startPosition < currentPosition ? 1 : -1);
        [self updateThemeColorWithPage:page];
    }
    [self updatePageAfterScrolling];
}

// 左右滑动结束后，可能需要切换页面
- (void)recommendationsScrollViewDidEndScrolling
{
    [self updatePageAfterScrolling];
}

- (void)updatePageAfterScrolling
{
    // 滑动后，如果前/后页超过50%的内容被显示，则将要切换页面
    NSUInteger page = floor((self.recommendationsScrollView.contentOffset.x - self.pageWidth / 2) / self.pageWidth) + 1;
    // 如果切换到了新的页面
    if (page != self.currentPage) {
        // 首先停止上一个页面的自动更新
        ONERecommendationBriefViewController *bVC = self.viewControllers[self.currentPage];
        [bVC stopAutoUpdate];
        // 然后开始新的页面的自动更新
        self.lastPage = self.currentPage;
        self.currentPage = page;
        bVC = self.viewControllers[self.currentPage];
        [bVC startAutoUpdate];
        
        // 切换页面之后，更新页面状态
        [self updateInterface];
        // 切换页面之后，预加载可能会显示的页面
        [self loadPage:++page];
    }
}

# pragma mark brief加载recommendation的回调函数

// Brief加载完成之后的回调函数，如果是当前页，则更新相应信息
- (void)ONERecommendationBriefViewDidLoadRecommendation:(ONERecommendationBriefViewController *)recommendationBriefViewController
{
    if (recommendationBriefViewController == self.viewControllers[self.currentPage]) {
        [self updateLikes:recommendationBriefViewController.recommendation.likes];
    }
}

// 加载到空的recommendation，将其从scrollView上移除
- (void)ONERecommendationBriefViewEmptyRecommendation:(ONERecommendationBriefViewController *)recommendationBriefViewController
{
    CGSize size = self.recommendationsScrollView.contentSize;
    size.width -= self.recommendationsScrollView.frame.size.width;
    self.recommendationsScrollView.contentSize = size;
    [recommendationBriefViewController removeFromParentViewController];
    [recommendationBriefViewController.view removeFromSuperview];
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

// 图片被点击了，切换到完整图片页面
- (void)ONERecommendationBriefViewImageTapped
{
    // 如果菜单显示中，隐藏之；否则加载完整的图片
    if ([self pullUpMenuShown]) {
        [self hidePullUpMenu];
    } else {
        // 加载整个图片
        ONERecommendationBriefViewController *briefVc = self.viewControllers[self.currentPage];
        ONERecommendationImageViewController *imageVC = [ONERecommendationImageViewController instanceWithRecommendation:briefVc.recommendation];
        imageVC.delegate = self;
        
//        [self addChildViewController:imageVC];
//        [self.view addSubview:imageVC.view];
//        [imageVC didMoveToParentViewController:self];
        imageVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:imageVC animated:YES completion:nil];
        
    }
}

// 图片页想要关闭，此方法来执行具体的关闭操作
- (void)ONERecommendationImageViewControllerDidFinishDisplay:(ONERecommendationImageViewController *)recommendationImageController
{
    // 移除图片页
//    [recommendationImageController.view removeFromSuperview];
    [self dismissViewControllerAnimated:YES completion:nil];
}

// blurView被点击了
- (void)ONERecommendationBriefViewBlurViewTapped
{
    // 如果菜单显示中，隐藏之
    if ([self pullUpMenuShown]) {
        [self hidePullUpMenu];
    }
}

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
//        [ONEAnimationHelper pushViewController:detailVC toViewController:self];
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
    // TODO 自定义动画
//    [ONEAnimationHelper popViewContorller:recommendationDetailController fromViewController:self];
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
    self.goToFirstButton.enabled = NO;
}

// 隐藏菜单
- (void)hidePullUpMenu
{
    // 菜单隐藏后，可以左右滑动
    [self.mainScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    self.recommendationsScrollView.scrollEnabled = YES;
    self.goToFirstButton.enabled = YES;
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
    // 收藏列表用 Array 来实现，加入收藏时要先判断是否已经存在
    if (![self.recommendationCollection containsObject:recommendation]) {
        [self.recommendationCollection addObject:recommendation];
    }
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
    [self.recommendationManager writeRecommendationCollectionToFile:self.recommendationCollection];
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

# pragma mark - 喜欢

// Brief更新了likes，如果是当前页，更新之；如果当前显示了详情页，更新之
- (void)ONERecommendationBriefView:(ONERecommendationBriefViewController *)recommendationBriefViewController didUpdateRecommendationLikes:(NSInteger)likes
{
    if (recommendationBriefViewController == self.viewControllers[self.currentPage]) {
        UIViewController *vc = self.presentedViewController;
        if ([vc isKindOfClass:[ONERecommendationDetailViewController class]]) {
            ONERecommendationDetailViewController *dVc = (ONERecommendationDetailViewController *)vc;
            [dVc updateLikes:likes];
        }
        [self updateLikes:likes];
    }
}

// Detail更新了likes，更新Brief
- (void)ONERecommendationDetailViewControllerLikesButtonTapped:(ONERecommendationDetailViewController *)recommendationDetailController action:(NSInteger)action
{
    ONERecommendationBriefViewController *bVc = self.viewControllers[self.currentPage];
    switch (action) {
        case 1:
            [bVc like];
            break;
        case -1:
            [bVc dislike];
            break;
        default:
            break;
    }
}

- (IBAction)likesViewTapped
{
    [self likesButtonTapped];
}

// 点击喜欢按钮
- (void)likesButtonTapped
{
    NSInteger likes = [self.likesLabel.text integerValue];
    ONERecommendationBriefViewController *bVC = self.viewControllers[self.currentPage];
    self.likesButton.selected = !self.likesButton.selected;
    if (self.likesButton.selected) {
        likes++;
        [bVC like];
    } else {
        likes--;
        [bVC dislike];
    }
    [self updateLikes:likes];
}

// 更新喜欢按钮
- (void)updateLikes:(NSInteger)likes
{
    static NSInteger MAX_LIKES = 999;
    // 如果数据非法，修正之
    if (likes < 0) {
        likes = 0;
    }
    if (likes == 0 && self.likesButton.selected) {
        likes = 1;
    }
    if (likes > MAX_LIKES) {
        likes = MAX_LIKES;
    }
    NSString *likeString = [NSString stringWithFormat:@"%ld%@",
                            (long)likes,
                            (likes == MAX_LIKES ? @"+" : @"")];
    
    self.likesLabel.text = likeString;
    
    self.likesButton.hidden = NO;
}

# pragma mark 返回首页

- (void)goToFirstButtonTapped
{
    [self.recommendationsScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    self.currentPage = 0;
    [self updateInterface];
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
            collectionController.recommendationCollection = self.recommendationCollection;
        }
    }
    
}

// 从收藏列表页面返回，读取并更新收藏列表数据
- (void)unwindFromRecommendationCollection:(UIStoryboardSegue *)sender
{
    ONERecommendationCollectionViewController *collectionController = sender.sourceViewController;
    // 从收藏列表回来之后，首先更新收藏列表数据
    self.recommendationCollection = collectionController.recommendationCollection;
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
