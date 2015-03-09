//
//  M80AttributedLabelURL.h
//  M80AttributedLabel
//
//  Created by amao on 13-8-31.
//  Copyright (c) 2013年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M80AttributedLabelDefines.h"

enum LinkType{
    LinkTypeURL     = 1,    // URL
    LinkTypeEmail   = 2,    // email
    LinkTypePhone   = 3,    // phone
    LinkTypeText    = 4     // text
};

@interface M80AttributedLabelURL : NSObject
@property (nonatomic,strong)    NSURL *linkInfo;
@property (nonatomic,assign)    NSRange range;
@property (nonatomic,strong)    UIColor *color;
@property (nonatomic,assign)    int     linkType;

+ (M80AttributedLabelURL *)urlWithLinkData: (NSURL *)linkData
                                     range: (NSRange)range
                                     color: (UIColor *)color
                                  linkType: (int)linkType;


+ (NSArray *)detectLinks: (NSString *)plainText;

+ (void)setCustomDetectMethod:(M80CustomDetectLinkBlock)block;
@end


