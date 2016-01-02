//
//  TimeAxisViewController.h
//  PictureManager
//
//  Created by 蒋尚秀 on 15/12/18.
//  Copyright © 2015年 -JSX-. All rights reserved.
//

#import "BasicViewController.h"
#import "TOSMBClient.h"

@interface TimeAxisViewController : BasicViewController

//连接服务器信息
@property (nonatomic,strong) TOSMBSession * session;
//根目录下的所有文件及文件夹
@property (nonatomic,strong) NSMutableArray * rootFiles;

@end
