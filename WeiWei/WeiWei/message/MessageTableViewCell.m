//
//  MessageTableViewCell.m
//  BDMapDemo
//
//  Created by tw001 on 14-10-9.
//  Copyright (c) 2014年 ESX. All rights reserved.
//

#import "WSocket.h"
#import "MessageTableViewCell.h"

@implementation MessageTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _tipImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_avatarImageView.frame.origin.x + _avatarImageView.frame.size.width - 8, _avatarImageView.frame.origin.y - 3, 18, 18)];
        _tipImageView.layer.masksToBounds = YES;
        _tipImageView.layer.cornerRadius = 9.0f;
        _tipImageView.image = [UIImage imageNamed:@"tip"];
        _tipImageView.hidden = YES;
        [self.contentView addSubview:_tipImageView];
        
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _tipImageView.frame.size.width, _tipImageView.frame.size.height)];
        _tipLabel.backgroundColor = [UIColor clearColor];
        _tipLabel.font = [UIFont systemFontOfSize:10.0f];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.textColor = [UIColor whiteColor];
        [_tipImageView addSubview:_tipLabel];
        
        _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(_contentLabel.frame.origin.x, 29, 240, 22)];
        _descLabel.font = [UIFont systemFontOfSize:15.0f];
        _descLabel.hidden = YES;
        [self.contentView addSubview:_descLabel];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width - 150 - 8, 5, 150, 30)];
        _timeLabel.font = [UIFont systemFontOfSize:12.0f];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:_timeLabel];
        
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

- (void)setContent:(Message *)msg fileManager:(NSFileManager *)fileManager
{
    if ([msg.type isEqualToString:@"chat"]) {
        _descLabel.hidden = NO;
        _timeLabel.hidden = NO;
        _contentLabel.text = msg.username;
        NSString *stat = @"";
        if (msg.direction == YES) {
            if (msg.delivery_status == 1) {
                stat = @"[发送中]";
            }else if (msg.delivery_status == 3) {
                stat = @"[发送失败]";
            }
        }else{
            if (msg.delivery_status == 1) {
                stat = @"[接收中]";
            }else if (msg.delivery_status == 3) {
                stat = @"[接收失败]";
            }
        }
        NSString *desc = [NSString stringWithFormat:@"%@%@", stat, msg.mDesc];
        _descLabel.text = desc;
        
        _descLabel.textColor = [UIColor darkGrayColor];
        _contentLabel.frame = CGRectMake(_contentLabel.frame.origin.x, 6, 220, 25);
        
        _timeLabel.text = msg.mTime;
        _avatarImageView.image = [UIImage imageNamed:msg.mAvatar];
        
//        WSocket *ws = [WSocket shareWSocket];
//        @autoreleasepool {
//            NSString *imgPath = [NSString stringWithFormat:@"%@%@.jpeg", ws.wJid.userDir, [ws upper16_MD5:msg.mAvatar]];
//            if ([msg.username isEqualToString:ws.wJid.username]) {
//                imgPath = nil;
//                imgPath = [NSString stringWithFormat:@"%@%@.jpeg", ws.wJid.userDir, @"me"];
//            }
//            if ([fileManager fileExistsAtPath:imgPath]) {
//                _avatarImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:imgPath]];
//            }else{
//                
//            }
//        }
        
    }else{
        _descLabel.hidden = YES;
        _timeLabel.hidden = YES;
        _contentLabel.text = msg.mContent;
        _contentLabel.frame = CGRectMake(_contentLabel.frame.origin.x, 10, 200, 40);
        _avatarImageView.image = [UIImage imageNamed:msg.mAvatar];
    }
    
    if (msg.tipCount > 0) {
        _tipImageView.hidden = NO;
        int count = msg.tipCount;
        if (count > 99) {
            count = 99;
        }
        _tipLabel.text = [NSString stringWithFormat:@"%d", count];
    }else{
        _tipImageView.hidden = YES;
        _tipLabel.text = @"";
    }
}

@end
