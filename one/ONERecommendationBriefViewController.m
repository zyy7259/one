//
//  ONERecommendSimpleViewController.m
//  one
//
//  Created by zyy on 14-7-13.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import "ONERecommendationBriefViewController.h"
#import "ONERecommendation.h"

@interface ONERecommendationBriefViewController ()

@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UIImageView *typeImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thingImageView;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;

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
    
    self.cityLabel.text = self.recommendation.city;
    // type image
    self.titleLabel.text = self.recommendation.title;
    self.descriptionLabel.text = self.recommendation.description;
    [self updateRecommendationImage];
    self.likesLabel.text = [@(self.recommendation.likes) stringValue];
    self.yearLabel.text = [@(self.recommendation.year) stringValue];
    self.monthLabel.text = [@(self.recommendation.month) stringValue];
    self.dayLabel.text = [@(self.recommendation.day) stringValue];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)updateRecommendationImage
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.recommendation.imageUrl]) {
        self.thingImageView.image = [UIImage imageWithContentsOfFile:self.recommendation.imageUrl];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
