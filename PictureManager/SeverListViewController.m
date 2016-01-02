//
//  SeverListViewController.m
//  PictureManager
//
//  Created by 蒋尚秀 on 15/12/26.
//  Copyright © 2015年 -JSX-. All rights reserved.
//

#import "SeverListViewController.h"
#import "TOSMBClient.h"
#import "LoadingView.h"
#import "RootViewController.h"
#import "TimeAxisViewController.h"

@interface SeverListViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) RootViewController * rootViewController;

@property (nonatomic,strong) UITableView * severTableView;
//存放服务器entry
@property (nonatomic,strong) NSMutableArray * severEntryArray;
//第三方库，搜索服务器
@property (nonatomic,strong) TONetBIOSNameService *netbiosService;

//记录当前连接的服务器IP
@property (nonatomic,strong) NSString * currentSeverHostName;

@property (nonatomic,strong) LoadingView * loadingView;

- (void)beginServiceBrowser;

@end

@implementation SeverListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createView];
    
    self.title = @"SMB Devices";
    
    if (self.severEntryArray == nil) {
        self.severEntryArray = [NSMutableArray array];
    }
    //
    _loadingView = [[LoadingView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_loadingView];
    
    [self beginServiceBrowser];
}

-(void)createView
{
    //创建列表
    _severTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _severTableView.delegate = self;
    _severTableView.dataSource = self;
    
    [self.view addSubview:_severTableView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshSeverList:)];
}

//刷新按钮
-(void)refreshSeverList:(UIBarButtonItem *)sender
{
    if (self.netbiosService)
    {
        //停止上次以查找并置空
        [self.netbiosService stopDiscovery];
        self.netbiosService = nil;
        //清空表格视图
        [self.severEntryArray removeAllObjects];
        [self.severTableView reloadData];
    }
    [self beginServiceBrowser];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)beginServiceBrowser
{
    if (self.netbiosService)
        return;

    self.netbiosService = [[TONetBIOSNameService alloc] init];
    [self.netbiosService startDiscoveryWithTimeOut:4.0f added:^(TONetBIOSNameServiceEntry *entry) {
        

            //如果不存在登陆记录，或者保留登陆记录的服务器地址不在当前列表
            //添加服务器
            [self.severEntryArray addObject:entry];
            [self.severTableView reloadData];
            
        
    } removed:^(TONetBIOSNameServiceEntry *entry) {
        [self.severEntryArray removeObject:entry];
        [self.severTableView reloadData];
    }];
}


#pragma mark - Table View -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.severEntryArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = [self.severEntryArray[indexPath.row] name];
    cell.detailTextLabel.text = nil;
    
    return cell;
}

- (void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [self showAlert:self.severEntryArray[indexPath.row]];
    
    //为什么要这么做？
    //    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}

-(void)connectToSever:(TONetBIOSNameServiceEntry *)entry UserName:(NSString *)username Password:(NSString *)password
{
    TOSMBSession *session = [[TOSMBSession alloc] initWithHostName:entry.name ipAddress:entry.ipAddressString];
    session.userName = username;
    session.password = password;
    
    [session requestContentsOfDirectoryAtFilePath:@"/"
                                          success:^(NSArray *files){
                                              
                                              //登陆成功
                                              
                                              _currentSeverHostName = session.hostName;
                                              
                                              //隐藏登陆小菊花
                                              [_loadingView hiddenLoadingView];
                                              
                                              _rootViewController = [[RootViewController alloc] init];
                                              //传值
                                              ((TimeAxisViewController *)((UINavigationController *)_rootViewController.viewControllers[0]).viewControllers[0]).session = session;
                                              ((TimeAxisViewController *)((UINavigationController *)_rootViewController.viewControllers[0]).viewControllers[0]).rootFiles = [NSMutableArray arrayWithArray:files];
                                              
                                              [self.navigationController pushViewController:_rootViewController animated:YES];
                                          }
                                            error:^(NSError *error) {
                                                //重新输入用户名密码
                                                [self showAlert:entry];
                                                [_loadingView hiddenLoadingView];
                                            }];
    
}

-(void)showAlert:(TONetBIOSNameServiceEntry *)entry
{
    if ([entry.name isEqualToString:_currentSeverHostName]) {
        //直接显示
        //有时候界面卡顿，会重复点击，重复添加
        if (self.navigationController.viewControllers.count>1) {
            return;
        }
        [self.navigationController pushViewController:self.rootViewController animated:YES];
        _loadingView.labelText = [NSString stringWithFormat:@"正在进入 %@",entry.name];
        [_loadingView showLoadingView];
        return;
    }
    
    _loadingView.labelText = [NSString stringWithFormat:@"正在登陆 %@",entry.name];
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"登陆:%@",entry.name] message:@"输入用户名及密码" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * loginAction = [UIAlertAction actionWithTitle:@"登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //重新登陆
        [self connectToSever:entry UserName:alertController.textFields[0].text Password:alertController.textFields[1].text];

        [_loadingView showLoadingView];
        
    }];
    
    UIAlertAction * saveAndLoginAction = [UIAlertAction actionWithTitle:@"保存&登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //将主机名以及用户名密码保存到userDefaults中
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary * dic = @{@"username":alertController.textFields[0].text,@"password":alertController.textFields[1].text};
        [userDefaults setObject:dic forKey:entry.name];
        [userDefaults synchronize];
        
        //连击服务器
        [self connectToSever:entry UserName:alertController.textFields[0].text Password:alertController.textFields[1].text];
        
        [_loadingView showLoadingView];
    }];
    
    UIAlertAction * cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"用户名";
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"密码";
        textField.secureTextEntry = YES;
    }];
    
    
    //判断当前服务器 是否已经保存登陆记录
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary * dic = [userDefaults objectForKey:entry.name];
    //如果是自动登陆
    if (dic) {
        
        //取出用户名密码进行自动填写
        alertController.textFields[0].text = [dic objectForKey:@"username"];
        alertController.textFields[1].text = [dic objectForKey:@"password"];
    }

    
    
    [alertController addAction:loginAction];
    [alertController addAction:saveAndLoginAction];
    [alertController addAction:cancleAction];
    
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [_loadingView hiddenLoadingView];
}


-(void)dealloc
{
    if (self.netbiosService)
        [self.netbiosService stopDiscovery];
}

@end
