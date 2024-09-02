//
//  ShadowServicesViewController.m
//  FunSDKDemo
//
//  Created by plf on 2023/4/25.
//  Copyright © 2023 plf. All rights reserved.
//

#import "ShadowServicesViewController.h"
#import "ShadowServicesManager.h"
#import "ConfigListView.h"
#import "XYShowAlertView.h"

@interface ShadowServicesViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView *listTB;
@property(nonatomic,strong)NSArray *listArray;

@property(nonatomic,strong)ConfigListView *configListView;

@property(nonatomic,strong)ShadowServicesManager *shadowServicesManager;
@property(nonatomic,copy)NSString *shadowServicesConfigListStr; // 配置字符串

@property(nonatomic,strong)NSDictionary *shadowServiceDataDic;//影子服务获取到的数据

@end

@implementation ShadowServicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNaviStyle];
    
    
    self.listArray = @[TS("TR_GetDevCfgsFromShadowService"),TS("TR_SetDevOffLineCfgsToShadowService"),TS("TR_AddShadowServiceListener"),TS("TR_RemoveShadowServiceListener")];
    
    [self.listTB setFrame:self.view.frame];
    [self.view addSubview:self.listTB];
    
//    //如果没有设置好配置，先选取要设置的配置
//    if (self.shadowServicesConfigListStr.length == 0) {
//        [self showSettingView];
//    }
 
}

- (void)setNaviStyle {
    self.navigationItem.title = TS("shadowServices");
    
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"new_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController)];
    self.navigationItem.leftBarButtonItem = leftBtn;
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle:TS("TR_ShadowConfigSetting") style:UIBarButtonItemStylePlain target:self action:@selector(showSettingView)];
    self.navigationItem.rightBarButtonItem = rightBtn;
}


#pragma mark - UITableViewDelegate/DataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    cell.textLabel.text = self.listArray[indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    __weak typeof(self) weakSelf = self;
    switch (indexPath.row) {
        case 0:
        {
            //如果没有设置好配置，先选取要设置的配置
            if (self.shadowServicesConfigListStr.length == 0) {
                [self showSettingView];
                
                return;
            }
            
            //影子服务器获取设备配置
            //可以同时获取多个配置
            [self.shadowServicesManager getDevCfgsFromShadowService:weakSelf.shadowServicesConfigListStr callBack:^(NSDictionary * _Nonnull dic) {
                weakSelf.shadowServiceDataDic = [NSDictionary dictionaryWithDictionary:dic];
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:TS("TR_GetDevCfgsFromShadowService") message:[NSString convertToJSONData:dic] preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:TS("OK") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                }];
                
                [alertController addAction:cancelAction];
                [self presentViewController:alertController animated:YES completion:nil];

            }];
        }
            break;
        case 1:
        {
            
            [SVProgressHUD showErrorWithStatus:TS("TR_Not_Support_Function") duration:2.0];
            
            
            //设置功能暂时不支持
            return;
            
//            if (self.shadowServiceDataDic.count == 0) {
//                return;
//            }
//
//            NSError *error = nil;
//            NSData *data = [NSJSONSerialization dataWithJSONObject:self.shadowServiceDataDic options:NSJSONWritingPrettyPrinted error:&error];
//            NSString *strValues = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//
//            [self.shadowServicesManager setDevOffLineCfgsToShadowService:strValues callBack:^(BOOL result) {
//                NSLog(@"%@",@"111");
//            }];
        }
            break;
        case 2:
        {
            
            //如果没有设置好配置，先选取要设置的配置
            if (self.shadowServicesConfigListStr.length == 0) {
                [self showSettingView];
                
                return;
            }
            
            //影子服务设备配置状态监听
            //可以同时获取多个配置
            [self.shadowServicesManager addShadowServiceListener:weakSelf.shadowServicesConfigListStr callBack:^(NSDictionary * _Nonnull dic) {
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:TS("TR_GetDevCfgsFromShadowService") message:[NSString convertToJSONData:dic] preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:TS("OK") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                }];
                
                UIAlertAction *unLinkAction = [UIAlertAction actionWithTitle:TS("TR_RemoveShadowServiceListener") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    //移除影子服务设备配置监听
                    [weakSelf.shadowServicesManager removeShadowServiceListener];
                }];
                
                [alertController addAction:cancelAction];
                [alertController addAction:unLinkAction];
                [self presentViewController:alertController animated:YES completion:nil];
            }];
        }
            break;
        case 3:
        {
            //移除影子服务设备配置监听
            [self.shadowServicesManager removeShadowServiceListener];
        }
            break;
            
            
        default:
            break;
    }
}




#pragma mark - button event
-(void)popViewController
{
    if([SVProgressHUD isVisible]){
        [SVProgressHUD dismiss];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)showSettingView
{
    [self.view addSubview:self.configListView];
    [self.configListView showSelectView];
}

-(ShadowServicesManager *)shadowServicesManager
{
    if(!_shadowServicesManager)
    {
        _shadowServicesManager = [[ShadowServicesManager alloc]init];
        _shadowServicesManager.devID = self.devID;
    }
    
    return _shadowServicesManager;
}

-(UITableView *)listTB
{
    if (!_listTB)
    {
        _listTB = [[UITableView alloc]init];
        _listTB.delegate = self;
        _listTB.dataSource = self;
        _listTB.separatorStyle = UITableViewCellSeparatorStyleNone;
        _listTB.tableFooterView = [UIView new];
    }
    
    return _listTB;
}

-(ConfigListView *)configListView
{
    if (!_configListView) {
        _configListView = [[ConfigListView alloc]initWithFrame:self.view.bounds];
        
        __weak typeof(self) weakSelf = self;
        _configListView.addConfigBlock = ^(NSString * _Nonnull configStr) {
            weakSelf.shadowServicesConfigListStr = configStr;
        };
    }
    
    return _configListView;
}


@end
