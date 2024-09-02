//
//  ShareToMeVC.m
//  FunSDKDemo
//
//  Created by yefei on 2022/10/24.
//  Copyright © 2022 yefei. All rights reserved.
//

#import "ShareToMeVC.h"
#import "DeviceShareManager.h"
#import "GTMNSString+HTML.h"
#import "ShareModel.h"

@interface ShareToMeVC ()


@property (nonatomic,strong) UITableView *shareToMe;

//分享给我的数据源
@property (nonatomic,strong) NSMutableArray *dataSourceShareToMe;
    
//设备分享管理者
@property (nonatomic,strong) DeviceShareManager *deviceShareManager;

//最近一次拒绝或接受的设备序号
@property (nonatomic,assign) int lastOperationIndex;

@end

@implementation ShareToMeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.shareToMe];
    [self getAllSharedAccountInfo];
    [self setNaviStyle];
    
    // Do any additional setup after loading the view.
}

//MARK: - LazyLoad
- (UITableView *)shareToMe{
    if (!_shareToMe) {
        _shareToMe = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
        _shareToMe.delegate = self;
        _shareToMe.dataSource = self;
        _shareToMe.rowHeight = 55;
        _shareToMe.tableFooterView = [[UIView alloc] init];
        
    }
    
    return _shareToMe;
}

- (NSMutableArray *)dataSourceMyShare{
    if (!_dataSourceShareToMe) {
        _dataSourceShareToMe = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _dataSourceShareToMe;
}

- (DeviceShareManager *)deviceShareManager{
    if (!_deviceShareManager) {
        _deviceShareManager = [[DeviceShareManager alloc] init];
    }
    
    return _deviceShareManager;
}

//MARK: - Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataSourceShareToMe.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellIdentifier"];
    }
    
    NSDictionary *dicInfo = [self.dataSourceShareToMe objectAtIndex:indexPath.row];
    NSString *uuid = [dicInfo objectForKey:@"uuid"];
    NSString *shareAccountName = [dicInfo objectForKey:@"account"];
    int ret = [[dicInfo objectForKey:@"ret"] intValue];
    
    NSString *acceptDescription = @"";
    if (ret == 0) {
        acceptDescription = TS("TR_Need_Accept_Share");
    }else if (ret == 1){
        acceptDescription = TS("TR_Shared_Accpet");
    }
    
    cell.textLabel.text = uuid;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@ %@",TS("share_come"),shareAccountName,acceptDescription];
    
    return cell;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dicInfo = [self.dataSourceShareToMe objectAtIndex:indexPath.row];
    NSString *devID = [dicInfo objectForKey:@"id"];
    NSString *uuid = [dicInfo objectForKey:@"uuid"];
    NSString *account = [dicInfo objectForKey:@"account"];
    NSString *strPowers = [dicInfo objectForKey:@"powers"];
    strPowers = [strPowers gtm_stringByUnescapingFromHTML];
    NSString *sharePD = nil;
    NSString *shareUser = nil;
    if (![strPowers isMemberOfClass:[NSNull class]]) {
        NSDictionary *dicPowers = [self dictionaryWithJsonString:strPowers];
        if (dicPowers && [dicPowers objectForKey:@"devInfo"]) {
            NSString *info = [dicPowers objectForKey:@"devInfo"];
            NSArray *arrayInfo = [ShareModel decodeDevInfo:info];
            sharePD = [arrayInfo objectAtIndex:2];
            shareUser = [arrayInfo objectAtIndex:1];
        }
    }
    int ret = [[dicInfo objectForKey:@"ret"] intValue];
    self.lastOperationIndex = (int)indexPath.row;
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    NSMutableAttributedString *alertControllerMessageStr = [[NSMutableAttributedString alloc] initWithString:ret == 1 ? TS("TR_Is_Sure_To_Cancel_Share") : [NSString stringWithFormat:@"%@(%@)%@",TS("TR_Accept_Share_Device_Tip_One"),account,TS("TR_Accept_Share_Device_Tip_Two")]];
    [alertControllerMessageStr addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, alertControllerMessageStr.length)];
    [alertControllerMessageStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(0, alertControllerMessageStr.length)];
    [alertVC setValue:alertControllerMessageStr forKey:@"attributedMessage"];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:TS("cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    UIAlertAction *actionOK = [UIAlertAction actionWithTitle:TS("TR_Accpet") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SVProgressHUD show];
        
        __weak typeof(self) weakSelf = self;
        [self.deviceShareManager acceptShareDeviceID:devID completion:^(int result) {
            if (result >= 0) {
                NSMutableDictionary *dicInfo = [[weakSelf.dataSourceShareToMe objectAtIndex:weakSelf.lastOperationIndex] mutableCopy];
                [dicInfo setObject:@1 forKey:@"ret"];
                [weakSelf.dataSourceShareToMe replaceObjectAtIndex:weakSelf.lastOperationIndex withObject:dicInfo];
                [weakSelf.shareToMe reloadData];
                
                [SVProgressHUD dismiss];
            }else{
                [SVProgressHUD showErrorWithStatus:TS("EE_AS_CHECK_USER_REGISTE_CODE")];
            }
        }];
    }];
    
    UIAlertAction *actionDeny = [UIAlertAction actionWithTitle:ret == 1 ? TS("OK") : TS("TR_Reject") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SVProgressHUD show];
        
        __weak typeof(self) weakSelf = self;
        [self.deviceShareManager denyShareDeviceID:devID completion:^(int result) {
            if (result >= 0) {
                [weakSelf.dataSourceShareToMe removeObjectAtIndex:self.lastOperationIndex];
                [weakSelf.shareToMe reloadData];
                [SVProgressHUD dismiss];
            }else{
                [SVProgressHUD showErrorWithStatus:TS("EE_AS_CHECK_USER_REGISTE_CODE")];
            }
        }];
    }];
    

    [actionDeny setValue:UIColor.redColor forKey:@"titleTextColor"];
    
    if (ret == 1) {
        [alertVC addAction:actionCancel];
        [alertVC addAction:actionDeny];
    }else{
        [alertVC addAction:actionCancel];
        [alertVC addAction:actionOK];
        [alertVC addAction:actionDeny];
    }
    
    [self presentViewController:alertVC animated:YES completion:nil];
    
    
}
//请求数据
- (void)getAllSharedAccountInfo{
    [SVProgressHUD show];
    __weak typeof(self) weakSelf = self;
    [weakSelf.deviceShareManager requestDeviceSharedToMe:^(int result, NSArray * _Nonnull sharedToMeList) {
        if (result >= 0) {
            weakSelf.dataSourceShareToMe = [sharedToMeList mutableCopy];
            [weakSelf.shareToMe reloadData];
        }
        
        [SVProgressHUD dismiss];
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

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }

    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}


- (void)setNaviStyle {
    self.navigationItem.title = TS("分享给我");
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
