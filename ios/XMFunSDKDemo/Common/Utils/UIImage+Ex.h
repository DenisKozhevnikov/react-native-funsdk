//
//  UIImage+Ex.h
//  XWorld
//
//  Created by liuguifang on 16/6/18.
//  Copyright © 2016年 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Ex)

//灰阶图
-(UIImage*)grayImage;

//MARK:颜色转图片
+(UIImage*)createImageWithColor:(UIColor*) color;

+ (UIImage *)resizeQRCodeImage:(CIImage *)image withSize:(CGFloat)size;

//MARK:修改图片大小
+(UIImage*)originImage:(UIImage *)image scaleToSize:(CGSize)size;

//MARK:修改图片颜色
+ (UIImage *)imageWithImageName:(NSString *)name imageColor:(UIColor *)imageColor;
+ (UIImage *)imageOriginal:(UIImage *)imgOriginal imageColor:(UIColor *)imgColor;

//MARK:旋转图片方向
+(UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation;

/**
 @brief 获取图片某个位置的RGB值
 @param point 需要取值的位置
 @return NSArray 返回@[@R,@G,@B]数组
 */
- (nullable NSArray<NSNumber *> *)pixelColorFromPoint:(CGPoint)point;

@end
