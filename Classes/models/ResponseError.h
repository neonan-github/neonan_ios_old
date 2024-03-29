//
//  ResponseError.h
//  Neonan
//
//  Created by capricorn on 12-11-2.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Jsonable.h"

//(1, "User not exist!", HttpResponseStatus.OK),
//(2, "User already exist!", HttpResponseStatus.OK),
//(3, "Wrong password!", HttpResponseStatus.OK),
//(4, "Data not found!", HttpResponseStatus.OK),
//(5, "Not auth!", HttpResponseStatus.OK),
//(6, "User has already voted the baby!", HttpResponseStatus.OK),
//(7, "订单验证失败"） 
//(-1, "Invliad parameters!", HttpResponseStatus.BAD_REQUEST),
//(-2, "Method not implemented!", HttpResponseStatus.NOT_IMPLEMENTED),
//(-3, "Server error!", HttpResponseStatus.INTERNAL_SERVER_ERROR);
#define ERROR_UNPREDEFINED -4 
#define ERROR_BAD_ORDER    7

@interface ResponseError : NSObject <Jsonable>

@property (assign, nonatomic) NSInteger errorCode;
@property (strong, nonatomic) NSString *message;

- (id)initWithCode:(NSInteger)code andMessage:(NSString *)message;

@end
