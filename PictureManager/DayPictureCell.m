//
//  DayPictureCell.m
//  PictureManager
//
//  Created by 蒋尚秀 on 15/12/23.
//  Copyright © 2015年 -JSX-. All rights reserved.
//

#import "DayPictureCell.h"
#import "PictureInfo.h"

#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

@interface DayPictureCell ()

//cell背景图片
@property (nonatomic, strong) UIImageView * backgroundImageView;
//每日照片标题
@property (nonatomic, strong) UILabel * titleLabel;
//当日拍摄日期
@property (nonatomic, strong) UILabel * shotDateLabel;
//分享按钮
@property (nonatomic, strong) UIButton * shareButton;
//打开当日图片集按钮
@property (nonatomic, strong) UIButton * openButton;
//每日精选照片视图控件数组
@property (nonatomic, strong) NSMutableArray * imageViewArray;

@end

@implementation DayPictureCell

#pragma -mark getter方法
//懒加载 重写各个控件的getter方法
-(UIImageView *)backgroundImageView
{
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, WIDTH)];
        
        _backgroundImageView.image = [[UIImage imageNamed:@"DayPictureCellBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
        _backgroundImageView.userInteractionEnabled = YES;
        [self.contentView addSubview:_backgroundImageView];
    }
    return _backgroundImageView;
}

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, WIDTH, 20)];
        _titleLabel.textColor = [UIColor purpleColor];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.text = @"标题";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}
-(UILabel *)shotDateLabel
{
    if (!_shotDateLabel) {
        _shotDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame), WIDTH, 20)];
        _shotDateLabel.textColor = [UIColor darkGrayColor];
        _shotDateLabel.font = [UIFont systemFontOfSize:12];
        _shotDateLabel.text = @"2015-12-25";
        _shotDateLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_shotDateLabel];
    }
    return _shotDateLabel;
}


