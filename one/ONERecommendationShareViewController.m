//
//  ONEShareViewController.m
//  one
//
//  Created by zyy on 14-7-21.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import "ONERecommendationShareViewController.h"

@interface ONERecommendationShareViewController ()

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@end

@implementation ONERecommendationShareViewController

- (id)initWithRecommendation:(ONERecommendation *)recommendation
{
    _recommendation = recommendation;
    return [self initWithNibName:NSStringFromClass([ONERecommendationShareViewController class]) bundle:nil];
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
    
    [self initButtons];
}

- (void)initButtons
{
    [self.cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
}

- (void)cancelButtonTapped
{
    [self.delegate ONERecommendationShareViewControllerDidFinishDisplay:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
