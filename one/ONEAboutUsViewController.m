//
//  ONEAboutUsViewController.m
//  one
//
//  Created by zyy on 14-7-19.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import "ONEAboutUsViewController.h"
#import "ONEImageManager.h"

@interface ONEAboutUsViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *aboutUsImageView;

@end

@implementation ONEAboutUsViewController

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
    self.title = @"关于我们";
    [self initBarButtons];
    self.scrollView.contentSize = self.scrollView.frame.size;
}

- (void)initBarButtons
{
    ONEImageManager *resourceManager = [ONEImageManager sharedManager];
    UIButton *returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [returnButton setImage:resourceManager.returnImage forState:UIControlStateNormal];
    [returnButton setImage:resourceManager.returnSelectedImage forState:UIControlStateSelected];
    [returnButton setImage:resourceManager.returnSelectedImage forState:UIControlStateHighlighted];
    returnButton.frame = CGRectMake(0, 0, 23, 23);
    [returnButton addTarget:self action:@selector(leftBarButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:returnButton];;
}

- (void)leftBarButtonTapped
{
    [self dismiss];
}

- (void)dismiss
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
