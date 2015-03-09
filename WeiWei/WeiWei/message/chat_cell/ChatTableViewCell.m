//
//  ChatTableViewCell.m
//  LeiRen
//
//  Created by tw001 on 14-9-17.
//  Copyright (c) 2014年 wave. All rights reserved.
//

#import "ChatTableViewCell.h"

@implementation ChatTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CELL_WIDTH;
        
        self.contentView.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1];
        
        _avatarBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 5, 40, 40)];
        _avatarBtn.layer.masksToBounds = YES;
        _avatarBtn.layer.cornerRadius = 20.0f;
        [self.contentView addSubview:_avatarBtn];
        
        _msgView = [[UIView alloc] initWithFrame:CGRectMake(45, 5, self.contentView.frame.size.width - 50*2, 40)];
        [self.contentView addSubview:_msgView];
        
        _bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_msgView addSubview:_bgImageView];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
