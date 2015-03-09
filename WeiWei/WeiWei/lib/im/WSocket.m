//
//  WSocket.m
//  WeiWei
//
//  Created by tw001 on 14/11/18.
//  Copyright (c) 2014年 wave. All rights reserved.
//

#import "WSocket.h"

@implementation WSocket

static WSocket *wSocket = nil;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _messagesList = [[NSMutableArray alloc] init];
    }
    return self;
}

+(WSocket *)shareWSocket
{
    if (wSocket == nil) {
        wSocket = [[WSocket alloc] init];
        NSLog(@"wSocket===================%@", wSocket);
        NSString *sIP = @"192.168.0.102";
        char *pcIp = (char *)[sIP cStringUsingEncoding:NSASCIIStringEncoding];
        im_init(pcIp, 8001, imReturn, imRecv, imState);
        wSocket.isConnect = kConnectFailue;
        wSocket.isConnect = im_connect();
        NSLog(@"链接结果是 isConnect=%d", wSocket.isConnect);
    }
    
    return wSocket;
}

#pragma mark - 回调
int imReturn(const int m_fun, const char *user_id, const char *serial_id, const int m_state)
{
    NSLog(@"return m_fun=%d user_id=%s serial_id===%s m_state===%d", m_fun, user_id, serial_id, m_state);
    NSString *user = [NSString stringWithFormat:@"%s", user_id];
    NSString *serid = [NSString stringWithFormat:@"%s", serial_id];
    
    switch (m_fun) {
        case IM_FUN_SEND_MSG:
        {
            int delivery_status = 1;
            if (m_state == IM_SERVER_REBACK_SUCCESS) {
                delivery_status = 2;
            }else{
                delivery_status = 3;
            }
            for (NSInteger i = wSocket.messagesList.count - 1; i >= 0; i--) {
                MsgObject *msgObj = [wSocket.messagesList objectAtIndex:i];
                if ([msgObj.foreignUser isEqualToString:user] && [msgObj.serial_id isEqualToString:serid]) {
                    msgObj.delivery_status = delivery_status;
                    [wSocket confirmSendMsg:delivery_status mid:msgObj.mid];
                }
            }
            
            break;
        }
        default:
            break;
    }
    
    return 0;
}

int imRecv(const int m_fun, const int m_type, const char *user_id, char *pData, const char *serial_id)
{
    NSLog(@"recv m_fun===%d m_type===%d user_id===%s", m_fun, m_type, user_id);
    NSString *user = [NSString stringWithFormat:@"%s", user_id];
    NSString *sid = [NSString stringWithFormat:@"%s", serial_id];
    NSString *msg = [wSocket charToString:pData dataLen:(int)strlen(pData)];
    NSLog(@"msg=====%@", msg);
    long timestamp = [[NSDate date] timeIntervalSince1970];
    switch (m_type) {
        case IM_DATA_TYPE_TEXT:
            [wSocket receiveMsg:user timestamp:timestamp m_type:MsgText msgStr:msg voice_time:0 serial_id:sid];
            break;
            
        default:
            break;
    }
    
    return 0;
}

int imState(const int m_fun, const int m_state)
{
    NSLog(@"m_fun===%d m_state===%d", m_fun, m_state);
    NSNumber *res = [NSNumber numberWithInt:m_state];
    switch (m_fun) {
        case IM_FUN_LOGIN:
        {
            if (wSocket.loginCount == 1) {
                [wSocket setMsgChatFailue];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kUserLogin object:res];
            break;
        }
        case IM_FUN_LOGOUT:
        {
            if (m_state == IM_SERVER_REBACK_LOGINOUT) {
                NSLog(@"退出成功");
            }else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您在别的地方已登录，请重新登录！" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [alertView show];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPassword];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoginOut object:res];
            break;
        }
        case IM_FUN_CONNECT:
        {
            if (m_state == IM_STATE_CLOSE) {
                wSocket.isConnect = IM_STATE_CLOSE;
            }else{
                wSocket.isConnect = m_state;
            }
            break;
        }
        default:
            break;
    }
    
    return 0;
}

