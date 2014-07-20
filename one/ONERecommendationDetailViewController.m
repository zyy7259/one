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

@interface ONERecommendationDetailViewController ()

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
    
    [self.dismissButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.collectButton addTarget:self action:@selector(collectButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    self.collectButton.selected = self.recommendation.collected;
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

- (void)dismiss
{
    [self.delegate ONERecommendationDetailViewControllerDidFinishDisplay:self];
}

// collect
- (void)collectButtonTapped
{
    self.collectButton.selected = !self.collectButton.selected;
    [self.recommendation updateCollected:self.collectButton.selected];
    return;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
