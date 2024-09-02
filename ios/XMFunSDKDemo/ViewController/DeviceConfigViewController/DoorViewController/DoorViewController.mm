//
//  DoorViewController.m
//  FunSDKDemo
//
//  Created by XM on 2019/4/10.
//  Copyright © 2019年 XM. All rights reserved.
//

#import "DoorViewController.h"
#import "DeviceManager.h"
#import "DeviceconfigTableViewCell.h"

#import "DoorUnlockViewController.h" //远程开锁
#import "TempPasswordViewController.h" //临时密码
#import "DoorUserNameViewController.h" //用户名管理
#import "DoorMessageTotalViewController.h" //消息统计
#import "NoDisturbingViewController.h" //免打扰管理
#import "DoorNotificationViewController.h" //推送管理
#import "FlipManager.h"
#import "OneKeyUnlock.h"

@interface DoorViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *devConfigTableView;

@property (nonatomic, strong) NSArray *configTitleArray;

@property (nonatomic, strong) FlipManager *flipManager;
@end

@implementation DoorViewController

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor whiteColor];
    
    [super viewDidLoad];
    //设置导航栏样式
    [self setNaviStyle];
    //初始化数据
    [self initDataSource];
    //配置子视图
    [self configSubView];
    //如果设备(门锁)是在休眠状态，需要先进行唤醒（深度休眠时需要在设备端唤醒）
    [self checkDeviceSleepType];
    //获取翻转信息
    [self.flipManager getFlipInfo];
}

#pragma mark -- UITableViewDelegate/DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.configTitleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DeviceconfigTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[DeviceconfigTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    NSString *detailInfo = [self.configTitleArray[indexPath.row] objectForKey:@"detailInfo"];
    if (detailInfo && detailInfo.length > 0) {
        cell.Labeltext.frame = CGRectMake(64, 9, ScreenWidth - 64, 22);
        cell.detailLabel.hidden = NO;
        cell.Labeltext.text = [self.configTitleArray[indexPath.row] objectForKey:@"title"];
        cell.detailLabel.text = detailInfo;
    }else{
        cell.Labeltext.frame = CGRectMake(64, 18, ScreenWidth - 64, 22);
        cell.detailLabel.hidden = YES;
        cell.Labeltext.text = [self.configTitleArray[indexPath.row] objectForKey:@"title"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *titleStr = [self.configTitleArray[indexPath.row] objectForKey:@"title"];
    if ([titleStr isEqualToString:TS("Unlock")]) { //远程开锁
        DoorUnlockViewController *vc = [[DoorUnlockViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:vc animated:NO];
    }else if ([titleStr isEqualToString:TS("TR_One_Key_Unlock")]) { //一键开锁
        [[OneKeyUnlock shareInstance] oneKeyUnlock];
    }
    else if ([titleStr isEqualToString:TS("Temporary_Password")]) { //临时密码
        TempPasswordViewController *vc = [[TempPasswordViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:vc animated:NO];
    }else if ([titleStr isEqualToString:TS("Door_Lock_PassWord_Manage")]) { //密码用户名管理
        DoorUserNameViewController *vc = [[DoorUserNameViewController alloc] initWithNibName:nil bundle:nil];
        vc.title = titleStr;
        [self.navigationController pushViewController:vc animated:NO];
    }else if ([titleStr isEqualToString:TS("Fingerprint_Manage")]) { //指纹用户名管理
        DoorUserNameViewController *vc = [[DoorUserNameViewController alloc] initWithNibName:nil bundle:nil];
        vc.title = titleStr;
        [self.navigationController pushViewController:vc animated:NO];
    }else if ([titleStr isEqualToString:TS("Door_Card_Manage")]) { //门卡用户名管理
        DoorUserNameViewController *vc = [[DoorUserNameViewController alloc] initWithNibName:nil bundle:nil];
        vc.title = titleStr;
        [self.navigationController pushViewController:vc animated:NO];
    }else if ([titleStr isEqualToString:TS("Message_Statistics")]) { //消息统计开关
        DoorMessageTotalViewController *vc = [[DoorMessageTotalViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:vc animated:NO];
    }else if ([titleStr isEqualToString:TS("No_disturb_manager")]) { //免打扰管理
        NoDisturbingViewController *vc = [[NoDisturbingViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:vc animated:NO];
    }else if ([titleStr isEqualToString:TS("Alarm_message_push")]) { //推送管理
        DoorNotificationViewController *vc = [[DoorNotificationViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:vc animated:NO];
    }
    else if ([titleStr isEqualToString:TS("TR_Flip")]) { //翻转
        //翻转
        [self.flipManager setFlip];
    }
    
}

//休眠中的设备需要先唤醒才能去获取其他配置
- (void)checkDeviceSleepType {
    ChannelObject *object = [[DeviceControl getInstance] getSelectChannel];
    [[DeviceManager getInstance] deviceWeakUp:object.deviceMac];
}
- (UITableView *)devConfigTableView {
    if (!_devConfigTableView) {
        _devConfigTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight -64 ) style:UITableViewStylePlain];
        _devConfigTableView.delegate = self;
        _devConfigTableView.dataSource = self;
        _devConfigTableView.rowHeight = 60;
        [_devConfigTableView registerClass:[DeviceconfigTableViewCell class] forCellReuseIdentifier:@"identifier"];
    }
    return _devConfigTableView;
}
- (void)setNaviStyle {
    self.navigationItem.title = TS("DEV_DOORLOCK");
    self.navigationItem.titleView = [[UILabel alloc] initWithTitle:self.navigationItem.title name:NSStringFromClass([self class])];
}
- (void)configSubView {
    [self.view addSubview:self.devConfigTableView];
}
- (void)initDataSource {
    self.configTitleArray = @[@{@"title":TS("TR_One_Key_Unlock"),@"detailInfo":@""},
                              @{@"title":TS("Unlock"),@"detailInfo":@""},
                              @{@"title":TS("Temporary_Password"),@"detailInfo":@""},
                               @{@"title":TS("Door_Lock_PassWord_Manage"),@"detailInfo":@""},
                               @{@"title":TS("Fingerprint_Manage"),@"detailInfo":@""},
                              @{@"title":TS("Door_Card_Manage"),@"detailInfo":@""},
                              @{@"title":TS("Message_Statistics"),@"detailInfo":TS("Message_Statistics_Tip")},
                              @{@"title":TS("Alarm_message_push"),@"detailInfo":@""},
                              @{@"title":TS("No_disturb_manager"),@"detailInfo":@""},
                              @{@"title":TS("TR_Flip"),@"detailInfo":@""}];
}

-(FlipManager *)flipManager{
    if (!_flipManager) {
        _flipManager = [[FlipManager alloc] init];
        ChannelObject *object = [[DeviceControl getInstance] getSelectChannel];
        _flipManager.devID = object.deviceMac;
    }
    
    return _flipManager;
}
@end
