//
//  AlarmMessageViewController.m
//  FunSDKDemo
//
//  Created by wujiangbo on 2018/12/1.
//  Copyright © 2018 wujiangbo. All rights reserved.
//

#import "AlarmMessageViewController.h"
#import "AlarmMessageCell.h"
#import "AlarmMessageConfig.h"
#import "AlarmMessageInfo.h"
#import <Masonry/Masonry.h>
#import "AlarmMessagePicViewController.h"

@interface AlarmMessageViewController ()<UITableViewDelegate,UITableViewDataSource,AlarmMessageCellDelegate,AlarmMessageConfigDelegate>
{
    NSMutableArray *messageArray;                   // 消息数组
    BOOL isEdit;//是否是编辑状态
}
@property (nonatomic,strong)UITableView *messageTableV;     //消息列表
@property (nonatomic,strong)AlarmMessageConfig *config;     //消息管理器
@property (nonatomic,strong)UIView *toolView;               //下方工具栏
@property (nonatomic,strong)UIButton *cancelBtn;            //取消按钮
@property (nonatomic,strong)UIButton *selectAllBtn;         //全选按钮
@property (nonatomic,strong)UIButton *deleteBtn;            //删除按钮

@end

@implementation AlarmMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    isEdit = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    //设置导航栏样式
    [self setNaviStyle];
    
    //数据初始化
    self.config = [[AlarmMessageConfig alloc] init];
    self.config.delegate = self;
    [self.view addSubview:self.messageTableV];
    [self.view addSubview:self.toolView];
    [self.toolView addSubview:self.cancelBtn];
    [self.toolView addSubview:self.deleteBtn];
    [self.toolView addSubview:self.selectAllBtn];
    
    //布局
    [self configSubviews];
    
    //获取推送消息列表
    [self.config searchAlarmInfo];
}

- (void)setNaviStyle {
    self.navigationItem.title = TS("Alarm_message_push");
    self.navigationItem.titleView = [[UILabel alloc] initWithTitle:self.navigationItem.title name:NSStringFromClass([self class])];
    
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"new_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController)];
    self.navigationItem.leftBarButtonItem = leftBtn;
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle:TS("Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editAction)];
    self.navigationItem.rightBarButtonItem = rightBtn;
}

-(void)configSubviews{
    [self.messageTableV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(self.view).offset(-64);
        make.top.equalTo(@64);
        make.left.equalTo(self);
    }];
    
    [self.toolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(@50);
        make.left.equalTo(self);
        make.bottom.equalTo(self);
    }];
    
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.toolView.mas_left);
        make.height.equalTo(@50);
        make.top.equalTo(self.toolView.mas_top);
        make.width.equalTo(self.view.mas_width).multipliedBy(0.33);
    }];
    
    [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.toolView);
        make.height.equalTo(@50);
        make.top.equalTo(self.toolView);
        make.width.equalTo(self.view.mas_width).multipliedBy(0.33);
    }];
    
    [self.selectAllBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.cancelBtn.mas_right);
        make.height.equalTo(@50);
        make.top.equalTo(self.toolView);
        make.width.equalTo(self.view.mas_width).multipliedBy(0.34);
    }];
}

