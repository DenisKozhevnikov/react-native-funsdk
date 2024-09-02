//
//  ConversionToLattice.m
//  XMFamily
//
//  Created by XM on 14/12/3.
//  Copyright (c) 2014年 XM. All rights reserved.
//

#import "ConversionToLattice.h"

@implementation ConversionToLattice


+(UIImage*)getImageWithResourceView:(UILabel*)lab
{
    if(&UIGraphicsBeginImageContextWithOptions != NULL)
    {
        UIGraphicsBeginImageContextWithOptions(lab.frame.size, NO, 1.0);
    } else {
        UIGraphicsBeginImageContext(lab.frame.size);
    }
    
    [lab.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSString *path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%d.png",123];
    if ([UIImagePNGRepresentation(image) writeToFile:path atomically:YES]) {
        NSLog(@"Succeeded! %@",path);
    }
    else {
        NSLog(@"Failed!");
    }
    return image;
    
}

+(unsigned char*)getLatticeWithImage:(UIImage*)image
{
    CGImageRef imageRef = [image CGImage];
    int width = (int)CGImageGetWidth(imageRef);
    int height = (int)CGImageGetHeight(imageRef);
    
    //从image的data buffer中取得影像，放入格式化后的rawData中
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = new unsigned char[height * width * 4];
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData,width, height, bitsPerComponent, bytesPerRow, colorSpace,kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    //清空CGContextRef再绘制
    CGContextClearRect(context, CGRectMake(0.0, 0.0, width, height));
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    int m = 0, n = 0;
    unsigned char *pRet = new unsigned char[width * height / 8];
    memset(pRet, 0, width * height / 8);
    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            int offset =(int) (bytesPerRow * i) + (int)(bytesPerPixel *j);
            int red = rawData[offset];
            int green = rawData[offset+1];
            int blue = rawData[offset+2];
            if (red > 100 && green > 100 && blue > 100) {
                printf("*");
                pRet[m] |= (0x1 << (7 - n));
            }else{
                printf("-");
            }
            n++;
            if (n == 8)
            {
                m++;
                n = 0;
            }
            
        }
        printf("\n");
    }
    
    return pRet;

}


@end
