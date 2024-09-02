//
//  BlueToothToolManager.m
//  JLink
//
//  Created by 吴江波 on 2022/2/28.
//

#import "BlueToothToolManager.h"
#import "TransferModel.h"
//#import <FunSDK/FunSDK.h>
#import "NSString+Utils.h"
#import "NSDate+Ex.h"

@interface BlueToothToolManager()
@property (nonatomic) NSTimer *timer;//倒计时定时器
@property (nonatomic,assign) int timeRemain;
@property (nonatomic) TransferModel *tranModel;                 //ip地址的表达方式转换
@end

@implementation BlueToothToolManager

- (instancetype)init{
    self = [super init];
    if (self) {
        self.isShowBluetoothTip = NO;
    }
    return self;
}

+(instancetype)sharedBlueToothToolManager{
    static BlueToothToolManager *sharedBlueToothToolManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedBlueToothToolManager = [[BlueToothToolManager alloc] init];
    });
    return sharedBlueToothToolManager;
}

-(void)initBlueTooth{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    [self.blueToothManager initBlueTooth];
}

-(BOOL)getBlueToothOpenState{
    return [self.blueToothManager getBlueToothOpenState];
}

#pragma mark - 开始搜索设备
-(void)startSearch{
    [self.blueToothManager startSearch];
}

-(void)startSearchWithTimeOut:(int)timeout{
    [self.blueToothManager startSearch];
    if (timeout > 0) {
        if (self.timer == nil) {
            self.timeRemain = timeout;
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
            
            [self.timer fire];
        }
    }
}

-(void)onTimer:(NSTimer*)time
{
    if (self.timeRemain > 0) {
        self.timeRemain --;
    }else{
        //超时了
        if (self.timer) {
            [self.timer invalidate];
            self.timer = nil;
        }
        [self stopSearch];
    }
}

-(void)connectPeripheral:(NSString *)mac{
    CBPeripheral *peripheral = [self.devDic objectForKey:mac];
    [self.blueToothManager connectPeripheral:peripheral];
}

#pragma mark - 停止搜索设备
-(void)stopSearch{
    [self.blueToothManager stopSearch];
}

-(void)cancelConnection{
    [self.blueToothManager cancelConnection];
}

#pragma mark - 开始配网添加设备之前的数据处理
-(void)startAddBlueToothDevice:(NSString *)ssid password:(NSString *)password mac:(NSString *)Mac{
    NSData *wifiData = [ssid dataUsingEncoding:NSUTF8StringEncoding];
    NSString *wifiDataHexStr = [NSString xm_hexStringWithData:wifiData];
    int wifiLength = (int)wifiData.length;
    NSString *wifiLengthHexString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",wifiLength]];
    wifiLengthHexString = [self supplement:wifiLengthHexString length:2];
    
    NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    NSString *passwordDataHexStr = [NSString xm_hexStringWithData:passwordData];
    int passLength = (int)passwordData.length;
    NSString *passLengthHexString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",passLength]];
    passLengthHexString = [self supplement:passLengthHexString length:2];

    //wifi信息部分长度
    NSString *wifiInfoHexLength = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",passLength + wifiLength + 3]];
    wifiInfoHexLength = [self supplement:wifiInfoHexLength length:4];
    
    NSString *wifiStr= [NSString stringWithFormat:@"%@%@%@%@%@",wifiLengthHexString,wifiDataHexStr,passLengthHexString,passwordDataHexStr,@"00"];

    int endH = [self decimalStringFromHexString:@"8b8b"] + [self decimalStringFromHexString:@"00"] + [self decimalStringFromHexString:@"01"] + [self decimalStringFromHexString:@"0002"]  + [self decimalStringFromHexString:wifiInfoHexLength] + wifiLength +  [self decimalStringFromHexString:wifiDataHexStr] + passLength +[self decimalStringFromHexString:passwordDataHexStr];
    NSString *endHexStr = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",endH % 256]];
    endHexStr = [self supplement:endHexStr length:2];
    NSString *totalData = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@",@"8B8B",@"00",@"01",@"0002",@"00",wifiInfoHexLength,wifiStr,endHexStr];
    NSString *logStr = [NSString stringWithFormat:@"快速配置流程：SDK_LOG:[APP_BLE][%@]info=%@ \n",[[NSDate date] xm_string],totalData];
//    Fun_Log([logStr UTF8String]);
    [self.blueToothManager writeDataIntoDevice:totalData];
}

#pragma mark - 补0
- (NSString *)supplement:(NSString *)str length:(int)len{
    NSString *resultStr = str;
    int addNum = len - (int)str.length;
    for (int i = 0; i < addNum ; i++) {
        resultStr = [NSString stringWithFormat:@"0%@",resultStr];
    }
    return resultStr;
}

