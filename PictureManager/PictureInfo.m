//
//  PictureInfo.m
//  PictureManager
//
//  Created by 蒋尚秀 on 15/12/23.
//  Copyright © 2015年 -JSX-. All rights reserved.
//

#import "PictureInfo.h"

@implementation PictureInfo

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _fileName = [aDecoder decodeObjectForKey:@"fileName"];
        _filePath = [aDecoder decodeObjectForKey:@"filePath"];
        _shotDate = [aDecoder decodeObjectForKey:@"shotDate"];
        _pictureHeight = [[aDecoder decodeObjectForKey:@"pictureHeight"] integerValue];
        _pictureWidth = [[aDecoder decodeObjectForKey:@"pictureWidth"] integerValue];
        _thumbnailImageData = [aDecoder decodeObjectForKey:@"thumbnailImageData"];
        _thumbnailPath = [aDecoder decodeObjectForKey:@"thumbnailPath"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_fileName forKey:@"fileName"];
    [aCoder encodeObject:_filePath forKey:@"filePath"];
    [aCoder encodeObject:_shotDate forKey:@"shotDate"];
    [aCoder encodeObject:[NSString stringWithFormat:@"%ld",_pictureWidth] forKey:@"pictureWidth"];
    [aCoder encodeObject:[NSString stringWithFormat:@"%ld",_pictureHeight] forKey:@"pictureHeight"];
    [aCoder encodeObject:_thumbnailImageData forKey:@"thumbnailImageData"];
    [aCoder encodeObject:_thumbnailPath forKey:@"thumbnailPath"];
}


@end
