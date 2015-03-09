//
//  Common.h
//  Test1
//
//  Created by tw001 on 15/2/3.
//  Copyright (c) 2015年 许 萍. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Common : NSObject

/// 获得设备号
+ (NSString *)getIdentifierForVendor;

/// 获取caches目录下文件夹路径
+ (NSString *)getCachesPath:(NSString *)directoryName;

/// 获得缓存文件夹路径
+ (NSString *)getCachesDirPath:(NSString *)cachesDir;

/// data json解析
+ (id)getSerializationData:(NSData *)data;

/// 设置tableView多余的横线为空
+ (void)setExtraCellLineHidden:(UITableView *)tableView tColor:(UIColor *)tColor;

/// 获得文字的尺寸
+ (CGSize)getContentSize:(NSString *)content withCGSize:(CGSize)size withSystemFontOfSize:(int)font;

#pragma mark image scale utility
+ (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage;
+ (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize;


@end
