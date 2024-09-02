//
//  JFDevConfigHelper+utils.h
//  FunSDKDemo
//
//  Created by coderXY on 2023/7/27.
//  Copyright © 2023 coderXY. All rights reserved.
//

#import "JFDevConfigHelper.h"

@interface JFDevConfigHelper (utils)
/** 数据解析 */
- (NSDictionary *)jf_jsonHandleWithMsgObj:(const char*)msgObj;
@end

