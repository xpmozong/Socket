//
//  LeftImageTableViewCell.m
//  BDMapDemo
//
//  Created by tw001 on 14-9-29.
//  Copyright (c) 2014年 ESX. All rights reserved.
//

#import "LeftImageTableViewCell.h"

@implementation LeftImageTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _bgImageView.frame = CGRectMake(0, 0, 95, 95);
        
        _picView = [[UIView alloc] initWithFrame:CGRectMake(62, 12.5, 66, 85)];
        [self.contentView addSubview:_picView];
        
        _picImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _picView.frame.size.width, 85)];
        [_picView addSubview:_picImageView];
        
        _picImageView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickPic:)];
        [_picImageView addGestureRecognizer:tapGes];
        
        _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _picView.frame.size.width, _picView.frame.size.height - 5)];
        _progressLabel.backgroundColor = [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1];
        _progressLabel.text = @"0%";
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        [_picView addSubview:_progressLabel];
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

/// 设置消息内容
- (void)setMsgContent:(MsgObject *)msgObj
{
    if (msgObj.download_progress < 100) {
        _progressLabel.hidden = NO;
        _picImageView.hidden = YES;
        _progressLabel.text = [NSString stringWithFormat:@"%d%%", msgObj.download_progress];
    }else{
        _progressLabel.hidden = YES;
        _picImageView.hidden = NO;
        _picImageView.image = [UIImage imageWithContentsOfFile:msgObj.imgPath];
        float w = _picImageView.image.size.width;
        float h = _picImageView.image.size.height;
        float sw = _picImageView.image.size.width / 69;
        float sh = _picImageView.image.size.height / 80;
        float scaleSize = sw > sh ? sw : sh;
        if (scaleSize > 1) {
            w = _picImageView.image.size.width / scaleSize;
            h = _picImageView.image.size.height / scaleSize;
        }
        _picImageView.frame = CGRectMake(_picImageView.frame.origin.x, _picImageView.frame.origin.y, w, h);
        _picView.frame = CGRectMake(_picView.frame.origin.x, _picView.frame.origin.y, w, _picImageView.frame.size.height + 5);
        float bgWidth = w + 28.5;
        _bgImageView.frame = CGRectMake(0, _bgImageView.frame.origin.y, bgWidth, _picView.frame.size.height + 10);
    }
}

/// 获得高度
+ (float)getMsgHeight:(MsgObject *)msgObj
{
    if (msgObj.download_progress < 100) {
        return 102.0f;
    }else{
        UIImage *picImage = [UIImage imageWithContentsOfFile:msgObj.imgPath];
        float w = picImage.size.width;
        float h = picImage.size.height;
        float sw = picImage.size.width / 69;
        float sh = picImage.size.height / 80;
        float scaleSize = sw > sh ? sw : sh;
        if (scaleSize > 1) {
            w = picImage.size.width / scaleSize;
            h = picImage.size.height / scaleSize;
        }
        
        return h + 22.0f;
    }
}

/// 点击图片
- (void)clickPic:(id)ges
{
    [_delegate lookImage:_rowIndex];
}

@end
