//
//  CommonTableViewCell.h
//  BDMapDemo
//
//  Created by tw001 on 14-10-20.
//  Copyright (c) 2014年 ESX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PublicTableViewCell.h"

@interface CommonTableViewCell : PublicTableViewCell
{
    UIImageView *_avatarImageView;
    UILabel *_contentLabel;
}

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *contentLabel;

@end
