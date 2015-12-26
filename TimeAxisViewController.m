//
//  TimeAxisViewController.m
//  PictureManager
//
//  Created by 蒋尚秀 on 15/12/18.
//  Copyright © 2015年 -JSX-. All rights reserved.
//

#import "TimeAxisViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "DayPictureCell.h"

@interface TimeAxisViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    //所有的照片信息 以数组套数组的方式存储
    //小数组中存放每日照片信息
    NSMutableArray * _allPicturesArray;
    //表格视图
    UITableView * _tableView;
}

@end

@implementation TimeAxisViewController

-(id)init
{
    if (self = [super init]) {

    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self createData];
    [self createView];
}

/**
 * 创建主视图
 */
-(void)createView
{
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;

    //分别注册6中cell
    for (int i=1; i<=6; i++) {
        [_tableView registerClass:[DayPictureCell class] forCellReuseIdentifier:[NSString stringWithFormat:@"cellId%d",i]];
    }
    
    //隐藏分割线
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:_tableView];
    
}

/**
 * 测试数据源
 */
-(void)createData
{
    _allPicturesArray = [[NSMutableArray alloc] init];
    
    NSMutableArray * tmpArray = [[NSMutableArray alloc]init];
    for (int i=0; i<6; i++) {
        [tmpArray addObject:@[@"1"]];
        [_allPicturesArray addObject:[tmpArray copy]];
    }
}


#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _allPicturesArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DayPictureCell * cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"cellId%ld",_allPicturesArray.count]];
    
    cell.dayWallPicturesArray = _allPicturesArray[indexPath.row];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DayPictureCell * cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"cellId%ld",_allPicturesArray.count]];
    
    cell.dayWallPicturesArray = _allPicturesArray[indexPath.row];
    
    return cell.cellHeight;
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
