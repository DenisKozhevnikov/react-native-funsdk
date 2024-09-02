//
//  MyShareListVC.m
//  FunSDKDemo
//
//  Created by yefei on 2022/10/24.
//  Copyright © 2022 yefei. All rights reserved.
//

#import "MyShareListVC.h"
#import "DeviceShareManager.h"
#import "SharePermissionVC.h"

@interface MyShareListVC ()

//已分享用户列表
@property (nonatomic,strong) UITableView *tbSharedList;
//已分享用户数据源
@property (nonatomic,strong) NSMutableArray *dataSourceShared;
//分享管理者
@property (nonatomic,strong) DeviceShareManager *deviceShareManager;


@end

@implementation MyShareListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.tbSharedList];
    [self setNaviStyle];

    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getSharedAccountInfo];

}

//MARK: - LazyLoad
- (DeviceShareManager *)deviceShareManager{
    if (!_deviceShareManager) {
        _deviceShareManager = [[DeviceShareManager alloc] init];
    }
    
    return _deviceShareManager;
}

- (UITableView *)tbSharedList{
    if (!_tbSharedList) {
        _tbSharedList = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
        _tbSharedList.delegate = self;
        _tbSharedList.dataSource = self;
        _tbSharedList.rowHeight = 55;
        _tbSharedList.tableFooterView = [[UIView alloc] init];
        
     
    }
    
    return _tbSharedList;
}


//MARK: - Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    
    return self.dataSourceShared.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dicInfo = [self.dataSourceShared objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellIdentifier"];
    }
    NSString *sharedUserName = [dicInfo objectForKey:@"account"];
    long time = [[dicInfo objectForKey:@"shareTime"] longValue];
    time = (long)(time * 0.001);
    
    cell.textLabel.text = sharedUserName;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *formaterYMD = [[NSDateFormatter alloc] init];
    formaterYMD.dateFormat = @"dd-MM-yyyy";

    NSCalendar *calender = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    [formaterYMD setLocale:[[NSLocale alloc] initWithLocaleIdentifier:calender.locale.localeIdentifier]];
    NSString *ymdStr = [formaterYMD stringFromDate:date];
    int ret = [[dicInfo objectForKey:@"ret"] intValue];
    NSString *acceptDescription;
    if (ret == 0) {
        acceptDescription = TS("TR_Shared_Not_Yet_Accept");
    }else if (ret == 1){
        acceptDescription = TS("TR_Shared_Accpet");
    }else{
        acceptDescription = TS("TR_Shared_Reject");
    }
    cell.detailTextLabel.text = [ymdStr stringByAppendingFormat:@" %@",acceptDescription];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < self.dataSourceShared.count) {
        return YES;
    }
    
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dicInfo = [self.dataSourceShared objectAtIndex:indexPath.row];
    NSString *shareID = [dicInfo objectForKey:@"id"];
    NSArray *arrayPermission = [dicInfo objectForKey:@"permissions"];
    
    
    
    __weak typeof(self) weakSelf = self;
    SharePermissionVC *vc = [[SharePermissionVC alloc] init];
    vc.isModify = YES;

    if (arrayPermission) {
        for (int i = 0; i < arrayPermission.count; i++) {
            NSDictionary *dicP = [arrayPermission objectAtIndex:i];
            NSString *param = [dicP objectForKey:@"label"];
            if ([[dicP objectForKey:@"enabled"] boolValue] && param) {
                if (![vc.selectArray containsObject:param]) {
                    [vc.selectArray addObject:param];
                }
            }
        }
    }
   
    vc.devId = self.devID;
    vc.shareId = shareID;
    [self.navigationController pushViewController:vc animated:YES];

}

//MARK:请求当前设备分享的账号信息
- (void)getSharedAccountInfo{
    [self.deviceShareManager requestSharedDevice:self.devID sharedInfo:^(int result, NSArray * _Nonnull sharedList) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (result >= 0) {
                self.dataSourceShared = [sharedList mutableCopy];
                [self.tbSharedList reloadData];
            }

        });
    }];
}


- (void)setNaviStyle {
    self.navigationItem.title = TS("TR_User_of_shared");
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
