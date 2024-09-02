//
//  ShareDeviceVC.m
//  FunSDKDemo
//
//  Created by yefei on 2022/10/21.
//  Copyright © 2022 yefei. All rights reserved.
//

#import "ShareDeviceVC.h"
#import "QRCodeGenerator.h"
#import "DeviceManager.h"
#import "ShareModel.h"
#import "DeviceShareManager.h"


@interface ShareDeviceVC ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>

//搜索用户输入框
@property (nonatomic,strong) UITextField *tfSearchUser;

@property (nonatomic,strong) UIButton *btnSearch;

//可分享用户列表
@property (nonatomic,strong) UITableView *tbList;

//可分享用户数据源
@property (nonatomic,strong) NSMutableArray *dataSource;

//分享管理者
@property (nonatomic,strong) DeviceShareManager *deviceShareManager;

//已分享用户列表
@property (nonatomic,strong) UITableView *tbSharedList;

//已分享用户数据源
@property (nonatomic,strong) NSMutableArray *dataSourceShared;



@end

@implementation ShareDeviceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self cfgSubviews];
    [self getSharedAccountInfo:NO];
    // Do any additional setup after loading the view.
}

- (void)cfgSubviews{
    [self.view addSubview:self.tfSearchUser];
    [self.view addSubview:self.btnSearch];
    [self.view addSubview:self.tbList];
    [self.view addSubview:self.tbSharedList];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setNaviStyle];
}


//MARK: - LazyLoad

- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _dataSource;
}

- (NSMutableArray *)dataSourceShared{
    if (!_dataSourceShared) {
        _dataSourceShared = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _dataSourceShared;
}

- (DeviceShareManager *)deviceShareManager{
    if (!_deviceShareManager) {
        _deviceShareManager = [[DeviceShareManager alloc] init];
    }
    
    return _deviceShareManager;
}


- (UITextField *)tfSearchUser{
    if (!_tfSearchUser) {
        _tfSearchUser = [[UITextField alloc] init];
        _tfSearchUser.frame = CGRectMake(15, 88, ScreenWidth-30-80, 44);
        _tfSearchUser.delegate = self;
        _tfSearchUser.textColor = [UIColor blackColor];
        _tfSearchUser.placeholder = TS("TR_Please_enter_user_name");
//        [_tfSearchUser addTarget:self action:@selector(textFieldSearchUserDidChanged:) forControlEvents:UIControlEventEditingChanged];
    }
    
    return _tfSearchUser;
}

- (UIButton *)btnSearch{
    if (!_btnSearch) {
        _btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnSearch.frame = CGRectMake(ScreenWidth-30-80+15, 88, 60, 44);
        [_btnSearch addTarget:self action:@selector(btnSearchClicked) forControlEvents:UIControlEventTouchUpInside];
        [_btnSearch setTitle:TS("TR_Search") forState:UIControlStateNormal];
        _btnSearch.titleLabel.font = [UIFont systemFontOfSize:15];
        [_btnSearch setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnSearch setBackgroundColor:[UIColor grayColor]];
    }
    
    return _btnSearch;
}

- (UITableView *)tbList{
    if (!_tbList) {
        _tbList = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.btnSearch.frame), ScreenWidth, 60) style:UITableViewStylePlain];
        _tbList.tag = 101;
//        [_tbList registerClass:[ShareDeviceCell class] forCellReuseIdentifier:kShareDeviceCell];
        [_tbList registerClass:[UITableViewCell class] forCellReuseIdentifier:@"kUITableViewCell"];
        _tbList.delegate = self;
        _tbList.dataSource = self;
        _tbList.tableFooterView = [[UIView alloc] init];
    }
    
    return _tbList;
}

- (UITableView *)tbSharedList{
    if (!_tbSharedList) {
        _tbSharedList = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.tbList.frame)+20, ScreenWidth, 60) style:UITableViewStylePlain];
        _tbSharedList.tag = 102;
        _tbSharedList.delegate = self;
        _tbSharedList.dataSource = self;
        _tbSharedList.rowHeight = 55;
        _tbSharedList.tableFooterView = [[UIView alloc] init];
//        _tbSharedList.hidden = YES;
//        [_tbSharedList addSubview:self.noMessageImageView];
        
    }
    
    return _tbSharedList;
}


//MARK:点击搜索
- (void)btnSearchClicked{
    if (self.tfSearchUser.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:TS("TR_Please_enter_user_name")];
        return;
    }
    
    
