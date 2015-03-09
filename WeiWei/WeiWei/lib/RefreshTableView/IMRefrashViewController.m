//
//  IMRefrashViewController.m
//  Draw
//
//  Created by 许 萍 on 14/12/7.
//  Copyright (c) 2014年 wave. All rights reserved.
//

#import "IMRefrashViewController.h"

@interface IMRefrashViewController ()
{
    float orginY;
}
@end

@implementation IMRefrashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    orginY = 64.0f;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityView.frame = CGRectMake((self.view.frame.size.width - 40) / 2, -40, 40, 40);
    [self.tableView addSubview:_activityView];
    
    [self setState:WavePullRefreshNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    return cell;
}

#pragma mark - ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _tableView) {
        if (_isPageFinish == NO) {
            if (_state == WavePullRefreshLoading) {
                
            }else{
                if (scrollView.contentOffset.y < (0 - orginY) && !_isLoading) {
                    [self HeaderTriggerRefresh];
                    [self scrollContentInset];
                }
            }
        }
    }
}

/// scroll contentInset
- (void)scrollContentInset
{
    [self setState:WavePullRefreshLoading];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    self.tableView.contentInset = UIEdgeInsetsMake(40 + orginY, 0.0f, 0, 0.0f);
    [UIView commitAnimations];
}

#pragma mark - Setters
- (void)setState:(WavePullRefreshState)aState
{
    switch (aState) {
        case WavePullRefreshPulling:
            break;
        case WavePullRefreshNormal:
            if (_state == WavePullRefreshPulling) {
                
            }
            [_activityView stopAnimating];
            break;
            
        case WavePullRefreshLoading:
            [_activityView startAnimating];
            break;
        default:
            break;
    }
    
    _state = aState;
}

- (void)HeaderTriggerRefresh
{
    if (_isLoading == NO) {
        _isLoading = YES;
        [self waveRefrashNewData];
    }
}


#pragma mark - 实例方法 refrash
/// 下拉刷新
- (void)doneDownReLoadingTableViewData
{
    _isLoading = NO;
    [self waveRefreshDidFinishedLoading];
}

/// 下拉刷新
- (void)doneDownReLoadingTableViewData2
{
    _isLoading = NO;
    [self waveRefreshDidFinishedLoading2];
}

/// 结束刷新
- (void)waveRefreshDidFinishedLoading
{
    [self setState:WavePullRefreshNormal];
    [self EndTriggerRefresh];
}

/// 结束刷新
- (void)waveRefreshDidFinishedLoading2
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.3];
    [self.tableView setContentInset:UIEdgeInsetsMake(orginY, 0.0f, 0.0f, 0.0f)];
    [UIView commitAnimations];
    
    [self setState:WavePullRefreshNormal];
}

/// 获得新数据
- (void)waveRefrashNewData
{

}

- (void)EndTriggerRefresh
{

}

@end
