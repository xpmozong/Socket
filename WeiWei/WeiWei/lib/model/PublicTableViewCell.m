//
//  PublicTableViewCell.m
//  WeiWei
//
//  Created by 许 萍 on 14/12/5.
//  Copyright (c) 2014年 许 萍. All rights reserved.
//

#import "PublicTableViewCell.h"

@implementation PublicTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        CELL_WIDTH;
        
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
