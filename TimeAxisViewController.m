//
//  TimeAxisViewController.m
//  PictureManager
//
//  Created by 蒋尚秀 on 15/12/18.
//  Copyright © 2015年 -JSX-. All rights reserved.
//

#import "TimeAxisViewController.h"
#import <ImageIO/ImageIO.h>
#import "PictureInfo.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "DayPictureCell.h"
#import "SeverListViewController.h"
#import "UpdateMessageView.h"

#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

@interface UIImage (Scale)
-(UIImage *)transformtoSize:(CGSize)newsize;
@end

@implementation UIImage (Scale)

-(UIImage *)transformtoSize:(CGSize)newsize
{
    // 创建一个bitmap的context
    UIGraphicsBeginImageContext(newsize);
    // 绘制改变大小的图片
    [self drawInRect:CGRectMake(0, 0, newsize.width, newsize.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage *TransformedImg=UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return TransformedImg;
}

@end

@interface TimeAxisViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    BOOL isFindAllPictures;
    NSInteger alreadyDownloadFilesCount;
}
//所有的照片信息 以数组套数组的方式存储
//小数组中存放所有照片信息
@property (nonatomic,strong) NSMutableArray * allPicturesArray;
//存放所有照片路径与0或1的键值对，（存放路径）标记哪些照片已下载，以及（0,1）那些照片服务器上删除了
@property (nonatomic,strong) NSMutableDictionary * allPicturesDic;
//排序后的照片数组，按照每天分组存储
@property (nonatomic,strong) NSMutableArray * sortedPicturesArray;
//存放所有TOSMBSessionFile文件
@property (nonatomic,strong) NSMutableArray * filesArray;
//表格视图
@property (nonatomic,strong) UITableView * tableView;
//更新信息小条
@property (nonatomic,strong) UpdateMessageView * updateView;

@property (nonatomic,strong) NSMutableArray * downloadArray;


@end

@implementation TimeAxisViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //如果为连接服务器，跳转到服务器列表页面
    if (!_session) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //数据源初始化
    [self readExifInfofromFile];
    _filesArray = [[NSMutableArray alloc] init];
    _downloadArray = [[NSMutableArray alloc] init];
    [self createView];
    
    //标记递归查找文件是否结束
    isFindAllPictures = NO;
    //添加数据加载等待视图
    _updateView = [[UpdateMessageView alloc] init];
    _updateView.hidden = NO;
    [self.view addSubview:_updateView];
    
    //这个循环要放在子线程去做
    //循环遍历文件夹
    [self performSelectorInBackground:@selector(traversalFlies) withObject:nil];
    
}

//遍历文件夹
-(void)traversalFlies
{
    for (TOSMBSessionFile * file in _rootFiles) {
        [self findAllPics:file.filePath];
    }
}

//排序数据段
NSComparator comparator = ^(TOSMBSessionFile * file1, TOSMBSessionFile * file2){
    if (file1.creationTime > file2.creationTime) {
        return NSOrderedDescending;
    }
    else if(file1.creationTime < file2.creationTime)
    {
        return NSOrderedAscending;
    }
    
    return NSOrderedSame;
};

