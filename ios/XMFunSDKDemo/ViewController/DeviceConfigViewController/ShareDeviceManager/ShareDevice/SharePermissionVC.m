//
//  SharePermissionVC.m
//  FunSDKDemo
//
//  Created by yefei on 2022/10/20.
//  Copyright © 2022 yefei. All rights reserved.





#import "SharePermissionVC.h"
#import "ShareDeviceVC.h"
#import "DeviceShareManager.h"

@interface SharePermissionVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *fuctionTable;

@property (nonatomic,strong) NSMutableArray *dataSource;


@property (nonatomic,strong) NSArray *permissionArr;

//分享按钮
@property (nonatomic,strong) UIButton *btnShare;

//分享管理者
@property (nonatomic,strong) DeviceShareManager *deviceShareManager;


@end

@implementation SharePermissionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configSubView];
}


//MARK: - LazyLoad
- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:0];
        _dataSource = @[@"云台",@"对讲",@"本地存储",@"修改设备配置",@"推送",@"查看云视频"];
    }
    
    return _dataSource;
}

- (NSMutableArray *)selectArray{
    if (!_selectArray) {
        _selectArray = [NSMutableArray arrayWithCapacity:0];
        if(_isModify){
            
        }else{
            [_selectArray addObjectsFromArray:@[@"DP_Intercom",@"DP_PTZ",@"DP_LocalStorage"]];
        }
    }
    
    return _selectArray;
}

- (DeviceShareManager *)deviceShareManager{
    if (!_deviceShareManager) {
        _deviceShareManager = [[DeviceShareManager alloc] init];
    }
    
    return _deviceShareManager;
}

//MARK: - UI
- (UITableView *)fuctionTable{
    if (!_fuctionTable) {
        _fuctionTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 20, ScreenWidth, 400) style:UITableViewStylePlain];
        [_fuctionTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellIdentifier"];
        _fuctionTable.delegate = self;
        _fuctionTable.dataSource = self;
        _fuctionTable.rowHeight = 50;
        _fuctionTable.tableFooterView = [[UIView alloc] init];
    
    }
    
    return _fuctionTable;
}

- (UIButton *)btnShare{
    if (!_btnShare) {
        _btnShare = [UIButton buttonWithType:UIButtonTypeSystem];
        _btnShare.frame = CGRectMake(50, ScreenHeight-80, ScreenWidth-100, 60);
        if (_isModify) {
            [_btnShare setTitle:TS("修改") forState:UIControlStateNormal];

        } else {
            [_btnShare setTitle:TS("Shared") forState:UIControlStateNormal];

        }
        [_btnShare setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _btnShare.layer.cornerRadius = 5;
        _btnShare.layer.masksToBounds = YES;
        _btnShare.backgroundColor = [UIColor grayColor];
        [_btnShare addTarget:self action:@selector(btnShareClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _btnShare;
}


- (void)configSubView{

    [self.view addSubview:self.fuctionTable];
    
    [self.view addSubview:self.btnShare];

    [self setNaviStyle];
    
    self.permissionArr = @[@"DP_Intercom",@"DP_PTZ",@"DP_LocalStorage",@"DP_ModifyConfig",@"DP_AlarmPush",@"DP_ViewCloudVideo"];
}


//MARK: - Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier"];
    cell.textLabel.text = self.dataSource[indexPath.row];

    if([self.selectArray containsObject:self.permissionArr[indexPath.row]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;

    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
            
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        if (![self.selectArray containsObject:self.permissionArr[indexPath.row]]) {
            [self.selectArray addObject:self.permissionArr[indexPath.row]];
        }
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
        if ([self.selectArray containsObject:self.permissionArr[indexPath.row]]) {
            [self.selectArray removeObject:self.permissionArr[indexPath.row]];
        }
    }
        
}

- (void)btnShareClicked{
    NSString *permissionList = @"";

    for (NSString * permission in self.selectArray) {
        if (permissionList.length <= 0) {
            permissionList = permission;
        }else{
            permissionList = [permissionList stringByAppendingFormat:@",%@",permission];
        }
    }
    if (_isModify) {
        [self.deviceShareManager changeSharedPermission:permissionList sharedUserID:self.shareId completion:^(int result) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (result >= 0) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            });
        }];
    } else {
       
        ShareDeviceVC *vc = [[ShareDeviceVC alloc] init];
        vc.permissions = permissionList;
        vc.devId = self.devId;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

- (void)setNaviStyle {
    self.navigationItem.title = TS("分享权限(多选)");
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
