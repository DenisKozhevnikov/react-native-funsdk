	//
//  VRGLViewController.m
//  VRDemo
//
//  Created by J.J. on 16/8/26.
//  Copyright © 2016年 xm. All rights reserved.
//

#import "VRGLViewController.h"
#import <FunSDK/VRSoft.h>
#import "PhoneInfoManager.h"

@interface VRGLViewController ()
{
    VRHANDLE mVRHandle;
    XMVRType mVRType;
    UInt64 mTimeTouchDown;
    double mTouchDownX;
    double mTouchDownY;
    QUEUE_YUV_DATA _yuvDatas;
    unsigned char * _pbyYUV;
    
    int _nYUVBufLen;
    int shapeNum;
}
@property(strong,nonatomic)EAGLContext* context;
@property(strong,nonatomic)GLKBaseEffect* effect;
//首次触摸屏幕时的位置
@property (nonatomic,assign) CGPoint firstTouchPoint;
//最后一次触发双击事件的时间 防止和自定义单击时间冲突 如果0.5秒内已经触发过双击 就不响应自定义单击事件
@property (nonatomic,assign) long long lastDoubleClickTime;
@end
@implementation VRGLViewController

@synthesize context;
@synthesize effect;

-(id)init{
    self = [super init];
    if ( self ) {
        self.VRShowMode = -1;
    }
    return self;
}

-(void)initControls{
    //双击手势
    UITapGestureRecognizer*doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleClicked:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTapGesture];

}

-(void)doubleClicked:(UITapGestureRecognizer *)sender {
    //NSLog(@"APPTEST:double");
    //判断设备场景
    if(self.iSceneType == XMVR_TYPE_TWO_LENSES){
        long long doubleClickTime = [[NSDate date] timeIntervalSince1970] * 1000;
        self.lastDoubleClickTime = doubleClickTime;
        if ( self.vrglViewControllerDelegateDelegate && [self.vrglViewControllerDelegateDelegate respondsToSelector:@selector(vrglViewControllerDoubleClicked:)]) {
            [self.vrglViewControllerDelegateDelegate vrglViewControllerDoubleClicked: [sender locationInView:self.view]];
        }
    }
}

-(void)setVRShapeType:(XMVRShape)shapetype
{
    NSLog(@"\n\n-------> setVRType = %d\n\n", mVRType);
    if ( mVRHandle ) {
        VRSoft_SetShape(mVRHandle, shapetype);
    }
}

-(void)setVRType:(XMVRType)type {
    // set 180VR or 360VR
    mVRType = type;
    NSLog(@"\n\n-------> setVRType = %d\n\n", mVRType);
    if ( mVRHandle ) {
        VRSoft_SetType(mVRHandle, mVRType);
//        VRSoft_SetCameraMount(mVRHandle,Ceiling);
    }
    if(mVRType == XMVR_TYPE_360D){
        
        VRSoft_SetCameraMount(mVRHandle,Ceiling);
    }
}

-(void)setVRVRCameraMount:(XMVRMount)Mount{
    VRSoft_SetCameraMount(mVRHandle,Mount);

}

-(void)setVRFecParams:(int)xCenter yCenter:(int)yCenter radius:(int)radius Width:(int)imgWidth Height:(int)imgHeight{
    if (mVRHandle) {
        
        VRSoft_SetFecParams(mVRHandle, xCenter, yCenter, radius, imgWidth, imgHeight);
    }
   
}
//智能分析报警之后界面旋转位置
-(void)setAnalyzeWithXL:(int)x0 YL:(int)y0 XR:(int)x1 YR:(int)y1 Width:(int)imgWidth Height:(int)imgHeight
{
    VRSoft_DisplayRect(mVRHandle, x0, y0, x1, y1, imgWidth, imgHeight);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor =[UIColor orangeColor];
    [self configSoftEAGLContext];
    UIPinchGestureRecognizer * twoFingerPinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(touchesPinch:)];
    [self.view addGestureRecognizer:twoFingerPinch];
}
//软解
-(void)configSoftEAGLContext {
    
    [self creatGLKView];
    
    if ( !mVRHandle ) {
        VRSoft_Create(&mVRHandle);
        
        // 1.0.7版本之后必须设置版权声明信息
        VRSoft_SetAttribute(mVRHandle, [@"COPYRIGHT" UTF8String],
                            (char *)[@"HangZhou XiongMai Technology CO.,LTD." UTF8String]);
        VRSoft_SetAttribute(mVRHandle, [@"PLATFORM" UTF8String],
                            (char *)[@"iOS" UTF8String]);
        
        VRSoft_Prepare(mVRHandle);
    }
    
    NSLog(@"\n\n-------> mVRType = %d\n\n", mVRType);
    VRSoft_SetType(mVRHandle, mVRType);
    
    [self SetPPIandInt];
    
    const char *version = VRSoft_Version();
    
    NSLog(@"%s", version);
    
}

