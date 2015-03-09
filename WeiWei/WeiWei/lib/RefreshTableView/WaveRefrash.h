//
//  WaveRefrash.h
//  Shop
//
//  Created by 许 萍 on 14-5-13.
//  Copyright (c) 2014年 许 萍. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define kFlipAnimationDuration  0.18f
#define kDateFormat             @"yyyy-MM-dd HH:mm:ss"
#define kDateString             @"最后更新时间"
#define kRefreshPulling         @"松开即可刷新..."
#define kDownRefreshNormal      @"下拉可以刷新..."
#define kUpRefreshNormal        @"上拉获取更多"
#define kRefreshLoading         @"加载中..."
#define kCompletion             @"已全部加载完毕"

typedef enum{
    WavePullRefreshPulling = 0,
    WavePullRefreshNormal,
    WavePullRefreshLoading,
    WavePullRefreshNoMore
    
} WavePullRefreshState;

@interface WaveRefrash : UIView
{
    float _edgeInsetsTop;
    float _edgeInsetsBottom;
}

@property (nonatomic, assign) float         edgeInsetsTop;
@property (nonatomic, assign) float         edgeInsetsBottom;

@end
