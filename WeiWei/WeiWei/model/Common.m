//
//  Common.m
//  Test1
//
//  Created by tw001 on 15/2/3.
//  Copyright (c) 2015年 许 萍. All rights reserved.
//

#import "Common.h"

#define ORIGINAL_MAX_WIDTH 750.0f

@implementation Common

/// 获得设备号
+ (NSString *)getIdentifierForVendor
{
    NSUUID *uid = [[UIDevice currentDevice] identifierForVendor];
    return [uid UUIDString];
}

/// 获取caches目录下文件夹路径
+ (NSString *)getCachesPath:(NSString *)directoryName
{
    NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    return [cachesDirectory stringByAppendingPathComponent:directoryName];
}

/// 获得缓存文件夹路径
+ (NSString *)getCachesDirPath:(NSString *)cachesDir
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *libraryDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *imageDir = [NSString stringWithFormat:@"%@/Caches/%@/", libraryDirectory, cachesDir];
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:imageDir isDirectory:&isDir];
    if (!(isDir == YES && existed == YES))
    {
        [fileManager createDirectoryAtPath:imageDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return imageDir;
}

/// data json解析
+ (id)getSerializationData:(NSData *)data
{
    id result = nil;
    if (data != nil) {
        result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    }
    
    return result;
}

/// 设置tableView多余的横线为空
+ (void)setExtraCellLineHidden:(UITableView *)tableView tColor:(UIColor *)tColor
{
    UIView *view = [UIView new];
    if (tColor != nil) {
        view.backgroundColor = tColor;
    }else{
        view.backgroundColor = [UIColor whiteColor];
    }
    [tableView setTableFooterView:view];
}

/// 获得文字的尺寸
+ (CGSize)getContentSize:(NSString *)content withCGSize:(CGSize)size withSystemFontOfSize:(int)font
{
    CGRect contentBounds = [content boundingRectWithSize:size
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:font]
                                                                                     forKey:NSFontAttributeName]
                                                 context:nil];
    return contentBounds.size;
}

#pragma mark image scale utility
+ (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage
{
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    
    return [Common imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

+ (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize
{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

@end
