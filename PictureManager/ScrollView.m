//
//  MainscrollViewView.m
//  PictureManager
//
//  Created by 蒋尚秀 on 15/12/18.
//  Copyright © 2015年 -JSX-. All rights reserved.
//

#import "ScrollView.h"

#define WIDTH self.frame.size.width
#define HEIGHT self.frame.size.height
//DayPictureWallView视图距离屏幕左右边距
#define LEFT_RIGHT_MARGIN 5
//每天DayPictureWallView之间的间距
#define VIEWS_MARGIN 10
//DayPictureWallView的高度
#define VIEW_HEIGHT 300
//顶部背景图片与滚动视图之间的交集高度
#define INTERSECTION 5



@interface ScrollView ()<UIScrollViewDelegate>
{
    //滚动视图
    UIScrollView * _scrollView;
    //顶部背景照片视图
    UIImageView * _backgroundImageView;
    //滚动视图顶部花边视图
    UIImageView * _scrollViewTopImageView;
    //滚动视图背景视图
    UIImageView * _scrollViewBackgroundView;
    
    //用户设置信息
    //背景图片
    NSString * _backgroundImagePath;
}

@end


@implementation ScrollView

-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self readUserSettingsFromFiles];
        [self createView];

    }
    return self;
}

//读取用户设置信息
-(void)readUserSettingsFromFiles
{
    NSUserDefaults * userSettings = [NSUserDefaults standardUserDefaults];
    _backgroundImagePath = [userSettings objectForKey:@"BackgroundImagePath"];
    
}

/**
 * 初始化
 * 创建所有视图资源
 */
-(void)createView
{
    //创建滚动视图
    _scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _scrollView.contentSize = CGSizeMake(WIDTH, 4000);
    
    _scrollView.delegate = self;
    
    //顶部背景图片
    _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, WIDTH)];
    _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    _backgroundImageView.clipsToBounds = YES;
    _backgroundImageView.image = [self backgroundImage];
    
    
    [_scrollView addSubview:_backgroundImageView];
    
    //滚动视图背景图片

    //滚动视图顶边距离
    NSInteger scrollViewTopMargin = WIDTH - INTERSECTION;
    //顶部花边视图
    _scrollViewTopImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, scrollViewTopMargin, WIDTH, VIEWS_MARGIN)];
    //每日照片墙背景视图
    _scrollViewBackgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, scrollViewTopMargin+VIEWS_MARGIN, WIDTH, _scrollView.contentSize.height-WIDTH-VIEWS_MARGIN)];
    _scrollViewBackgroundView.backgroundColor = [UIColor whiteColor];
    //定义花边视图图片
    _scrollViewTopImageView.image = [UIImage imageNamed:@"huaduobg"];
    //设置内容显示模式
//    _scrollViewTopImageView.contentMode = UIViewContentModeScaleAspectFill;
    //添加到视图中
    [_scrollView addSubview:_scrollViewTopImageView];
    [_scrollView addSubview:_scrollViewBackgroundView];
    
//    for (int i=0; i<_viewsArray.count; i++) {
//        DayPictureWallView * dayView = [[DayPictureWallView alloc] initWithFrame:CGRectMake(LEFT_RIGHT_MARGIN, i*VIEW_HEIGHT+VIEWS_MARGIN, WIDTH-2*LEFT_RIGHT_MARGIN, VIEW_HEIGHT)];
//        [_scrollViewTopImageView addSubview:dayView];
//    }
    [self addSubview:_scrollView];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //当下拉滚动视图时，放大顶部背景视图
    if (scrollView.isDragging && scrollView.contentOffset.y<=0) {
        
        //放大顶部背景图片
        _backgroundImageView.transform = CGAffineTransformMakeScale((1-scrollView.contentOffset.y/200), (1-scrollView.contentOffset.y/200)) ;
        
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    _backgroundImageView.transform = CGAffineTransformMakeScale(1, 1) ;
}

//从UserInfo中读取背景图片
-(UIImage *)backgroundImage
{
    if (!_backgroundImagePath) {
        return [UIImage imageNamed:@"DefaultBackgroundImage"];
    }
    else
    {
        return [UIImage imageNamed:_backgroundImagePath];
    }
}


@end
