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
#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"

@interface ONERecommendationImageViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *thingImageView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
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
    [self loadRecommendationImage];
}

// 加载要显示的图片
- (void)loadRecommendationImage
{
    // 如果没有加载图片，加载之
    if ([ONEStringUtils isEmptyString:self.recommendation.imageLocalLocation]) {
        // 加载loading gif
        [self addLoadingGif];
        [self.recommendationManager downloadRecommendationImage:self.recommendation imageUrl:self.recommendation.imageUrl namePostfix:nil imageCompletionHandler:^(NSURL *location) {
            if (location != nil) {
                // 记录图片地址后加载图片
                self.recommendation.imageLocalLocation = location.path;
                [self showRecommendationImage];
            }
        }];
    } else {
        [self showRecommendationImage];
    }
}

- (void)showRecommendationImage
{
    NSString *filePath = self.recommendation.imageLocalLocation;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        self.thingImageView.image = [UIImage imageWithContentsOfFile:filePath];
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
    UIImageWriteToSavedPhotosAlbum(self.thingImageView.image, self, @selector(imageDidSaved), nil);
}

- (void)imageDidSaved
{
    NSLog(@"success");
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
