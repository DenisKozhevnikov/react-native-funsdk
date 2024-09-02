//
//  JFBluetoothSearchResultAlertView.m
//  FunSDKDemo
//
//  Created by coderXY on 2023/7/31.
//  Copyright © 2023 coderXY. All rights reserved.
//

#import "JFBluetoothSearchResultAlertView.h"
#import "JFBluetoothSearchResultPresenter.h"
#import "JFBluetoothSearchResultCell.h"

@interface JFBluetoothSearchResultAlertView ()<UIGestureRecognizerDelegate>
/** 背景view */
@property (nonatomic, strong) UIView *bgView;
/** title */
@property (nonatomic, strong) UILabel *titleLab;
/** 设备列表 */
@property (nonatomic, strong, readwrite) UITableView *devTabList;
/** 设备数据源 */
@property (nonatomic, strong, readwrite) NSMutableArray *dataSource;
/** 搜索结果persenter */
@property (nonatomic, strong) JFBluetoothSearchResultPresenter *resultPresenter;
/** JFBluetoothSearchResultAlertViewDelegate */
@property (nonatomic, weak, readwrite) id<JFBluetoothSearchResultAlertViewDelegate>delegate;

@end

@implementation JFBluetoothSearchResultAlertView

+ (instancetype)shareInstance{
    static JFBluetoothSearchResultAlertView *alertView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        alertView = [[JFBluetoothSearchResultAlertView alloc] initWithFrame:CGRectZero];
    });
    return alertView;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self searchResultSubviews];
        [self searchResultConfig];
    }
    return self;
}
// MARK: 展示
+ (void)jf_showResultViewWithDataSource:(NSMutableArray *)dataSource delegate:(id<JFBluetoothSearchResultAlertViewDelegate>)delegate{
    [[JFBluetoothSearchResultAlertView shareInstance] jf_showResultViewWithDataSource:dataSource delegate:delegate];
}
- (void)jf_showResultViewWithDataSource:(NSMutableArray *)dataSource delegate:(id<JFBluetoothSearchResultAlertViewDelegate>)delegate{
    // 只在蓝牙添加方式页面弹出
    if(![NSStringFromClass([[UIViewController xm_currentViewController] class]) isEqualToString:@"JFBluetoothModeAddDevController"]) return;
    self.delegate = delegate;
    [self dismissAction];
    UIWindow *window = [UIViewController xm_window];
    [window addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(window);
    }];
    [UIView animateWithDuration:0.4 animations:^{
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.equalTo(self);
            make.width.mas_equalTo(SCREEN_WIDTH*0.8);
            // w:h = 3:4
            make.height.mas_equalTo(self.bgView.mas_width).dividedBy(0.75);
        }];
    }];
    [self layoutIfNeeded];
    //
    self.dataSource = dataSource;
    [self.devTabList reloadData];
}
// MARK: - (void)dismissAction;
+ (void)dismissAction{
    [[JFBluetoothSearchResultAlertView shareInstance] dismissAction];
}
- (void)dismissAction{
    [self removeFromSuperview];
}

// MARK: searchResultSubviews
- (void)searchResultSubviews{
    self.backgroundColor = [JFCommonColor_333 colorWithAlphaComponent:0.3];
    [self addSubview:self.bgView];
    [self.bgView addSubview:self.titleLab];
    [self.bgView addSubview:self.devTabList];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgView.mas_top).offset(10);
        make.left.right.equalTo(self.bgView);
        make.height.mas_equalTo(40);
    }];
    [self.devTabList mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLab.mas_bottom).offset(5);
        make.left.bottom.right.equalTo(self.bgView);
    }];
}
// MARK: searchResultConfig
- (void)searchResultConfig{
    XMLog(@"%s", __FUNCTION__);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    tap.numberOfTapsRequired = 1;
    tap.delegate = self;
    [tap addTarget:self action:@selector(dismissAction)];
    [self addGestureRecognizer:tap];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    id touchView = touch.view;
    if([touchView isEqual:self.bgView] ||
       [touchView isEqual:self.devTabList] ||
       [NSStringFromClass([touchView class]) isEqualToString:@"UITableViewCellContentView"]) return NO;
    return YES;
}

#pragma mark - lazy load
// MARK: bgView
- (UIView *)bgView{
    if(!_bgView){
        _bgView = [[UIView alloc] initWithFrame:CGRectZero];
        _bgView.backgroundColor = JFCommonColor_FFF;
    }
    return _bgView;
}

- (UILabel *)titleLab{
    if(!_titleLab){
        _titleLab = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLab.font = JF_Font_Weight(18, 0.2);
        _titleLab.text = TS("TR_Searching_result_title");
        _titleLab.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLab;
}

// MARK: devTabList
- (UITableView *)devTabList{
    if(!_devTabList){
        _devTabList = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _devTabList.separatorStyle = UITableViewCellSeparatorStyleNone;
        _devTabList.showsVerticalScrollIndicator = NO;
        _devTabList.delegate = (id<UITableViewDelegate>)self.resultPresenter;
        _devTabList.dataSource = (id<UITableViewDataSource>)self.resultPresenter;
        [_devTabList registerClass:[JFBluetoothSearchResultCell class] forCellReuseIdentifier:NSStringFromClass([JFBluetoothSearchResultCell class])];
    }
    return _devTabList;
}
// MARK: dataSource
- (NSMutableArray *)dataSource{
    if(!_dataSource){
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}
// MARK: resultPresenter
- (JFBluetoothSearchResultPresenter *)resultPresenter{
    if(!_resultPresenter){
        _resultPresenter = [[JFBluetoothSearchResultPresenter alloc] initWithView:self];
    }
    return _resultPresenter;
}


@end
