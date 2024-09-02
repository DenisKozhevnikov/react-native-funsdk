//
//  ScanViewController.h
//  FunSDKDemo
//
//  Created by zhang on 2019/6/4.
//  Copyright © 2019 zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ScanBlock) (NSString *);

@interface ScanViewController : UIViewController

@property (nonatomic, copy) ScanBlock block;
@end

NS_ASSUME_NONNULL_END