-(void)findAllPics:(NSString *)path
{
    static int i=0;
    //开始遍历的文件夹个数
    static int startedDirectories = 0;
    startedDirectories++;
    
    [_session requestContentsOfDirectoryAtFilePath:path success:^(NSArray *files) {
        
        for (TOSMBSessionFile * file in files) {
            if (file.directory==YES) {
                //只要是文件或者目录就加
                [self findAllPics:file.filePath];
            }
            else
            {
                if ([[[file.filePath pathExtension] lowercaseString] isEqualToString:@"jpg"] ||
                    [[[file.filePath pathExtension] lowercaseString] isEqualToString:@"png"] ||
                    [[[file.filePath pathExtension] lowercaseString] isEqualToString:@"bmp"] ||
                    [[[file.filePath pathExtension] lowercaseString] isEqualToString:@"tiff"] ||
                    [[[file.filePath pathExtension] lowercaseString] isEqualToString:@"gif"]) {
                    
                    //如果是没下载过exif信息的文件
                    if (![self isAlreadyDownload:file]) {
                        
                        //下载该文件exif信息
                        [self downloadExif:file];
                        
                        //存放所有需要下载的照片信息
                        [_filesArray addObject:file];
                        i++;
                        _updateView.updateInfo = [NSString stringWithFormat:@"已检索到%d个图片文件",i];
                    }
                }
            }
        }

        //遍历完成的文件夹个数
        static int finishedDirctories = 0;
        finishedDirctories++;
        //开始遍历个数和结束遍历个数相等时，遍历结束
        if (startedDirectories == finishedDirctories) {
            NSLog(@"遍历结束");
            isFindAllPictures = YES;
        }
    } error:^(NSError *error) {
        NSLog(@"获取文件目录失败");
    }];
    
}

//下载exif全部结束
-(void)downloadExifComplited
{
    //下载完成后续工作
    //1.删除所有服务器中不存在的文件
    for (PictureInfo * info in _allPicturesArray) {
        //移除所有标记为0的图片
        if ([_allPicturesDic[info.filePath] isEqualToString:@"0"]) {
            [_allPicturesDic removeObjectForKey:info.filePath];
            [_allPicturesArray removeObject:info];
            
            //获得拍摄时间作为Key值
            NSString * key = [self formatDateStringWithDate:info.shotDate];
            //遍历照片数组 以天位单位
            for (NSInteger i=0; i<_sortedPicturesArray.count; i++)
            {
                NSMutableDictionary * dayDic = _sortedPicturesArray[i];
                if([dayDic.allKeys[0] isEqualToString:key])
                {
                    
                    NSMutableArray * selectedArray = dayDic[key][@"SELECTEDARRAY"];
                    NSMutableDictionary * selectedDic = dayDic[key][@"SELECTEDDIC"];
                    NSMutableArray * otherArray = dayDic[key][@"OTHERARRAY"];
                    NSMutableDictionary * otherDic = dayDic[key][@"OTHERDIC"];
                   
                    if (!selectedDic[info.filePath])
                    { //如果在SELECTED里面
                       //在selectedDic里拿到sesectedArray里要删除的Index
                        NSInteger deleteIndex = [selectedDic[info.filePath] integerValue];
                        //在sesectedArray删除该照片
                        [selectedArray removeObjectAtIndex:deleteIndex];
                        
                        //在sesectedArray中删除的照片以下的照片的index-1
                        for (NSInteger i = deleteIndex;i<selectedArray.count;i++)
                        {
                            selectedDic[((PictureInfo *)selectedArray[i]).filePath] = @(i-1);
                        }
                    }
                    else
                    {//如果不在SELECTED里面
                        //在otherDic里拿到otherArray里要删除的Index
                        NSInteger deleteIndex = [otherDic[info.filePath] integerValue];
                        //在otherArray删除该照片
                        [otherArray removeObjectAtIndex:deleteIndex];
                        
                        //在otherArray中删除的照片以下的照片的index-1
                        for (NSInteger i = deleteIndex;i<otherArray.count;i++)
                        {
                            otherDic[((PictureInfo *)otherArray[i]).filePath] = @(i-1);
                        }
                        
                    }
                    
                    //for (NSInteger i=0;i<selectedArray.count;i++) {
//                        if ([[selectedArray[i] filePath] isEqualToString:info.filePath]) {
//                            [selectedArray removeObjectAtIndex:i];
//                            
//                            return;
//                        }
//                    }
                    
                    //若未在精选中找到 遍历其余所有照片
//                    NSMutableArray * otherArray = dayDic[key][@"OTHER"];
//                    for(NSInteger i=0;i<otherArray.count;i++)
//                    {
//                        if ([[otherArray[i] filePath] isEqualToString:info.filePath]) {
//                            [otherArray removeObjectAtIndex:i];
//                            return;
//                        }
//                    }
                    //return;
                }
            }
            
            
        }
    }
    //2.排序并重新组织和存储数据，便于显示
    
}