#pragma mark - 实例方法
/// 获得表情数组
- (NSArray *)getEmojiArray
{
    NSArray *array = [NSArray arrayWithObjects:@"[微笑]", @"[撇嘴]", @"[色]", @"[发呆]", @"[得意]", @"[流泪]", @"[害羞]", @"[闭嘴]", @"[睡]", @"[大哭]", @"[尴尬]", @"[发怒]", @"[调皮]", @"[龇牙]", @"[惊讶]", @"[难过]", @"[酷]", @"[冷汗]", @"[抓狂]", @"[吐]", @"[偷笑]", @"[可爱]", @"[白眼]", @"[傲慢]", @"[饥饿]", @"[困]", @"[惊恐]", @"[流汗]", @"[憨笑]", @"[大兵]", @"[奋斗]", @"[咒骂]", @"[疑问]", @"[嘘]", @"[晕]", @"[折磨]", @"[衰]", @"[骷髅]", @"[敲打]", @"[再见]", @"[擦汗]", @"[抠鼻]", @"[鼓掌]", @"[糗大了]", @"[坏笑]", @"[左哼哼]", @"[右哼哼]", @"[哈欠]", @"[鄙视]", @"[委屈]", @"[快哭了]", @"[阴险]", @"[亲亲]", @"[吓]", @"[可怜]", @"[菜刀]", @"[西瓜]", @"[啤酒]", @"[篮球]", @"[乒乓]", @"[咖啡]", @"[饭]", @"[猪头]", @"[玫瑰]", @"[凋谢]", @"[示爱]", @"[爱心]", @"[心碎]", @"[蛋糕]", @"[闪电]", @"[炸弹]", @"[刀]", @"[足球]", @"[瓢虫]", @"[便便]", @"[月亮]", @"[太阳]", @"[礼物]", @"[拥抱]", @"[强]", @"[弱]", @"[握手]", @"[胜利]", @"[抱拳]", @"[勾引]", @"[拳头]", @"[差劲]", @"[爱你]", @"[NO]", @"[OK]", @"[爱情]", @"[飞吻]", @"[跳跳]", @"[发抖]", @"[怄火]", @"[转圈]", @"[磕头]", @"[回头]", @"[跳绳]", @"[挥手]", @"[激动]", @"[街舞]", @"[献吻]", @"[左太极]", @"[右太极]", @"[钱]", nil];
    
    return array;
}

/// 获得表情字典
- (NSMutableDictionary *)getEmojiDictionary
{
    NSArray *array1 = [self getEmojiArray];
    NSMutableArray *array2 = [[NSMutableArray alloc] init];
    for (int i = 0; i < 106; i++) {
        NSString *imgName = [NSString stringWithFormat:@"face_%03d", i];
        [array2 addObject:imgName];
    }
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjects:array2 forKeys:array1];
    
    return dict;
}

/// 获得缓存文件夹路径
- (NSString *)getCachesDirPath:(NSString *)cachesDir
{
    NSString *libraryDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *imageDir = [NSString stringWithFormat:@"%@/Caches/%@/", libraryDirectory, cachesDir];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:imageDir isDirectory:&isDir];
    if (!(isDir == YES && existed == YES))
    {
        [fileManager createDirectoryAtPath:imageDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return imageDir;
}

/// 创建对方文件夹
- (NSString *)getCreateForeignDirPath:(NSString *)cachesDir foreignUser:(NSString *)foreignUser
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *foreignDir = [NSString stringWithFormat:@"%@%@/", cachesDir, foreignUser];
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:foreignDir isDirectory:&isDir];
    if (!(isDir == YES && existed == YES))
    {
        [fileManager createDirectoryAtPath:foreignDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return foreignDir;
}

/// MD5加密 32位加密（小写）
- (NSString *)lower32_MD5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (int)strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

/// md5 16位加密 （大写）
- (NSString *)upper16_MD5:(NSString *)str
{
    
    if (str) {
        const char *cStr = [str UTF8String];
        unsigned char result[16];
        CC_MD5( cStr, (int)strlen(cStr), result );
        return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                result[0], result[1], result[2], result[3],
                result[4], result[5], result[6], result[7],
                result[8], result[9], result[10], result[11],
                result[12], result[13], result[14], result[15]
                ];
    }else{
        return nil;
    }
}

