//
//  ONERecommendSimpleViewController.m
//  one
//
//  Created by zyy on 14-7-13.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import "ONERecommendationBriefViewController.h"
#import "ONERecommendation.h"
#import "ONERecommendationManager.h"
#import "ONELogger.h"
#import "ONEDateUtils.h"
#import "ONEViewUtils.h"
#import "ONEImageManager.h"
#import "ONEConstants.h"
#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"
#import "FXBlurView.h"

@interface ONERecommendationBriefViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *thingImageView;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekdayLabel;
@property (weak, nonatomic) IBOutlet UIImageView *typeImageView;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet FXBlurView *blurView;
@property (weak, nonatomic) IBOutlet UIView *introView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *introLabel;
@property (weak, nonatomic) IBOutlet UILabel *briefDetailLabel;

@property ONERecommendationManager *recommendationManager;
@property NSDateComponents *dateComponents;
@property FLAnimatedImageView *loadingImageView;
@property NSThread *autoUpdateThread;

@end

@implementation ONERecommendationBriefViewController

+ (id)instanceWithDateComponents:(NSDateComponents *)dateComponents
{
    return [[self alloc] initWithDateComponents:dateComponents];
}

- (id)initWithDateComponents:(NSDateComponents *)dateComponents
{
    _dateComponents = dateComponents;
    return [self initWithNibName:NSStringFromClass([ONERecommendationBriefViewController class]) bundle:nil];
}

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
    // Do any additional setup after loading the view from its nib.
    self.blurView.blurRadius = 10;
    self.recommendationManager = [ONERecommendationManager sharedManager];
    [self showDate];
    [self loadRecommendation];
}

// 展示日期信息，不管是否有recommendation的数据，日期总是可以显示
- (void)showDate
{
    NSString *dayText = [@(self.dateComponents.day) stringValue];
    if (self.dateComponents.day < 10) {
        dayText = [@"0" stringByAppendingString:dayText];
    }
    self.dayLabel.text = dayText;
    self.monthLabel.text = [[ONEDateUtils sharedDateHelper] briefStringOfMonth:self.dateComponents.month];
    self.weekdayLabel.text = [[ONEDateUtils sharedDateHelper] stringOfWeekday:self.dateComponents.weekday];
}

# pragma mark 加载recommendation

// 加载recommendation
- (void)loadRecommendation
{
    // 加载loading gif
    [self addLoadingGif];
    
    // 加载recommendation，首先从本地加载，如果不成功会从服务器加载；图片会额外加载
    ONERecommendation *r = [self.recommendationManager getRecommendationWithDateComponents:self.dateComponents dataCompletionHandler:^(ONERecommendation *r) {
        [self showServerRecommendation:r];
    } imageCompletionHandler:^(NSURL *location) {
        [self showRecommendationImageWithLocation:location];
    }];
    [self showLocalRecommendation:r];
}

// 显示从本地加载的recommendation
- (void)showLocalRecommendation:(ONERecommendation *)recommendation
{
    if (recommendation == nil) {
        // 本地无数据，即将从服务器拉取数据
        [ONELogger logTitle:@"loading data from server..." content:nil];
        return;
    }
    self.recommendation = recommendation;
    [self showRecommendation];
}

// 显示从服务器加载的recommendation
- (void)showServerRecommendation:(ONERecommendation *)recommendation
{
    if (recommendation == nil) {
        // 服务器无数据，显示默认recommendation
        [ONELogger logTitle:@"no recommendation from server..." content:nil];
        [self noRecommendation];
        return;
    }
    self.recommendation = recommendation;
    [self showRecommendation];
}

// 展示recommendation
- (void)showRecommendation
{
    // 即将展示recommendation，说明数据获取完毕，将self传给delegate
    [self.delegate ONERecommendationBriefViewDidLoadRecommendation:self];
    // 展示recommendation
    [self showRecommendationImage];
    self.typeImageView.image = [[ONEImageManager sharedManager] briefTypeImage:self.recommendation.type];
    self.cityLabel.text = self.recommendation.city;
    self.titleLabel.text = self.recommendation.title;
    self.introLabel.text = self.recommendation.intro;
    [self updateLikes:self.recommendation.likes];
    self.briefDetailLabel.attributedText = [ONEViewUtils attributedStringWithString:self.recommendation.briefDetail font:self.briefDetailLabel.font color:self.briefDetailLabel.textColor lineSpacing:17];
    [self.briefDetailLabel sizeToFit];
    self.blurView.hidden = NO;
}

