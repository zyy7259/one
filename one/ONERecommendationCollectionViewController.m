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

@interface ONERecommendationCollectionViewController ()

@property (weak, nonatomic) IBOutlet UITableView *collectionTableView;

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
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ONERecommendation *recommendation = self.recommendationCollection[indexPath.row];
    ONERecommendationDetailViewController *detailController = [[ONERecommendationDetailViewController alloc] initWithRecommendation:recommendation];
    detailController.delegate = self;
    [self presentViewController:detailController animated:YES completion:nil];
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