-(void)creatGLKView
{
    NSLog(@"\nJFFISH: creatGLKView \n");
    GLKView* view;
    if(!context){
        context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
        
    }
    
    //鱼眼加载图标位置异常处理
    CGFloat widht = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    CGFloat x = self.view.frame.origin.x;
    CGFloat y = self.view.frame.origin.y;
    
    if (widht < height) {
        height = widht * self.hwRatio;
    }
    self.view.frame = CGRectMake(x, y, widht, height);
    
    view = [[GLKView alloc]initWithFrame:self.view.frame];
    view.context = context;
    
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    // 将此“EAGLContext”实例设置为OpenGL的“当前激活”的“Context”。这样，以后所有“GL”的指令均作用在这个“Context”上。随后，发送第一个“GL”指令：激活“深度检测”。
    
    [EAGLContext setCurrentContext:context];
    
    self.preferredFramesPerSecond = 60;
    
    self.view = view;
    [self initControls];
}

-(void)SetPPIandInt
{
    NSLog(@"\nJFFISH: SetPPIandInt \n");
    CGFloat scale_screen = [UIScreen mainScreen].scale;
    VRSoft_SetPPIZoom(scale_screen);
    
    //手机物理分辨率
    CGSize size = [PhoneInfoManager getRealResolutionRatioSize];
    float realWidth = size.width > size.height ? size.height : size.width;
    float realHeight = size.width < size.height ? size.height : size.width;
    //手机逻辑分辨率
    CGSize logicalSize = [[UIScreen mainScreen] currentMode].size;
    float logicalWidth = logicalSize.width > logicalSize.height ? logicalSize.height : logicalSize.width;
    float logicalHeight = logicalSize.width < logicalSize.height ? logicalSize.height : logicalSize.width;
    // 判断设备方向
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (TARGET_IPHONE_SIMULATOR || scale_screen != 3) {
        VRSoft_Init(mVRHandle,
                    self.view.frame.size.width ,
                    self.view.frame.size.height );
        self.lastVRScreenWidth = self.view.frame.size.width;
        //NSLog(@"CY=%f,%f",self.view.frame.size.width,self.view.frame.size.height);
    }else{
        //plus获取屏幕宽高为375*667,放大3倍后为1125*2001
        if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft) {
            // 横屏时需特殊处理
            VRSoft_Init(mVRHandle,
                        self.view.frame.size.width * realWidth /logicalWidth,
                        self.view.frame.size.height * realHeight / logicalHeight);
            self.lastVRScreenWidth = self.view.frame.size.width * realWidth /logicalWidth;
        }
        else{
            VRSoft_Init(mVRHandle,
                        self.view.frame.size.width * realWidth /logicalWidth,
                        self.view.frame.size.height * realHeight / logicalHeight);
            self.lastVRScreenWidth = self.view.frame.size.width * realWidth /logicalWidth;
        }
        //NSLog(@"CY=%f,%f,%f,%f",self.view.frame.origin.x,self.view.frame.origin.y,self.view.frame.size.width,self.view.frame.size.height);
//        NSLog(@"-->>>>>>>-");
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"\n---------> vrview width : %f\n", self.view.frame.size.width);
    NSLog(@"\n---------> vrview height : %f\n", self.view.frame.size.height);
    
//    VRSoft_Init(mVRHandle,
//                self.view.frame.size.width,
//                self.view.frame.size.height);
//    NSLog(@"%f,%f",self.view.frame.size.width,self.view.frame.size.height);
//    CGFloat scale_screen = [UIScreen mainScreen].scale;
//    VRSoft_SetPPIZoom(scale_screen);
    if (self.iCodecType == 5 || self.iCodecType == 4) {
        [self SetPPIandInt];
    }
    
}
- (void)update {
}

-(void)viewDidLayoutSubviews
{
    [self reloadInitView:self.view.frame];
}

-(void)reloadInitView:(CGRect)frame{
//    VRSoft_Init(mVRHandle,
//                frame.size.width,
//                frame.size.height);
    if (self.iCodecType == 4 || self.iCodecType == 5) {
        [self SetPPIandInt];
    }
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0, 0, 0, 1.0f);
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [self loadYUVImageFromFile];
    
    VRSoft_Drawself(mVRHandle);
}

