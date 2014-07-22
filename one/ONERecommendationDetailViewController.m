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
#import "ONEShareViewController.h"
#import "ONEResourceManager.h"

@interface ONERecommendationDetailViewController () <UIScrollViewDelegate, ONEShareDelegate>

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
@property (weak, nonatomic) IBOutlet UIButton *collectButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *collectFloatButton;
@property (weak, nonatomic) IBOutlet UIButton *shareFloatButton;
@property ONEResourceManager *resourceManager;

@end

@implementation ONERecommendationDetailViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

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
    self.resourceManager = [ONEResourceManager sharedManager];
    
    self.typeImageView.image = [[ONEResourceManager sharedManager] detailTypeImage:self.recommendation.type];
    self.titleLabel.text = self.recommendation.title;
    self.introLabel.text = self.recommendation.intro;
    self.likesLabel.text = [@(self.recommendation.likes) stringValue];
    [self showDetailScrollViewAndLabel];
    [self showRecommendationImage];
    [self initButtons];
}

// 展示图片
- (void)showRecommendationImage
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.recommendation.blurredImageUrl]) {
        self.thingImageView.image = [UIImage imageWithContentsOfFile:self.recommendation.blurredImageUrl];
    } else {
        // 重新拉取图片
    }
}

- (void)showDetailScrollViewAndLabel
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
    
    // 修改detailPanel的frame
    self.detailPanel.frame = CGRectMake(self.detailPanel.frame.origin.x,
                                        self.detailPanel.frame.origin.y,
                                        CGRectGetWidth(self.detailPanel.frame),
                                        ceil(labelRect.size.height));
    // 修改detailLabel的frame
    self.detailLabel.frame = CGRectMake(self.detailLabel.frame.origin.x,
                                        self.detailLabel.frame.origin.y,
                                        ceil(labelRect.size.width),
                                        ceil(labelRect.size.height));
    // 修改scrollView的contentSize
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.detailLabel.frame) + self.detailPanel.frame.origin.y + 31);
    self.scrollView.delegate = self;
}

- (void)initButtons
{
    [self connectButtons];
    self.collectButton.selected = self.recommendation.collected;
    self.collectFloatButton.selected = self.recommendation.collected;
}

- (void)connectButtons
{
    [self.collectButton addTarget:self action:@selector(collectButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.shareButton addTarget:self action:@selector(shareButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.dismissButton addTarget:self action:@selector(dismissButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.collectFloatButton addTarget:self action:@selector(collectButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.shareFloatButton addTarget:self action:@selector(shareButtonTapped) forControlEvents:UIControlEventTouchUpInside];
}

# pragma mark 收藏/取消收藏

- (void)collectButtonTapped:(UIButton *)collectButton
{
    // 首先更新collectButton的状态
    self.collectButton.selected = !collectButton.selected;
    self.collectFloatButton.selected = self.collectButton.selected;
    // 然后更新recommendation的状态
    self.recommendation.collected = collectButton.selected;
    // 然后根据状态来调用delegate的相应方法
    if (self.recommendation.collected) {
        [self.delegate ONERecommendationDetailViewControllerDidCollectRecommendation:self.recommendation];
    } else {
        [self.delegate ONERecommendationDetailViewControllerDidDecollectRecommendation:self.recommendation];
    }
    return;
}

# pragma mark 分享

- (void)shareButtonTapped
{
    [[ONEShareViewController sharedShareViewControllerWithDelegate:self] shareRecommendation:self.recommendation];
}

# pragma mark 隐藏

- (void)dismissButtonTapped
{
    [self.delegate ONERecommendationDetailViewControllerDidFinishDisplay:self];
}

# pragma mark 上下滑动时，动态调页面

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateInterface];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self updateInterface];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updateInterface];
}

# pragma mark 更新页面

- (void)updateInterface
{
    [self updateButtonPositions];
    [self updateThingImagePosition];
}

// 动态调整图片位置
- (void)updateThingImagePosition
{
    CGFloat offset = self.scrollView.contentOffset.y;
    if (offset < 0) {
        // 向下bounce，放大图片
        CGFloat delta = -offset;
        CGRect frame = self.view.frame;
        CGFloat height = frame.size.height;
        CGFloat width = frame.size.width;
        CGFloat newHeight = height + delta;
        CGFloat newWidth = width / height * newHeight;
        frame = CGRectMake(-(newWidth - width)/2, -(newHeight - height)/2, newWidth, newHeight);
        self.thingImageView.frame = frame;
    } else {
        // 滚动scrollView，移动图片
        CGFloat delta = offset;
        CGRect frame = self.view.frame;
        frame.origin.y -= delta / 2;
        self.thingImageView.frame = frame;
    }
}

