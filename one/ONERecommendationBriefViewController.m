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

@property ONERecommendation *recommendation;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.cityLabel.text = self.recommendation.city;
    // type image
    self.titleLabel.text = self.recommendation.title;
    self.descriptionLabel.text = self.recommendation.description;
    [self loadImage];
    self.likesLabel.text = [@(self.recommendation.likes) stringValue];
    self.yearLabel.text = [@(self.recommendation.year) stringValue];
    self.monthLabel.text = [@(self.recommendation.month) stringValue];
    self.dayLabel.text = [@(self.recommendation.day) stringValue];
}

- (void)loadImage
{
    self.thingImageView.image = [UIImage imageNamed:@"404.jpg"];
    NSURL *imageUrl = [NSURL URLWithString:self.recommendation.imageUrl];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // update the image view
            self.thingImageView.image = [UIImage imageWithData:imageData];
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
