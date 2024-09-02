//
//  FisheyeBulbConfig.m
//  FunSDKDemo
//
//  Created by zhang on 2019/12/11.
//  Copyright © 2019 zhang. All rights reserved.
//

#import "FisheyeBulbConfig.h"

@interface FisheyeBulbConfig ()
{
    
}
@end

@implementation FisheyeBulbConfig


#pragma mark - SDK回调  这个是必须的
-(void)OnFunSDKResult:(NSNumber *) pParam{
    [super OnFunSDKResult:pParam];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
