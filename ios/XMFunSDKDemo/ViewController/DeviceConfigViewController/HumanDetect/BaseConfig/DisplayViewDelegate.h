//
//  DisplayViewDelegate.h
//  XWorld
//
//  Created by liuguifang on 16/5/20.
//  Copyright © 2016年 xiongmaitech. All rights reserved.
//
@class DisplayView;

@protocol DisplayViewDelegate <NSObject>

@required
-(void)displayView:(DisplayView*)dispView ctlBtnClickedWithStatus:(int)status;

@end
