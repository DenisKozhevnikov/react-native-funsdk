//
//  QRCodeImageShowView.h
//  FunSDKDemo
//
//  Created by P on 2020/8/11.
//  Copyright © 2020 P. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QRCodeImageShowView : UIView

@property (nonatomic,copy) void (^disMissSelfView)(void);

@property (nonatomic,strong)UIImage *qrCodeImage;

-(void)setQrCodeImage:(UIImage *)qrCodeImage;

@end

NS_ASSUME_NONNULL_END
