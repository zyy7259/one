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
#import "ONEResourceManager.h"

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
    ONEResourceManager *resourceManager = [ONEResourceManager defaultManager];
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
    cell.imageView.image = [[ONEResourceManager defaultManager] briefTypeImage:recommendation.type];
//    cell.editing = YES;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ONERecommendation *recommendation = self.recommendationCollection[indexPath.row];
    ONERecommendationDetailViewController *detailController = [[ONERecommendationDetailViewController alloc] initWithRecommendation:recommendation];
    detailController.delegate = self;
    [self presentViewController:detailController animated:YES completion:nil];
}

- (void)editTapped
{
    self.navigationItem.rightBarButtonItem = self.completeBarButton;
}

- (void)completeTapped
{
    self.navigationItem.rightBarButtonItem = self.editBarButton;
}

- (void)ONERecommendationDetailViewControllerDidFinishDisplay:(ONERecommendationDetailViewController *)recommendationDetailController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
