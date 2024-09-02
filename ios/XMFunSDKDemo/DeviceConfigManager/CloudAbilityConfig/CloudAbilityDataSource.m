//
//  CloudAbilityDataSource.m
//  FunSDKDemo
//
//  Created by XM on 2018/12/27.
//  Copyright © 2018年 XM. All rights reserved.
//

#import "CloudAbilityDataSource.h"

@implementation CloudAbilityDataSource

#pragma mark - 根据能力级读取云服务状态
- (NSString *)getCloudString {
    NSArray *array = [self getCloudArray];
        return array[_cloudState];
}

- (NSString *)getVideoString {
    NSArray *array = [self getPicVideoArray];
    if (_VideoOrPicState == VideoOrPicCloudStateNone || _VideoOrPicState == VideoOrPicCloudState_Pic) {
        return array[0];
    }
    if (_VideoOrPicState == VideoCloudState_Open || _VideoOrPicState == VideoOrPicState_AllOpen) {
        return array[2];
    }
    return array[1];
}

- (NSString *)getPicString {
    NSArray *array = [self getPicVideoArray];
    if (_VideoOrPicState == VideoOrPicCloudStateNone || _VideoOrPicState == VideoOrPicCloudState_Video) {
        return array[0];
    }
    if (_VideoOrPicState == PicCloudState_Open || _VideoOrPicState == VideoOrPicState_AllOpen) {
        return array[2];
    }
    return array[1];
}

- (NSArray *)getCloudArray {
    NSArray *array = @[TS("not_suport"), TS("in_normal_use"), TS("out_of_date"), TS("not_opened")];
    return array;
}
- (NSArray *)getPicVideoArray {
    NSArray *array = @[TS("not_suport"), TS("not_opened"), TS("in_normal_use")];
    return array;
}
@end
