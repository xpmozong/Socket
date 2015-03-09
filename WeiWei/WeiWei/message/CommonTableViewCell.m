//
//  CommonTableViewCell.m
//  BDMapDemo
//
//  Created by tw001 on 14-10-20.
//  Copyright (c) 2014年 ESX. All rights reserved.
//

#import "CommonTableViewCell.h"

@implementation CommonTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        _avatarImageView.layer.masksToBounds = YES;
        _avatarImageView.layer.cornerRadius = 20.0f;
        [self.contentView addSubview:_avatarImageView];
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(_avatarImageView.frame.origin.x + _avatarImageView.frame.size.width + 10, 10, 200, 30)];
        _contentLabel.font = [UIFont systemFontOfSize:18.0f];
        [self.contentView addSubview:_contentLabel];
        
    }
    
    return self;
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
