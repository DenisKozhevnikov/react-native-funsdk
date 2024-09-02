//
//  DefaultPoint.h
//  XMEye
//
//  Created by XM on 2017/5/4.
//  Copyright © 2017年 Megatron. All rights reserved.
//
#import <Foundation/Foundation.h>

typedef enum DefaultPoint_Type{
    DefaultPoint_Type_None = 0,
    
    DefaultPoint_Type_LeftToRight = 101, //从左上到右下
    DefaultPoint_Type_RightToLeft, //右下到左上
    DefaultPoint_Type_Mutual,    //双向
    DefaultPoint_Type_Line_Custom,
    
    DefaultPoint_Type_Thr = 201,
    DefaultPoint_Type_Four,
    DefaultPoint_Type_Five,
    DefaultPoint_Type_L,
    DefaultPoint_Type_C,
    DefaultPoint_Type_Area_Custom,
    
    DefaultPoint_Type_Carport = 301, //车库滞留
    DefaultPoint_Type_NO_PARKING, //禁止停车
    DefaultPoint_Type_Corridor,   //走廊
    DefaultPoint_Type_Stay_Custom,
    
    DefaultPoint_Type_Jewelry = 401, //珠宝首饰
    DefaultPoint_Type_Baby_Room,    //宝宝房
    DefaultPoint_Type_sanctum,    //书房
    DefaultPoint_Type_Move_Custom,
}DefaultPoint_Type;
@interface DefaultPoint : NSObject

@property (nonatomic) enum DefaultPoint_Type type;
-(NSMutableArray*)getPointArray:(DefaultPoint_Type)type;
@end
