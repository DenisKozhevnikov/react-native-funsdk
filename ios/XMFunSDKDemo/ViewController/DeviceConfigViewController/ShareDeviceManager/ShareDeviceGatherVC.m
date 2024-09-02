//
//  ShareDeviceGatherVC.m
//  FunSDKDemo
//
//  Created by yefei on 2022/10/20.
//  Copyright © 2022 yefei. All rights reserved.
//

#import "ShareDeviceGatherVC.h"
#import "SharePermissionVC.h"
#import "MyShareVC.h"
#import "ShareToMeVC.h"
#import "ScanViewController.h"
#import "ShareModel.h"
#import "DeviceShareManager.h"

@interface ShareDeviceGatherVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *gatherList;

@property (nonatomic,strong) NSArray *dataSource;

//分享管理者
@property (nonatomic,strong) DeviceShareManager *deviceShareManager;
@end

@implementation ShareDeviceGatherVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataSource = @[@"分享我的设备",@"我的分享",@"来自分享"];
    [self.view addSubview:self.gatherList];
    [self setNaviStyle];
    
}
//MARK: - LazyLoad
- (UITableView *)gatherList{
    if (!_gatherList) {
        _gatherList = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
        [_gatherList registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellIdentifier"];
        _gatherList.delegate = self;
        _gatherList.dataSource = self;
        _gatherList.rowHeight = 55;
        _gatherList.tableFooterView = [[UIView alloc] init];
        
    }
    
    return _gatherList;
}

- (DeviceShareManager *)deviceShareManager{
    if (!_deviceShareManager) {
        _deviceShareManager = [[DeviceShareManager alloc] init];
    }
    
    return _deviceShareManager;
}

//MARK: - Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier"];
    cell.textLabel.text = self.dataSource[indexPath.row];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == 0){
        SharePermissionVC * vc = [SharePermissionVC new];
        vc.devId = self.devId;
        [self.navigationController pushViewController:vc animated:YES];
    }else if(indexPath.row == 1){
        MyShareVC * vc = [MyShareVC new];
        [self.navigationController pushViewController:vc animated:YES];
    }else {
        ShareToMeVC * vc = [ShareToMeVC new];
        [self.navigationController pushViewController:vc animated:YES];
    }

}


- (void)setNaviStyle {
    self.navigationItem.title = TS("分享管理");
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
