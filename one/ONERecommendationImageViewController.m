//
//  ONERecommendationImageViewController.m
//  one
//
//  Created by zyy on 14-7-19.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import "ONERecommendationImageViewController.h"
#import "ONERecommendation.h"
#import "ONERecommendationManager.h"
#import "ONEStringUtils.h"
#import "ONEViewUtils.h"
#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"

@interface ONERecommendationImageViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *thingImageView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIView *hintView;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;
@property ONERecommendation *recommendation;
@property ONERecommendationManager *recommendationManager;
@property FLAnimatedImageView *loadingImageView;

@end

@implementation ONERecommendationImageViewController

+ (id)instanceWithRecommendation:(ONERecommendation *)recommendation
{
    return [[self alloc] initWithRecommendation:recommendation];
}

- (id)initWithRecommendation:(ONERecommendation *)recommendation
{
    _recommendation = recommendation;
    return [self initWithNibName:NSStringFromClass([ONERecommendationImageViewController class]) bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    // Do any additional setup after loading the view from its nib.
    self.recommendationManager = [ONERecommendationManager sharedManager];
    [self showRecommendationImage];
}

- (void)showRecommendationImage
{
    NSString *filePath = self.recommendation.imageLocalLocation;
    if (filePath != nil) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            self.thingImageView.image = [UIImage imageWithContentsOfFile:filePath];
        } else {
            self.thingImageView.image = [UIImage imageNamed:filePath];
        }
        [self initButtons];
        // 图片加载完成，移除loading gif
        [self removeLoadingGif];
    } else {
        // TODO 重新拉取图片
    }
}

- (IBAction)imageTapped:(UIGestureRecognizer *)sender
{
    [self.delegate ONERecommendationImageViewControllerDidFinishDisplay:self];
}

- (IBAction)imageLongPressed:(UIGestureRecognizer *)sender
{
    
}

- (void)initButtons
{
    self.saveButton.hidden = NO;
    [self.saveButton addTarget:self action:@selector(saveButtonTapped) forControlEvents:UIControlEventTouchUpInside];
}

- (void)saveButtonTapped
{
    self.saveButton.enabled = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        UIImageWriteToSavedPhotosAlbum(self.thingImageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    });
}

- (void)               image: (UIImage *) image
    didFinishSavingWithError: (NSError *) error
                 contextInfo: (void *) contextInfo
{
    if (error == nil) {
        self.hintLabel.text = @"已保存到相册";
        [self imageDidSaved];
    } else {
        NSLog(@"%@", error);
        self.hintLabel.text = @"保存失败";
        [self imageDidSaved];
    }
}

- (void)imageDidSaved
{
    self.hintView.hidden = NO;
    self.hintView.alpha = 1.0;
    [UIView animateWithDuration:2.0 animations:^{
        self.hintView.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.hintView.hidden = YES;
        self.saveButton.enabled = YES;
    }];
}

# pragma mark Loading Gif

- (void)addLoadingGif
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"loadingBlack@2x" withExtension:@"gif"];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
