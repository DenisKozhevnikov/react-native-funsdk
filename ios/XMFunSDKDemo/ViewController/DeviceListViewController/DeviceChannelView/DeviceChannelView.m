//
//  DeviceChannelView.m
//  FunSDKDemo
//
//  Created by wujiangbo on 2020/10/15.
//  Copyright © 2020 wujiangbo. All rights reserved.
//

#import "DeviceChannelView.h"
#import <Masonry/Masonry.h>

@implementation DeviceChannelView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.channelTableV];
        [self addSubview:self.confirmBtn];
        [self addSubview:self.noTipsBtn];
        [self addSubview:self.cannelBtn];
        //布局
        [self configSubView];
    }
    
    return self;
}

#pragma mark - 控件布局
-(void)configSubView
{
    [self.noTipsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom).offset(-20);
        make.width.equalTo(self).multipliedBy(0.8);
        make.height.equalTo(@40);
        make.centerX.equalTo(self);
    }];
    
    [self.cannelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.noTipsBtn.mas_top).offset(-20);
        make.width.equalTo(self).multipliedBy(0.8);
        make.height.equalTo(@40);
        make.centerX.equalTo(self);
    }];
    
    [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.cannelBtn.mas_top).offset(-20);
        make.width.equalTo(self).multipliedBy(0.8);
        make.height.equalTo(@40);
        make.centerX.equalTo(self);
    }];
    
    [self.channelTableV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self);
        make.bottom.equalTo(self.confirmBtn.mas_top).offset(-20);
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
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %d,%@",TS("Channel"),indexPath.row + 1 ,channel.channelName];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.channelClicked) {
        self.channelClicked([self.channelArray objectAtIndex:indexPath.row],self.devID);
    }
}

#pragma mark - UIButtomEvent
-(void)confirmBtnClicked:(UIButton *)sender{
    if (self.confirmBtnClicked) {
        NSMutableArray *selectChannelArray = [[NSMutableArray alloc] initWithCapacity:0];
        NSArray *indexPaths = [self.channelTableV indexPathsForSelectedRows];
        for (int i = 0; i < indexPaths.count; i++) {
            NSIndexPath *indexPath = [indexPaths objectAtIndex:i];
            [selectChannelArray addObject:[self.channelArray objectAtIndex:indexPath.row]];
        }
        self.confirmBtnClicked(selectChannelArray,self.devID);
    }
}

-(void)cannelBtnClicked:(UIButton *)sender{
    self.hidden = YES;
}

-(void)noTipsBtnClicked:(UIButton *)sender{
    if (self.noTipsBtnClicked) {
        self.noTipsBtnClicked();
    }
}

#pragma mark - lazyload
-(UITableView *)channelTableV{
    if (!_channelTableV) {
        _channelTableV = [[UITableView alloc] init];
        _channelTableV.delegate = self;
        _channelTableV.dataSource = self;
        [_channelTableV registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ChannelCell"];
//        _channelTableV.allowsMultipleSelectionDuringEditing=YES;
//        [_channelTableV setEditing:YES]; //////设置uitableview为编译状态
    }
    
    return _channelTableV;
}

-(UIButton *)noTipsBtn{
    if (!_noTipsBtn) {
        _noTipsBtn = [[UIButton alloc] init];
        [_noTipsBtn setTitle:TS("TR_Never_Show") forState:UIControlStateNormal];
        _noTipsBtn.backgroundColor = GlobalMainColor;
        _noTipsBtn.hidden = YES;
        [_noTipsBtn addTarget:self action:@selector(noTipsBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _noTipsBtn;
}

-(UIButton *)confirmBtn{
    if (!_confirmBtn) {
        _confirmBtn = [[UIButton alloc] init];
        [_confirmBtn setTitle:TS("OK") forState:UIControlStateNormal];
        _confirmBtn.backgroundColor = GlobalMainColor;
        [_confirmBtn addTarget:self action:@selector(confirmBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        _confirmBtn.hidden = YES;
    }
    
    return _confirmBtn;
}

-(UIButton *)cannelBtn{
    if (!_cannelBtn) {
        _cannelBtn = [[UIButton alloc] init];
        [_cannelBtn setTitle:TS("Cancel") forState:UIControlStateNormal];
        _cannelBtn.backgroundColor = GlobalMainColor;
        [_cannelBtn addTarget:self action:@selector(cannelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _cannelBtn;
}

@end