/// 时间戳转时间
- (NSString *)turnTime:(NSString *)timestamp nowtime:(long)nowtime isShowHM:(BOOL)isShowHM
{
    int time = (int)[timestamp longLongValue];
    int betweentime = (int)nowtime - time;
    
    int year = betweentime / (3600*24*365);
    int month = betweentime / (3600*24*30);
    int days = betweentime / (3600*24);
    int hours = betweentime % (3600*24)/3600;
    int minute = betweentime % (3600*24)/60;
    
    NSString *dateContent = nil;
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:@"HH:mm"];
    NSString *md = [formatter stringFromDate:confromTimesp];
    
    if (year != 0 && year > 0) {
        if (isShowHM) {
            dateContent = [NSString stringWithFormat:@"%i%@ %@", month, @"年前", md];
        }else{
            dateContent = [NSString stringWithFormat:@"%i%@", month, @"年前"];
        }
    }else if (month != 0 && month > 2 && isShowHM) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        NSTimeZone *timeZone = [NSTimeZone localTimeZone];
        [formatter setTimeZone:timeZone];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        dateContent = [formatter stringFromDate:confromTimesp];
    }else if(month != 0 && month > 0){
        if (isShowHM) {
            dateContent = [NSString stringWithFormat:@"%i%@ %@", month, @"个月前", md];
        }else{
            dateContent = [NSString stringWithFormat:@"%i%@", month, @"个月前"];
        }
    }else if(days != 0 && days > 0){
        if (isShowHM) {
            dateContent = [NSString stringWithFormat:@"%i%@ %@", days,@"天前", md];
        }else{
            dateContent = [NSString stringWithFormat:@"%i%@", days, @"天前"];
        }
    }else if(hours != 0 && hours > 0){
        if (isShowHM) {
            dateContent = [NSString stringWithFormat:@"%i%@ %@", hours, @"小时前", md];
        }else{
            dateContent = [NSString stringWithFormat:@"%i%@", hours, @"小时前"];
        }
        
    }else if(minute != 0 && minute > 0){
        dateContent = [NSString stringWithFormat:@"%i%@", minute, @"分钟前"];
    }else{
        dateContent = md;
    }
    
    return dateContent;
}