-(void)SoftTouchMove:(NSSet *)SoftTouch Softevent:(UIEvent *)Softevent{
    // 最多只处理两个点
    GLfloat values[4];
    int pointerCount = 0;
    
    for(UITouch *touch in Softevent.allTouches) {
        if ( pointerCount < 2 ) {
            CGPoint locInSelf = [touch locationInView:self.view];
            values[pointerCount*2] = locInSelf.x;
            values[pointerCount*2 + 1] = locInSelf.y;
            pointerCount ++;
            continue;
        } else {
            break;
        }
    }
    
    if ( pointerCount == 1 ) {
        VRSoft_OnTouchMove(mVRHandle, values[0], values[1]);
    }
}

#pragma mark 捏合
-(void)SoftTouchesPinch:(CGFloat)scale{
    VRSoft_OnTouchPinchScale(mVRHandle,scale);
}

//鱼眼YUV数据
-(void)PushData:(int)width height:(int)height YUVData:(unsigned char *)pData{
    SYUVData *pNew = new SYUVData(width, height, pData);
    _yuvDatas.push(pNew);
    int nSize = (int)_yuvDatas.size();
    for (int i = 4; i < nSize; i++) {
        SYUVData *item = _yuvDatas.front();
        _yuvDatas.pop();
        delete item;
    }
}

-(SYUVData *)PopData{
    SYUVData *pItem = NULL;
    if (!_yuvDatas.empty()) {
        pItem = _yuvDatas.front();
        _yuvDatas.pop();
    }
    return pItem;
}

- (void)loadYUVImageFromFile{
    SYUVData *pData = [self PopData];
    if (pData) {
        int nDataLen = pData->width * pData->height * 3 / 2;
        if (_nYUVBufLen< nDataLen || _pbyYUV == NULL) {
            if (_pbyYUV) {
                free(_pbyYUV);
                _pbyYUV = NULL;
            }
            _pbyYUV = (unsigned char *)malloc(nDataLen);//new unsigned char[nDataLen];
            _nYUVBufLen = nDataLen;
        }
        memcpy(_pbyYUV, pData->pData, nDataLen);
        
        VRSoft_SetYUV420PTexture(mVRHandle,_pbyYUV, _nYUVBufLen , pData->width, pData->height );
        
        delete pData;
    }
}

-(UInt64)getTimeMS{
    return [[NSDate date] timeIntervalSince1970]*1000;
}

-(void)delayAutoAdjust {
    VRSoft_AutoAdjust(mVRHandle);
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"---> touchesBegan");
    if(self.iSceneType == XMVR_TYPE_TWO_LENSES){
        self.firstTouchPoint = [touches.anyObject locationInView:self.view];
        return;
    }
    for(UITouch *touch in event.allTouches) {
        CGPoint locInSelf = [touch locationInView:self.view];
        VRSoft_OnTouchDown(mVRHandle, locInSelf.x, locInSelf.y);
        mTouchDownX = locInSelf.x;
        mTouchDownY = locInSelf.y;
        mTimeTouchDown = [self getTimeMS];
        break;
    }
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if(self.iSceneType == XMVR_TYPE_TWO_LENSES){
        return;
    }
    // 最多只处理两个点
    GLfloat values[4];
    int pointerCount = 0;
    for(UITouch *touch in event.allTouches) {
        if ( pointerCount < 2 ) {
            CGPoint locInSelf = [touch locationInView:self.view];
            values[pointerCount*2] = locInSelf.x;
            values[pointerCount*2 + 1] = locInSelf.y;
            pointerCount ++;
            continue;
        } else {
            break;
        }
    }
    
    if ( pointerCount == 1 ) {
        VRSoft_OnTouchMove(mVRHandle, values[0], values[1]);
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //双目进入指哪看哪
    if(self.iSceneType == XMVR_TYPE_TWO_LENSES){
        CGPoint point = [[touches anyObject] locationInView:self.view];
            
        long long recognizeTime = [[NSDate date] timeIntervalSince1970] * 1000;
        if (recognizeTime - self.lastDoubleClickTime >= 500) {
            if (self.vrglViewControllerDelegateDelegate && [self.vrglViewControllerDelegateDelegate respondsToSelector:@selector(vrglViewController:firstPoint:)]) {
                [self.vrglViewControllerDelegateDelegate vrglViewController:point firstPoint:self.firstTouchPoint];
            }
        }
        return;
    }
    for(UITouch *touch in event.allTouches) {
        CGPoint locInSelf = [touch locationInView:self.view];
        VRSoft_OnTouchUp(mVRHandle, locInSelf.x, locInSelf.y);
        UInt64 timeOffset = [self getTimeMS] - mTimeTouchDown;
        if ( timeOffset > 0 && timeOffset < 200 ) {
            double dx = locInSelf.x - mTouchDownX;
            double dy = locInSelf.y - mTouchDownY;
            NSLog(@"---> timeOffset = %llu, dx = %f, dy = %f", timeOffset, dx, dy);
            if((dx > -10 && dx < 10) && (dy > -10 && dy < 10)){
                return;
            }
            
            double velocityX = dx * 1000 / timeOffset;
            double velocityY = dy * 1000 / timeOffset;
            NSLog(@"---> velocityX = %f, velocityY = %f", velocityX, velocityY);
            VRSoft_OnTouchFling(mVRHandle, velocityX*2, velocityY*2);
        }
        // 只处理一个点就可以了
        break;
    }
    
    [self performSelector:@selector(delayAutoAdjust) withObject:nil afterDelay:0.12f];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
    if(self.iSceneType == XMVR_TYPE_TWO_LENSES){
        CGPoint point = [[touches anyObject] locationInView:self.view];
            
        long long recognizeTime = [[NSDate date] timeIntervalSince1970] * 1000;
        if (recognizeTime - self.lastDoubleClickTime >= 500) {
            if (self.vrglViewControllerDelegateDelegate && [self.vrglViewControllerDelegateDelegate respondsToSelector:@selector(vrglViewController:firstPoint:)]) {
                [self.vrglViewControllerDelegateDelegate vrglViewController:point firstPoint:self.firstTouchPoint];
            }
        }
    }
}

