//
//  CHShareView.h
//  TransfarDriver
//
//  Created by Kevin on 15/7/16.
//  Copyright (c) 2015年 Transfar. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_OPTIONS(NSUInteger, TFSharePlatformTypeOptions){
    
    TFSharePlatformTypeWeiXin = 1 << 0,
    TFSharePlatformTypeWeixinPengYouQuan = 1 << 1,
    TFSharePlatformTypeQQ = 1 << 2,
    TFSharePlatformTypeZone = 1 << 3,
    TFSharePlatformTypeSinaWeibo =1 << 4,
    TFSharePlatformTypeCopy = 1 << 5,
    TFSharePlatformTypeMessage = 1 << 6,
    TFAll = 1111111
};

@protocol CHShareViewDelegate <NSObject>
@optional
- (void)didShareButtonClick:(TFSharePlatformTypeOptions)TFSharePlatformType;

@end


@interface CHShareView : UIView

@property (nonatomic, strong)  UIView              *backGroundView;
@property (nonatomic, strong)  UILabel             *titleLab;
@property (nonatomic, copy)    NSString            *title;
@property (nonatomic, strong)  UIButton            *cancelButton;

@property (nonatomic, weak)id<CHShareViewDelegate>delegate;

- (id)initWithSharePlatfromTypeOptions:(TFSharePlatformTypeOptions)options;

- (void)showInView:(UIView *)view;

- (void)hideView;

@end

