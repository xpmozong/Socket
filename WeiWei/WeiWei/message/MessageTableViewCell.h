//
//  MessageTableViewCell.h
//  BDMapDemo
//
//  Created by tw001 on 14-10-9.
//  Copyright (c) 2014年 ESX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"
#import "CommonTableViewCell.h"

@interface MessageTableViewCell : CommonTableViewCell

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIImageView *tipImageView;
@property (nonatomic, strong) UILabel *tipLabel;

- (void)setContent:(Message *)msg fileManager:(NSFileManager *)fileManager;

@end