-(void)addPicturesToSortedDic:(PictureInfo *)info
{
    if (!info.shotDate) {
        
    }
    NSString * key = [self formatDateStringWithDate:info.shotDate];
    //取出每日照片
    for(NSInteger i=0;i<_sortedPicturesArray.count;i++)
    {
        NSMutableDictionary * dayDic = _sortedPicturesArray[i];
        if ([dayDic.allKeys[0] isEqualToString:key]) {
            NSMutableArray * selectedArray = dayDic[key][@"SELECTEDARRAY"];
            NSMutableDictionary * selectedDic = dayDic[key][@"SELECTEDDIC"];
            if (selectedArray.count<6) {
                //添加到selectedArray
                [selectedArray addObject:info];
                [selectedDic setObject:@(selectedArray.count-1) forKey:info.filePath];
                return;
            }
            else
            {
                NSMutableArray * otherArray = dayDic[key][@"OTHERARRAY"];
                NSMutableDictionary * otherDic = dayDic[key][@"OTHERDIC"];
                //添加到otherArray
                BOOL isInserted = NO;
                for (NSInteger j=0; j<otherArray.count; j++) {
                    if ([otherArray[j] shotDate] < info.shotDate) {
                        [otherArray insertObject:info atIndex:j];
                        [otherDic setObject:@(j) forKey:info.filePath];
                        isInserted = YES;
                        j++;
                    }
                    if (isInserted) {
                        otherDic[((PictureInfo *)otherArray[j]).filePath] = @(j);
                    }
                    
                }
                return;
            }
        }
    }
    
    //没有当日照片
    NSMutableDictionary * selectedDic = [[NSMutableDictionary alloc] init];
    NSMutableArray * selectedArray = [[NSMutableArray alloc] init];
    [selectedArray addObject:info];
    [selectedDic setObject:@(0) forKey:info.filePath];
    NSMutableArray * otherArray = [[NSMutableArray alloc] init];
    NSMutableDictionary * otherDic = [[NSMutableDictionary alloc] init];
    NSMutableDictionary * bothDic = [[NSMutableDictionary alloc] init];
    [bothDic setObject:selectedArray forKey:@"SELECTEDARRAY"];
    [bothDic setObject:selectedDic forKey:@"SELECTEDDIC"];
    [bothDic setObject:otherArray forKey:@"OTHERARRAY"];
    [bothDic setObject:otherDic forKey:@"OTHERDIC"];
    NSMutableDictionary * dayDic = [[NSMutableDictionary alloc] init];
    [dayDic setObject:bothDic forKey:key];

    //加入_sortedArray
    //数组为空，直接add
    if (_sortedPicturesArray.count==0) {
        [_sortedPicturesArray addObject:dayDic];
        return;
    }
    int i = 0;
    for (NSDictionary * dic in _sortedPicturesArray) {
        if ([key compare:dic.allKeys[0]]>0) {
            [_sortedPicturesArray insertObject:dayDic atIndex:i];
            return;
        }
        i++;
    }
    //最早日期的一天
    [_sortedPicturesArray addObject:dayDic];
}


//返回2015-12-02这种格式的字符串
-(NSString *)formatDateStringWithString:(NSString *)dateStr
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];//设置时区
    [formatter setTimeZone:timeZone];
    NSDate * date = [formatter dateFromString:dateStr];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    return [formatter stringFromDate:date];
}

-(NSString *)formatDateStringWithDate:(NSDate *)date
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [formatter stringFromDate:date];
}

//判断沙盒中是否已经存在当前照片的exif信息
-(BOOL)isAlreadyDownload:(TOSMBSessionFile *)file
{
    if ([_allPicturesDic objectForKey:file.filePath]) {
        //遍历到的文件说明服务器端还存在，所以置为1，当所有服务器端的文件都下载完成后，删除标志是0的所有文件
        [_allPicturesDic setObject:@"1" forKey:file.filePath];
        return YES;
    }
    return NO;
}

