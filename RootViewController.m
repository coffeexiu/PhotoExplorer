//
//  RootViewController.m
//  PictureManager
//
//  Created by 蒋尚秀 on 15/12/18.
//  Copyright © 2015年 -JSX-. All rights reserved.
//

#import "RootViewController.h"
#import "BasicViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createViewControllers];
}
/**
 * 添加各大模块
 */
-(void)createViewControllers
{
    NSArray * classNameArray = @[@"TimeAxisViewController"];
    NSArray * tabBarTitleArray = @[@"时光相册"];
    NSArray * tabBarImageArray = @[@"1-watch"];
    NSArray * navigateBarTitleArray = @[@"时光轴"];
    NSMutableArray * controllersArray = [[NSMutableArray alloc] init];
    
    for(int i=0;i<classNameArray.count;i++)
    {
        Class class = NSClassFromString(classNameArray[i]);
        BasicViewController * bc = [[class alloc]init];
        
        //创建导航控制器
        UINavigationController * nvc = [[UINavigationController alloc] initWithRootViewController:bc];

        nvc.navigationBar.items[0].title = navigateBarTitleArray[i];
        
        nvc.tabBarItem.title = tabBarTitleArray[i];
        nvc.tabBarItem.image = [UIImage imageNamed:tabBarImageArray[i]];
        
        
        [controllersArray addObject:nvc];
    }
    
    self.viewControllers = controllersArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
