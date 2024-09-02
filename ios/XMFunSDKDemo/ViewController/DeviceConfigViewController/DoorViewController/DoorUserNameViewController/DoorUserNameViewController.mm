//
//  DoorUserNameViewController.m
//  FunSDKDemo
//
//  Created by XM on 2019/4/11.
//  Copyright © 2019年 XM. All rights reserved.
//

#import "DoorUserNameViewController.h"
#import "ItemTableviewCell.h"
#import "DoorUserNameConfig.h"

@interface DoorUserNameViewController () <UITableViewDelegate,UITableViewDataSource,DoorUserNameDelegate>
{
    DoorUserNameConfig *config; //门锁用户信息
    UITableView *tableView;
}
@property (nonatomic,strong) NSMutableDictionary *dataDic;

@property (nonatomic, strong) NSMutableDictionary *passWordDic; //密码
@property (nonatomic, strong) NSMutableDictionary *fingerDic;//指纹
@property (nonatomic, strong) NSMutableDictionary *cardDic;//门卡

@property (nonatomic, strong) NSMutableArray *adminArray; //管理员
@property (nonatomic, strong) NSMutableArray *forceArray; //
@property (nonatomic, strong) NSMutableArray *generalArray; //普通用户
@property (nonatomic, strong) NSMutableArray *guestArray; //宾客
@property (nonatomic, strong) NSMutableArray *temporaryArray; //临时
@end

@implementation DoorUserNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configSubView];
    // 获取门锁用户信息
    [self getDoorUserNameConfig];
}

- (void)viewWillDisappear:(BOOL)animated{
    //有加载状态、则取消加载
    if ([SVProgressHUD isVisible]){
        [SVProgressHUD dismiss];
    }
}

