//
//  ONERecommendDetailViewController.m
//  one
//
//  Created by zyy on 14-7-13.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import "ONERecommendationDetailViewController.h"
#import "ONERecommendation.h"
#import "ONEResourceManager.h"
#import "ONEShareViewController.h"

@interface ONERecommendationDetailViewController () <ONEShareDelegate>

@property ONERecommendation *recommendation;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@property (weak, nonatomic) IBOutlet UIImageView *thingImageView;
@property (weak, nonatomic) IBOutlet UIImageView *typeImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *introLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UIView *detailPanel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *collectButton;

@end

@implementation ONERecommendationDetailViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithRecommendation:(ONERecommendation *)recommendation
{
    self = [self initWithNibName:NSStringFromClass([ONERecommendationDetailViewController class]) bundle:nil];
    if (self) {
        self.recommendation = recommendation;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.typeImageView.image = [[ONEResourceManager sharedManager] detailTypeImage:self.recommendation.type];
    self.titleLabel.text = self.recommendation.title;
    self.introLabel.text = self.recommendation.intro;
    [self updateDetailScrollViewAndLabel];
    self.likesLabel.text = [@(self.recommendation.likes) stringValue];

    if ([[NSFileManager defaultManager] fileExistsAtPath:self.recommendation.blurredImageUrl]) {
        self.thingImageView.image = [UIImage imageWithContentsOfFile:self.recommendation.blurredImageUrl];
    }
    
    [self connectButtons];
    
    self.collectButton.selected = self.recommendation.collected;
}

- (void)connectButtons
{
    [self.collectButton addTarget:self action:@selector(collectButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.shareButton addTarget:self action:@selector(shareButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.dismissButton addTarget:self action:@selector(dismissButtonTapped) forControlEvents:UIControlEventTouchUpInside];
}

- (void)updateDetailScrollViewAndLabel
{
    // 设置detailLabel要显示的文字
    NSString *labelText = self.recommendation.detail;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:17];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelText length])];
    self.detailLabel.attributedText = attributedString;
    
    CGSize maxSize = CGSizeMake(self.detailLabel.frame.size.width, MAXFLOAT);
    CGRect labelRect = [self.detailLabel.text boundingRectWithSize:maxSize
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                        attributes:@{NSFontAttributeName: self.detailLabel.font,
                                                                     NSParagraphStyleAttributeName: paragraphStyle}
                                                           context:nil];
    self.detailLabel.frame = CGRectMake(self.detailLabel.frame.origin.x,
                                        self.detailLabel.frame.origin.y,
                                        ceil(labelRect.size.width),
                                        ceil(labelRect.size.height));
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.detailLabel.frame) + self.detailPanel.frame.origin.y + 31);
}

# pragma mark 收藏/取消收藏

- (void)collectButtonTapped
{
    // 首先更新collectButton的状态
    self.collectButton.selected = !self.collectButton.selected;
    // 然后更新recommendation的状态
    self.recommendation.collected = self.collectButton.selected;
    // 然后根据状态来调用delegate的相应方法
    if (self.recommendation.collected) {
        [self.delegate ONERecommendationDetailViewControllerDidCollectRecommendation:self.recommendation];
    } else {
        [self.delegate ONERecommendationDetailViewControllerDidDecollectRecommendation:self.recommendation];
    }
    return;
}

# pragma mark 分享

- (void)shareButtonTapped
{
    [[ONEShareViewController sharedShareViewControllerWithDelegate:self] shareRecommendation:self.recommendation];
}

# pragma mark 隐藏

- (void)dismissButtonTapped
{
    [self.delegate ONERecommendationDetailViewControllerDidFinishDisplay:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
