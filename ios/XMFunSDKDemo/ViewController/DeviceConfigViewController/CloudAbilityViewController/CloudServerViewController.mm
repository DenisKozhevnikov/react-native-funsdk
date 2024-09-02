//
//  CloudServerViewController.m
//  FunSDKDemo
//
//  Created by XM on 2019/1/3.
//  Copyright © 2019年 XM. All rights reserved.
//

#import "CloudServerViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "DeviceManager.h"
#import "SystemInfoConfig.h"
#import <Masonry/Masonry.h>
#import <WebKit/WebKit.h>
#import "EncrypManager.h"

@protocol OCAndJSInteractionProtocol <JSExport>

-(void)openCloudStorageList:(NSString *)param;
-(void)closeWindow;
@end

@interface OCAndJSInteraction : NSObject <OCAndJSInteractionProtocol>

@property (nonatomic,weak) id <OCAndJSInteractionProtocol>delegate;

@end

@implementation OCAndJSInteraction

-(void)openCloudStorageList:(NSString *)param
{http://10.6.2.51/Attendance-index.html
    if (self.delegate) {
        [self.delegate openCloudStorageList:param];
    }
}

- (void)closeWindow{
    if (self.delegate) {
        [self.delegate closeWindow];
    }
}

@end

@interface CloudServerViewController () <WKScriptMessageHandler,WKNavigationDelegate,OCAndJSInteractionProtocol,SystemInfoConfigDelegate>


@property (nonatomic, strong) NSString *hardWare;       //硬件版本

@property (nonatomic, strong) NSString *softWare;       //软件版本

@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, strong) NSURLRequest *webURLRequest;

@property (nonatomic,strong) JSContext *context;

@property (nonatomic, strong) UIProgressView *progressView;

@property (nonatomic,strong) NSTimer *countTimer;
@property (nonatomic,assign) int curLoadNum; // 范围 1-10
@property (nonatomic,assign) BOOL ifFinished;   // 是否加载完毕

@property (nonatomic,strong) SystemInfoConfig *config;

@property (nonatomic,strong) UIButton *btnClose;

@property (nonatomic,copy) NSString *reference;     //
@property (nonatomic,copy) NSString *payRefresh;    // 支付后需要刷新的界面地址

@property (nonatomic,copy) NSString *lastUrl;       // 最后一次重定向网址
@end

@implementation CloudServerViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [self.navigationController.navigationBar setHidden:YES];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"closeWindow"];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"openCloudStorageList"];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"openQRScan"];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [self.navigationController.navigationBar setHidden:NO];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"closeWindow"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"openCloudStorageList"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"openQRScan"];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.title = TS("Cloud_storage");
    self.navigationItem.titleView = [[UILabel alloc] initWithTitle:self.navigationItem.title name:NSStringFromClass([self class])];

    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0,0, ScreenWidth, ScreenHeight)];
    self.webView.scrollView.bounces = NO;
    self.webView.navigationDelegate = self;
    [self.view addSubview:self.webView];
    
     [self.webView addSubview:self.btnClose];
    [self.btnClose mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@70);
        make.height.equalTo(@50);
        make.right.equalTo(self.webView).mas_offset(0);
        make.top.equalTo(self.webView).mas_offset(25);
    }];
    
    self.progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.frame = CGRectMake(0, 0, ScreenWidth, 10);
    self.progressView.progress = 0;
    self.progressView.progressTintColor = [UIColor blueColor];
    self.progressView.trackTintColor = [UIColor lightGrayColor];
    //设置进度条的高度，下面这句代码表示进度条的宽度变为原来的1倍，高度变为原来的1.5倍.
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    [self.webView addSubview:self.progressView];
    
    // 先判断是否是主账号，然后根据结果继续操作 （demo没有处理回调，如果没有主账号系统或者联系人系统的话，这个方法就不用调用处理）
    [[DeviceManager getInstance] checkMasterAccount:nil];
    //判断当前硬件和软件信息，云服务需要用到这两个信息
    [self checkDeviceAbility];
}
- (UIButton *)btnClose{
    if (!_btnClose) {
        _btnClose = [[UIButton alloc] init];
        [_btnClose setImage:[[UIImage imageNamed:@"windclose_white.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [_btnClose addTarget:self action:@selector(closeWindow) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _btnClose;
}
- (void)closeWindow{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
        
    });
}
//MARK: WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    if ([message.name isEqualToString:@"closeWindow"]) {
        [self closeWindow];
    }else if ([message.name isEqualToString:@"openCloudStorageList"]){
        NSDictionary *dic = (NSDictionary *)message.body;
        NSString *body = [dic objectForKey:@"body"];
        if ([body isEqualToString:@"0"]) {
            [self gotoCloudPhotoVC];
        }else if ([body isEqualToString:@"1"]){
            [self gotoCloudVideoPlaybackVC];
        }
    }else if ([message.name isEqualToString:@"openQRScan"]){
        [self onScanQRCode];
    }
}

