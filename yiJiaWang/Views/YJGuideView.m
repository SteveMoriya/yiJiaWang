//
//  YJGuideView.m
//  yiJiaWang
//
//  Created by kevin on 2016/10/14.
//  Copyright © 2016年 kevin. All rights reserved.
//

#import "YJGuideView.h"

@interface YJGuideView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollerView;
@property (nonatomic, strong) NSArray      *guideImages;
@property (nonatomic, strong) UIButton     *jumpButton;
@property (nonatomic, strong) UIButton     *loginButton;
@property (nonatomic, strong) UIButton     *registerButton;

@end

@implementation YJGuideView

- (NSArray *)guideImages
{
    if (!_guideImages) {
        
        _guideImages = @[@"1.jpg",@"2.jpg",@"3.jpg",@"4.jpg",@"5.jpg",@"6.jpg",@"7.jpg"];
    }
    return _guideImages;
}

- (UIButton *)jumpButton
{
    if (!_jumpButton) {
        
        _jumpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_jumpButton setTitle:@"跳过" forState:UIControlStateNormal];
        [_jumpButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _jumpButton.frame = CGRectMake(kDEVICEWIDTH-90, kDEVICEHEIGHT-140, 80, 80);
        if (iPhone5||iPhone4) {
            _jumpButton.frame = CGRectMake(kDEVICEWIDTH-80, kDEVICEHEIGHT-140, 80, 80);
        }
        [_jumpButton addTarget:self action:@selector(removeSelfClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _jumpButton;
}

- (UIButton *)loginButton
{
    if (!_loginButton) {
        
        _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _loginButton.frame = CGRectMake(12, kDEVICEHEIGHT-60,(kDEVICEWIDTH-24)/2, 50);
        _loginButton.tag = 100;
        [_loginButton addTarget:self action:@selector(loginOrRegisterBUttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginButton;
}

- (UIButton *) registerButton
{
    if (!_registerButton) {
        
        _registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _registerButton.tag = 101;
        [_registerButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _registerButton.frame = CGRectMake((kDEVICEWIDTH-24)/2+5, kDEVICEHEIGHT-60,(kDEVICEWIDTH-24)/2-5, 50);
        [_registerButton addTarget:self action:@selector(loginOrRegisterBUttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _registerButton;
}



- (UIScrollView *)scrollerView
{
    if (!_scrollerView) {
        
        _scrollerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        _scrollerView.delegate = self;
        _scrollerView.showsHorizontalScrollIndicator = NO;
        _scrollerView.pagingEnabled = YES;
        [_scrollerView setContentSize:CGSizeMake(CGRectGetWidth(self.frame)*self.guideImages.count, CGRectGetHeight(self.frame))];
         [self addSubview:_scrollerView];
        
        for (int i=0; i<self.guideImages.count; i++) {
            
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_scrollerView.frame)*i, 0, CGRectGetWidth(_scrollerView.frame), CGRectGetHeight(_scrollerView.frame))];
            imgView.image = [UIImage imageNamed:self.guideImages[i]];
            [_scrollerView addSubview:imgView];
            
            if (i==self.guideImages.count-1) {
                
                imgView.userInteractionEnabled = YES;
                [imgView addSubview:self.loginButton];
                [imgView addSubview:self.registerButton];
            }
        }
        
    }
    return _scrollerView;
}

- (instancetype) initWithFrame:(CGRect)frame
{
    self  =  [super initWithFrame:frame];
    if (self) {
      
        [self.scrollerView setContentOffset:CGPointMake(0, 0)];
        [[UIApplication sharedApplication].keyWindow addSubview:self.jumpButton];
    }
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x>6*CGRectGetWidth(self.frame)+70.0) {
        
        [self removeSelfClick:nil];
    }
}

- (void)removeSelfClick:(id)sender
{
    [UIView animateWithDuration:0.4 animations:^{
        
        self.alpha = 0.0f;
        self.jumpButton.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
       
        [self removeFromSuperview];
        [self.jumpButton removeFromSuperview];
        
        if (_scrollFinishBlock) {
            
            _scrollFinishBlock();
        }
    }];
}

- (void)loginOrRegisterBUttonClick:(UIButton *)button
{
    [UIView animateWithDuration:0.4 animations:^{
        
        self.alpha = 0.0f;
        self.jumpButton.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
        [self.jumpButton removeFromSuperview];
        
        if (_scrollFinishBlock) {
            
            _scrollFinishBlock();
        }
        
        if (_loginButtonOrRegisterButtonBlock) {
            _loginButtonOrRegisterButtonBlock(button.tag);
        }
    }];
    
}

@end
