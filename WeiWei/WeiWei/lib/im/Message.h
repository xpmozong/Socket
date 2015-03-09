//
//  Message.h
//  LeiRen
//
//  Created by tw001 on 14-9-17.
//  Copyright (c) 2014年 wave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject

@property (copy, nonatomic) NSString *type;
@property (copy, nonatomic) NSString *username;
@property (copy, nonatomic) NSString *mAvatar;
@property (copy, nonatomic) NSString *mContent;
@property (copy, nonatomic) NSString *mDesc;
@property (copy, nonatomic) NSString *mTime;
@property (copy, nonatomic) NSString *file_url;
@property (assign, nonatomic) long mtimestamp;
@property (assign, nonatomic) int tipCount;
@property (assign, nonatomic) BOOL direction;
@property (assign, nonatomic) BOOL isread;
@property (assign, nonatomic) int delivery_status;
@property (assign, nonatomic) int mid;

@end