-(void)onScanQRCode{
    
}
#pragma mark 检查设备硬件软件信息
- (void)checkDeviceAbility {
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    DeviceObject *device = [[DeviceControl getInstance] GetDeviceObjectBySN:channel.deviceMac];
    if (device.info.hardWare && device.info.hardWare.length >0 && device.info.softWareVersion && device.info.softWareVersion.length >0) {
        [self requestURL];
        //刷新加载进度
        self.countTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(countTimerAction) userInfo:nil repeats:YES];
        self.curLoadNum = 0;
        self.ifFinished = NO;
    }else{
        _config = [[SystemInfoConfig alloc] init];
        _config.delegate = self;
        [_config getSystemInfo];
    }
}

#pragma mark  webView请求
-(void)requestURL {
    char szUserID[128] = {0};
    FUN_GetFunStrAttr(EFUN_ATTR_LOGIN_USER_ID, szUserID, 128);
    NSString *URLString;
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    //准备跳转到云存储
    self.jumpSign = @"xmc.css";
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    DeviceObject *device = [[DeviceControl getInstance] GetDeviceObjectBySN:channel.deviceMac];
    if ([currentLanguage containsString:@"zh-Hans"] || [currentLanguage containsString:@"zh-Hant"]) {
        if (self.jumpSign.length > 0) {
            URLString = [NSString stringWithFormat:@"https://boss2.xmcsrv.net/index.do?user_id=%s&uuid=%@&hardware=%@&software=%@&lan=zh-CN&appKey=%@&devName=%@&goods=%@",szUserID,device.deviceMac,device.info.hardWare,device.info.softWareVersion,OCSTR(APPKEY),device.deviceName,self.jumpSign];
        }else{
            URLString = [NSString stringWithFormat:@"https://boss2.xmcsrv.net/index.do?user_id=%s&uuid=%@&hardware=%@&software=%@&lan=zh-CN&appKey=%@&devName=%@",szUserID,device.deviceMac,device.info.hardWare,device.info.softWareVersion,OCSTR(APPKEY),device.deviceName];
        }


    }else{
        if (self.jumpSign.length > 0) {
            URLString = [NSString stringWithFormat:@"https://boss2.xmcsrv.net/index.do?user_id=%s&uuid=%@&hardware=%@&software=%@&lan=en&appKey=%@&devName=%@&goods=%@",szUserID,device.deviceMac,device.info.hardWare,device.info.softWareVersion,OCSTR(APPKEY),device.deviceName,self.jumpSign];
        }else{
            URLString = [NSString stringWithFormat:@"https://boss2.xmcsrv.net/index.do?user_id=%s&uuid=%@&hardware=%@&software=%@&lan=en&appKey=%@&devName=%@",szUserID,device.deviceMac,device.info.hardWare,device.info.softWareVersion,OCSTR(APPKEY),device.deviceName];
        }

    }

    // url中文处理
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)URLString,
                                                              (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",
                                                              NULL,
                                                              kCFStringEncodingUTF8));
 
    self.webURLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:encodedString] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    [self.webView loadRequest:self.webURLRequest];
}

#pragma mark - 模拟加载动画
-(void)countTimerAction{
    if (self.curLoadNum < 24 && self.ifFinished == NO) {
        self.curLoadNum++;
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationCurveEaseIn animations:^{
            self.progressView.progress = self.curLoadNum / 30.0;
        } completion:nil];
    }
    else{
        if (self.ifFinished) {
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationCurveEaseIn animations:^{
                self.progressView.progress = 1;
            } completion:^(BOOL complete){
                self.progressView.hidden = YES;
                
                [self.countTimer invalidate];
                self.countTimer = nil;
            }];
        }
    }
}