/// 特殊字符转义
- (NSString *)specialCharactersToEscape:(NSString *)escapeStr
{
    escapeStr = (NSMutableString *)[escapeStr stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    escapeStr = (NSMutableString *)[escapeStr stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    escapeStr = (NSMutableString *)[escapeStr stringByReplacingOccurrencesOfString:@"%" withString:@"\%"];
    escapeStr = (NSMutableString *)[escapeStr stringByReplacingOccurrencesOfString:@"&" withString:@"\\&"];
    return escapeStr;
}

/// 特殊字符反转义
- (NSString *)specialCharactersToAgainstEscape:(NSString *)escapeStr
{
    escapeStr = (NSMutableString *)[escapeStr stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
    escapeStr = (NSMutableString *)[escapeStr stringByReplacingOccurrencesOfString:@"''" withString:@"'"];
    escapeStr = (NSMutableString *)[escapeStr stringByReplacingOccurrencesOfString:@"\%" withString:@"%"];
    escapeStr = (NSMutableString *)[escapeStr stringByReplacingOccurrencesOfString:@"\\&" withString:@"&"];
    return escapeStr;
}

#pragma mark---- 字符串和16进制互转
/// 十六进制转换为普通字符串的。
- (NSString *)stringFromHexString:(NSString *)hexString
{
    if (hexString.length == 1)
    {
        return hexString;
    }
    
    for (int i = 0; i < hexString.length; i++)
    {
        char s = [hexString characterAtIndex:i];
        if (s < 48 || (s > 58 && s <65) || (s >70 && s < 97) || s >102)
            return hexString;
    }
    
    if (hexString.length == 0)
    {
        return hexString;
    }
    
    
    char *myBuffer = (char *)malloc((int)[hexString length] / 2 + 1);
    bzero(myBuffer, [hexString length] / 2 + 1);
    for (int i = 0; i < [hexString length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        //  NSLog(@"hexCharStr = %@",hexCharStr);
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:4];
    //  NSLog(@"------字符串=======%@",unicodeString);
    if (!unicodeString)
        return hexString;
    return unicodeString;
    
    
}

/// 普通字符串转换为十六进制的。
- (NSString *)hexStringFromString:(NSString *)string
{
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)
        
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1)
            
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        
        else
            
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}

#pragma mark - 建表
/// 建表
- (void)createTables
{
    DBConnect *dbConnect = [DBConnect shareConnect];
    // 建消息表
    NSString *msgsql = [NSString stringWithFormat:@"CREATE TABLE '%@' ('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 'date' TEXT default '(null)', 'direction' INTEGER default 0, 'local_user' TEXT default '(null)', 'message' TEXT default '(null)', 'delivery_status' INTEGER default 0, 'file_url' TEXT default '(null)', 'voice_time' INTEGER default 0, 'isread' INTEGER default 0, 'foreign_user' TEXT default '(null)', 'm_type' INTEGER default 0, 'serial_id' VARCHAR(20) default '(null)', 'destroy_image_time' INTEGER default 0, 'upload_progress' INTEGER default 0, 'download_progress' INTEGER default 0, 'voice_read' INTEGER default 0)", kMsgChatTableName];
    if ([dbConnect isTableOK:kMsgChatTableName] == NO) {
        [dbConnect createTableSql:msgsql];
    }
}

#pragma mark - 登录、注册、重置密码
/// 登录
- (int)logining:(NSString *)username passwd:(NSString *)passwd isRetry:(BOOL)isRetry
{
    NSLog(@"登录 %@ %@ %d", username, passwd, _isConnect);
    if (isRetry == NO) {
        _wJid = nil;
        _wJid = [[WJID alloc] init];
        _wJid.username = username;
        _wJid.userDir = [self getCachesDirPath:_wJid.username];
        _loginCount++;
//        [wSocket setMsgChatFailue];
    }
    
    if (_isConnect == kConnectFailue) {
        NSNumber *num = [NSNumber numberWithInt:ConnectStateFailue];
        [[NSNotificationCenter defaultCenter] postNotificationName:kConnectState object:num];
        return kConnectFailue;
        
    }else{
        char *u = [self stringToChar:username];
        char *pwd = [self stringToChar:passwd];
        int response = im_login(u, pwd);
        return response;
    }
    
    return 0;
}

#pragma mark - 聊天
/// 获得消息列表
- (int)getMsgList:(NSString *)foreignUser
             page:(int)page
       srmsgCount:(int)srmsgCount
       foreignDir:(id)foreignDir
{
    int offset = (page - 1) * kPageSize;
    if (srmsgCount > 0) {
        offset += srmsgCount;
    }
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE local_user='%@' AND foreign_user='%@' ORDER BY id DESC LIMIT %d,%d", kMsgChatTableName, _wJid.username, foreignUser, offset, kPageSize];
    long time1 = 0;
    long time2 = 0;
    
    if (_messagesList.count > 0) {
        MsgObject *firstObj = [_messagesList objectAtIndex:0];
        time1 = firstObj.mtimestamp;
    }
    
    BOOL isPageFinish = YES;
    long timestamp = [[NSDate date] timeIntervalSince1970];
    NSArray *array = [[DBConnect shareConnect] getDBlist:sql];
    if (array.count > 0) {
        for (NSDictionary *dictionary in array) {
            isPageFinish = NO;
            MsgObject *msgObj = [[MsgObject alloc] init];
            msgObj.mid = [[dictionary objectForKey:@"id"] intValue];
            msgObj.mtimestamp = [[dictionary objectForKey:@"date"] intValue];
            msgObj.direction = [[dictionary objectForKey:@"direction"] boolValue];
            msgObj.localUser = [dictionary objectForKey:@"local_user"];
            msgObj.messageStr = [dictionary objectForKey:@"message"];
            msgObj.delivery_status = [[dictionary objectForKey:@"delivery_status"] intValue];
            msgObj.serial_id = [dictionary objectForKey:@"serial_id"];
            msgObj.file_url = [dictionary objectForKey:@"file_url"];
            if (![[dictionary objectForKey:@"voice_time"] isEqualToString:kDefaultNull]) {
                msgObj.voice_time = [[dictionary objectForKey:@"voice_time"] intValue];
            }
            msgObj.isread = [[dictionary objectForKey:@"isread"] intValue];
            msgObj.foreignUser = [dictionary objectForKey:@"foreign_user"];
            msgObj.m_type = [[dictionary objectForKey:@"m_type"] intValue];
            msgObj.upload_progress = [[dictionary objectForKey:@"upload_progress"] intValue];
            msgObj.download_progress = [[dictionary objectForKey:@"download_progress"] intValue];
            if (msgObj.m_type == MsgImage) {
                if (msgObj.direction) {
                    msgObj.imgPath = [NSString stringWithFormat:@"%@%@", foreignDir, msgObj.file_url];
                }else{
                    msgObj.imgPath = [NSString stringWithFormat:@"%@%@.jpeg", foreignDir, [wSocket upper16_MD5:msgObj.file_url]];
                }
            }
            if (_messagesList.count == 0) {
                [_messagesList addObject:msgObj];
            }else{
                if (msgObj == nil) {
                    NSLog(@"获得消息列表====%@", msgObj);
                }else{
                    [_messagesList insertObject:msgObj atIndex:0];
                }
            }
            if (time1 == 0) {
                time1 = timestamp;
            }
            time2 = msgObj.mtimestamp;
            if ((time2 + kBetweenTime) <= time1) {
                time1 = msgObj.mtimestamp;
                MsgObject *msgObjt = [[MsgObject alloc] init];
                msgObjt.messageStr = [self turnTime:[dictionary objectForKey:@"date"] nowtime:timestamp isShowHM:YES];
                msgObjt.m_type = MsgTime;
                msgObjt.mtimestamp = time1;
                if (msgObjt == nil) {
                    NSLog(@"获得消息列表时间====%@", msgObjt);
                }else{
                    [_messagesList insertObject:msgObjt atIndex:0];
                }
            }
        }
        
        MsgObject *firstObj = [_messagesList objectAtIndex:0];
        if (firstObj.m_type != MsgTime) {
            MsgObject *msgObjt = [[MsgObject alloc] init];
            msgObjt.messageStr = [self turnTime:[NSString stringWithFormat:@"%ld", firstObj.mtimestamp] nowtime:timestamp isShowHM:YES];
            msgObjt.m_type = MsgTime;
            msgObjt.mtimestamp = firstObj.mtimestamp;
            if (msgObjt == nil) {
                NSLog(@"获得消息列表firstObj====%@", msgObjt);
            }else{
                [_messagesList insertObject:msgObjt atIndex:0];
            }
        }
        
    }else{
        if (page == 1) {
            MsgObject *msgOj = [[MsgObject alloc] init];
            msgOj.m_type = MsgEmpty;
            msgOj.foreignUser = foreignUser;
            [_messagesList addObject:msgOj];
        }
    }
    
    if (page != 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kMsgListMessage object:[NSNumber numberWithInt:isPageFinish]];
    }
    
    return 0;
}

/// 获得消息页数
- (int)getMsgPageCount:(NSString *)foreignUser
{
    NSString *sql = [NSString stringWithFormat:@"SELECT count(*) count FROM %@ WHERE local_user='%@' AND foreign_user='%@'", kMsgChatTableName, _wJid.username, foreignUser];
    int count = [[DBConnect shareConnect] getDBDataCount:sql];
    
    int pageCount = 0;
    if (count > 0) {
        if (count % kPageSize == 0) {
            pageCount = count / kPageSize;
        }else{
            pageCount = (count / kPageSize) + 1;
        }
    }
    
    return pageCount;
}

/// 加时间
- (void)addNowTime:(long)timestamp
{
    if (_messagesList.count > 0) {
        MsgObject *lastMsgObj = [_messagesList lastObject];
        if (lastMsgObj.m_type != MsgTime) {
            if (timestamp - kBetweenTime > lastMsgObj.mtimestamp) {
                MsgObject *msgObjt = [[MsgObject alloc] init];
                msgObjt.messageStr = [self turnTime:[NSString stringWithFormat:@"%ld", timestamp] nowtime:timestamp isShowHM:YES];
                msgObjt.m_type = MsgTime;
                msgObjt.mtimestamp = timestamp;
                [_messagesList addObject:msgObjt];
            }
        }
    }else{
        MsgObject *msgObjt = [[MsgObject alloc] init];
        msgObjt.messageStr = [self turnTime:[NSString stringWithFormat:@"%ld", timestamp] nowtime:timestamp isShowHM:YES];
        msgObjt.m_type = MsgTime;
        msgObjt.mtimestamp = timestamp;
        [_messagesList addObject:msgObjt];
    }
}

/// 向其他用户发送数据 mType 1-文本 3-图片 4-语音
- (int)sendMsgToUser:(NSString *)foreignUser
               mType:(int)mType
                 msgStr:(NSString *)msgStr
{
    NSLog(@"foreignUser===%@ msgStr=====%@", foreignUser, msgStr);
    if (_isConnect == kConnectFailue) {
        return kConnectFailue;
    }

    char *username = [self stringToChar:foreignUser];
    char *pcData = [self stringToChar:[self hexStringFromString:msgStr]];
    int pDataLen = (int)strlen(pcData);
    
    char sid[20];
    im_get_serial_id(sid);
    NSString *serial_id = [NSString stringWithFormat:@"%s", sid];
    
    int delivery_status = 1;
    if (mType == MsgText) {
        long timestamp = [[NSDate date] timeIntervalSince1970];
        [self addNowTime:timestamp];
        MsgObject *msgObj = [[MsgObject alloc] init];
        msgObj.mtimestamp = timestamp;
        msgObj.direction = YES;
        msgObj.localUser = _wJid.username;
        msgObj.messageStr = msgStr;
        msgObj.isread = YES;
        msgObj.foreignUser = foreignUser;
        msgObj.m_type = mType;
        msgObj.file_url = @"";
        msgObj.delivery_status = delivery_status;
        
        [_messagesList addObject:msgObj];
        [[NSNotificationCenter defaultCenter] postNotificationName:kMsgListMessage object:[NSNumber numberWithInt:MsgChatRefrashTypeSendSuccess]];
        
        msgObj.serial_id = serial_id;
        NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO %@ (date, direction, local_user, message, delivery_status, isread, foreign_user, m_type, serial_id) values ('%ld', '%d', '%@', '%@', '%d', '%d', '%@', '%d', '%@')", kMsgChatTableName, timestamp, 1, msgObj.localUser, msgObj.messageStr, delivery_status, 1, foreignUser, mType, serial_id];
        msgObj.mid = [[DBConnect shareConnect] executeInsertSql:insertSql];
        
        int result = im_send_user_data(sid, username, pcData, pDataLen, IM_DATA_TYPE_TEXT);
        NSLog(@"result===%d", result);
        
    }
    
    return 0;
}

/// 发送图片
- (void)sendImage:(NSString *)foreignUser
            image:(UIImage *)image
       foreignDir:(NSString *)foreignDir
{
    long timestamp = [[NSDate date] timeIntervalSince1970];
    NSString *imageName = [NSString stringWithFormat:@"%ld.jpeg", timestamp];
    NSString *imagePath = [NSString stringWithFormat:@"%@%@", foreignDir, imageName];
    NSLog(@"上传的图片地址：%@", imagePath);
    
    [self addNowTime:timestamp];
    
//    char *username = [self stringToChar:foreignUser];
    char sid[20];
    im_get_serial_id(sid);
    NSString *serial_id = [NSString stringWithFormat:@"%s", sid];
    
    MsgObject *msgObj = [[MsgObject alloc] init];
    msgObj.mtimestamp = timestamp;
    msgObj.direction = YES;
    msgObj.localUser = _wJid.username;
    msgObj.messageStr = @"[图片]";
    msgObj.delivery_status = 1;
    msgObj.isread = YES;
    msgObj.foreignUser = foreignUser;
    msgObj.m_type = MsgImage;
    msgObj.file_url = imageName;
    msgObj.imgPath = imagePath;
    msgObj.serial_id = serial_id;
    if (_isConnect == kConnectFailue) {
        msgObj.serial_id = @"-2";
    }
    [_messagesList addObject:msgObj];
    
    NSData *imgData = UIImageJPEGRepresentation(image, 1);
    [imgData writeToFile:imagePath atomically:YES];
    
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO %@ (date, direction, local_user, message, delivery_status, isread, foreign_user, m_type, file_url, serial_id) values ('%ld', '%d', '%@', '%@', '%d', '%d', '%@', '%d', '%@', '%@')", kMsgChatTableName, msgObj.mtimestamp, msgObj.direction, msgObj.localUser, msgObj.messageStr, msgObj.delivery_status, msgObj.isread, msgObj.foreignUser, msgObj.m_type, imageName, msgObj.serial_id];
    msgObj.mid = [[DBConnect shareConnect] executeInsertSql:insertSql];
    NSLog(@"msgObj.mid====%d", msgObj.mid);
    
//    [self addRemind:msgObj];
    
//    NSLog(@"imgData=%@", imgData);
    
//    char *data = (char *)[imgData bytes];
//    im_send_user_image(sid, username, data, imgData.length);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMsgListMessage object:[NSNumber numberWithInt:MsgChatRefrashTypeSendSuccess]];
}

/// 发送失败的消息
- (int)resendFailueMsg:(MsgObject *)msgObjt
            foreignDir:(NSString *)foreignDir
{
    
    MsgObject *msgObj = [[MsgObject alloc] init];
    msgObj.mid = msgObjt.mid;
    msgObj.date = msgObjt.date;
    msgObj.mtimestamp = msgObjt.mtimestamp;
    msgObj.direction = msgObjt.direction;
    msgObj.localUser = [NSString stringWithFormat:@"%@", msgObjt.localUser];
    msgObj.foreignUser = [NSString stringWithFormat:@"%@", msgObjt.foreignUser];
    msgObj.delivery_status = 1;
    msgObj.file_url = [NSString stringWithFormat:@"%@", msgObjt.file_url];
    msgObj.isread = msgObjt.isread;
    msgObj.m_type = msgObjt.m_type;
    msgObj.voice_time = msgObjt.voice_time;
    if (_isConnect == kConnectFailue) {
        msgObj.serial_id = @"-2";
    }
    msgObj.imgPath = [NSString stringWithFormat:@"%@", msgObjt.imgPath];
    
    NSString *msgDelSql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE id='%d'", kMsgChatTableName, msgObj.mid];
    [[DBConnect shareConnect] executeUpdateSql:msgDelSql];
    [_messagesList removeObject:msgObjt];
    if (msgObj.m_type == MsgText) {
        msgObj.messageStr = [NSString stringWithFormat:@"%@", msgObjt.messageStr];
        NSLog(@"重发消息===%@", msgObj.messageStr);
        [self sendMsgToUser:msgObj.foreignUser mType:msgObj.m_type msgStr:msgObj.messageStr];
        
    }else if (msgObj.m_type == MsgImage) {
        msgObj.messageStr = @"[图片]";
        msgObj.delivery_status = 1;
        
        [_messagesList addObject:msgObj];
        
        char sid[20];
        im_get_serial_id(sid);
        NSString *serial_id = [NSString stringWithFormat:@"%s", sid];
        
        NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO %@ (date, direction, local_user, message, delivery_status, isread, foreign_user, m_type, file_url, serial_id) values ('%ld', '%d', '%@', '%@', '%d', '%d', '%@', '%d', '%@', '%@')", kMsgChatTableName, msgObj.mtimestamp, msgObj.direction, msgObj.localUser, msgObj.messageStr, msgObj.delivery_status, msgObj.isread, msgObj.foreignUser, msgObj.m_type, msgObj.file_url, serial_id];
        msgObj.mid = [[DBConnect shareConnect] executeInsertSql:insertSql];
        NSLog(@"重发图片===%d", msgObj.mid);
        
        NSData *imgData = [NSData dataWithContentsOfFile:msgObjt.imgPath];
        char *username = [self stringToChar:msgObjt.foreignUser];
        
        char *data = (char *)[imgData bytes];
        im_send_user_image(sid, username, data, imgData.length);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kMsgListMessage object:[NSNumber numberWithInt:MsgChatRefrashTypeNormal]];
    }
    
    return 0;
}

