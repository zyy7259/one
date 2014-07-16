//
//  ONERecommendDetailViewController.m
//  one
//
//  Created by zyy on 14-7-13.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import "ONERecommendationDetailViewController.h"
#import "ONERecommendation.h"

@interface ONERecommendationDetailViewController ()

@property ONERecommendation *recommendation;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@property (weak, nonatomic) IBOutlet UIImageView *thingImageView;
@property (weak, nonatomic) IBOutlet UIImageView *typeImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *storeButton;

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
    
    self.titleLabel.text = self.recommendation.title;
    self.descriptionLabel.text = self.recommendation.description;
    [self loadImage];
    
    [self.dismissButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
}

- (void)loadImage
{
    self.thingImageView.image = [UIImage imageNamed:@"404.jpg"];
    NSURL *imageUrl = [NSURL URLWithString:self.recommendation.imageUrl];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.thingImageView.image = [UIImage imageWithData:imageData];
        });
    });
}

- (void)dismiss
{
    [self.delegate ONERecommendationDetailViewControllerDidFinishDisplay:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