//下载exif信息
-(void)downloadExif:(TOSMBSessionFile *)file
{
    TOSMBExifDownloadTask * downloadTask = [_session downloadExifForFileAtPath:file.filePath destinationPath:nil
    progressHandler:^(uint64_t totalBytesWritten, uint64_t totalBytesExpected)
    {
        NSLog(@"%f", (CGFloat)totalBytesWritten / (CGFloat) totalBytesExpected);
    }
    completionHandler:^(PictureInfo *pictureInfo)
    {
        //记录已下载的文件个数
        static int i = 0;
        i++;
        //更新显示信息
        _updateView.updateInfo = [NSString stringWithFormat:@"已完成%d/%ld,剩余%ld分%.0f秒",i,_filesArray.count,(_filesArray.count-i)/250,((_filesArray.count-i)%250/250.0)*60];
        //将下载解析完成的照片文件添加到数组中
        [_allPicturesDic setObject:@"1" forKey:pictureInfo.filePath];
        //将缩略图信息写入文件
        if (pictureInfo.thumbnailImageData && pictureInfo.thumbnailImageData.length>0) {
            
            NSString * tmpPath = [pictureInfo.filePath substringToIndex:pictureInfo.filePath.length-pictureInfo.fileName.length-1];
            NSString * exifPath = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:_session.hostName] stringByAppendingPathComponent:@"EXIF"] stringByAppendingPathComponent:tmpPath];
            
            NSFileManager * manager = [NSFileManager defaultManager];
            BOOL rect = [manager createDirectoryAtPath:exifPath withIntermediateDirectories:YES attributes:nil error:nil];
            if (rect) {
                NSString * destinationPath = [exifPath stringByAppendingPathComponent:pictureInfo.fileName];
                
                [pictureInfo.thumbnailImageData writeToFile:destinationPath atomically:YES];
                
                pictureInfo.thumbnailImageData = nil;
                
                pictureInfo.thumbnailPath = destinationPath;
            }
        }
        else
        {
            [self downloadImageFile:pictureInfo];
        }
        [_allPicturesArray addObject:pictureInfo];
        [self addPicturesToSortedDic:pictureInfo];
        
        //每下载100张照片，保存到沙盒，并刷新界面
        if (_allPicturesDic.count-alreadyDownloadFilesCount>=10) {
            [self writeExifInfoToFile];
            //记录已写入沙盒的文件个数
            alreadyDownloadFilesCount = _allPicturesDic.count;
            [self.tableView reloadData];
        }
        
        //所有文件下载完成
        if (isFindAllPictures && i==_filesArray.count) {
            NSLog(@"所有文件下载完成");
            alreadyDownloadFilesCount = _allPicturesDic.count;
            [self.tableView reloadData];
            //后续工作
            [self downloadExifComplited];
        }
    }
    failHandler:^(NSError *error)
    {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
    [downloadTask resume];
}

#pragma -mark exif文件读写

//从文件中读取上次下载exif信息
-(void)readExifInfofromFile
{
    //读取exif
    NSString * infoPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:_session.hostName] stringByAppendingPathComponent:@"INFO"];
    NSString * allInfoPath = [infoPath stringByAppendingPathComponent:@"AllPicturesInfo"];
    
    NSData * data = [NSData dataWithContentsOfFile:allInfoPath];
    if (data) {
    
        _allPicturesArray = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
        alreadyDownloadFilesCount = _allPicturesArray.count;
        
        //读取标记
        NSString * pathDic = [infoPath stringByAppendingPathComponent:@"AllPicturesSign"];
        
        _allPicturesDic = [NSMutableDictionary dictionaryWithContentsOfFile:pathDic];
        //将所有value都置为0
        for (int i=0;i<_allPicturesDic.count;i++) {
            [_allPicturesDic setObject:@"0" forKey:_allPicturesDic.allKeys[i]];
        }
        //读取排序结构
        NSString * pathSorted = [infoPath stringByAppendingPathComponent:@"SortedPictures"];
        
        NSData * sortedData = [NSData dataWithContentsOfFile:pathSorted];
        _sortedPicturesArray = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:sortedData]];
    }
    else
    {
        _allPicturesArray = [[NSMutableArray alloc] init];
        _allPicturesDic = [[NSMutableDictionary alloc] init];
        _sortedPicturesArray = [[NSMutableArray alloc] init];
        alreadyDownloadFilesCount = 0;
    }
    
}

