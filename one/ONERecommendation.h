//
//  ONERecommendation.h
//  one
//
//  Created by zyy on 14-7-13.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ONERecommendationDelegate;

@interface ONERecommendation : NSObject

@property NSString *city;
@property NSString *address;
@property NSInteger type;
@property NSString *title;
@property NSString *intro;
@property NSString *briefDetail;
@property NSString *detail;
@property NSString *blurredImageUrl;
@property NSString *imageUrl;
@property NSInteger likes;
@property NSInteger year;
@property NSInteger month;
@property NSInteger day;
@property NSInteger weekday;

@property (nonatomic) BOOL collected;
@property id<ONERecommendationDelegate> delegate;

- (id)initWithJSONData:(NSData *)jsonData;
- (id)initWithProperties:(NSDictionary *)properties;

- (NSDictionary *)properties;
- (NSString *)date;
- (void)updateCollected:(BOOL)collected;

@end

@protocol ONERecommendationDelegate <NSObject>

- (void)ONERecommendationDidCollect:(ONERecommendation *)recommendation;
- (void)ONERecommendationDidDecollect:(ONERecommendation *)recommendation;

@end