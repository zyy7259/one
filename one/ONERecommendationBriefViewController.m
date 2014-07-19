//
//  ONERecommendSimpleViewController.m
//  one
//
//  Created by zyy on 14-7-13.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import "ONERecommendationBriefViewController.h"
#import "ONERecommendation.h"
#import "ONEDateHelper.h"
#import "ONEResourceManager.h"
#import "JCRBlurView.h"

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

@end

@implementation ONERecommendationBriefViewController

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
    self = [self initWithNibName:NSStringFromClass([ONERecommendationBriefViewController class]) bundle:nil];
    if (self) {
        self.recommendation = recommendation;
    }
    return self;
}

- (void)setRecommendation:(ONERecommendation *)recommendation
{
    _recommendation = recommendation;
    
    // 如果还没有加载，直接返回
    if (!self.isViewLoaded) {
        return;
    }
    if (recommendation == nil) {
        return;
    }
    [self updateRecommendation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self updateRecommendation];
}

- (void)updateRecommendation
{
    [self updateRecommendationImage];
    self.dayLabel.text = [@(self.recommendation.day) stringValue];
    self.monthLabel.text = [[ONEDateHelper defaultDateHelper] briefStringOfMonth:self.recommendation.month];
    self.weekdayLabel.text = [[ONEDateHelper defaultDateHelper] stringOfWeekday:self.recommendation.weekday];
    self.typeImageView.image = [[ONEResourceManager defaultManager] briefTypeImage:self.recommendation.type];
    self.cityLabel.text = self.recommendation.city;
    self.titleLabel.text = self.recommendation.title;
    self.introLabel.text = self.recommendation.intro;
    self.likesLabel.text = [@(self.recommendation.likes) stringValue];
}

- (void)updateRecommendationImage
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.recommendation.imageUrl]) {
        self.thingImageView.image = [UIImage imageWithContentsOfFile:self.recommendation.imageUrl];
    }
}

- (IBAction)introViewTapped:(UITapGestureRecognizer *)sender
{
    [self.delegate ONERecommendationBriefViewIntroTapped];
}

- (IBAction)imageTapped:(UITapGestureRecognizer *)sender
{
    [self.delegate ONERecommendationBriefViewImageTapped];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