//将获取到exif头的文件信息保存到沙盒中
-(void)writeExifInfoToFile
{
    //存储标记
    NSString * infoPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:_session.hostName] stringByAppendingPathComponent:@"INFO"];
    
    NSString * dicPath = [infoPath stringByAppendingPathComponent:@"AllPicturesSign"];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    BOOL rect = [fileManager createDirectoryAtPath:infoPath withIntermediateDirectories:YES attributes:nil error:nil];
    if (rect) {
        [_allPicturesDic writeToFile:dicPath atomically:YES];
        
        //存储exif
        NSString * allInfoPath = [infoPath stringByAppendingPathComponent:@"AllPicturesInfo"];
        BOOL rect = [NSKeyedArchiver archiveRootObject:_allPicturesArray toFile:allInfoPath];
        if (rect) {
            NSLog(@"%ld条数据保存成功",_allPicturesArray.count);
        }
        else
        {
            NSLog(@"数据保存失败:%ld",_allPicturesArray.count);
        }
        
    }
    
    //存储sortArray
    [self writeSortedArrayToFile];
}

-(void)writeSortedArrayToFile
{
    //存储sortArray
    NSString * sortedPath = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:_session.hostName] stringByAppendingPathComponent:@"INFO"] stringByAppendingPathComponent:@"SortedPictures"];
    
    [NSKeyedArchiver archiveRootObject:_sortedPicturesArray toFile:sortedPath];
}

