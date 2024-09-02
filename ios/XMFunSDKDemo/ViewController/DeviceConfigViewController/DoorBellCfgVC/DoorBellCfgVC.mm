//
//  DoorBellCfgVC.m
//  FunSDKDemo
//
//  Created by Megatron on 2019/8/20.
//  Copyright © 2019 Megatron. All rights reserved.
//

#import "DoorBellCfgVC.h"
#import "NetWorkCfgManager.h"
#import "CapturePriorityManager.h"
#import "StorageSnapshotCfgManager.h"
#import "ForceShutDownManager.h"
#import "NotifyLightManager.h"
#import "DeviceAbilityManager.h"
#import "LeftTextRightTextArrowCell.h"
#import <Masonry/Masonry.h>

static NSString *const kLeftTextRightTextArrowCell = @"kLeftTextRightTextArrowCell";

@interface DoorBellCfgVC () <UICollectionViewDelegate,UICollectionViewDataSource>

//设备能力集管理者
@property (nonatomic,strong) DeviceAbilityManager *deviceAbilityManager;
//录像本地存储管理者
@property (nonatomic,strong) NetWorkCfgManager *netWorkCfgManager;
//拍照优先管理者
@property (nonatomic,strong) CapturePriorityManager *capturePriorityManager;
//拍照本地存储管理者
@property (nonatomic,strong) StorageSnapshotCfgManager *storageSnapshotCfgManager;
//强制关机管理者
@property (nonatomic,strong) ForceShutDownManager *forceShutDownManager;
//设备呼吸灯管理者
@property (nonatomic,strong) NotifyLightManager *notifyLightManager;

//
@property (nonatomic,strong) UICollectionView *listView;
//
@property (nonatomic,strong) NSMutableArray *dataSource;
//
@property (nonatomic,strong) NSMutableDictionary *dicRequestSign;

@end

@implementation DoorBellCfgVC

- (void)readyRequest{
    [self.dicRequestSign removeAllObjects];
    [self.dicRequestSign setObject:@0 forKey:@"NetWorkCfgManager"];
    [self.dicRequestSign setObject:@0 forKey:@"CapturePriorityManager"];
    [self.dicRequestSign setObject:@0 forKey:@"StorageSnapshotCfgManager"];
    [self.dicRequestSign setObject:@0 forKey:@"ForceShutDownManager"];
    [self.dicRequestSign setObject:@0 forKey:@"NotifyLightManager"];
}

- (void)removeRequestSign:(NSString *)sign{
    [self.dicRequestSign removeObjectForKey:sign];
    
    if (self.dicRequestSign.allKeys.count == 0) {
        [SVProgressHUD dismiss];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configSubView];
    
    [self readyRequest];
    __weak typeof(self) weakSelf = self;
    
    [SVProgressHUD show];
    
    [self.deviceAbilityManager getSystemFunctionConfig:^(int result) {
        if (weakSelf.deviceAbilityManager.supportNotifyLight) {
            [weakSelf.notifyLightManager requestNotifyLightCfg:weakSelf.devID completion:^(int result) {
                if (result >= 0) {
                    [weakSelf.listView reloadData];
                    [self removeRequestSign:@"NotifyLightManager"];
                }else{
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%i",result]];
                }
            }];
        }else{
            [self removeRequestSign:@"NotifyLightManager"];
        }
        
        if (weakSelf.deviceAbilityManager.supportForceShutDownControl) {
            [weakSelf.forceShutDownManager requestForceShutDownCfg:weakSelf.devID completion:^(int result) {
                if (result >= 0) {
                    [weakSelf.listView reloadData];
                    [self removeRequestSign:@"ForceShutDownManager"];
                }else{
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%i",result]];
                }
            }];
        }else{
            [self removeRequestSign:@"ForceShutDownManager"];
        }
    }];
    
    [self.netWorkCfgManager requestNetWorkSetEnableVideoCfg:self.devID completion:^(int result) {
        if (result >= 0) {
            [weakSelf.listView reloadData];
            [self removeRequestSign:@"NetWorkCfgManager"];
        }else{
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%i",result]];
        }
    }];
    
    [self.capturePriorityManager requestCapturePriorityCfg:self.devID completion:^(int result) {
        if (result >= 0) {
            [weakSelf.listView reloadData];
            [self removeRequestSign:@"CapturePriorityManager"];
        }else{
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%i",result]];
        }
    }];
    
    [self.storageSnapshotCfgManager requestStorageSnapshotCfg:self.devID completion:^(int result) {
        if (result >= 0) {
            [weakSelf.listView reloadData];
            [self removeRequestSign:@"StorageSnapshotCfgManager"];
        }else{
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%i",result]];
        }
    }];
}

