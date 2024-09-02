//
//  UIImage+Ex.m
//  XWorld
//
//  Created by liuguifang on 16/6/18.
//  Copyright © 2016年 xiongmaitech. All rights reserved.
//

#import "UIImage+Ex.h"

@implementation UIImage (Ex)

-(UIImage*)grayImage{
    int width = self.size.width;
    int height = self.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate (nil,width,height,8,0,colorSpace,kCGImageAlphaNone);
    CGColorSpaceRelease(colorSpace);
    if (context == NULL) {
        return nil;
    }
    CGContextDrawImage(context,CGRectMake(0, 0, width, height), self.CGImage);
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    UIImage *grayImage = [UIImage imageWithCGImage:cgImage];
    CFRelease(cgImage);
    CGContextRelease(context);
    return grayImage;
}

//MARK:颜色转图片
+(UIImage*)createImageWithColor:(UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIImage *)resizeQRCodeImage:(CIImage *)image withSize:(CGFloat)size{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;

    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
    CGContextRef contextRef = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpaceRef, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef imageRef = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(contextRef, kCGInterpolationNone);
    CGContextScaleCTM(contextRef, scale, scale);
    CGContextDrawImage(contextRef, extent, imageRef);
    CGImageRef imageRefResized = CGBitmapContextCreateImage(contextRef);
    //Release
    CGContextRelease(contextRef);

    CGImageRelease(imageRef);
    
    CGColorSpaceRelease(colorSpaceRef);

    UIImage *theImage = [UIImage imageWithCGImage:imageRefResized];
    
    CFRelease(imageRefResized);
    
    return theImage;
}

//MARK:修改图片大小
+(UIImage*)originImage:(UIImage *)image scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);  //size 为CGSize类型，即你所需要的图片尺寸
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;   //返回的就是已经改变的图片
}

//MARK:修改图片颜色
+ (UIImage *)imageWithImageName:(NSString *)name imageColor:(UIColor *)imageColor {
    UIImage *image = [UIImage imageNamed:name];;

    return [self imageOriginal:image imageColor:imageColor];
}

+ (UIImage *)imageOriginal:(UIImage *)imgOriginal imageColor:(UIColor *)imgColor{
    UIGraphicsBeginImageContextWithOptions(imgOriginal.size, NO, 0.0f);

    [imgColor setFill];

    CGRect bounds = CGRectMake(0, 0, imgOriginal.size.width, imgOriginal.size.height);

    UIRectFill(bounds);

    [imgOriginal drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];

    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return tintedImage;
}

//MARK:旋转图片方向
+(UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation
{
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;

    switch (orientation) {
      case UIImageOrientationLeft:
           rotate =M_PI_2;
           rect =CGRectMake(0,0,image.size.height, image.size.width);
           translateX=0;
           translateY= -rect.size.width;
           scaleY =rect.size.width/rect.size.height;
           scaleX =rect.size.height/rect.size.width;
          break;
      case UIImageOrientationRight:
           rotate =3 *M_PI_2;
           rect =CGRectMake(0,0,image.size.height, image.size.width);
           translateX= -rect.size.height;
           translateY=0;
           scaleY =rect.size.width/rect.size.height;
           scaleX =rect.size.height/rect.size.width;
          break;
      case UIImageOrientationDown:
           rotate =M_PI;
           rect =CGRectMake(0,0,image.size.width, image.size.height);
           translateX= -rect.size.width;
           translateY= -rect.size.height;
          break;
      default:
           rotate =0.0;
           rect =CGRectMake(0,0,image.size.width, image.size.height);
           translateX=0;
           translateY=0;
          break;
    }

    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context =UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX,translateY);
    CGContextScaleCTM(context, scaleX,scaleY);
    //绘制图片

    CGContextDrawImage(context, CGRectMake(0,0,rect.size.width, rect.size.height), image.CGImage);

    UIImage *newPic =UIGraphicsGetImageFromCurrentImageContext();

    return newPic;
}

- (nullable NSArray<NSNumber *> *)pixelColorFromPoint:(CGPoint)point{
    // 判断点是否超出图像范围
    if (!CGRectContainsPoint(CGRectMake(0, 0, self.size.width, self.size.height), point)) return nil;
    
    // 将像素绘制到一个1×1像素字节数组和位图上下文。
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = self.CGImage;
    CGFloat width = self.size.width;
    CGFloat height = self.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = {0, 0, 0, 0};
    CGContextRef context = CGBitmapContextCreate(pixelData, 1, 1, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    // 将指定像素绘制到上下文中
    CGContextTranslateCTM(context, -pointX, pointY - height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, width, height), cgImage);
    CGContextRelease(context);
    
    CGFloat red = (CGFloat)pixelData[0];
    CGFloat green = (CGFloat)pixelData[1];
    CGFloat blue = (CGFloat)pixelData[2];
    
    return @[@(red), @(green), @(blue)];
}

@end
