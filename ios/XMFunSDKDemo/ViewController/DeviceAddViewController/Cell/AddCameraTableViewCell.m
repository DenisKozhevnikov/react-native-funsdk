//
//  AddCameraTableViewCell.m
//  XMEye
//
//  Created by 杨翔 on 2020/5/14.
//  Copyright © 2020 Megatron. All rights reserved.
//

#import "AddCameraTableViewCell.h"
#import <Masonry/Masonry.h>

@interface AddCameraTableViewCell()<UITextFieldDelegate>
@end

@implementation AddCameraTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configSubViews];
    }
    return self;
}

-(void)configSubViews{
    [self.contentView addSubview:self.textfield];
    [self.textfield mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.centerX.equalTo(self);
        make.centerY.equalTo(self);
        make.top.equalTo(@5);
    }];
    
    [self.contentView addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.textfield);
        make.centerX.equalTo(self.textfield);
        make.height.equalTo(@0.5);
        make.bottom.equalTo(self);
    }];
}
#pragma mark -- lazyload
-(UITextField *)textfield{
    if (!_textfield) {
        _textfield = [[UITextField alloc] init];
        _textfield.font = [UIFont systemFontOfSize:15];
        _textfield.delegate = self;
    }
    return _textfield;
}

-(UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor lightGrayColor];
        _lineView.alpha = 0.7;
    }
    return _lineView;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([textField.placeholder isEqual:TS("Enter_Device_Port")]){
        NSString * str = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        NSString *userNameregex = @"([0-9])*$";
        NSPredicate *userNamepred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",userNameregex];
        
        BOOL value = [userNamepred evaluateWithObject:str];
        
        if (value){
            if ([str intValue]>65535) {
                return NO;
            }
        }else{
            return NO;
        }
    }
    
    if ([textField.placeholder isEqual:TS("Enter_Device_Name2")] ||[textField.placeholder isEqual:TS("TR_Please_Input_Dev_Name")]){
        if ([NSString isEmoji:string]){
            return NO;
        }else{
            NSString * str = [textField.text stringByReplacingCharactersInRange:range withString:string];
            
            if (str.length>26){
                return NO;
            }
        }
    }
    return YES;
}

@end
