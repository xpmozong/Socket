//
//  LeftTextTableViewCell.m
//  BDMapDemo
//
//  Created by tw001 on 14-9-29.
//  Copyright (c) 2014年 ESX. All rights reserved.
//

#import "LeftTextTableViewCell.h"

@implementation LeftTextTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)longPress:(UIGestureRecognizer *)ges
{
    if (ges.state == 1) {
        NSLog(@"长按开始 %d", (int)ges.state);
        [_delegate longPressBegin:_indexPath];
    }
    if (ges.state == 3) {
        NSLog(@"长按结束 %d", (int)ges.state);
        [_delegate longPressShowMenu:_indexPath];
    }
}

/// 设置消息内容
- (void)setMsgContent:(MsgObject *)msgObj
{
    for (UIView *sview in [_msgView subviews]) {
        if ([sview isKindOfClass:[M80AttributedLabel class]]) {
            [sview removeFromSuperview];
        }
    }
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longPress.minimumPressDuration = 1.0;
    [_msgView addGestureRecognizer:longPress];
    
    float orginX = 45;
    
    msgObj.msgLabel.frame = CGRectMake(17, kTextTop, msgObj.msgLabel.frame.size.width, msgObj.msgRowHeight - kTextTop * 2);
    _msgView.frame = CGRectMake(orginX, _msgView.frame.origin.y, msgObj.msgLabel.frame.size.width + 20, msgObj.msgRowHeight - kTextTop);
    _bgImageView.frame = CGRectMake(0, 0, _msgView.frame.size.width + 10, _msgView.frame.size.height);
    
    [_msgView addSubview:msgObj.msgLabel];
}

/// 获得高度
+ (float)getMsgHeight:(MsgObject *)msgObj
{
    return msgObj.msgRowHeight;
}

@end
