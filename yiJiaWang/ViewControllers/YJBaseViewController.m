//
//  YJBaseViewController.m
//  yiJiaWang
//
//  Created by kevin on 2016/10/11.
//  Copyright © 2016年 kevin. All rights reserved.
//

#import "YJBaseViewController.h"

@interface YJBaseViewController ()

@end

@implementation YJBaseViewController

- (UIView *)navigationBar{
    if (!_navigationBar) {
        _navigationBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kDEVICEWIDTH, 64)];
        _navigationBar.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1.0];
    }
    return _navigationBar;
}

- (UIButton *)backButton
{
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"back_gray"];
        _backButton.frame = CGRectMake(0, 12+(44-image.size.height)/2, image.size.width, image.size.height);
        [_backButton setImage:image forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchDown];
    }
    return _backButton;
}

- (UILabel *)titleLable
{
    if (!_titleLable) {
        _titleLable = [[UILabel alloc] init];
        _titleLable.font = [UIFont systemFontOfSize:17];
        _titleLable.textColor = [UIColor colorWithRed:33.0/255.0 green:49.0/255.0 blue:74.0/255.0 alpha:1.0];
        _titleLable.textAlignment = NSTextAlignmentCenter;
        [self.navigationBar addSubview:_titleLable];
    }
    return _titleLable;
}

- (void)setNavBarWithTitle:(NSString *)title
{
    self.titleLable.text = title;
    self.titleLable.frame = CGRectMake((kDEVICEWIDTH-200)/2, 10, 200, 44);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backButtonAction:(UIButton *)sender
{};

- (void)addDefaultBackButton
{
    [self.view addSubview:self.navigationBar];
    [self.navigationBar addSubview: self.backButton];
}

@end
