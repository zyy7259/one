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
#import "ONEDateHelper.h"
#import "ONEResourceManager.h"
#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"

@interface ONERecommendationBriefViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *thingImageView;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekdayLabel;
@property (weak, nonatomic) IBOutlet UIImageView *typeImageView;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *introLabel;
@property (weak, nonatomic) IBOutlet UILabel *briefDetailLabel;
@property (weak, nonatomic) IBOutlet UIView *introView;

@property ONERecommendationManager *recommendationManager;
@property NSDateComponents *dateComponents;
@property FLAnimatedImageView *loadingImageView;

@end

@implementation ONERecommendationBriefViewController

+ (id)instanceWithDateComponents:(NSDateComponents *)dateComponents
{
    return [[self alloc] initWithDateComponents:dateComponents];
}

- (id)initWithDateComponents:(NSDateComponents *)dateComponents
{
    self = [self initWithNibName:NSStringFromClass([ONERecommendationBriefViewController class]) bundle:nil];
    self.dateComponents = dateComponents;
    
    return self;
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
    
    self.recommendationManager = [ONERecommendationManager sharedManager];
    [self showDate];
    [self loadRecommendation];
}

// 展示日期信息，不管是否有recommendation的数据，日期总是可以显示
- (void)showDate
{
    self.dayLabel.text = [@(self.dateComponents.day) stringValue];
    self.monthLabel.text = [[ONEDateHelper sharedDateHelper] briefStringOfMonth:self.dateComponents.month];
    self.weekdayLabel.text = [[ONEDateHelper sharedDateHelper] stringOfWeekday:self.dateComponents.weekday];
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
        if (location != nil) {
            [self showRecommendationImage];
        }
    }];
    [self showLocalRecommendation:r];
}

// 显示从本地加载的recommendation
- (void)showLocalRecommendation:(ONERecommendation *)recommendation
{
    if (recommendation == nil) {
        // 本地无数据，即将从服务器拉取数据
        [ONELogger logTitle:@"loading......" content:nil];
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
        [ONELogger logTitle:@"nil......" content:nil];
        [self showDefaultRecommendation];
        return;
    }
    self.recommendation = recommendation;
    [self showRecommendation];
}

// 展示recommendation
- (void)showRecommendation
{
    [self showRecommendationImage];
    self.typeImageView.image = [[ONEResourceManager sharedManager] briefTypeImage:self.recommendation.type];
    self.cityLabel.text = self.recommendation.city;
    self.titleLabel.text = self.recommendation.title;
    self.introLabel.text = self.recommendation.intro;
    self.likesLabel.text = [@(self.recommendation.likes) stringValue];
    
    NSString *labelText = self.recommendation.briefDetail;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:17];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelText length])];
    self.briefDetailLabel.attributedText = attributedString;
    [self.briefDetailLabel sizeToFit];
    
    // 移除loading gif
    [self removeLoadingGif];
}

// 展示图片
- (void)showRecommendationImage
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.recommendation.blurredImageUrl]) {
        self.thingImageView.image = [UIImage imageWithContentsOfFile:self.recommendation.blurredImageUrl];
    } else {
        // TODO 重新拉取图片
    }
}

// 展示默认的recommendation
- (void)showDefaultRecommendation
{
    self.view.backgroundColor = [UIColor colorWithRed:67.0/255.0 green:217.0/255.0 blue:213.0/255.0 alpha:1.0];
    self.titleLabel.text = nil;
    self.introLabel.text = nil;
    self.briefDetailLabel.text = nil;
    // 移除loading gif
    [self removeLoadingGif];
}

# pragma mark Loading Gif

- (void)addLoadingGif
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"loading" withExtension:@"gif"];
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
    if ([self shouldInteract]) {
        [self.delegate ONERecommendationBriefViewImageTapped];
    }
}

# pragma mark 简介被点击

- (IBAction)introViewTapped:(UITapGestureRecognizer *)sender
{
    if ([self shouldInteract]) {
        [self.delegate ONERecommendationBriefViewIntroTapped];
    }
}

# pragma mark 是否能和用户互动

- (BOOL)shouldInteract
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
