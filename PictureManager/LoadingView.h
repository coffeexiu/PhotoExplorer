//
//  LoadingView.h
//  Day8-UIActivityIndicatorView
//
//  Created by 蒋尚秀 on 15/12/16.
//  Copyright © 2015年 -JSX-. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingView : UIView

//自己配置的文字
@property (nonatomic,copy) NSString * labelText;
/**
 * 显示阴影层
 */
-(void)showLoadingView;

/**
 * 隐藏阴影层
 */
-(void)hiddenLoadingView;

/**
 * 设置小菊花为深色，小方块透明
 */
-(void)transBack:(BOOL)rect;

@end
