//
//  RightImageTableViewCell.m
//  BDMapDemo
//
//  Created by tw001 on 14-9-29.
//  Copyright (c) 2014年 ESX. All rights reserved.
//

#import "RightImageTableViewCell.h"

@implementation RightImageTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _bgImageView.frame = CGRectMake(self.contentView.frame.size.width - 50 - 130, 0, 95, 95);
        
        _picView = [[UIView alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width - 50 - 75, 12.5, 66, 85)];
        [self.contentView addSubview:_picView];
        
        _picImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _picView.frame.size.width, 66)];
        [_picView addSubview:_picImageView];
        
        _picImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rightClickPic:)];
        [_picImageView addGestureRecognizer:tapGes];
        
        _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _picView.frame.size.width, _picView.frame.size.height - 5)];
        _progressLabel.backgroundColor = [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:0.5];
        _progressLabel.text = @"0%";
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        _progressLabel.font = [UIFont systemFontOfSize:13.0f];
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
    if (msgObj.delivery_status == 1) {
        _failueBtn.hidden = YES;
        _activityView.hidden = NO;
        [_activityView startAnimating];
        
    }else if (msgObj.delivery_status == 2) {
        _failueBtn.hidden = YES;
        _activityView.hidden = YES;
        [_activityView stopAnimating];
        
    }else if (msgObj.delivery_status == 3){
        _failueBtn.hidden = NO;
        _activityView.hidden = YES;
        [_failueBtn addTarget:self action:@selector(clickResendMsg) forControlEvents:UIControlEventTouchUpInside];
        [_activityView stopAnimating];
    }
    
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
    _picView.frame = CGRectMake(self.frame.size.width - 58 - w, _picView.frame.origin.y, w, _picImageView.frame.size.height + 5);
    _activityView.frame = CGRectMake(_picView.frame.origin.x - _activityView.frame.size.width - 2, _activityView.frame.origin.y, 30, 30);
    _failueBtn.frame = CGRectMake(_picView.frame.origin.x - _failueBtn.frame.size.width - 5, _failueBtn.frame.origin.y, 30, 30);
    float bgWidth = w + 29;
    _bgImageView.frame = CGRectMake(self.frame.size.width - 84 - bgWidth, _bgImageView.frame.origin.y, bgWidth, _picView.frame.size.height + 10);
    
    if (msgObj.upload_progress < 100) {
        _progressLabel.hidden = NO;
        _progressLabel.frame = CGRectMake(0, 0, _picView.frame.size.width, _picView.frame.size.height - 5);
        if (msgObj.delivery_status == 1) {
            _progressLabel.text = [NSString stringWithFormat:@"%d%%", msgObj.upload_progress];
        }else{
            _progressLabel.text = @"发送失败";
        }
    }else{
        _progressLabel.hidden = YES;
    }
    
}

/// 获得高度
+ (float)getMsgHeight:(MsgObject *)msgObj
{
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

/// 点击重新发送消息
- (void)clickResendMsg
{
    [_delegate resendMsg:_rowIndex];
}

/// 点击图片
- (void)rightClickPic:(id)ges
{
    [_delegate lookImage:_rowIndex];
}

@end
