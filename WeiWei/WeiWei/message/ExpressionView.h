//
//  ExpressionView.h
//  BDMapDemo
//
//  Created by tw001 on 14-9-24.
//  Copyright (c) 2014年 ESX. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ExpressionDelegate <NSObject>

@optional
/// 选中表情
- (void)selectedExpression:(NSString *)str;
/// 删除
- (void)delClicked;
/// 发送
- (void)sendClicked;

@end

@interface ExpressionView : UIView<UIScrollViewDelegate>

@property (assign, nonatomic) float w;
@property (assign, nonatomic) float h;
@property (strong, nonatomic) UIPageControl *ePageControl;
@property (strong, nonatomic) UIScrollView  *eScrollView;
@property (strong, nonatomic) UIButton      *delBtn;
@property (strong, nonatomic) UIButton      *sendBtn;
@property (assign, nonatomic) id<ExpressionDelegate>delegate;
@property (strong, nonatomic) NSArray       *m_emojiArray;


- (id)initWithFrame:(CGRect)frame m_emojiArray:(NSArray *)m_emojiArray m_emojiDictionary:(NSDictionary *)m_emojiDictionary;

@end