#pragma mark 判断主账号信息结果回调
- (void)checkMaster:(NSString *)sId Result:(int)result {
    if (result >=1) { //主账号
        
    }else if (result == 0) { //不是主账号
        
    }else{//获取失败
        [MessageUI ShowErrorInt:result];
    }
}
#pragma mark 获取能力级回调信息
- (void)SystemInfoConfigGetResult:(NSInteger)result {
    if (result <=0) {
        [MessageUI ShowErrorInt:(int)result];
    }else{
        [self checkDeviceAbility];
    }
}

- (void)appDidBecomeActive{
    if (self.payRefresh.length > 0) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[self URLDecodedString:self.payRefresh]]]];
        self.payRefresh = @"";
    }
}
#pragma mark - Delegate
//MARK: WKNavigationDelegate
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {

}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
}

// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"cy=%@",self.lastUrl);
    
    if ([self.lastUrl containsString:@"load=finish"]) {
    }
}

//提交发生错误时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
}

// 接收到服务器跳转请求即服务重定向时之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
}

// 根据WebView对于即将跳转的HTTP请求头信息和相关信息来决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSString *url = navigationAction.request.URL.absoluteString;
    
    self.lastUrl = url;
    
    if ([url containsString:@"load=finish"]) {
        
        NSString *result = [url stringByReplacingOccurrencesOfString:@"https://" withString:@""];
        NSRange range = [result rangeOfString:@"/"];
        result = [result substringToIndex:range.location];
        result = [result stringByAppendingString:@"://"];
        
        self.reference = result;
    }
    
    if ([url hasPrefix:[EncrypManager decodeDesWithString:@"g/YDHcdWV88SD3hNRdUv3g=="]] || [url hasPrefix:[EncrypManager decodeDesWithString:@"yDr7Oo5wVabA97rtGojXfg=="]]) {
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
        [self requestURL];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    else if ([url hasPrefix:[EncrypManager decodeDesWithString:@"jwfWjrP9Nk74eL6BToh6gSC0lOfs1+S+"]]){
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    NSDictionary *header = [navigationAction.request allHTTPHeaderFields];
    BOOL hasReferer = [header objectForKey:@"Referer"] != nil;

    if (hasReferer && [url hasPrefix:[EncrypManager decodeDesWithString:@"Y3wWIbplqLsI48y7V0Ck5C1ASxyGDkT1"]] && ![[header objectForKey:@"Referer"] isEqualToString:self.reference]) {
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSURL *urls = [navigationAction.request URL];
                NSString *originUrlStr = urls.absoluteString;
                
                NSRange range = [originUrlStr rangeOfString:@"redirect_url="];
                NSString *result = [originUrlStr substringFromIndex:range.location+range.length];
                self.payRefresh = result;

                NSArray *array = [originUrlStr componentsSeparatedByString:@"redirect_url"];
                NSString *nowUrlStr = [NSString stringWithFormat:@"%@redirect_url=%@",[array objectAtIndex:0],self.reference];
//                nowUrlStr = [nowUrlStr stringByReplacingOccurrencesOfString:@"boss2-china.xmcsrv.net" withString:@"boss.5gsee.net"];
                NSURL *newUrl = [NSURL URLWithString:nowUrlStr];

                NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:newUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
                [req setHTTPMethod:@"GET"];
                [req setValue:self.reference forHTTPHeaderField:@"Referer"];
                [webView loadRequest:req];
            });
        });

        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (NSString *)URLDecodedString:(NSString *)url
{
    NSString *result = [url stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    return [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark 界面跳转
- (void)gotoCloudPhotoVC {
    CloudPhotoViewController *cloudPhotoVC = [[CloudPhotoViewController alloc] init];
    [self.navigationController pushViewController:cloudPhotoVC animated:YES];
}
- (void)gotoCloudVideoPlaybackVC {
    CloudVideoViewController *cloudVideoVC = [[CloudVideoViewController alloc] init];
    [self.navigationController pushViewController:cloudVideoVC animated:YES];
}
@end
