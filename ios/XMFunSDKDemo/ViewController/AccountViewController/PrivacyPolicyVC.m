//
//  PrivacyPolicyVC.m
//  XWorld_General
//
//  Created by SaturdayNight on 2018/5/4.
//  Copyright © 2018年 xiongmaitech. All rights reserved.
//

#import "PrivacyPolicyVC.h"
#import <Masonry/Masonry.h>
#import <WebKit/WebKit.h>

static NSString * const privacyURL = @"https://www.xmeye.net/page/privacy.jsp";

@interface PrivacyPolicyVC ()

@property (nonatomic,strong) WKWebView *webPrivacy;

@end

@implementation PrivacyPolicyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configNav];
    
    [self.view addSubview:self.webPrivacy];
    
    [self myLayout];
}

#pragma mark - EventAction
-(void)backItemClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 设置导航栏
-(void)configNav
{
    self.navigationItem.title = TS("Privacy_Policy");
    self.navigationItem.titleView = [[UILabel alloc] initWithTitle:self.navigationItem.title name:NSStringFromClass([self class])];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"new_back.png"] style:UIBarButtonItemStyleDone target:self action:@selector(backItemClicked)];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
}

#pragma mark - Layout
-(void)myLayout
{
    [self.webPrivacy mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}

#pragma mark - LazyLoad
-(WKWebView *)webPrivacy
{
    if (!_webPrivacy) {
        _webPrivacy= [[WKWebView alloc] initWithFrame:CGRectMake(0,0, ScreenWidth, ScreenHeight)];

        NSURL *url = [NSURL URLWithString:privacyURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [_webPrivacy loadRequest:request];
        [self writeToCache];
    }
    
    return _webPrivacy;
}

- (void)writeToCache
{
    NSString * htmlResponseStr = [NSString stringWithContentsOfURL:[NSURL  URLWithString:privacyURL] encoding:NSUTF8StringEncoding error:Nil];
    //创建文件管理器
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    //获取document路径
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,      NSUserDomainMask, YES) objectAtIndex:0];
    [fileManager createDirectoryAtPath:[cachesPath stringByAppendingString:@"/Caches"] withIntermediateDirectories:YES attributes:nil error:nil];
    //写入路径
    NSString * path = [cachesPath stringByAppendingString:[NSString stringWithFormat:@"/Caches/%@.html",@"privacyCache"]];
    
    [htmlResponseStr writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

@end
