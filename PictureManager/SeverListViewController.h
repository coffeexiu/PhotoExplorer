//
//  SeverListViewController.h
//  PictureManager
//
//  Created by 蒋尚秀 on 15/12/26.
//  Copyright © 2015年 -JSX-. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TOSMBSession;

typedef void(^LoginSucceed)(TOSMBSession * session, NSArray * rootFiles);

@interface SeverListViewController : UIViewController

@property (nonatomic,copy) LoginSucceed longinSucceed;

-(void)setLonginSucceed:(LoginSucceed)longinSucceed;

@end
