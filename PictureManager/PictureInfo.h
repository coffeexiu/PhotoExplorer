//
//  PictureInfo.h
//  PictureManager
//
//  Created by 蒋尚秀 on 15/12/23.
//  Copyright © 2015年 -JSX-. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PictureInfo : NSObject<NSCoding>

//照片文件名称
@property (nonatomic, copy) NSString * fileName;
//照片所在路径
@property (nonatomic, copy) NSString * filePath;
//照片拍摄时间，当读取不到拍摄时间时，使用创建时间
@property (nonatomic, copy) NSDate * shotDate;
//照片宽度
@property (nonatomic, assign) NSInteger pictureWidth;
//照片高度
@property (nonatomic, assign) NSInteger pictureHeight;
//缩略图数据流
@property (nonatomic, copy) NSData * thumbnailImageData;
//缩略图存储路径
@property (nonatomic, copy) NSString * thumbnailPath;


@end