- (int)decimalStringFromHexString:(NSString *)string{
    int stringLength = (int)string.length;
    int length = 0;
    if (string.length == 1) {
        length = [[NSString stringWithFormat:@"%lu",strtoul([string UTF8String],0,16)] intValue];
    }else{
        for(int i = 0 ; i < stringLength / 2;i ++){
            NSString *curStr = [string substringWithRange:NSMakeRange(i * 2, 2)];
            NSString *decimalStr = [NSString stringWithFormat:@"%lu",strtoul([curStr UTF8String],0,16)];
            length = length + [decimalStr intValue];
        }
    }
    return length;
}

#pragma mark - 蓝牙状态改变
-(void)blueToothStateChanged:(CBCentralManager *)central{
    if (@available(iOS 10.0, *)) {
        if(central.state == CBManagerStatePoweredOn)
        {
            XMLog(@"蓝牙设备开着");
            self.isShowBluetoothTip = NO;
        }
        else if (central.state == CBManagerStatePoweredOff)
        {
            XMLog(@"蓝牙设备关着");
            self.isShowBluetoothTip = YES;
        }else {
            XMLog(@"该设备蓝牙未授权或者不支持蓝牙功能");
            self.isShowBluetoothTip = YES;
        }
    } else {
        // Fallback on earlier versions
        self.isShowBluetoothTip = NO;
    }
    
    if (self.blueToothStateBlock) {
        self.blueToothStateBlock(self.isShowBluetoothTip);
    }
}

#pragma mark - 搜索到设备
-(void)foundDev:(NSMutableDictionary *)dic peripheral:(CBPeripheral *)peripheral
{
    if (dic) {
        id kCBAdvDataManufacturerData = [dic objectForKey:@"kCBAdvDataManufacturerData"];
        NSString *newStr = [NSString xm_hexStringWithData:kCBAdvDataManufacturerData];
        if ([newStr containsString:@"8b8b8b8b"]) {
            NSMutableDictionary *serviceData = [dic objectForKey:@"kCBAdvDataServiceData"];
            NSString *name = [dic objectForKey:@"kCBAdvDataLocalName"];
            if (serviceData) {
                NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
                NSString *macStr = @"";
                if (newStr.length >= 16) {
                    //这里和android统一 android是系统方法直接可以获取到mac iOS需要硬件支持
                    NSString *tempMac = [newStr substringWithRange:NSMakeRange(4, 12)];
                    macStr = [NSString stringWithFormat:@"%@%@%@%@%@%@",[tempMac substringWithRange:NSMakeRange(10, 2)],[tempMac substringWithRange:NSMakeRange(8, 2)],[tempMac substringWithRange:NSMakeRange(6, 2)],[tempMac substringWithRange:NSMakeRange(4, 2)],[tempMac substringWithRange:NSMakeRange(2, 2)],[tempMac substringWithRange:NSMakeRange(0, 2)]];
                }

               NSString *strPid = [[NSString alloc]initWithData:[[serviceData allValues] objectAtIndex:0] encoding:enc];
                [self.devDic setObject:peripheral forKey:[NSString stringWithFormat:@"%@%@",macStr,strPid]];
                NSString *logStr = [NSString stringWithFormat:@"快速配置流程：SDK_LOG:[APP_BLE][%@]搜索到设备%@Pid=%@name=%@mac=%@ \n",[[NSDate date] xm_string],dic,strPid,name,macStr];
//                Fun_Log([logStr UTF8String]);
                if (self.blueToothFoundDevice) {
                    self.blueToothFoundDevice(strPid,name,macStr);
                }
            }
        }
    }
}

