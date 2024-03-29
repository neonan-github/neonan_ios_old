//
//  CommenListModel.h
//  Neonan
//
//  Created by capricorn on 12-11-9.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonItem : NSObject

@property (strong, nonatomic) NSString *thumbUrl;
@property (strong, nonatomic) NSString *contentType;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *contentId;
@property (strong, nonatomic) NSString *videoUrl;
@property (strong, nonatomic) NSNumber *dateMillis;
@property (strong, nonatomic) NSString *sortName;

@property (readonly, nonatomic) NSString *date;
@property (readonly, nonatomic) NSString *readableContentType;
@end

@interface CommonListModel : NSObject <Jsonable>

@property (assign, nonatomic) NSUInteger totalCount;
@property (strong, nonatomic) NSArray *items;

- (void)appendMoreData:(CommonListModel *)data;
@end