//    self.ifSearched = YES;
    
    [SVProgressHUD show];
    [self.tfSearchUser resignFirstResponder];
    [self.deviceShareManager searchUser:self.tfSearchUser.text completion:^(int result, NSArray * _Nonnull users) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            if (users.count <= 0) {
                [SVProgressHUD showErrorWithStatus:TS("用户不存在")];
                [self.dataSource removeAllObjects];
            }else{
                [self.dataSource removeAllObjects];
                self.dataSource = [users mutableCopy];
            }
            
            [self.tbList reloadData];
        });
    }];
}


//MARK: - Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag == 101) {
        return self.dataSource.count;
    }else{
        return self.dataSourceShared.count;
    }
 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == 101) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"kUITableViewCell"];
        NSString *title = [[self.dataSource objectAtIndex:indexPath.row] objectForKey:@"account"];

        cell.textLabel.text = title;
        cell.textLabel.textColor = [UIColor blackColor];
            
        return cell;
        
    }else{
        NSDictionary *dicInfo = [self.dataSourceShared objectAtIndex:indexPath.row];

        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"kTBShareCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"kTBShareCell"];
        }
        NSString *sharedUserName = [dicInfo objectForKey:@"account"];
        long time = [[dicInfo objectForKey:@"shareTime"] longValue];
        time = (long)(time * 0.001);

        cell.textLabel.text = sharedUserName;
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
        NSDateFormatter *formaterYMD = [[NSDateFormatter alloc] init];
        formaterYMD.dateFormat = @"yyyy-MM-dd";
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
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == 102) {
        if (indexPath.row < self.dataSourceShared.count) {
            return YES;
        }
    }

    return NO;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSDictionary *dicInfo = [self.dataSourceShared objectAtIndex:indexPath.row];
        NSString *shareDeviceID = [dicInfo objectForKey:@"id"];
        __weak typeof(self) weakSelf = self;
        [SVProgressHUD show];
        [self.deviceShareManager cancelShareDeviceID:shareDeviceID completion:^(int result) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (result >= 0) {
                    [SVProgressHUD dismiss];
                    [weakSelf.dataSourceShared removeObjectAtIndex:indexPath.row];
                    [self.tbSharedList reloadData];
                }else{
                    [SVProgressHUD showErrorWithStatus:TS("EE_AS_CHECK_USER_REGISTE_CODE")];
                }
            });
        }];
    }
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return TS("TR_Cancel_Share");
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView.tag == 101) {
        if (self.dataSource.count > 0) {
            NSString *userID = [[self.dataSource objectAtIndex:indexPath.row] objectForKey:@"id"];
            NSString *permissions = self.permissions;
            
            [SVProgressHUD show];
            [self.deviceShareManager shareDevice:self.devId toUser:userID permission:permissions comletion:^(int result) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (result >= 0) {
                        [self getSharedAccountInfo:YES];
                    }else{
                        [SVProgressHUD showErrorWithStatus:TS("TR_Share_F")];
                    }
                });
            }];
            
            
        }
    }else if (tableView.tag == 102){
                
        NSDictionary *dicInfo = [self.dataSourceShared objectAtIndex:indexPath.row];
        NSString *shareDeviceID = [dicInfo objectForKey:@"id"];
        __weak typeof(self) weakSelf = self;
        [SVProgressHUD show];
        [self.deviceShareManager cancelShareDeviceID:shareDeviceID completion:^(int result) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (result >= 0) {
                    [SVProgressHUD dismiss];
                    [weakSelf.dataSourceShared removeObjectAtIndex:indexPath.row];
                    [self.tbSharedList reloadData];
                }else{
                    [SVProgressHUD showErrorWithStatus:TS("EE_AS_CHECK_USER_REGISTE_CODE")];
                }
            });
        }];

        
    }
}


//MARK:请求当前设备分享的账号信息
- (void)getSharedAccountInfo:(BOOL)needShowSuccess{
    [SVProgressHUD show];
    [self.deviceShareManager requestSharedDevice:self.devId sharedInfo:^(int result, NSArray * _Nonnull sharedList) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (result >= 0) {
                self.dataSourceShared = [sharedList mutableCopy];
                [self.tbSharedList reloadData];
            }
            
            if (needShowSuccess) {
                [SVProgressHUD showSuccessWithStatus:TS("TR_Share_S")];
            }else{
               [SVProgressHUD dismiss];
            }
        });
    }];
}

- (void)setNaviStyle {
    self.navigationItem.title = TS("分享设备");
    self.navigationItem.titleView = [[UILabel alloc] initWithTitle:self.navigationItem.title name:NSStringFromClass([self class])];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
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
