//
//  IMRefrashViewController.h
//  Draw
//
//  Created by 许 萍 on 14/12/7.
//  Copyright (c) 2014年 wave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaveRefrash.h"

@interface IMRefrashViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_tableView;
    BOOL _isPageFinish;
}
@property (nonatomic, strong) UITableView       *tableView;
@property (nonatomic, assign) WavePullRefreshState state;   // 状态
@property (nonatomic, assign) BOOL  isPageFinish;
@property (nonatomic, assign) BOOL  isLoading;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;    // 风火轮

#pragma mark - 实例方法 refrash
/// 下拉刷新
- (void)doneDownReLoadingTableViewData;
/// 下拉刷新
- (void)doneDownReLoadingTableViewData2;
/// 获得新数据
- (void)waveRefrashNewData;


@end