#pragma mark - 处理返回的数据
-(void)dealWithResponseData:(NSData *)data{
    NSString *responseDataStr = [NSString xm_hexStringWithData:data];
    if (responseDataStr.length >= 22) {
        NSString *result = [responseDataStr substringWithRange:NSMakeRange(18, 2)];
//        Fun_Log([NSString stringWithFormat:@"快速配置流程: 蓝牙配网 特服务征数据解析 UUID：%@（%@） \n",responseDataStr,result].UTF8String);
        if (responseDataStr.length == 22) {
            if ([result isEqualToString:@"01"]) {
                if(self.blueToothResponse){
                    self.blueToothResponse();
                }
            }else{
                if (self.blueToothResponseFailedBlock) {
                    self.blueToothResponseFailedBlock(result);
                }
            }
            return;
        }

        if ([result isEqualToString:@"00"]) {
            NSString *nameLenStr = [responseDataStr substringWithRange:NSMakeRange(20, 2)];
            int nameLen = [self decimalStringFromHexString:nameLenStr];
            NSString *nameStr = [responseDataStr substringWithRange:NSMakeRange(22, nameLen * 2)];
            NSData *namedata = [self convertHexStrToData:nameStr];
            NSString *useName = [[ NSString alloc] initWithData:namedata encoding:NSUTF8StringEncoding];
            NSLog(@"useName = %@",useName);
            
            NSString *passLenStr = [responseDataStr substringWithRange:NSMakeRange(22 + nameLen * 2, 2)];
            int passLen = [self decimalStringFromHexString:passLenStr];
            NSString *passStr = [responseDataStr substringWithRange:NSMakeRange(22 + nameLen * 2 + 2, passLen * 2)];
            NSData *passdata = [self convertHexStrToData:passStr];
            NSString *password = [[ NSString alloc] initWithData:passdata encoding:NSUTF8StringEncoding];
            NSLog(@"password = %@",password);
            
            NSString *snLenStr = [responseDataStr substringWithRange:NSMakeRange(22 + nameLen * 2 + 2 + passLen * 2, 2)];
            int snLen = [self decimalStringFromHexString:snLenStr];
            NSString *snStr = [responseDataStr substringWithRange:NSMakeRange(22 + nameLen * 2 + 2 + passLen * 2 + 2, snLen * 2)];
            NSData *snData = [self convertHexStrToData:snStr];
            NSString *sn = [[ NSString alloc] initWithData:snData encoding:NSUTF8StringEncoding];
            NSLog(@"sn = %@",sn);
            
            NSString *ipStr =  [responseDataStr substringWithRange:NSMakeRange(22 + nameLen * 2 + 2 + passLen * 2 + 2 + snLen * 2 , 8)];
            NSString *ip = [self.tranModel transferString:[NSString stringWithFormat:@"0x%@",ipStr]];
            
            NSString *macStr = [responseDataStr substringWithRange:NSMakeRange(22 + nameLen * 2 + 2 + passLen * 2 + 2 + snLen * 2 + 8 , 12)];
            NSString *mac = [self.tranModel dealWithMacString:macStr];
            
            NSString *token = @"";
            int totalLenth = 22 + nameLen * 2 + 2 + passLen * 2 + 2 + snLen * 2 + 8 + 12 + 2;
            if (responseDataStr.length > totalLenth + 2) {  //返回了token
//                Fun_Log("快速配置流程：蓝牙配网返回token \n");
                NSString *tokenLenStr = [responseDataStr substringWithRange:NSMakeRange(totalLenth - 2, 2)];
                int tokenlen = [self decimalStringFromHexString:tokenLenStr];
                NSString *tokenStr = [responseDataStr substringWithRange:NSMakeRange(totalLenth, tokenlen * 2)];
                NSData *tokenData = [self convertHexStrToData:tokenStr];
                token = [[ NSString alloc] initWithData:tokenData encoding:NSUTF8StringEncoding];
            }

            if (self.blueToothResponseSuccessBlock) {
                self.blueToothResponseSuccessBlock(useName, password, sn,ip ,mac,token,YES);
            }
        }
        else{
            if (self.blueToothResponseFailedBlock) {
                self.blueToothResponseFailedBlock(result);
            }
        }
    }
}

- (NSData *)convertHexStrToData:(NSString *)str
{
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:20];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    return hexData;
}

#pragma mark - lazyload
-(BlueToothManager *)blueToothManager{
    if (!_blueToothManager) {
        _blueToothManager = [[BlueToothManager alloc] init];
//        WeakSelf(weakSelf);
        @XMWeakify(self)
        _blueToothManager.blueToothStateBlock = ^(CBCentralManager * central) {
            [weak_self blueToothStateChanged:central];
        };
        _blueToothManager.blueToothFoundDevice = ^(NSMutableDictionary * _Nonnull dic, CBPeripheral * _Nonnull peripheral) {
            [weak_self foundDev:dic peripheral:peripheral];
        };
        _blueToothManager.blueToothConnectBlock = ^{
            @XMStrongify(self)
            if (self.blueToothConnectSuccessBlock) {
                self.blueToothConnectSuccessBlock();
            }
        };
        _blueToothManager.blueToothResponseBlock = ^(NSData * _Nonnull data) {
            [weak_self dealWithResponseData:data];
        };
        _blueToothManager.blueToothConnectFailedBlock = ^(NSError * _Nonnull error) {
            @XMStrongify(self)
            if (self.blueToothConnectFailedBlock) {
                self.blueToothConnectFailedBlock(error);
            }
        };
    }
    
    return _blueToothManager;
}



-(NSMutableDictionary *)devDic{
    if (!_devDic) {
        _devDic = [[NSMutableDictionary alloc] init];
    }
    
    return _devDic;
}

-(TransferModel *)tranModel{
    if (!_tranModel) {
        _tranModel = [[TransferModel alloc] init];
    }
    return _tranModel;
}

@end