#pragma -mark -创建视图

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
    
    //左上角设置按钮
    UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [button setTitle:@"选择" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(changeSever:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
}

//显示展示服务器连接列表
-(void)changeSever:(UIButton *)sender
{
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _sortedPicturesArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DayPictureCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellId1"];
    
    NSDictionary * dayDictionay = _sortedPicturesArray[indexPath.row];
    
    cell.dayWallPicturesArray = dayDictionay[dayDictionay.allKeys[0]][@"SELECTEDARRAY"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
   
//    NSLog(@"-----------即将出现的行：%ld",indexPath.row);
//    NSMutableArray * threeDaysArray = [[NSMutableArray alloc] init];
//    //即将出现的cell
//    NSDictionary * willDisplayDictionary = _sortedPicturesArray[indexPath.row];
//    NSArray * willDisplayArray = willDisplayDictionary[willDisplayDictionary.allKeys[0]][@"SELECTEDARRAY"];
//    
//    [threeDaysArray addObject:willDisplayArray];
//    
//    //即将出现cell的下面一个cell
//    if (indexPath.row+1<_sortedPicturesArray.count) {
//        NSDictionary * downDictionary = _sortedPicturesArray[indexPath.row+1];
//        NSArray * downArray = downDictionary[downDictionary.allKeys[0]][@"SELECTEDARRAY"];
//        [threeDaysArray addObject:downArray];
//    }
//    //即将出现cell的上面一个cell
//    if (indexPath.row-1>=0) {
//        NSDictionary * upDictionary = _sortedPicturesArray[indexPath.row-1];
//        NSArray * upArray = upDictionary[upDictionary.allKeys[0]][@"SELECTEDARRAY"];
//        [threeDaysArray addObject:upArray];
//    }
//    
//    //将三天的照片加入到下载队列
//    [self downloadWithThreeDaysPicture:threeDaysArray];
    
}

//当前关注的照片和 前一天 后一天的照片
-(void)downloadWithThreeDaysPicture:(NSArray *)array;
{
    for (NSArray * dayArray in array) {
        for (PictureInfo * info in dayArray) {
            //照片没有缩略图信息 前往下载（或者从文件制作）
            if (![self isExistThumbnailFile:info]) {
                //下载文件
                [self downloadImageFile:info];
            }
        }
    }
}

-(BOOL)isExistThumbnailFile:(PictureInfo *)info
{
    if ( info.thumbnailPath && ![info.thumbnailPath isEqualToString:@""]) {
        NSFileManager * manager = [NSFileManager defaultManager];
        if ([manager fileExistsAtPath:info.thumbnailPath]) {
            return YES;
        }
    }
    return NO;
}

//下载图片 并处理缩略图信息
-(void)downloadImageFile:(PictureInfo *)info
{
    static int count = 0;
    //拼接存储下载后文件的路径
    NSArray * array = [info.filePath componentsSeparatedByString:@"/"];
    NSString * tmpPath = [info.filePath substringToIndex:info.filePath.length-[[array lastObject] length]];
    //拼接与原服务器中目录一致的多级目录
    NSString * destinationDir = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:_session.hostName] stringByAppendingPathComponent:@"PIC"] stringByAppendingString:tmpPath];
    //创建目录结构
    NSFileManager * manager = [NSFileManager defaultManager];
    BOOL rect = [manager createDirectoryAtPath:destinationDir withIntermediateDirectories:YES attributes:nil error:nil];
    if (rect) {
        
        //下载完成后的文件的存放地址

        NSString * destinationFilePath = [destinationDir stringByAppendingString:[array lastObject]];
        
        //查看本地是否已经有下载文件
        if ([manager fileExistsAtPath:destinationFilePath]) {
            //如果文件已经存在 计算并存储缩略图
            [self writeThumbnail:destinationFilePath andWithCount:count];
            count++;
            if(count==10)
            {
                //累计10个未写入文件的缩略图 写入文件
                [self writeSortedArrayToFile];
                count = 0;
            }
//            [self.tableView reloadData];
            //从本地文件制作 无需下载 直接返回
            return;
            
        }
        NSLog(@"%ld",_session.downloadTasks.count);
        for (TOSMBSessionDownloadTask * task in _session.downloadTasks) {
            if ([task.destinationFilePath isEqualToString:destinationFilePath]) {
                //已经在下载了 不要重复下载
                return;
            }
        }
        //下载任务设置
        TOSMBSessionDownloadTask * downloadTask = [_session downloadTaskForFileAtPath:info.filePath destinationPath:destinationFilePath progressHandler:^(uint64_t totalBytesWritten, uint64_t totalBytesExpected) {
            
        } completionHandler:^(NSString *filePath) {
            
            [self writeThumbnail:filePath andWithCount:count];
            
        } failHandler:^(NSError *error) {
            //下载失败
            NSLog(@"下载失败：%@",error);
        }];
        //开始下载
        [downloadTask resume];
    }
    
}

//将缩略图写入本地文件
-(NSString *)writeThumbnailToFile:(NSString *)filePath
{
    
    UIImage * image = [UIImage imageWithContentsOfFile:filePath];
    
    int maxWidth = image.size.width > image.size.height ? image.size.width : image.size.height;
    
    float scale = 200.0/maxWidth;
    
//    UIImage * imageScale = [image transformtoSize:CGSizeMake(image.size.width*scale, image.size.height*scale)];
    
    NSData * data = UIImageJPEGRepresentation(image, scale);
    
    NSArray * array = [filePath componentsSeparatedByString:[_session.hostName stringByAppendingPathComponent:@"PIC"]];
    
    NSString * fileName = [[array[1] componentsSeparatedByString:@"/"] lastObject];
    
    NSString * tmpPath = [array[1] substringToIndex:[array[1] length]-fileName.length];
    
    NSString * thumbnailPath = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:_session.hostName] stringByAppendingPathComponent:@"EXIF"] stringByAppendingPathComponent:tmpPath];
    
    NSFileManager * manager = [NSFileManager defaultManager];
    BOOL rect = [manager createDirectoryAtPath:thumbnailPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    if (rect) {
        
        NSString * thumbnailFilePath = [thumbnailPath stringByAppendingPathComponent:fileName];
        [data writeToFile:thumbnailFilePath atomically:YES];
        return thumbnailFilePath;
    }
    
    return nil;
}

