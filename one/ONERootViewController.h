//
//  ONERecommendViewController.h
//  one
//
//  Created by zyy on 14-7-13.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ONERootViewController : UIViewController <UIScrollViewDelegate>

- (IBAction)unwindFromRecommendationCollection:(UIStoryboardSegue *)sender;
- (IBAction)unwindFromSetting:(UIStoryboardSegue *)sender;

@end