-(void)configNav{
    self.navigationItem.title = TS("DoorBell_Cfg");
    self.navigationItem.titleView = [[UILabel alloc] initWithTitle:self.navigationItem.title name:NSStringFromClass([self class])];
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 0, 32, 32);
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"new_back.png"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(leftBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarBtn = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    
//    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [rightBtn setTitle:TS("ad_save") forState:UIControlStateNormal];
//    rightBtn.frame = CGRectMake(0, 0, 48, 32);
//    [rightBtn addTarget:self action:@selector(rightBtnClicked) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *rightBarBtn = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    
    self.navigationItem.leftBarButtonItem = leftBarBtn;
    //self.navigationItem.rightBarButtonItems = @[rightBarBtn];
}

- (void)leftBtnClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

//MARK: - ConfigSubView
- (void)configSubView{
    [self.view addSubview:self.listView];
    
    [self.listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

//MARK: - Delegate
//MARK: UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *name = [self.dataSource objectAtIndex:indexPath.row];

            LeftTextRightTextArrowCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kLeftTextRightTextArrowCell forIndexPath:indexPath];
            cell.lbLeft.text = name;
            cell.lbRight.text = @"";
    
    if ([name isEqualToString:@"录像本地存储"]) {
        cell.lbRight.text = [self.netWorkCfgManager getNetWorkSetEnableVideoEnabled] ? @"开" : @"关";
    }else if ([name isEqualToString:@"拍照优先"]){
        cell.lbRight.text = [self.capturePriorityManager getCapturePriorityType] == 0 ? @"关":@"自动";
    }else if ([name isEqualToString:@"拍照本地存储"]){
        cell.lbRight.text = [[self.storageSnapshotCfgManager getStorageSnapshotMode] isEqualToString:@"ClosedSnap"] ? @"关" : @"开";
    }else if ([name isEqualToString:@"强制关机"]){
        cell.lbRight.text = [self.forceShutDownManager getForceShutDownMode] == 0 ?  @"不强制关机" : [NSString stringWithFormat:@"%i分钟",[self.forceShutDownManager getForceShutDownMode]];
    }else if ([name isEqualToString:@"设备呼吸灯"]){
        cell.lbRight.text = [self.notifyLightManager getNotifyLightEnabled] ? @"开" : @"关";
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{

    NSString *name = [self.dataSource objectAtIndex:indexPath.row];
    if ([name isEqualToString:@"强制关机"]){
        return self.deviceAbilityManager.supportForceShutDownControl ? CGSizeMake(SCREEN_WIDTH, 50) : CGSizeZero;
    }else if ([name isEqualToString:@"设备呼吸灯"]){
        return self.deviceAbilityManager.supportNotifyLight ? CGSizeMake(SCREEN_WIDTH, 50) : CGSizeZero;
    }else{
        return CGSizeMake(SCREEN_WIDTH, 50);
    }
}

//MAKR: - LazyLoad
- (DeviceAbilityManager *)deviceAbilityManager{
    if (!_deviceAbilityManager) {
        _deviceAbilityManager = [[DeviceAbilityManager alloc] init];
    }
    
    return _deviceAbilityManager;
}

- (NetWorkCfgManager *)netWorkCfgManager{
    if (!_netWorkCfgManager) {
        _netWorkCfgManager = [[NetWorkCfgManager alloc] init];
    }
    
    return _netWorkCfgManager;
}

- (CapturePriorityManager *)capturePriorityManager{
    if (!_capturePriorityManager) {
        _capturePriorityManager = [[CapturePriorityManager alloc] init];
    }
    
    return _capturePriorityManager;
}

- (StorageSnapshotCfgManager *)storageSnapshotCfgManager{
    if (!_storageSnapshotCfgManager) {
        _storageSnapshotCfgManager = [[StorageSnapshotCfgManager alloc] init];
    }
    
    return _storageSnapshotCfgManager;
}

- (ForceShutDownManager *)forceShutDownManager{
    if (!_forceShutDownManager) {
        _forceShutDownManager = [[ForceShutDownManager alloc] init];
    }
    
    return _forceShutDownManager;
}

- (NotifyLightManager *)notifyLightManager{
    if (!_notifyLightManager) {
        _notifyLightManager = [[NotifyLightManager alloc] init];
    }
    
    return _notifyLightManager;
}

- (UICollectionView *)listView{
    if (!_listView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        
        _listView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _listView.backgroundColor = [UIColor whiteColor];
        _listView.delegate = self;
        _listView.dataSource = self;
        [_listView registerClass:[LeftTextRightTextArrowCell class] forCellWithReuseIdentifier:kLeftTextRightTextArrowCell];
    }
    
    return _listView;
}

- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:0];
        [_dataSource addObject:@"录像本地存储"];
        [_dataSource addObject:@"拍照优先"];
        [_dataSource addObject:@"拍照本地存储"];
        [_dataSource addObject:@"强制关机"];
        [_dataSource addObject:@"设备呼吸灯"];
    }
    
    return _dataSource;
}

- (NSMutableDictionary *)dicRequestSign{
    if (!_dicRequestSign) {
        _dicRequestSign = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    
    return _dicRequestSign;
}

@end
