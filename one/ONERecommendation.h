//
//  ONERecommendation.h
//  one
//
//  Created by zyy on 14-7-13.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ONEREcommendationDelegate;

@interface ONERecommendation : NSObject

@property NSString *city;
@property NSString *address;
@property NSUInteger type;
@property NSString *title;
@property NSString *intro;
@property NSString *briefDetail;
@property NSString *detail;
@property NSString *imageUrl;
@property NSUInteger likes;
@property NSUInteger year;
@property NSUInteger month;
@property NSUInteger day;
@property NSUInteger weekday;

@property (nonatomic) BOOL collected;
@property id<ONEREcommendationDelegate> delegate;

- (id)initWithJSONData:(NSData *)jsonData;
- (id)initWithProperties:(NSDictionary *)properties;
- (id)initWithCity:(NSString *)city
           address:(NSString *)address
              type:(NSUInteger)type
             title:(NSString *)title
             intro:(NSString *)intro
       briefDetail:(NSString *)briefDetail
            detail:(NSString *)detail
          imageUrl:(NSString *)imageUrl
             likes:(NSUInteger)likes
              year:(NSUInteger)year
             month:(NSUInteger)month
               day:(NSUInteger)day
           weekday:(NSUInteger)weekday;

- (NSDictionary *)properties;
- (NSString *)date;
- (void)updateCollected:(BOOL)collected;

@end

@protocol ONEREcommendationDelegate <NSObject>

- (void)ONERecommendationDidCollect:(ONERecommendation *)recommendation;
- (void)ONERecommendationDidDecollect:(ONERecommendation *)recommendation;

@end