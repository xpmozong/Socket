//
//  LeftTableViewCell.m
//  LeiRen
//
//  Created by tw001 on 14-9-17.
//  Copyright (c) 2014年 wave. All rights reserved.
//

#import "LeftTableViewCell.h"

@implementation LeftTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _bgImageView.image = [[UIImage imageNamed:@"bubble_left"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 20, 10, 20)];
        
        [_avatarBtn setFrame:CGRectMake(5, _avatarBtn.frame.origin.y, _avatarBtn.frame.size.width, _avatarBtn.frame.size.height)];
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
