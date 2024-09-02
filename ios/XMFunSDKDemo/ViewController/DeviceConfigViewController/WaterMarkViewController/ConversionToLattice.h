//
//  ConversionToLattice.h
//  XMFamily
//
//  Created by XM on 14/12/3.
//  Copyright (c) 2014年 XM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConversionToLattice : NSObject
//将view属性的控件转换获得image
+(UIImage*)getImageWithResourceView:(UILabel*)lab;

//通过image获取字符点阵
+(unsigned char*)getLatticeWithImage:(UIImage*)image;

@end
