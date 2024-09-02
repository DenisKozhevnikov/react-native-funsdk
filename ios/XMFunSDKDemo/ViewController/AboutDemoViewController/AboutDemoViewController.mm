//
//  AboutDemoViewController.m
//  FunSDKDemo
//
//  Created by zhang on 2021/9/1.
//  Copyright © 2021 zhang. All rights reserved.
//

#import "AboutDemoViewController.h"
#import "DataEncrypt.h"

@interface AboutDemoViewController () <UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *itemArray;
    UITableView *tableView;
    UISwitch *encryptSwitch;
    DataEncrypt *encrypt;
}
@end

@implementation AboutDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置导航栏样式
    [self setNaviStyle];
    
    //初始化数据
    [self initDataSource];
    
    //配置子视图
    [self configSubView];
}

//打开或者关闭 P2P数据加密传输
- (void)entryptSwitchEvent:(UISwitch*)enSwitch {
    [encrypt setP2PDataEncrypt:enSwitch.isOn];
}


#pragma mark -- UITableViewDelegate/DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return itemArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCellcell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSString *title = itemArray[indexPath.row];
    cell.textLabel.text = title;
    if ([title isEqualToString:TS("Encrypted transmission")]) {
        [cell addSubview:self.encryptSwitch];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)initDataSource {
    itemArray = [[NSMutableArray alloc] initWithCapacity:0];
    [itemArray addObject:TS("Encrypted transmission")];
}

- (void)configSubView {
    [self.view addSubview:self.tableView];
}

- (void)setNaviStyle {
    self.navigationItem.title = TS("About_Demo");
    self.navigationItem.titleView = [[UILabel alloc] initWithTitle:self.navigationItem.title name:NSStringFromClass([self class])];
}

- (UITableView *)tableView {
    if (!tableView) {
        tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.rowHeight = 60;
        tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return tableView;
}

- (UISwitch*)encryptSwitch {
    if (encryptSwitch == nil) {
        encryptSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(ScreenWidth-60, 15, 40, 30)];
        [encryptSwitch addTarget:self action:@selector(entryptSwitchEvent:) forControlEvents:UIControlEventValueChanged];
        encrypt = [[DataEncrypt alloc] init];
        [encryptSwitch setOn:[encrypt getSavedType]];
    }
    return encryptSwitch;
}
@end
