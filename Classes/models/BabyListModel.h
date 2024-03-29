//
//  BabyListModel.h
//  Neonan
//
//  Created by capricorn on 12-11-8.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BabyItem : NSObject

@property (strong, nonatomic) NSString *photoUrl;
@property (assign, nonatomic) NSInteger voteNum;
@property (strong, nonatomic) NSString *contentId;
@property (strong, nonatomic) NSString *babyName;
@property (strong, nonatomic) NSArray *videos;
@property (assign, nonatomic) BOOL voted;

@property (readonly, nonatomic) NSString *contentType;
@property (readonly, nonatomic) NSArray *videoShots;
@property (readonly, nonatomic) NSArray *videoUrls;

@end

@interface BabyListModel : NSObject <Jsonable>

@property (assign, nonatomic) NSUInteger totalCount;
@property (strong, nonatomic) NSArray *items;

- (void)appendMoreData:(BabyListModel *)data;
@end