/// 确认发送消息状态
- (void)confirmSendMsg:(int)delivery_status mid:(int)mid
{
    NSString *msgDelSql = [NSString stringWithFormat:@"UPDATE %@ SET delivery_status='%d' WHERE id='%d'", kMsgChatTableName, delivery_status, mid];
    [[DBConnect shareConnect] executeUpdateSql:msgDelSql];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMsgListMessage object:[NSNumber numberWithInt:MsgChatRefrashTypeNormal]];
}

#pragma mark - 接收聊天消息保存
/// 接收聊天消息保存
- (void)receiveMsg:(NSString *)foreign_user
         timestamp:(long)timestamp
            m_type:(int)m_type
            msgStr:(NSString *)msgStr
        voice_time:(int)voice_time
         serial_id:(NSString *)serial_id
{
    NSString *ssql = [NSString stringWithFormat:@"SELECT COUNT(*) count FROM %@ WHERE serial_id='%@' AND direction='0' AND foreign_user='%@'", kMsgChatTableName, serial_id, foreign_user];
    msgStr = [self stringFromHexString:msgStr];
    int count = [[DBConnect shareConnect] getDBDataCount:ssql];
    if (count == 0) {
        long nowtimestamp = [[NSDate date] timeIntervalSince1970];
        MsgObject *msgObj = [[MsgObject alloc] init];
        msgObj.direction = false;
        msgObj.localUser = _wJid.username;
        NSString *imgDir = [self getCreateForeignDirPath:_wJid.userDir foreignUser:foreign_user];
        if (m_type == MsgImage) {
            msgObj.messageStr = @"[图片]";
            msgObj.file_url = msgStr;
            if (msgObj.direction) {
                msgObj.imgPath = [NSString stringWithFormat:@"%@%@", imgDir, msgObj.file_url];
            }else{
                msgObj.imgPath = [NSString stringWithFormat:@"%@%@.jpeg", imgDir, [wSocket upper16_MD5:msgObj.file_url]];
            }
            msgObj.delivery_status = 1;
            
        }else if (m_type == MsgVoice) {
            msgObj.delivery_status = 2;
            msgObj.messageStr = @"[语音]";
            msgObj.file_url = msgStr;
            msgObj.voice_time = voice_time;
            msgObj.download_progress = 100;
            
        }else{
            msgObj.delivery_status = 2;
            msgObj.messageStr = @"";
            
            if (msgStr) {
                msgObj.messageStr = msgStr;
            }
            msgObj.file_url = nil;
        }
        msgObj.foreignUser = foreign_user;
        msgObj.m_type = m_type;
        msgObj.mtimestamp = timestamp;
        msgObj.isread = NO;
        msgObj.serial_id = serial_id;
        [self receiveMsgInsertDB:msgObj];
//        [self addRemind:msgObj];
        int mCount = (int)_messagesList.count;
        if (mCount > 0) {
            MsgObject *lastMsgObj = [_messagesList lastObject];
            if ([lastMsgObj.foreignUser isEqualToString:foreign_user]) {
                if (timestamp - kBetweenTime > lastMsgObj.mtimestamp) {
                    MsgObject *msgObjt = [[MsgObject alloc] init];
                    msgObjt.messageStr = [wSocket turnTime:[NSString stringWithFormat:@"%ld", timestamp] nowtime:nowtimestamp isShowHM:YES];
                    msgObjt.m_type = MsgTime;
                    msgObjt.mtimestamp = timestamp;
                    [_messagesList addObject:msgObjt];
                }
            }
            if ([lastMsgObj.foreignUser isEqualToString:foreign_user]) {
                [_messagesList addObject:msgObj];
            }
            if ([lastMsgObj.foreignUser isEqualToString:foreign_user]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kMsgListMessage object:[NSNumber numberWithInt:MsgChatRefrashTypeReciveMsg]];
            }
        }
        if (m_type == MsgImage) {
            NSLog(@"接收保存的图片=%@", msgObj.imgPath);
            
        }
        
    } else {
        NSLog(@"消息的index重复了");
    }
}

