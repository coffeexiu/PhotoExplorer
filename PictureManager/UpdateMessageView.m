//
//  UpdateMessageView.m
//  PictureManager
//
//  Created by 蒋尚秀 on 15/12/29.
//  Copyright © 2015年 -JSX-. All rights reserved.
//

#import "UpdateMessageView.h"

#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

@interface UpdateMessageView ()

@property (nonatomic,strong) UILabel * infoLabel;
@property (nonatomic,strong) UIActivityIndicatorView * indicatorView;

@end

@implementation UpdateMessageView


-(id)init
{
    if (self = [super init]) {
        
        self.frame = CGRectMake(0, 64, WIDTH, 22);
        //设置半透明色
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
        
        //添加加载标
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _indicatorView.frame = CGRectMake(0, 0, 22, 22);
        //背景全透明色
        _indicatorView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        [self addSubview:_indicatorView];
        
        _infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_indicatorView.frame)+5, 0, WIDTH-27, 22)];
        _infoLabel.textColor = [UIColor whiteColor];
        _infoLabel.font = [UIFont systemFontOfSize:10];
        _infoLabel.text = @"正在检索照片...";
        _infoLabel.numberOfLines = 2;
        [self addSubview:_infoLabel];
        
    }
    return self;
}

-(void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];

    if (hidden) {
        [_indicatorView stopAnimating];
    }
    else
    {
        [_indicatorView startAnimating];
    }
}

-(void)setUpdateInfo:(NSString *)updateInfo
{
    _infoLabel.text = updateInfo;
}

@end