-(void)writeThumbnail:(NSString *)filePath andWithCount:(NSInteger)count
{
    //为了获取拍摄日期 首先要获取exif头信息
    //获取exif头信息的准备工作
    NSURL * url = [NSURL fileURLWithPath:filePath];
    CGImageSourceRef imageRef = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
    NSDictionary * imageProperty = (__bridge NSDictionary*)CGImageSourceCopyPropertiesAtIndex(imageRef, 0, NULL);
    //获取exif头信息
    NSDictionary * exifDic = imageProperty[(NSString *)kCGImagePropertyExifDictionary];
    
    //获得拍摄时间
    NSString * dateStr = exifDic[@"DateTimeOriginal"];
    //获得作为key值的日期格式字符串
    NSString * key = [self formatDateStringWithString:dateStr];
    //如果exif信息中拍摄日期获取失败 获取文件创建日期
    if (!dateStr || [dateStr isEqualToString:@""]) {
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSDictionary *fileAttributes =[fileManager attributesOfItemAtPath:filePath error:nil];
        NSDate *createDate = (NSDate*)[fileAttributes objectForKey: NSFileCreationDate];
        
        key = [self formatDateStringWithDate:createDate];
        if (!dateStr || [dateStr isEqualToString:@""]) {
            
        }
    }
    
    //获得作为key值的短路径
    NSString * subPath = [filePath componentsSeparatedByString:[_session.hostName stringByAppendingPathComponent:@"PIC"]][1];
    
    //遍历每一天的照片数组
    for (NSDictionary * dic in _sortedPicturesArray) {
        if ([dic.allKeys[0] isEqualToString:key]) {
            NSMutableDictionary * selectedDic = dic[key][@"SELECTEDDIC"];
            NSMutableArray * selectedArray = dic[key][@"SELECTEDARRAY"];
            //在SELECTED数组中找到该文件
            if (selectedDic[subPath]) {
                PictureInfo * info = selectedArray[[selectedDic[subPath] integerValue]];
                //将缩略图存到沙盒 并将缩略图路径写入_sortedArray
                info.thumbnailPath = [self writeThumbnailToFile:filePath];
                //记录当前缩略图未写入文件的个数 当达到10个时一并写入
                count++;
                if (count==10) {
                    count=0;
                    [self writeSortedArrayToFile];
                }
                //刷新表格
                [self.tableView reloadData];
                return;
            }
            else
            {
                NSMutableDictionary * otherDic = dic[key][@"OTHERDIC"];
                NSMutableArray * otherArray = dic[key][@"OTHERARRAY"];
                //在OTHER数组中找到该文件
                if (otherDic[subPath]) {
                    PictureInfo * info = otherArray[[otherDic[subPath] integerValue]];
    
                    //将缩略图存到沙盒 并将缩略图路径写入_sortedArray
                    info.thumbnailPath = [self writeThumbnailToFile:filePath];

                    //记录当前缩略图未写入文件的个数 当达到10个时一并写入
                    count++;
                    if (count==10) {
                        count=0;
                        [self writeSortedArrayToFile];
                    }
                    //刷新表格
                    [self.tableView reloadData];
                }
            }
            
        }
        
    }
}




-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //如果这个cell里面的照片有正在下载的，就删除下载任务
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DayPictureCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellId1"];
    
    NSDictionary * dayDictionay = _sortedPicturesArray[indexPath.row];
    
    NSString * shotDate = dayDictionay.allKeys[0];
    cell.dayWallPicturesArray = dayDictionay[shotDate][@"SELECTEDARRAY"];
    
    return cell.cellHeight;
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
