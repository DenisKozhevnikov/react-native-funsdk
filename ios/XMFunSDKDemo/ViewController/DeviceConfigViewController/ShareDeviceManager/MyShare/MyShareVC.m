//
//  MyShareVC.m
//  FunSDKDemo
//
//  Created by yefei on 2022/10/22.
//  Copyright © 2022 yefei. All rights reserved.
//

#import "MyShareVC.h"
#import "DeviceShareManager.h"
#import "MyShareListVC.h"

@interface MyShareVC ()

@property (nonatomic,strong) UITableView *myShare;

//分享给我的数据源
@property (nonatomic,strong) NSMutableArray *dataSourceMyShare;
	
//设备分享管理者
@property (nonatomic,strong) DeviceShareManager *deviceShareManager;

@end

@implementation MyShareVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.myShare];
    [self setNaviStyle];
    [self getAllSharedAccountInfo];
    // Do any additional setup after loading the view.
}
//MARK: - LazyLoad
- (UITableView *)myShare{
    if (!_myShare) {
        _myShare = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
        _myShare.delegate = self;
        _myShare.dataSource = self;
        _myShare.rowHeight = 55;
        _myShare.tableFooterView = [[UIView alloc] init];
    }
    
    return _myShare;
}

- (NSMutableArray *)dataSourceMyShare{
    if (!_dataSourceMyShare) {
        _dataSourceMyShare = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _dataSourceMyShare;
}

- (DeviceShareManager *)deviceShareManager{
    if (!_deviceShareManager) {
        _deviceShareManager = [[DeviceShareManager alloc] init];
    }
    
    return _deviceShareManager;
}

//MARK: - Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataSourceMyShare.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellIdentifier"];
    }

    
    NSDictionary *dicInfo = [self.dataSourceMyShare objectAtIndex:indexPath.row];
    NSString *uuid = [dicInfo objectForKey:@"UUID"];
    int userNum = [[dicInfo objectForKey:@"USER_NUM"] intValue];
    
    cell.textLabel.text = uuid;

    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %i %@",TS("TR_Share_User_Count_One"),userNum,TS("TR_Share_User_Count_Two")];
    
    return cell;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dicInfo = [self.dataSourceMyShare objectAtIndex:indexPath.row];
    NSString *uuid = [dicInfo objectForKey:@"UUID"];
    MyShareListVC * vc = [MyShareListVC new];
    vc.devID = uuid;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)getAllSharedAccountInfo{
//    [SVProgressHUD show];
    __weak typeof(self) weakSelf = self;
    [self.deviceShareManager requestSharedDevice:@"" sharedInfo:^(int result, NSArray * _Nonnull sharedList) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (result >= 0) {
                weakSelf.dataSourceMyShare = [[weakSelf analyzeData:sharedList] mutableCopy];
                [weakSelf.myShare reloadData];
                
            }
            
        });
    }];
}

//MARK:解析数据
- (NSMutableArray *)analyzeData:(NSArray *)sharedList{
    NSMutableArray *arrayResult = [NSMutableArray arrayWithCapacity:0];
    NSMutableDictionary *dicResult = [NSMutableDictionary dictionaryWithCapacity:0];
    
    //计算每个设备被分享的用户数量
    for (int i = 0; i < sharedList.count; i++) {
        NSDictionary *dicInfo = [sharedList objectAtIndex:i];
        NSString *uuid = [dicInfo objectForKey:@"uuid"];
        
        if ([dicResult objectForKey:uuid]) {
            int sharedUserNum = [[[dicResult objectForKey:uuid] objectForKey:@"USER_NUM"] intValue] + 1;
            [dicResult setObject:@{@"UUID":uuid,@"USER_NUM":[NSNumber numberWithInt:sharedUserNum]} forKey:uuid];
        }else{
            [dicResult setObject:@{@"UUID":uuid,@"USER_NUM":@1} forKey:uuid];
        }
    }
    
    NSArray *keys = dicResult.allKeys;
    for (int i = 0; i < keys.count; i++) {
        [arrayResult addObject:[dicResult objectForKey:[keys objectAtIndex:i]]];
    }
    
    //按序列号排列
    [arrayResult sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        NSString *uuid1 = [obj1 objectForKey:@"UUID"];
        NSString *uuid2 = [obj2 objectForKey:@"UUID"];
        
        return [uuid1 compare:uuid2];
    }];
    
    return arrayResult;
}

- (void)setNaviStyle {
    self.navigationItem.title = TS("我的分享");
    self.navigationItem.titleView = [[UILabel alloc] initWithTitle:self.navigationItem.title name:NSStringFromClass([self class])];
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
