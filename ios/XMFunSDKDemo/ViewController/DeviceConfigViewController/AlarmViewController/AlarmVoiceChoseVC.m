//
//  AlarmVoiceChoseVC.m
//  XWorld_General
//
//  Created by Megatron on 2019/3/27.
//  Copyright © 2019 xiongmaitech. All rights reserved.
//

#import "AlarmVoiceChoseVC.h"
#import <Masonry/Masonry.h>
#import "NetCustomRecordVC.h"

@interface TriggerCellBoxListCell : UITableViewCell

@property (nonatomic,strong) UIButton *btnAdd;
@property (nonatomic,copy) void (^TriggerCellBoxListCellAddAction)();

@end

@implementation TriggerCellBoxListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.btnAdd];
        
        [self.btnAdd mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@40);
            make.height.equalTo(@40);
            make.right.equalTo(self.contentView).mas_offset(-20);
            make.centerY.equalTo(self.contentView);
        }];
    }
    
    return self;
}

#pragma mark - LazyLoad
- (UIButton *)btnAdd{
    if (!_btnAdd) {
        _btnAdd = [[UIButton alloc] init];
        [_btnAdd setImage:[UIImage imageNamed:@"link_add_selected"] forState:UIControlStateNormal];
        [_btnAdd setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [_btnAdd addTarget:self action:@selector(btnAddClicked) forControlEvents:UIControlEventTouchUpInside];
        _btnAdd.hidden = YES;
    }
    
    return _btnAdd;
}

#pragma mark - EventAction
- (void)btnAddClicked{
    if (self.TriggerCellBoxListCellAddAction) {
        self.TriggerCellBoxListCellAddAction();
    }
}

@end

@interface AlarmVoiceChoseVC () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tbList;

@end

@implementation AlarmVoiceChoseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configNav];
    
    [self configSubviews];
}

#pragma mark - UI
- (void)configNav{
    self.navigationItem.title = TS("TR_Device_Alarm_Bell_Select");
    self.navigationItem.titleView = [[UILabel alloc] initWithTitle:self.navigationItem.title name:NSStringFromClass([self class])];
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle:TS("ad_save") style:UIBarButtonItemStyleDone target:self action:@selector(onConfirm)];
    self.navigationItem.rightBarButtonItem = rightBtn;
}

- (void)configSubviews{
    [self.view addSubview:self.tbList];
    
    [self.tbList mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - EventAction
- (void)leftBtnClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onConfirm{
    //点击确认，数据返回到上层界面做处理，本界面不发送命令
    if (self.AlarmVoiceChoseVoiceTypeAction) {
        self.AlarmVoiceChoseVoiceTypeAction([[[self.arrayDataSource objectAtIndex:self.selectedVoiceTypeIndex] objectForKey:@"VoiceEnum"] intValue]);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TriggerCellBoxListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"kTriggerCellBoxListCell"];
    
    if (indexPath.row == self.selectedVoiceTypeIndex) {
        cell.textLabel.textColor = [UIColor redColor];
    }else{
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    cell.btnAdd.hidden = YES;
    NSDictionary *dic = [self.arrayDataSource objectAtIndex:indexPath.row];
    if ([dic isKindOfClass:[NSDictionary class]]) {
        int voiceEnum = [[dic objectForKey:@"VoiceEnum"] intValue];
        if (voiceEnum == 550) {//表示支持自定义语音
            cell.btnAdd.hidden = NO;
        }
    }
    
    cell.TriggerCellBoxListCellAddAction = ^{
        //自定义语言设置界面
        NetCustomRecordVC *vc = [[NetCustomRecordVC alloc] init];
        vc.devID = self.devID;
        
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    cell.textLabel.text = [[self.arrayDataSource objectAtIndex:indexPath.row] objectForKey:@"VoiceText"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.selectedVoiceTypeIndex = (int)indexPath.row;
    
    [tableView reloadData];
}

#pragma mark - LazyLoad
- (UITableView *)tbList{
    if (!_tbList) {
        _tbList = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tbList.dataSource = self;
        _tbList.delegate = self;
        _tbList.tableFooterView = [[UIView alloc] init];
        [_tbList registerClass:[TriggerCellBoxListCell class] forCellReuseIdentifier:@"kTriggerCellBoxListCell"];
    }
    
    return _tbList;
}

- (NSMutableArray *)arrayDataSource{
    if (!_arrayDataSource) {
        _arrayDataSource = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _arrayDataSource;
}

@end
