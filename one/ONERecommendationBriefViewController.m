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
#import "ONEDateHelper.h"
#import "ONEResourceManager.h"

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
    [self loadRecommendation];
}

- (void)loadRecommendation
{
    ONERecommendation *r = [self.recommendationManager getRecommendationWithDateComponents:self.dateComponents dataCompletionHandler:^(ONERecommendation *r) {
        self.recommendation = r;
    } imageCompletionHandler:^(NSURL *location) {
        if (location != nil) {
            [self updateRecommendationImage];
        }
    }];
    self.recommendation = r;
}

- (void)setRecommendation:(ONERecommendation *)recommendation
{
    _recommendation = recommendation;

    // 如果还没有加载或者_recommendation为空，直接返回
    if (_recommendation == nil) {
        return;
    }
    
    [self updateRecommendationImage];
    self.dayLabel.text = [@(self.recommendation.day) stringValue];
    self.monthLabel.text = [[ONEDateHelper sharedDateHelper] briefStringOfMonth:self.recommendation.month];
    self.weekdayLabel.text = [[ONEDateHelper sharedDateHelper] stringOfWeekday:self.recommendation.weekday];
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
}

- (void)updateRecommendationImage
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.recommendation.blurredImageUrl]) {
        self.thingImageView.image = [UIImage imageWithContentsOfFile:self.recommendation.blurredImageUrl];
    }
}

- (IBAction)imageTapped:(UITapGestureRecognizer *)sender
{
    [self.delegate ONERecommendationBriefViewImageTapped];
}

- (IBAction)introViewTapped:(UITapGestureRecognizer *)sender
{
    [self.delegate ONERecommendationBriefViewIntroTapped];
}

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
