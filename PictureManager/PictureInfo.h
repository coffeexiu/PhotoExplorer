//
//  PictureInfo.h
//  PictureManager
//
//  Created by 蒋尚秀 on 15/12/23.
//  Copyright © 2015年 -JSX-. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PictureInfo : NSObject

//照片文件名称
@property (nonatomic, copy) NSString * fileName;
//照片所在路径
@property (nonatomic, copy) NSString * filePath;
//照片拍摄时间
@property (nonatomic, copy) NSDate * shotDate;
//照片创建时间
@property (nonatomic, copy) NSDate * createDate;
//照片宽度
@property (nonatomic, assign) NSInteger pictureWidth;
//照片高度
@property (nonatomic, assign) NSInteger pictureHeight;
//缩略图数据流
@property (nonatomic, copy) NSData * thumbnailImageData;

-(id)initWithDictionary:(NSDictionary *)dict;


@end
