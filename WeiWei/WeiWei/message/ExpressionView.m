//
//  ExpressionView.m
//  BDMapDemo
//
//  Created by tw001 on 14-9-24.
//  Copyright (c) 2014年 ESX. All rights reserved.
//

#import "ExpressionView.h"

@implementation ExpressionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame m_emojiArray:(NSArray *)m_emojiArray m_emojiDictionary:(NSDictionary *)m_emojiDictionary
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0.5)];
        lineView.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:lineView];
        
        _w = frame.size.width;
        _h = frame.size.height;
        self.m_emojiArray = m_emojiArray;
        
        float count = m_emojiArray.count;
        int pageCount = 4 * (_w / 45);
        int epage = (int)ceilf(count / pageCount);
        
        _eScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 5, _w, _h - 30)];
        _eScrollView.contentSize = CGSizeMake(_w * epage, _h - 16 - 25);
        _eScrollView.pagingEnabled = YES;
        _eScrollView.showsHorizontalScrollIndicator = NO;
        _eScrollView.showsVerticalScrollIndicator = NO;
        _eScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _eScrollView.delegate = self;
        [self addSubview:_eScrollView];
        
        CGSize size = CGSizeMake(28, 28);
        CGSize size2 = CGSizeMake(45, 45);
        for (int page = 0; page < epage; page++) {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(page * _w, 0, _w, _eScrollView.frame.size.height)];
            [_eScrollView addSubview:view];
            for (int i = 0; i < 4; i++) {
                int k = _w/45;
                for (int y = 0; y < k; y++) {
                    int index = i * k + y + (page * pageCount);
                    if (index < count) {
                        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                        button.frame = CGRectMake(0 + y * size2.width + 8.5, 0 + i * size2.height, size.width, size.height);
                        NSString *imageName = [NSString stringWithFormat:@"%@", [m_emojiArray objectAtIndex:index]];
                        NSString *imgName = [m_emojiDictionary objectForKey:imageName];
                        [button setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
                        button.tag = index;
                        [button addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];
                        [view addSubview:button];
                    }
                }
            }
        }
        _ePageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, _h - 40, _w, 16)];
        _ePageControl.numberOfPages = epage;
        [_ePageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
        _ePageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        _ePageControl.currentPageIndicatorTintColor = [UIColor darkGrayColor];
        [self addSubview:_ePageControl];
        
        _delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _delBtn.frame = CGRectMake(_w - 100 - 10, _ePageControl.frame.origin.y, 50, 30);
        _delBtn.backgroundColor = COLOR(224, 224, 224, 1);
        _delBtn.layer.cornerRadius = 3.0f;
        _delBtn.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        [_delBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_delBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
        [_delBtn setTitle:@"删除" forState:UIControlStateNormal];
        [_delBtn addTarget:self action:@selector(delBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_delBtn];
        
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendBtn.frame = CGRectMake(_w - 50 - 5, _ePageControl.frame.origin.y, 50, 30);
        _sendBtn.backgroundColor = COLOR(249, 43, 24, 1);
        _sendBtn.layer.cornerRadius = 3.0f;
        _sendBtn.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        [_sendBtn addTarget:self action:@selector(sendBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_sendBtn];
        
    }
    return self;
}

#pragma mark - scrollView delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int page = scrollView.contentOffset.x / _w;
    _ePageControl.currentPage = page;
}

/// 换页
- (void)changePage:(UIPageControl *)pc
{
    [UIView animateWithDuration:0.2 animations:^{
        _eScrollView.contentOffset = CGPointMake(pc.currentPage * _w, 0);
    }];
}

/// 选中
- (void)selected:(UIButton *)btn
{
    NSString *str = [_m_emojiArray objectAtIndex:btn.tag];
    [_delegate selectedExpression:str];
}

/// 删除
- (void)delBtnClicked
{
    [_delegate delClicked];
}

/// 发送
- (void)sendBtnClicked
{
    [_delegate sendClicked];
}

@end
