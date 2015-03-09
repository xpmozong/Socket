//
//  MsgObject.m
//  Ershixiong
//
//  Created by tw001 on 14-8-29.
//  Copyright (c) 2014年 wave. All rights reserved.
//

#import "MsgObject.h"

@implementation MsgObject

//- (id)mutableCopyWithZone:(NSZone *)zone
//{
//    MsgObject *msgObj = [[MsgObject alloc] init];
//    msgObj.mid = _mid;
//    msgObj.date = [_date mutableCopy];
//    msgObj.mtimestamp = _mtimestamp;
//    msgObj.direction = _direction;
//    msgObj.localUser = [_localUser mutableCopy];
//    msgObj.foreignUser = [_foreignUser mutableCopy];
//    msgObj.delivery_status = _delivery_status;
//    msgObj.file_url = [_file_url mutableCopy];
//    msgObj.isread = _isread;
//    msgObj.m_type = _m_type;
//    msgObj.voice_time = _voice_time;
//    msgObj.serial_id = _serial_id;
//    msgObj.uploadImageCount = _uploadImageCount;
//    msgObj.uploadVoiceCount = _uploadVoiceCount;
//    msgObj.upload_progress = _upload_progress;
//    msgObj.download_progress = _download_progress;
//    msgObj.destroy_image_time = _destroy_image_time;
//    msgObj.imgPath = [_imgPath mutableCopy];
//    msgObj.resend_count = _resend_count;
//    msgObj.send_count = _send_count;
//    msgObj.msgLabel = nil;
//    msgObj.msgRowHeight = 0;
//    
//    return msgObj;
//}

- (NSString *)description
{
    return [NSString stringWithFormat:@"mid=%d localUser=%@ foreignUser=%@ serial_id=%@ delivery_status=%d send_count=%d resend_count=%d", _mid, _localUser, _foreignUser, _serial_id, _delivery_status, _send_count, _resend_count];
//    return [NSString stringWithFormat:@"mid=%d %@", _mid, _msgLabel];
}

@end
