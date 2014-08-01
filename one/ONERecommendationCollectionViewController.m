//
//  ONERecommendationCollectListViewController.m
//  one
//
//  Created by zyy on 14-7-18.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import "ONERecommendationCollectionViewController.h"
#import "ONERecommendation.h"
#import "ONERecommendationDetailViewController.h"
#import "ONEImageManager.h"
#import "ONERootViewController.h"

@interface ONERecommendationCollectionViewController ()

@property (weak, nonatomic) IBOutlet UITableView *collectionTableView;
@property UIBarButtonItem *editBarButton;
@property UIBarButtonItem *completeBarButton;

@end

@implementation ONERecommendationCollectionViewController

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
    self.collectionTableView.delegate = self;
    self.collectionTableView.dataSource = self;
    self.collectionTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self initBarButtons];
}

- (void)initBarButtons
{
    ONEImageManager *resourceManager = [ONEImageManager sharedManager];
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [editButton setImage:resourceManager.editImage forState:UIControlStateNormal];
    [editButton setImage:resourceManager.editSelectedImage forState:UIControlStateSelected];
    [editButton setImage:resourceManager.editSelectedImage forState:UIControlStateHighlighted];
    editButton.frame = CGRectMake(0, 0, 23, 23);
    [editButton addTarget:self action:@selector(editTapped) forControlEvents:UIControlEventTouchUpInside];
    self.editBarButton = [[UIBarButtonItem alloc] initWithCustomView:editButton];
    self.navigationItem.rightBarButtonItem = self.editBarButton;
    
    UIButton *completeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [completeButton setImage:resourceManager.completeImage forState:UIControlStateNormal];
    [completeButton setImage:resourceManager.completeSelectedImage forState:UIControlStateSelected];
    [completeButton setImage:resourceManager.completeSelectedImage forState:UIControlStateHighlighted];
    completeButton.frame = CGRectMake(0, 0, 23, 23);
    [completeButton addTarget:self action:@selector(completeTapped) forControlEvents:UIControlEventTouchUpInside];
    self.completeBarButton = [[UIBarButtonItem alloc] initWithCustomView:completeButton];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.recommendationCollection.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CollectionPrototypeCell" forIndexPath:indexPath];
    
    ONERecommendation *recommendation = self.recommendationCollection[indexPath.row];
    cell.textLabel.text = recommendation.title;
    cell.detailTextLabel.text = recommendation.intro;
    cell.imageView.image = [[ONEImageManager sharedManager] collectTypeImage:recommendation.type];
    cell.accessoryView = [[UIImageView alloc] initWithImage:[ONEImageManager sharedManager].arrowRightGreyImage];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    // 给当前选中的cell加一个背景色
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:223.0/255.0 green:223.0/255.0 blue:223.0/255.0 alpha:1.0];
    
    // 切换界面
    ONERecommendation *recommendation = self.recommendationCollection[indexPath.row];
    recommendation.collected = YES;
    ONERecommendationDetailViewController *detailController = [[ONERecommendationDetailViewController alloc] initWithRecommendation:recommendation];
    detailController.delegate = self;
    detailController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:detailController animated:YES completion:nil];
    
    // 界面切换大概结束后回复cell的背景色
    [self performSelector:@selector(resetCellBackgroundColor:) withObject:cell afterDelay:0.4];
}

- (void)resetCellBackgroundColor:(UITableViewCell *)cell
{
    cell.backgroundColor = [UIColor whiteColor];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

// 点击cell的编辑按钮
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 如果是删除按钮
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // 首先更新recommendation的状态
        ONERecommendation *r = self.recommendationCollection[indexPath.row];
        r.collected = NO;
        // 然后通知delegate，r被取消收藏了
        [self.delegate ONERecommendationCollectionViewControllerDidDeleteRecommendation:r];
        // 将r从数据源删除
        [self.recommendationCollection removeObject:r];
        // 更新tableView
        [self.collectionTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)editTapped
{
    self.navigationItem.rightBarButtonItem = self.completeBarButton;
    [self.collectionTableView setEditing:YES animated:YES];
}

- (void)completeTapped
{
    self.navigationItem.rightBarButtonItem = self.editBarButton;
    [self.collectionTableView setEditing:NO animated:YES];
}

- (void)ONERecommendationDetailViewControllerDidFinishDisplay:(ONERecommendationDetailViewController *)recommendationDetailController
{
    [self.collectionTableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)ONERecommendationDetailViewControllerDidCollectRecommendation:(ONERecommendation *)recommendation
{
    if (![self.recommendationCollection containsObject:recommendation]) {
        [self.recommendationCollection addObject:recommendation];
    }
    [self.collectionTableView reloadData];
    UIViewController *vc = self.presentingViewController;
    if ([vc isKindOfClass:[ONERootViewController class]]) {
        ONERootViewController *rVc = (ONERootViewController *)vc;
        [rVc ONERecommendationDetailViewControllerDidCollectRecommendation:recommendation];
    }
}

- (void)ONERecommendationDetailViewControllerDidDecollectRecommendation:(ONERecommendation *)recommendation
{
    [self.recommendationCollection removeObject:recommendation];
    [self.collectionTableView reloadData];
    UIViewController *vc = self.presentingViewController;
    if ([vc isKindOfClass:[ONERootViewController class]]) {
        ONERootViewController *rVc = (ONERootViewController *)vc;
        [rVc ONERecommendationDetailViewControllerDidDecollectRecommendation:recommendation];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