/// 聊天接收消息插入数据库
- (void)receiveMsgInsertDB:(MsgObject *)msgObj
{
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO %@ (date, direction, local_user, message, delivery_status, isread, foreign_user, m_type, file_url, serial_id, voice_time, download_progress) values ('%ld', '%d', '%@', '%@', '%d', '%d', '%@', '%d', '%@', '%@', '%d', '%d');", kMsgChatTableName, msgObj.mtimestamp, 0, msgObj.localUser, [self specialCharactersToEscape:msgObj.messageStr], msgObj.delivery_status, msgObj.isread, msgObj.foreignUser, msgObj.m_type, msgObj.file_url, msgObj.serial_id, msgObj.voice_time, msgObj.download_progress];
    msgObj.mid = [[DBConnect shareConnect] executeInsertSql:insertSql];
}



#pragma mark - 私有函数
/// char * 转 NSString
- (NSString *)charToString:(char *)pData dataLen:(int)dataLen
{
    NSData *data = [NSData dataWithBytes:pData length:dataLen];
    NSString *str = nil;
    str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return str;
}

/// NSString 转 char *
- (char *)stringToChar:(NSString *)str
{
    return (char*)[str cStringUsingEncoding:NSUTF8StringEncoding];
}

/// 程序第一次启动的时候，将正在发送中的消息置为发送失败
- (void)setMsgChatFailue
{
    NSString *updateSql = [NSString stringWithFormat:@"UPDATE %@ SET delivery_status='3' WHERE local_user='%@' AND delivery_status='1' AND direction='1'", kMsgChatTableName, _wJid.username];
    [[DBConnect shareConnect] executeUpdateSql:updateSql];
}

@end
