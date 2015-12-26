//
//  DayPictureCell.h
//  PictureManager
//
//  Created by 蒋尚秀 on 15/12/23.
//  Copyright © 2015年 -JSX-. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DayPictureCell : UITableViewCell

//数据源
//每日精选封面照片
@property (nonatomic,strong) NSMutableArray * dayWallPicturesArray;

//返回cell行高
@property (nonatomic,assign) CGFloat cellHeight;


@end
