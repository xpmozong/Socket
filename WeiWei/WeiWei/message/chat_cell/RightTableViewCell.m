//
//  RightTableViewCell.m
//  LeiRen
//
//  Created by tw001 on 14-9-17.
//  Copyright (c) 2014年 wave. All rights reserved.
//

#import "RightTableViewCell.h"
#define KFacialSizeWidth 24
#define KFacialSizeHeight 24

@implementation RightTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _bgImageView.image = [[UIImage imageNamed:@"bubble_right"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 20, 10, 20)];
        
        _failueBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, 10, 30, 30)];
        [_failueBtn setBackgroundImage:[UIImage imageNamed:@"failue"] forState:UIControlStateNormal];
        _failueBtn.hidden = YES;
        [self.contentView addSubview:_failueBtn];
        
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityView.frame = CGRectMake(50, 10, 30, 30);
        _activityView.hidden = YES;
        [self.contentView addSubview:_activityView];
        
        [_avatarBtn setFrame:CGRectMake(self.contentView.frame.size.width - 40 - 5, _avatarBtn.frame.origin.y, _avatarBtn.frame.size.width, _avatarBtn.frame.size.height)];
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