//重写数据源setter方法
-(void)setDayWallPicturesArray:(NSMutableArray *)dayWallPicturesArray
{
    for (UIImageView * imageView in self.contentView.subviews) {
        if (imageView.tag == 10) {
            [imageView removeFromSuperview];
        }
    }
    _dayWallPicturesArray = dayWallPicturesArray;
    
    _imageViewArray = [[NSMutableArray alloc] init];
    
    NSInteger count = _dayWallPicturesArray.count;
    
    self.backgroundImageView.frame = CGRectMake(0, 0, WIDTH, WIDTH);

    
    for (NSInteger i=0; i<count; i++) {
        UIImageView * view = [[UIImageView alloc] init];
        
        view.backgroundColor = [UIColor colorWithRed:arc4random()%256/255.0 green:arc4random()%256/255.0 blue:arc4random()%256/255.0 alpha:1.0];
        view.tag = 10;
        
        [_imageViewArray addObject:view];
        [self.contentView addSubview:view];
    }
    
    NSInteger LeftMargin = 12;
    
    switch (count) {
        case 1:
            [_imageViewArray[0] setFrame:CGRectMake(LeftMargin, CGRectGetMaxY(self.shotDateLabel.frame), WIDTH-24, WIDTH-24)];
            break;
        case 2:
            [_imageViewArray[0] setFrame:CGRectMake(LeftMargin, CGRectGetMaxY(self.shotDateLabel.frame), (WIDTH-20)/2-5, (WIDTH-20)/2-5)];
            [_imageViewArray[1] setFrame:CGRectMake(CGRectGetMaxX([_imageViewArray[0] frame])+5, CGRectGetMaxY(self.shotDateLabel.frame), (WIDTH-20)/2-5, (WIDTH-20)/2-5)];
            break;
        case 3:
            [_imageViewArray[0] setFrame:CGRectMake(LeftMargin, CGRectGetMaxY(self.shotDateLabel.frame), 2*(WIDTH-20)/3-5, 2*(WIDTH-20)/3-5)];
            [_imageViewArray[1] setFrame:CGRectMake(CGRectGetMaxX([_imageViewArray[0] frame])+5, CGRectGetMaxY(self.shotDateLabel.frame), (WIDTH-20)/3-5, (WIDTH-20)/3-5)];
            [_imageViewArray[2] setFrame:CGRectMake(CGRectGetMaxX([_imageViewArray[0] frame])+5, CGRectGetMaxY([_imageViewArray[1] frame])+5, (WIDTH-20)/3-5, (WIDTH-20)/3-5)];
            break;
        case 4:
            [_imageViewArray[0] setFrame:CGRectMake(LeftMargin, CGRectGetMaxY(self.shotDateLabel.frame), (WIDTH-20)/2-5, (WIDTH-20)/2-5)];
            [_imageViewArray[1] setFrame:CGRectMake(CGRectGetMaxX([_imageViewArray[0] frame])+5, CGRectGetMaxY(self.shotDateLabel.frame), (WIDTH-20)/2-5, (WIDTH-20)/2-5)];
            [_imageViewArray[2] setFrame:CGRectMake(LeftMargin, CGRectGetMaxY([_imageViewArray[0] frame])+5, (WIDTH-20)/2-5, (WIDTH-20)/2-5)];
            [_imageViewArray[3] setFrame:CGRectMake(CGRectGetMaxX([_imageViewArray[2] frame])+5, CGRectGetMaxY([_imageViewArray[1] frame])+5, (WIDTH-20)/2-5, (WIDTH-20)/2-5)];
            break;
        case 5:
            [_imageViewArray[0] setFrame:CGRectMake(LeftMargin, CGRectGetMaxY(self.shotDateLabel.frame), (WIDTH-20)/2-5, (WIDTH-20)/2-5)];
            [_imageViewArray[1] setFrame:CGRectMake(CGRectGetMaxX([_imageViewArray[0] frame])+5, CGRectGetMaxY(self.shotDateLabel.frame), (WIDTH-20)/2-5, (WIDTH-20)/2-5)];
            [_imageViewArray[2] setFrame:CGRectMake(LeftMargin, CGRectGetMaxY([_imageViewArray[0] frame])+5, (WIDTH-35)/3, (WIDTH-35)/3)];
            [_imageViewArray[3] setFrame:CGRectMake(CGRectGetMaxX([_imageViewArray[2] frame])+5, CGRectGetMaxY([_imageViewArray[0] frame])+5, (WIDTH-35)/3, (WIDTH-35)/3)];
            [_imageViewArray[4] setFrame:CGRectMake(CGRectGetMaxX([_imageViewArray[3] frame])+5, CGRectGetMaxY([_imageViewArray[0] frame])+5, (WIDTH-35)/3, (WIDTH-35)/3)];
            break;
        case 6:
            [_imageViewArray[0] setFrame:CGRectMake(LeftMargin, CGRectGetMaxY(self.shotDateLabel.frame), 2*(WIDTH-20)/3-5, 2*(WIDTH-20)/3-5)];
            [_imageViewArray[1] setFrame:CGRectMake(CGRectGetMaxX([_imageViewArray[0] frame])+5, CGRectGetMaxY(self.shotDateLabel.frame), (WIDTH-20)/3-5, (WIDTH-20)/3-5)];
            [_imageViewArray[2] setFrame:CGRectMake(CGRectGetMaxX([_imageViewArray[0] frame])+5, CGRectGetMaxY([_imageViewArray[1] frame])+5, (WIDTH-20)/3-5, (WIDTH-20)/3-5)];
            [_imageViewArray[3] setFrame:CGRectMake(LeftMargin, CGRectGetMaxY([_imageViewArray[0] frame])+5, (WIDTH-35)/3, (WIDTH-35)/3)];
            [_imageViewArray[4] setFrame:CGRectMake(CGRectGetMaxX([_imageViewArray[3] frame])+5, CGRectGetMaxY([_imageViewArray[0] frame])+5, (WIDTH-35)/3, (WIDTH-35)/3)];
            [_imageViewArray[5] setFrame:CGRectMake(CGRectGetMaxX([_imageViewArray[4] frame])+5, CGRectGetMaxY([_imageViewArray[0] frame])+5, (WIDTH-35)/3, (WIDTH-35)/3)];
            break;
            
        default:
            break;
    }
    
    _cellHeight = CGRectGetMaxY([[_imageViewArray lastObject] frame])+40;
    
    self.backgroundImageView.frame = CGRectMake(0, 0, WIDTH, _cellHeight);
    self.titleLabel.text = @"标题";
    self.shotDateLabel.text = @"2015-12-25";
}


//-(void)setDayWallPicturesArray:(NSMutableArray *)dayWallPicturesArray
//{
//    _dayWallPicturesArray = dayWallPicturesArray;
//    
//    //设置时间格式
//    NSDateFormatter * format = [[NSDateFormatter alloc] init];
//    format.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
//    format.dateFormat = @"yyyy-MM-dd";
//    
//    for (PictureInfo * picInfo in _dayWallPicturesArray) {
//        _shotDateLabel.text = [format stringFromDate:picInfo.shotDate];
//    
//        
//    }
//}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
