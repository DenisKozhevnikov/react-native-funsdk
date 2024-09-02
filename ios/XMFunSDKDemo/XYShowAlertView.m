//
//  XYShowAlertView.m
//
//
//  Created by 杨 on 16/1/12.
//  Copyright © 2016年 杨. All rights reserved.
//

#import "XYShowAlertView.h"
#import <Masonry/Masonry.h>
//#import "AppDelegate.h"
#import <Photos/Photos.h>

#define DefaultHeight 70

// 屏幕的宽度 和 高度
#define ScreenWidth [[UIScreen mainScreen] bounds].size.width
#define APP_STATUSBAR_HEIGHT (CGRectGetHeight([UIApplication sharedApplication].statusBarFrame))
#define ScreenHeight ([[UIScreen mainScreen] bounds].size.height+20-APP_STATUSBAR_HEIGHT)
#define NavBarBGColor GET_COLOR(30,190,165,1)
#define GET_COLOR(r,g,b,a) [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a]

@interface XYShowAlertView ()

@property (nonatomic,strong) UILabel *lbTitle;
@property (nonatomic,strong) UILabel *lbContent;
@property (nonatomic,strong) UIImageView *imageV;
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UILabel *timeLabel;

@end

@implementation XYShowAlertView

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, -100, ScreenWidth, DefaultHeight);
        self.backgroundColor = [UIColor colorWithRed:39/255.0 green:39/255.0 blue:39/255.0 alpha:0.7];
        self.backgroundColor = [UIColor blackColor];
        self.windowLevel = UIWindowLevelAlert;
        self.hidden = NO;
        
        //
//        AppDelegate *delegate = (AppDelegate *)([UIApplication sharedApplication].delegate);
//        [self mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.equalTo(delegate.window);
//        }];
        
        self.imageV = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 20, 20)];
        self.imageV.image = [UIImage imageNamed:@"AppIcon.png"];
        self.imageV.backgroundColor = [UIColor clearColor];
        self.imageV.layer.cornerRadius = 3;
        self.imageV.layer.masksToBounds = YES;
        [self addSubview:self.imageV];
        
        self.lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.imageV.frame) + 10, self.imageV.center.y - 7, 56, 14)];
        self.lbTitle.textAlignment = NSTextAlignmentLeft;
        self.lbTitle.textColor = [UIColor whiteColor];
        self.lbTitle.font = [UIFont systemFontOfSize:14];
        self.lbTitle.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.lbTitle];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.lbTitle.frame) + 10, self.imageV.center.y - 7, 50, 12)];
        self.timeLabel.textAlignment = NSTextAlignmentLeft;
        self.timeLabel.text = TS("Now");
        self.timeLabel.textColor = NavBarBGColor;
        self.timeLabel.font = [UIFont systemFontOfSize:12];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.timeLabel];
        
        self.lbContent = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.imageV.frame) + 10, CGRectGetMaxY(self.lbTitle.frame) + 5, ScreenWidth - 60, 25)];
        self.lbContent.textColor = [UIColor whiteColor];
        self.lbContent.font = [UIFont systemFontOfSize:13];
        self.lbContent.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.lbContent];
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapActionHappened)];
        recognizer.numberOfTapsRequired = 1;
        recognizer.numberOfTouchesRequired = 1;
        
        [self addGestureRecognizer:recognizer];
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 5)];
        self.imageView.layer.cornerRadius = 2.5;
        self.imageView.layer.masksToBounds = YES;
        self.imageView.backgroundColor = [UIColor whiteColor];
        self.imageView.center = CGPointMake(self.frame.size.width/2.0, DefaultHeight - 7);
        
        [self addSubview:self.imageView];
    }
    
    return self;
}

static XYShowAlertView *alertView;

+(instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        alertView = [[XYShowAlertView alloc] init];
    
    });
    
    return alertView;
}

-(void)showAlertViewWithTitle:(NSString *)title andDetailText:(NSString *)detailText{    
    self.hidden = NO;
    
    self.lbTitle.text = title;
    
    CGSize size1 = CGSizeMake(MAXFLOAT, 14);
    CGRect rect1 = [title boundingRectWithSize:size1 options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil];
    
    self.lbTitle.frame = CGRectMake(CGRectGetMaxX(self.imageV.frame) + 10, self.imageV.center.y - 7, rect1.size.width, 14);
    self.timeLabel.frame = CGRectMake(CGRectGetMaxX(self.lbTitle.frame) + 10, self.imageV.center.y - 7, 50, 12);
    
    self.lbContent.font = [UIFont systemFontOfSize:13];
    self.lbContent.numberOfLines = 5;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:detailText];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:6];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [detailText length])];
    
    self.lbContent.attributedText = attributedString;
    
    CGFloat screenWidth = ScreenWidth < ScreenHeight ? ScreenWidth : ScreenHeight;
    
    CGSize size = CGSizeMake(screenWidth - 60, MAXFLOAT);
    CGRect rect = [detailText boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil];
    
    if (rect.size.height < DefaultHeight) {
         self.frame = CGRectMake(0, -100, screenWidth, DefaultHeight);
         self.imageView.center = CGPointMake(self.frame.size.width/2.0, DefaultHeight - 7);
         self.lbContent.frame = CGRectMake(CGRectGetMaxX(self.imageV.frame) + 10, CGRectGetMaxY(self.lbTitle.frame) + 5, screenWidth - 60, 25 + 25);
    }
    else{
        self.frame = CGRectMake(0, -100, screenWidth, rect.size.height + 10);
        self.imageView.center = CGPointMake(self.frame.size.width/2.0, CGRectGetMaxY(self.lbContent.frame) + 10 - 7);
        self.lbContent.frame = CGRectMake(CGRectGetMaxX(self.imageV.frame) + 10, CGRectGetMaxY(self.lbTitle.frame) + 5, screenWidth - 60, rect.size.height);
    }
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^(){
        if (CGRectGetMaxY(self.lbContent.frame) < DefaultHeight) {
            self.frame = CGRectMake(0, 0, screenWidth, DefaultHeight);
        }
        else{
            self.frame = CGRectMake(0, 0, screenWidth, CGRectGetMaxY(self.lbContent.frame) + 10);
            self.imageView.center = CGPointMake(self.frame.size.width/2.0, CGRectGetMaxY(self.frame) - 7);
        }
    }completion:nil];
    
    __weak typeof(self) blockSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (alertView.hidden == NO) {
            alertView.hidden = YES;
        }
        //[blockSelf tapActionHappened];
        if (CGRectGetMaxY(self.lbContent.frame) < DefaultHeight) {
            blockSelf.frame = CGRectMake(0, -100, screenWidth, DefaultHeight);
        }
        else{
            blockSelf.frame = CGRectMake(0, -100, screenWidth, CGRectGetMaxY(self.lbContent.frame) + 10);
        }
    });
}

-(void)tapActionHappened
{
    if (self.showAlertViewClicked) {
        self.showAlertViewClicked(1);
    }
    if (alertView.hidden == NO) {
        alertView.hidden = YES;
    }
}

@end
