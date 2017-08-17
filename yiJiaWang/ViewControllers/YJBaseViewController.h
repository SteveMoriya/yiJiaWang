//
//  YJBaseViewController.h
//  yiJiaWang
//
//  Created by kevin on 2016/10/11.
//  Copyright © 2016年 kevin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YJBaseViewController : UIViewController

@property (nonatomic, strong) UIView   *navigationBar;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel  *titleLable;

- (void)addDefaultBackButton;
- (void)setNavBarWithTitle:(NSString *)title;
- (void)backButtonAction:(UIButton *)sender;

@end