#pragma mark - 获取门锁用户信息
- (void)getDoorUserNameConfig {
    [SVProgressHUD showWithStatus:TS("")];
    if (config == nil) {
        config = [[DoorUserNameConfig alloc] init];
        config.delegate = self;
    }
    //调用获取门锁用户信息的接口
    [config getDoorUserNameConfig];
}
#pragma mark 获取门锁用户信息代理回调
- (void)DoorUserNameConfigGetResult:(NSInteger)result {
    if (result >0) {
        //成功，刷新界面数据
        self.dataDic = [config getDoorUserInfo];
        [self initDataSource];
        [self.tableView reloadData];
        [SVProgressHUD dismiss];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}

#pragma mark - 保存门锁用户信息（
-(void)saveConfig{
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
    if ([self.title isEqualToString:TS("Door_Lock_PassWord_Manage")]) { //密码管理
        tempDic = self.passWordDic;
    }
     if ([self.title isEqualToString:TS("Fingerprint_Manage")]) { //指纹管理
         tempDic = self.fingerDic;
     }
    if ([self.title isEqualToString:TS("Door_Card_Manage")]) { //指纹管理
        tempDic = self.cardDic;
    }
    if (![[tempDic objectForKey:@"Admin"] isEqual:[NSNull null]]){
        [tempDic setObject:self.adminArray forKey:@"Admin"];
    }
    if (![[tempDic objectForKey:@"Force"] isEqual:[NSNull null]]) {
        [tempDic setObject:self.forceArray forKey:@"Force"];
    }
    if (![[tempDic objectForKey:@"General"] isEqual:[NSNull null]]) {
        [tempDic setObject:self.generalArray forKey:@"General"];
    }
    if (![[tempDic objectForKey:@"Guest"] isEqual:[NSNull null]]) {
        [tempDic setObject:self.guestArray forKey:@"Guest"];
    }
    if (![[tempDic objectForKey:@"Temporary"] isEqual:[NSNull null]]) {
        [tempDic setObject:self.temporaryArray forKey:@"Temporary"];
    }
    
    if ([self.title isEqualToString:TS("Door_Lock_PassWord_Manage")]) { //密码管理
       [self.dataDic setObject:tempDic forKey:@"PassWdManger"];
    }
    if ([self.title isEqualToString:TS("Fingerprint_Manage")]) { //指纹管理
        [self.dataDic setObject:tempDic forKey:@"FingerManger"];
    }
    if ([self.title isEqualToString:TS("Door_Card_Manage")]) { //指纹管理
        [self.dataDic setObject:tempDic forKey:@"CardManger"];
    }

    if (self.dataDic == nil) {
        return;
    }
    [SVProgressHUD show];
    [config setDoorUserName:self.dataDic];
}
#pragma mark 保存门锁临时密码代理回调
- (void)DoorUserNameConfigSetResult:(NSInteger)result {
    if (result >0) {
        //成功
        [SVProgressHUD dismissWithSuccess:TS("Success")];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}

#pragma mark - uitableview datasouse
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
        return self.adminArray.count;
    }
    else if (section == 1){
        return self.forceArray.count;
    }
    else if (section == 2){
        return self.generalArray.count;
    }
    else if (section == 3){
        return self.guestArray.count;
    }
    else if (section == 4){
        return self.temporaryArray.count;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     ItemTableviewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItemTableviewCell"];
    if (!cell) {
        cell = [[ItemTableviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ItemTableviewCell"];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    int num = 0;
    NSMutableDictionary *dic;
    if (indexPath.section == 0) {
        num = (int)indexPath.row;
        dic = [self.adminArray[indexPath.row] mutableCopy];
    }
    else if (indexPath.section == 1){
        num = (int)self.adminArray.count + (int)indexPath.row;
        dic = [self.forceArray[indexPath.row] mutableCopy];
    }
    else if (indexPath.section == 2){
        num = (int)self.adminArray.count + (int)self.forceArray.count + (int)indexPath.row;
        dic = [self.generalArray[indexPath.row] mutableCopy];
    }
    else if (indexPath.section == 3){
        num = (int)self.adminArray.count + (int)self.forceArray.count + (int)self.generalArray.count + (int)indexPath.row;
        dic = [self.guestArray[indexPath.row] mutableCopy];
    }
    else{
        num = (int)self.adminArray.count + (int)self.forceArray.count + (int)self.generalArray.count + (int)self.guestArray.count +(int)indexPath.row;
        dic = [self.temporaryArray[indexPath.row] mutableCopy];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@%d",TS("password"),num + 1];
    cell.Labeltext.text = [dic objectForKey:@"NickName"];
    return cell;
}

#pragma mark - UItableView delegate 单元格点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableDictionary *dic;
    if (indexPath.section == 0) {
        dic = [self.adminArray[indexPath.row] mutableCopy];
    }
    else if (indexPath.section == 1){
        dic = [self.forceArray[indexPath.row] mutableCopy];
    }
    else if (indexPath.section == 2){
        dic = [self.generalArray[indexPath.row] mutableCopy];
    }
    else if (indexPath.section == 3){
        dic = [self.guestArray[indexPath.row] mutableCopy];
    }
    else{
        dic = [self.temporaryArray[indexPath.row] mutableCopy];
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:TS("Change_Name") message:[dic objectForKey:@"NickName"] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmBtn = [UIAlertAction actionWithTitle:TS("OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *devNameNew = alertController.textFields[0].text;
        NSUInteger length = [devNameNew lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        //如果用户名称超出，那么提示
        if (length > 32 || length <= 0) {
            [SVProgressHUD showErrorWithStatus:TS("devname_null")];
            return ;
        }
        [dic setObject:devNameNew forKey:@"NickName"];
        if (indexPath.section == 0) {
            [self.adminArray replaceObjectAtIndex:indexPath.row withObject:dic];
        }
        else if (indexPath.section == 1){
            [self.forceArray replaceObjectAtIndex:indexPath.row withObject:dic];
        }
        else if (indexPath.section == 2){
            [self.generalArray replaceObjectAtIndex:indexPath.row withObject:dic];
        }
        else if (indexPath.section == 3){
            [self.guestArray replaceObjectAtIndex:indexPath.row withObject:dic];
        }
        else{
            [self.temporaryArray replaceObjectAtIndex:indexPath.row withObject:dic];
        }
        
        [self.tableView reloadData];
    }];
    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:TS("Cancel") style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:confirmBtn];
    [alertController addAction:cancelBtn];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
    }];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark  获取到门锁用户信息后处理数据
- (void)initDataSource {
    if (self.dataDic) {
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
        if ([self.title isEqualToString:TS("Door_Lock_PassWord_Manage")]) { //密码管理
            if ([[self.dataDic allKeys] containsObject:@"PassWdManger"]) {
                self.passWordDic = [[self.dataDic objectForKey:@"PassWdManger"] mutableCopy];
                tempDic = self.passWordDic;
            }
        }
        if ([self.title isEqualToString:TS("Fingerprint_Manage")]) { //指纹管理
            if ([[self.dataDic allKeys] containsObject:@"FingerManger"]) {
                self.fingerDic = [[self.dataDic objectForKey:@"FingerManger"] mutableCopy];
                tempDic = self.fingerDic;
            }
        }
        if ([self.title isEqualToString:TS("Door_Card_Manage")]) { //门卡管理
            if ([[self.dataDic allKeys] containsObject:@"CardManger"]) {
                self.cardDic = [[self.dataDic objectForKey:@"CardManger"] mutableCopy];
                tempDic = self.cardDic;
            }
        }
        if (tempDic != nil) {
            if (![[tempDic objectForKey:@"Admin"] isEqual:[NSNull null]]){
                self.adminArray = [[tempDic objectForKey:@"Admin"] mutableCopy];
            }
            if (![[tempDic objectForKey:@"Force"] isEqual:[NSNull null]]) {
                self.forceArray = [[tempDic objectForKey:@"Force"] mutableCopy];
            }
            if (![[tempDic objectForKey:@"General"] isEqual:[NSNull null]]) {
                self.generalArray = [[tempDic objectForKey:@"General"] mutableCopy];
            }
            if (![[tempDic objectForKey:@"Guest"] isEqual:[NSNull null]]) {
                self.guestArray = [[tempDic objectForKey:@"Guest"] mutableCopy];
            }
            if (![[tempDic objectForKey:@"Temporary"] isEqual:[NSNull null]]) {
                self.temporaryArray = [[tempDic objectForKey:@"Temporary"] mutableCopy];
            }
        }
    }
}
#pragma mark - 界面和数据初始化
- (void)configSubView {
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave  target:self action:@selector(saveConfig)];
    self.navigationItem.rightBarButtonItem = rightButton;
    [self.view addSubview:self.tableView];
}
- (UITableView *)tableView {
    if (!tableView) {
        tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 250 ) style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[ItemTableviewCell class] forCellReuseIdentifier:@"ItemTableviewCell"];
    }
    return tableView;
}
-(NSMutableArray *)adminArray{
    if (!_adminArray) {
        _adminArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _adminArray;
}

-(NSMutableArray *)forceArray{
    if (!_forceArray) {
        _forceArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _forceArray;
}

-(NSMutableArray *)generalArray{
    if (!_generalArray) {
        _generalArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _generalArray;
}

-(NSMutableArray *)guestArray{
    if (!_guestArray) {
        _guestArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _guestArray;
}

-(NSMutableArray *)temporaryArray{
    if (!_temporaryArray) {
        _temporaryArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _temporaryArray;
}
@end