#pragma mark - button event
#pragma mark 点击返回上层
-(void)popViewController{

    if ([SVProgressHUD isVisible]){
        [SVProgressHUD dismiss];
    }

    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 点击编辑
-(void)editAction{
    if (isEdit == NO) {
        isEdit = YES;
        self.toolView.hidden = NO;
    }else{
        isEdit = NO;
        self.toolView.hidden = YES;
    }
    
    [self.messageTableV reloadData];
}

#pragma mark 点击开始下载图片
-(void)beginDownlaodAlarmPic:(int)index{
    if (isEdit) {
        return;
    }
    AlarmMessageInfo *info = [messageArray objectAtIndex:index];
    NSString *uID = [info getuId];
    NSString *filePath = [[NSString alarmMessagePicPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",uID]];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    //图片存在则直接跳转
    if (data && [data length] > 1024) {
        AlarmMessagePicViewController *picVC = [[AlarmMessagePicViewController alloc] init];
        
        picVC.imageV.image = [UIImage imageWithData:data];
        
        [self.navigationController pushViewController:picVC animated:YES];
    }
    //图片不存在则去下载图片
    else{
        [SVProgressHUD show];
        [self.config downloadImage:filePath info:[info jsonStr]];
    }
    
}

#pragma mark 选择消息
-(void)selectAlarmMessage:(int)index{
    AlarmMessageInfo *info = [messageArray objectAtIndex:index];
    info.bSelected = !info.bSelected;
}

#pragma mark 工具栏点击事件
-(void)cancelBtnClicked:(UIButton *)sender{
    for (int i=0; i<messageArray.count; i++) {
        AlarmMessageInfo *resourceItem = messageArray[i];
        resourceItem.bSelected = NO;
    }
    
    //修改界面
    [self.messageTableV reloadData];
}

-(void)selectAllBtnClicked:(UIButton *)sender{
    for (int i=0; i<messageArray.count; i++) {
        AlarmMessageInfo *resourceItem = messageArray[i];
        resourceItem.bSelected = YES;
    }
    
    //修改界面
    [self.messageTableV reloadData];
}

-(void)deleteBtnClicked:(UIButton *)sender{
    [self.config deleteAlarmMessage:messageArray];
}

-(NSString *)getAlarmTypeText:(NSString *)msgType
{
    NSString *text = @"";
    
    if ([msgType isEqualToString:@"LowElectAlarm"]) {
        text = TS("DL_LowElectAlarm");
    }
    else if ([msgType isEqualToString:@"ForceDelAlarm"]) {
        text = TS("DL_ForceDelAlarm");
    }
    else if ([msgType isEqualToString:@"ForceFingerOpen"]) {
        text = TS("DL_ForceFingerOpen");
    }
    else if ([msgType isEqualToString:@"PasswdError"]) {
        text = TS("DL_PasswdError");
    }
    else if ([msgType isEqualToString:@"FingerPrintError"]) {
        text = TS("DL_FingerPrintError");
    }
    else if ([msgType isEqualToString:@"CardError"]) {
        text = TS("DL_CardError");
    }
    else if ([msgType isEqualToString:@"Trespassing"]) {
        text = TS("DL_Trespassing");
    }
    else if ([msgType isEqualToString:@"UnKnowKey"]) {
        text = TS("DL_UnKnowKey");
    }
    return text;
}

-(NSString *)getNotifyTypeText:(NSString *)msgType
{
    NSString *text = @"";
    
    if ([msgType isEqualToString:@"Card"]) {
        text = TS("Has_go_home");
    }
    else if ([msgType isEqualToString:@"FingerPrint"]){
        text = TS("Has_go_home");
    }
    else if ([msgType isEqualToString:@"Passwd"]){
        text = TS("Has_go_home");
    }
    else if ([msgType isEqualToString:@"Temporary"]){
        text = TS("Visitors_visit");
    }
    else if ([msgType isEqualToString:@"Key"]){
        text = TS("Unlock_by_key");
    }
    else if ([msgType isEqualToString:@"DoorBell"]){
        text = TS("DoorBell_pressed");
    }
    else if ([msgType isEqualToString:@"HasBeenOpen"]){
        text = TS("DL_HasBeenOpen");
    }
    else if ([msgType isEqualToString:@"HasBeenClose"]){
        text = TS("DL_HasBeenClose");
    }
    else if ([msgType isEqualToString:@"HasBeenLocked"]){
        text = TS("DL_HasBeenLocked");
    }
    else if ([msgType isEqualToString:@"LockedCancel"]){
        text = TS("DL_LockedCancel");
    }
    else if ([msgType isEqualToString:@"DoorLockRestore"]){
        text = TS("DL_DoorLockRestore");
    }
    else if ([msgType isEqualToString:@"LowBattery"]){
        text = TS("DL_LowBattery");
    }
    
    return text;
}

#pragma mark -- UITableViewDelegate/DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return messageArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AlarmMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlarmMessageCell"];
    if (!cell) {
        cell = [[AlarmMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AlarmMessageCell"];
    }
    cell.index = (int)indexPath.row;
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    AlarmMessageInfo *info = [messageArray objectAtIndex:indexPath.row];
    if (isEdit == YES) {
        cell.selectBtn.hidden = NO;
        cell.selectBtn.selected = info.bSelected;
    }else{
        cell.selectBtn.hidden = YES;
    }
    NSString *videoType;
    if ([[info getEvent] isEqualToString:@"VideoMotion"]) {
        videoType = @"Motion_detection";//移动检测
    }else if ([[info getEvent] isEqualToString:@"VideoBlind"]) {
        videoType = @"Video_block"; //视频遮挡
    }else if ([[info getEvent] isEqualToString:@"VideoLoss"]) {
        videoType = @"Video_loss_alarm"; //视频丢失
    }else if ([[info getEvent] isEqualToString:@"LocalIO"]) {
        videoType = @"LocalIO"; //本地IO报警
    }else if ([[info getEvent] isEqualToString:@"appEventHumanDetectAlarm"]){
        videoType = @"appEventHumanDetectAlarm"; //徘徊检测
    }else if ([[info getEvent] isEqualToString:@"VideoAnalyze"]){
        videoType = @"AnalyzeConfig"; //智能分析报警
    }else if ([[info getEvent] isEqualToString:@"LocalAlarm"]){
        videoType = @"Caller"; //访客来电
    }else if ([[info getEvent] isEqualToString:@"PIRAlarm"]){
        videoType = @"IDR_MSG_LOITERING"; //徘徊检测
    }else if ([[info getEvent] isEqualToString:@"LowBattery"]){
        videoType = @"IDR_LOW_BATTERY"; //低电量
    }else if ([[info getEvent] isEqualToString:@"ReserveWakeAlarm"]){
        videoType = @"IDR_MSG_RESERVER_WAKE"; //预约唤醒
    }else if ([[info getEvent] isEqualToString:@"IntervalWakeAlarm"]){
        videoType = @"IDR_MSG_INTERVAL_WAKE"; //间隔唤醒
    }else if ([[info getEvent] isEqualToString:@"ForceDismantleAlarm"]){
        videoType = @"IDR_MSG_FORCE_DISMANTLE"; //智能设备被拔出
    }else if ([[info getEvent] isEqualToString:@"DoorLockCall"]||[[info getEvent] isEqualToString:@"DoorLockNotify"]){
        videoType = [self getNotifyTypeText:[info getPushMSGType]];
    }else if ([[info getEvent] isEqualToString:@"DoorLockAlarm"]){
        videoType = [self getAlarmTypeText:[info getPushMSGType]];
    }else{
        videoType = [info getEvent];
    }
    NSString *msg = [info getPushMSG];
    if (msg == nil || [msg isEqual:[NSNull class]]) {
        msg = @"";
    }
    cell.detailLabel.text =  [NSString stringWithFormat:@"%@\n%@\n%@\n%@",[info getStartTime],TS([videoType UTF8String]),[info  getStatus],msg];
    
    //获取缩略图，存在则显示缩略图，不存在显示默认图片
    NSData *data = [self findAlarmImage:info];
    UIImage *image = [UIImage imageWithData:data];
    if (data != nil) {
        cell.pushImageView.image = image;
    }else{
        cell.pushImageView.image = [UIImage imageNamed:@"icon_funsdk.png"];
    }
    
    cell.tag = [[info getuId] longLongValue];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (isEdit == YES) {
        AlarmMessageCell *xMFileListCell = (AlarmMessageCell *)[tableView cellForRowAtIndexPath:indexPath];
        AlarmMessageInfo *info = [messageArray objectAtIndex:indexPath.row];
        info.bSelected = !info.bSelected;
        xMFileListCell.selectBtn.selected = info.bSelected;
    }
}

#pragma mark - 获取缩略图
-(NSData*)findAlarmImage:(AlarmMessageInfo *)info
{
    if ([info getPicSize].length > 0) {
        NSString *uID = [info getuId];
        NSString *filePath = [[NSString thumbnailPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",uID]];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        if (data && [data length] > 1024) {
            return data;
        }
        else{
            [self.config downloadAlarmThumbnail:filePath info:[info jsonStr]];
            //[self.config searchAlarmThumbnail:uID fileName:filePath];
        }
    }
    return nil;
}

#pragma mark - sdk回调处理
#pragma mark 报警消息查询回调
-(void)getAlarmMessageConfigResult:(NSInteger)result message:(NSMutableArray *)array{
    if (result >= 0) {
        [SVProgressHUD dismiss];
        messageArray = [array mutableCopy];
        [self.messageTableV reloadData];
    }
    else{
        [SVProgressHUD showErrorWithStatus:TS("Error")];
    }
}
#pragma mark 报警图片搜索回调
-(void)searchAlarmPicConfigResult:(NSInteger)result imagePath:(NSString *)imagePath{
    NSString* imageName = [[imagePath componentsSeparatedByString:@"/"]lastObject];
    //缩略图
    if ([imagePath containsString:@"Thumbnail"]) {
        for (int i = 0; i < messageArray.count; i++) {
            AlarmMessageInfo *json = [messageArray objectAtIndex:i];
            if ([[NSString stringWithFormat:@"%@.jpg",[json getuId]] isEqualToString:imageName]) {
                AlarmMessageCell *cell = (AlarmMessageCell *)[self.messageTableV viewWithTag:[[[imageName componentsSeparatedByString:@"."] firstObject] longLongValue]];
                NSData *data = [NSData dataWithContentsOfFile:imagePath];
                UIImage *image = [[UIImage alloc] initWithData:data];
                if (image != nil) {
                    cell.pushImageView.image = image;
                    data = nil;
                }
            }
        }
    }
    //报警图
    else{
        AlarmMessagePicViewController *picVC = [[AlarmMessagePicViewController alloc] init];
        
        NSData *data = [NSData dataWithContentsOfFile:imagePath];
        
        picVC.imageV.image = [UIImage imageWithData:data];
        
        [self.navigationController pushViewController:picVC animated:YES];
    }
}

#pragma mark 报警消息删除回调
-(void)deleteAlarmMessageConfigResult:(NSInteger)result message:(NSMutableArray *)array{
    if (result >= 0) {
        [SVProgressHUD dismiss];
        messageArray = [array mutableCopy];
        [self.messageTableV reloadData];
    }
    else{
        [SVProgressHUD showErrorWithStatus:TS("Error")];
    }
}

#pragma mark - lazy load
-(UITableView *)messageTableV{
    if (!_messageTableV) {
        _messageTableV = [[UITableView alloc] init];
        _messageTableV.delegate = self;
        _messageTableV.dataSource = self;
        [_messageTableV registerClass:[AlarmMessageCell class] forCellReuseIdentifier:@"AlarmMessageCell"];
        _messageTableV.rowHeight = 100;
        _messageTableV.tableFooterView = [[UIView alloc] init];
    }
    
    return _messageTableV;
}

-(UIView *)toolView{
    if (!_toolView) {
        _toolView = [[UIView alloc] init];
        _toolView.backgroundColor = [UIColor lightGrayColor];
        _toolView.hidden = YES;
    }
    
    return _toolView;
}

-(UIButton *)cancelBtn{
    if (!_cancelBtn) {
        _cancelBtn = [[UIButton alloc] init];
        [_cancelBtn setTitle:TS("Cancel") forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(cancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _cancelBtn;
}

-(UIButton *)selectAllBtn{
    if (!_selectAllBtn) {
        _selectAllBtn = [[UIButton alloc] init];
        [_selectAllBtn setTitle:TS("TR_Select_All") forState:UIControlStateNormal];
        [_selectAllBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_selectAllBtn addTarget:self action:@selector(selectAllBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _selectAllBtn;
}

-(UIButton *)deleteBtn{
    if (!_deleteBtn) {
        _deleteBtn = [[UIButton alloc] init];
        [_deleteBtn setTitle:TS("Delete") forState:UIControlStateNormal];
        [_deleteBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_deleteBtn addTarget:self action:@selector(deleteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _deleteBtn;
}

@end
