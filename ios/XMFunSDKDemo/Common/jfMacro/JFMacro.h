//
//  JFMacro.h
//  FunSDKDemo
//
//  Created by coderXY on 2023/7/26.
//  Copyright © 2023 coderXY. All rights reserved.
//

#ifndef JFMacro_h
#define JFMacro_h

#ifdef DEBUG
# define XMLog(fmt, ...) NSLog((@"[文件名:%s]\n" "[函数名:%s]\n" "[行号:%d] \n" fmt), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
# define XMLog(...);
#endif

// MARK: 主线程
/** 判断当前线程是否为主线程 */
#ifndef dispatch_main_async_safe
#define dispatch_main_async_safe(block)\
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {\
        block();\
    } else {\
        dispatch_async(dispatch_get_main_queue(), block);\
    }
#endif

// MARK: 弱引用
/** 弱引用，使用方法：@XMWeakify(self) */
#ifndef XMWeakify
    #if DEBUG
        #if __has_feature(objc_arc)
            #define XMWeakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
        #else
            #define XMWeakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
        #endif
    #else
        #if __has_feature(objc_arc)
            #define XMWeakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
        #else
            #define XMWeakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
        #endif
    #endif
#endif
// MARK: 强引用
/** 弱引用，使用方法：@XMStrongify(self),使用此方法时需先使用 XMWeakify */
#ifndef XMStrongify
    #if DEBUG
        #if __has_feature(objc_arc)
            #define XMStrongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
        #else
            #define XMStrongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
        #endif
#else
        #if __has_feature(objc_arc)
            #define XMStrongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
        #else
            #define XMStrongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
        #endif
    #endif
#endif

///** 两字符串是否相等 */
//#define JF_IsEqualToStr(strX, strY) [strX isEqualToString:strY]

#endif /* JFMacro_h */
