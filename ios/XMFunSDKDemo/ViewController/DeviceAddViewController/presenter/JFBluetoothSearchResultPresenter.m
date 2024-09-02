//
//  JFBluetoothSearchResultPresenter.m
//  FunSDKDemo
//
//  Created by coderXY on 2023/7/31.
//  Copyright © 2023 coderXY. All rights reserved.
//

#import "JFBluetoothSearchResultPresenter.h"
#import "JFBluetoothSearchResultAlertView.h"
#import "JFBluetoothSearchResultCell.h"

@interface JFBluetoothSearchResultPresenter ()<UITableViewDelegate, UITableViewDataSource>
/** controller */
@property (nonatomic, weak) JFBluetoothSearchResultAlertView *alertView;

@end

@implementation JFBluetoothSearchResultPresenter

- (instancetype)initWithView:(id)view{
    self = [super init];
    if(self){
        self.alertView = (JFBluetoothSearchResultAlertView *)view;
    }
    return self;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.alertView.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    JFBluetoothSearchResultCell *cell = [self.alertView.devTabList dequeueReusableCellWithIdentifier:NSStringFromClass([JFBluetoothSearchResultCell class]) forIndexPath:indexPath];
    XMSearchedDev *devModel = self.alertView.dataSource[indexPath.row];
    NSString *name = [NSString stringWithFormat:@"%@: %@", devModel.name, devModel.mac];
    [cell jf_updateCellWithDevname:name];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    XMSearchedDev *devModel = self.alertView.dataSource[indexPath.row];
    // 移除弹框
    [JFBluetoothSearchResultAlertView dismissAction];
    //
    if(self.alertView.delegate && [self.alertView.delegate respondsToSelector:@selector(jf_didSelectedDevModel:)]){
        [self.alertView.delegate jf_didSelectedDevModel:devModel];
    }
}

@end
