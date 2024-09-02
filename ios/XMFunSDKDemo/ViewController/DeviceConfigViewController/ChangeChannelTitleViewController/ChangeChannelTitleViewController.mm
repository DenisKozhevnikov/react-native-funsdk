//
//  ChangeChannelTitleViewController.m
//  FunSDKDemo
//
//  Created by wujiangbo on 2020/10/24.
//  Copyright © 2020 wujiangbo. All rights reserved.
//

#import "ChangeChannelTitleViewController.h"
#import <Masonry/Masonry.h>
#import "ChannelTitleConfig.h"

@interface ChangeChannelTitleViewController ()<UITextFieldDelegate,ChannelTitleConfigDelegate>
{
    ChannelTitleConfig *config;
}
@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) DeviceObject *devObject;

@end

@implementation ChangeChannelTitleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.channelTableV];
    self.navigationItem.title = TS("TR_modify_channelName");
    self.navigationItem.titleView = [[UILabel alloc] initWithTitle:self.navigationItem.title name:NSStringFromClass([self class])];
    
    [self configSubView];
    
    if (!config) {
        config = [[ChannelTitleConfig alloc] init];
        config.delegate = self;
    }
    
    //获取通道数据
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    self.devObject = [[DeviceControl getInstance] GetDeviceObjectBySN:channel.deviceMac];
    self.channelArray = [self.devObject.channelArray mutableCopy];
    [self.channelTableV reloadData];
}

#pragma mark - 控件布局
-(void)configSubView
{
    [self.channelTableV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view.mas_width);
        make.height.equalTo(self.view.mas_height);
        make.top.equalTo(self);
        make.left.equalTo(self);
    }];
}

#pragma mark - UITableView datasourse/delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.channelArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChannelCell"];
    ChannelObject *channel = [self.channelArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@" ,channel.channelName];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //获取对应通道信息
    [config getLogoConfigWithChannel:indexPath.row];
    //点击弹出修改框
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:TS("TR_modify_channelName") message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:TS("Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
     UIAlertAction *okAction = [UIAlertAction actionWithTitle:TS("OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
         
         if (self.nameTextField.text.length == 0)
         {
             [SVProgressHUD showErrorWithStatus:TS("devname_is_empty") duration:1.0];
             return;
         }
         NSIndexPath *currentPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
         //找到对应的cell
         UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:currentPath];
         currentCell.textLabel.text = self.nameTextField.text;
         
         ChannelObject *channel = [self.channelArray objectAtIndex:indexPath.row];
         channel.channelName = self.nameTextField.text;
         [self.channelArray replaceObjectAtIndex:indexPath.row withObject:channel];
        
         //修改通道名称
         [self setDeviceName];
         
        }];
        
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
        
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            
        textField.placeholder = TS("modify_devname");
        

        ChannelObject * channelObject = [self.devObject.channelArray objectAtIndex:indexPath.row];
        textField.text = channelObject.channelName;

        // 监听文字改变的方法，也可以通过通知
        [textField addTarget:self action:@selector(textFieldDidChange:)forControlEvents:UIControlEventEditingChanged];
        self.nameTextField = textField;
        self.nameTextField.delegate = self;
    }];
        
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)textFieldDidChange:(UITextField *)textField{
    if (textField.text.length > 25) {
        textField.text = [textField.text substringToIndex:25];
    }
}



#pragma mark - ChannelTitleConfigDelegate
-(void)getChannelTitleConfigResult:(NSInteger)result {
    if (result > 0) {
        NSString *title = [config readLogoTitle];
        NSLog(@"title");
    }else{
        //[SVProgressHUD showErrorWithStatus:TS("Error")];
    }
}

-(void)setChannelTitleConfigResult:(NSInteger)result
{
    if (result > 0) {
        [SVProgressHUD showSuccessWithStatus:TS("Success")];
        ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
        DeviceObject *object= [[DeviceControl getInstance] GetDeviceObjectBySN:channel.deviceMac];
        object.channelArray = [self.channelArray mutableCopy];
    }else{
        [SVProgressHUD showErrorWithStatus:TS("Error")];
    }
}

#pragma mark - 设置通道名称
-(void)setDeviceName{
    [config setLogoTitle:self.nameTextField.text];
    
    [config SetConfig];
}

#pragma mark - lazyload
-(UITableView *)channelTableV{
    if (!_channelTableV) {
        _channelTableV = [[UITableView alloc] init];
        _channelTableV.delegate = self;
        _channelTableV.dataSource = self;
        [_channelTableV registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ChannelCell"];
    }
    
    return _channelTableV;
}

@end
