//
//  ONERecommendationCollectListViewController.h
//  one
//
//  Created by zyy on 14-7-18.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ONERecommendationDetailViewController.h"

@interface ONERecommendationCollectionViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ONERecommendationDetailDelegate>

@property NSMutableArray *recommendationCollection;

@end
