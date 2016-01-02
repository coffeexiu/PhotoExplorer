//
//  LoadingView.m
//  Day8-UIActivityIndicatorView
//
//  Created by 蒋尚秀 on 15/12/16.
//  Copyright © 2015年 -JSX-. All rights reserved.
//

#import "LoadingView.h"

@interface LoadingView ()
{
    //展示文字
    UILabel * _titleLabel;
    //加载框
    UIActivityIndicatorView * _activity;
}


@end

@implementation LoadingView

//因为调用时会用到坐标，所以重写坐标方法
-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        //通过这种方式设置透明度，不会影响子视图的透明度
        self.backgroundColor = [UIColor colorWithRed:0.333 green:0.333 blue:0.333 alpha:0.5];
        
        //添加子控件
        [self createView];
        self.hidden = YES;
    }
    return self;
}

/**
 * 添加视图
 */
-(void)createView
{
    //初始化加载视图
    _activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(100, 100, 130, 130)];
    //设置居中
    _activity.center = self.center;
    //设置加载视图背景颜色
    _activity.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    //切圆角
    _activity.layer.cornerRadius = 6;
    //设置加载视图样式 大白
    _activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [_activity startAnimating];
    
    //设置文字视图
    _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 78, 130, 20)];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    //自适应宽度
//    _titleLabel.adjustsFontSizeToFitWidth = YES;
    //可以换行
    _titleLabel.numberOfLines = 0;
    //设置文字颜色
    _titleLabel.textColor = [UIColor whiteColor];
    //设置文字大小
    _titleLabel.font = [UIFont systemFontOfSize:12];
    //添加到加载视图上
    [_activity addSubview:_titleLabel];
    
    //添加到底层视图
    [self addSubview:_activity];
}

/** 
 * 显示阴影层
 */
-(void)showLoadingView
{
    self.hidden = NO;
    [_activity startAnimating];
    _titleLabel.text = _labelText;
    
    CGRect rect = [_titleLabel.text boundingRectWithSize:CGSizeMake(130, 99999) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil];
    _titleLabel.frame = CGRectMake(0, _activity.frame.size.height-rect.size.height, 130, rect.size.height);
}

/**
 * 隐藏阴影层
 */
-(void)hiddenLoadingView
{
    self.hidden = YES;
    [_activity stopAnimating];
}

-(void)transBack:(BOOL)rect
{
    if (rect) {
        _activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        //透明色，并且不影响上面其他控件显示
        _activity.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        _titleLabel.textColor = [UIColor darkGrayColor];
    }
    else{
        _activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        //透明色，并且不影响上面其他控件显示
        _activity.backgroundColor = [UIColor darkGrayColor];
        _titleLabel.textColor = [UIColor whiteColor];
    }
    
}

@end