- (void) touchesPinch:(UIPinchGestureRecognizer *)recognizer{
    if(self.iSceneType == XMVR_TYPE_TWO_LENSES){
        return;
    }
    VRSoft_OnTouchPinchScale(mVRHandle,recognizer.scale);
}

-(void)DoubleTap:(UITapGestureRecognizer*)recognizer{
    if (mVRType == XMVR_TYPE_180D) {
        int times = 5;
        shapeNum++;
        if (shapeNum == times)
        {
            shapeNum = 0;
        }

        switch (shapeNum) {
            case 0:
                [self setVRShapeType:Shape_Ball];
                break;
            case 1:
                [self setVRShapeType:Shape_Rectangle];
                break;
            case 2:
                [self setVRShapeType:Shape_Cylinder];
                break;
            case 3:
                [self setVRShapeType:Shape_Grid_4R];
                break;
            case 4:
                [self setVRShapeType:Shape_Grid_3R];
                break;
            default:
                break;
        }
    }else if (mVRType == XMVR_TYPE_360D){
        //根据吸顶 还是 壁挂模式  设置双击时的响应的形状
        int times;
        if ( [[NSUserDefaults standardUserDefaults] integerForKey:@"VRShowMode"] == 1) {
            times = 7;
        }else{
            times = 2;
        }
        if (self.VRShowMode == 1) {
            times = 7;
        }else if (self.VRShowMode == 2){
            times = 2;
        }
        
        shapeNum++;
        if (shapeNum == times)
        {
            shapeNum = 0;
        }
        
        switch (shapeNum) {
            case 0:
                [self setVRShapeType:Shape_Ball];
                break;
            case 1:
                [self setVRShapeType:Shape_Rectangle];
                break;
            case 2:
                [self setVRShapeType:Shape_Ball_Bowl];
                break;
            case 3:
                [self setVRShapeType:Shape_Ball_Hat];
                break;
            case 4:
                [self setVRShapeType:Shape_Cylinder];
                break;
            case 5:
                [self setVRShapeType:Shape_Grid_4R];
                break;
            case 6:
                [self setVRShapeType:Shape_Rectangle_2R];
                break;
            default:
                break;
        }
    }
    
    //改变悬浮窗口的按钮状态
    NSString *shapeTag = [NSString stringWithFormat:@"%d",shapeNum];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AcceptDelegate" object:@{@"parameter1":shapeTag}];
}

-(void)setVRShowMode:(int)VRShowMode{
    _VRShowMode = VRShowMode;
    shapeNum = 0;
}

-(void)setChangeModel:(BOOL)changeModel{
    if(changeModel == YES){
        shapeNum = 0;
    }else{
        NSLog(@"the type no change");
    }
}

// 设置双目镜头横向平铺方式时的左右镜头切换(其他模式无效)
-(void)setVRSoftTwoLensesScreen:(XMTwoLensesScreen)screenModel{
    VRSoft_SetTwoLensesScreen(mVRHandle, screenModel);
}

// 设置双目镜头横向平铺方式时当前是左画面还是右画面(其他模式无效)
-(XMTwoLensesScreen)getVRSoftTwoLensesScreen{
    return VRSoft_GetTwoLensesScreen(mVRHandle);
}

// 设置双目镜头显示方式
-(void)setTwoLensesDrawMode:(XMTwoLensesDrawMode)model{
    NSLog(@"\nJFFISH: setTwoLensesDrawMode = %d \n",model);
    VRSoft_SetTwoLensesDrawMode(mVRHandle, model);
}
@end