// 动态调整按钮的位置
- (void)updateButtonPositions
{
    static CGFloat duration = 0.3;
    static CGFloat lastPosition = 0;
    static BOOL hasFloated = NO;
    static CGFloat threshold = 185;
    
    static BOOL originInitialized = NO;
    static CGRect collectButtonFrame;
    static CGRect shareButtonFrame;
    static CGRect collectButtonFloatFrame;
    static CGRect shareButtonFloatFrame;
    if (!originInitialized) {
        originInitialized = YES;
        // 在移除浮动按钮时，先将浮动按钮移动到这两个frame所指示的位置
        collectButtonFrame = self.collectButton.frame;
        collectButtonFrame.size = self.dismissButton.frame.size;
        shareButtonFrame = self.shareButton.frame;
        shareButtonFrame.size = self.dismissButton.frame.size;
        // 在添加浮动按钮时，要将浮动按钮移动到这两个位置
        collectButtonFloatFrame = self.dismissButton.frame;
        collectButtonFloatFrame.origin.x += (self.dismissButton.frame.size.width + self.dismissButton.frame.origin.x);
        shareButtonFloatFrame = collectButtonFloatFrame;
        shareButtonFloatFrame.origin.x += (self.dismissButton.frame.size.width + self.dismissButton.frame.origin.x);
    }
    
    CGFloat startPosition = lastPosition;
    CGFloat endPosition = self.scrollView.contentOffset.y;
    
    if (endPosition > startPosition) {
        // 向上滑
        if (!hasFloated) {
            // 如果按钮还没有悬浮，判断是否需要悬浮
            if (self.scrollView.contentOffset.y >= threshold) {
                endPosition = self.scrollView.contentOffset.y;
                // 将按钮浮动
                hasFloated = YES;
                // 首先获取按钮在view上的预期位置
                CGRect collectButtonDesiredRect = [self.view convertRect:self.collectButton.frame fromView:self.scrollView];
                    // 因为收藏和已收藏按钮的大小不一样，所以有一个delta
                if (self.recommendation.collected) {
                    //
                } else {
                    collectButtonDesiredRect.origin.x += 8;
                }
                collectButtonDesiredRect.size = collectButtonFloatFrame.size;
                CGRect shareButtonDesiredRect = [self.view convertRect:self.shareButton.frame fromView:self.scrollView];
                shareButtonDesiredRect.size = shareButtonFloatFrame.size;
                // 然后将按钮从原来的superView上移除
                self.collectButton.hidden = YES;
                self.shareButton.hidden = YES;
                // 设置浮动按钮的位置
                self.collectFloatButton.frame = collectButtonDesiredRect;
                self.shareFloatButton.frame = shareButtonDesiredRect;
                // 添加并显示浮动按钮
                [self.collectFloatButton removeFromSuperview];
                [self.shareFloatButton removeFromSuperview];
                [self.view addSubview:self.collectFloatButton];
                [self.view addSubview:self.shareFloatButton];
                self.collectFloatButton.hidden = NO;
                self.shareFloatButton.hidden = NO;
                
                [UIView animateWithDuration:duration
                                 animations:^{
                                     self.collectFloatButton.frame = collectButtonFloatFrame;
                                     self.shareFloatButton.frame = shareButtonFloatFrame;
                                 }];
            }
        }
    } else {
        // 向下滑
        if (hasFloated) {
            // 如果按钮已经悬浮，判断是否需要取消悬浮
            if (self.scrollView.contentOffset.y <= threshold) {
                endPosition = self.scrollView.contentOffset.y;
                // 将按钮复位
                hasFloated = NO;
                // 获取浮动按钮在scrollView上的预期位置
                CGRect collectButtonDesiredRect = [self.view convertRect:self.collectFloatButton.frame toView:self.scrollView];
                CGRect shareButtonDesiredRect = [self.view convertRect:self.shareFloatButton.frame toView:self.scrollView];
                // 将浮动按钮转移到scrollView上
                [self.collectFloatButton removeFromSuperview];
                [self.shareFloatButton removeFromSuperview];
                self.collectFloatButton.frame = collectButtonDesiredRect;
                self.shareFloatButton.frame = shareButtonDesiredRect;
                [self.scrollView addSubview:self.collectFloatButton];
                [self.scrollView addSubview:self.shareFloatButton];
                // 因为收藏和已收藏按钮的大小不一样，所以有一个delta
                CGRect collectButtonFrameWithDelta = collectButtonFrame;
                if (self.recommendation.collected) {
                    collectButtonFrameWithDelta.origin.x += 2;
                } else {
                    collectButtonFrameWithDelta.origin.x += 10;
                }
                // 将浮动按钮用动画转移到目标位置
                [UIView animateWithDuration:duration
                                 animations:^{
                                     self.collectFloatButton.frame = collectButtonFrameWithDelta;
                                     self.shareFloatButton.frame = shareButtonFrame;
                                 } completion:^(BOOL finished) {
                                     // 将浮动按钮隐藏
                                     self.collectFloatButton.hidden = YES;
                                     self.shareFloatButton.hidden = YES;
                                     // 将按钮添加到scrollView上
                                     self.collectButton.hidden = NO;
                                     self.shareButton.hidden = NO;
                                 }];
            }
        }
    }
    lastPosition = endPosition;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
