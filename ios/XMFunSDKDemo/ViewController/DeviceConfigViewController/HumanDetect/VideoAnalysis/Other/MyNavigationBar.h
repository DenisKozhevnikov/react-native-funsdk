//
//  MyNavigationBar.h
//  XMEye
//
//  Created by Megatron on 12/5/14.
//  Copyright (c) 2014 Megatron. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MyNavigationBarDelegate <NSObject>
@optional
-(void)navigationBarEventLeft;
-(void)navigationBarEventRight;
-(void)navigationBarEventTitle;
@end

@interface MyNavigationBar : UIView

@property (nonatomic,strong) UIImageView *imgView;
@property (nonatomic,strong) UIImageView *titleImg;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UIButton *btnLeft;
@property (nonatomic,strong) UIButton *btnRight;
@property (nonatomic,strong) UIButton *btnRank;
@property (nonatomic,strong) NSMutableArray *arrayRubbish;
@property (nonatomic,assign) BOOL ifShow;
@property (nonatomic,assign) id <MyNavigationBarDelegate> delegate;

-(void)showMyNavBar;

@end