// 加载指定位置的图片
- (void)showRecommendationImageWithLocation:(NSURL *)location
{
    if (location != nil) {
        // 记录图片地址后加载图片
        self.recommendation.imageLocalLocation = location.path;
        [self showRecommendationImage];
    } else {
        // 图片加载失败
        [self noRecommendation];
    }
}

// 展示图片
- (void)showRecommendationImage
{
    NSString *filePath = self.recommendation.imageLocalLocation;
    if (filePath != nil) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            self.thingImageView.image = [UIImage imageWithContentsOfFile:filePath];
        } else {
            self.thingImageView.image = [UIImage imageNamed:filePath];
        }
        // 图片加载完成，移除loading gif
        [self removeLoadingGif];
    } else {
        // 如果是从本地加载的recommendation，而且对应的图片没有下载成功，重新下载一次
        [ONELogger logTitle:[NSString stringWithFormat:@"re-download recommendation %ld%ld%ld blurred image", (long)self.recommendation.year, (long)self.recommendation.month, (long)self.recommendation.day] content:nil];
        [self.recommendationManager downloadRecommendationImage:self.recommendation imageCompletionHandler:^(NSURL *location) {
            [self showRecommendationImageWithLocation:location];
        }];
    }
}

- (void)updateLikes:(NSInteger)likes
{
    self.likesLabel.text = [@(likes) stringValue];
}

// 没有拿到recommendation
- (void)noRecommendation
{
    if (DEBUGGING) {
        self.recommendation = [self.recommendationManager defaultRecommendationForDateComponents:self.dateComponents];
        [self showRecommendation];
    } else {
        [self.delegate ONERecommendationBriefViewEmptyRecommendation:self];
        // 移除loading gif
        [self removeLoadingGif];
    }
}

# pragma mark Loading Gif

- (void)addLoadingGif
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"loadingWhite@2x" withExtension:@"gif"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    FLAnimatedImage *fImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:data];
    self.loadingImageView = [FLAnimatedImageView new];
    self.loadingImageView.frame = self.view.frame;
    self.loadingImageView.animatedImage = fImage;
    [self.view addSubview:self.loadingImageView];
}

- (void)removeLoadingGif
{
    [self.loadingImageView removeFromSuperview];
}

# pragma mark 图片被点击

- (IBAction)imageTapped:(UITapGestureRecognizer *)sender
{
    if ([self canInteract]) {
        [self.delegate ONERecommendationBriefViewImageTapped];
    }
}

# pragma mark blur view 被点击

- (IBAction)blurViewTapped:(UITapGestureRecognizer *)sender
{
    if ([self canInteract]) {
        [self.delegate ONERecommendationBriefViewBlurViewTapped];
    }
}

# pragma mark 简介被点击

- (IBAction)introViewTapped:(UITapGestureRecognizer *)sender
{
    if ([self canInteract]) {
        [self.delegate ONERecommendationBriefViewIntroTapped];
    }
}

# pragma mark 是否能和用户互动

- (BOOL)canInteract
{
    return self.recommendation != nil;
}

# pragma mark 给用户点击的反馈

- (void)shadowIntroView
{
    self.introView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2];
}

- (void)deshadowIntroView
{
    self.introView.backgroundColor = [UIColor clearColor];
}

# pragma mark 自动更新

- (void)startAutoUpdate
{
    if (!self.autoUpdateThread.isCancelled) {
        [self.autoUpdateThread cancel];
    }
    self.autoUpdateThread = [[NSThread alloc] initWithTarget:self selector:@selector(autoUpdate) object:nil];
//    [self.autoUpdateThread start];
}

- (void)stopAutoUpdate
{
    [self.autoUpdateThread cancel];
}

- (void)autoUpdate
{
    while (YES) {
        // sleep for 10 sec
        [NSThread sleepForTimeInterval:10];
        if ([self canInteract]) {
            // fetch likes info
            [self.recommendationManager getRecommendationLikes:self.recommendation likesHandler:^(NSInteger likes) {
                if (likes < 0) {
                    likes = 0;
                }
//                [ONELogger logTitle:[NSString stringWithFormat:@"fetch likes info - %ld", (long)likes] content:nil];
                [self updateLikes:likes];
                [self.delegate ONERecommendationBriefView:self didUpdateRecommendationLikes:likes];
            }];
        }
    }
}

# pragma mark 喜欢 不喜欢

- (void)like
{
    self.recommendation.likes++;
    [self.recommendationManager likeRecommendation:self.recommendation];
}

- (void)dislike
{
    self.recommendation.likes--;
    [self.recommendationManager dislikeRecommendation:self.recommendation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
