//
//  NSObject+JSContextTracker.h
//  yiJiaWang
//
//  Created by kevin on 16/9/19.
//  Copyright © 2016年 zhuming. All rights reserved.
//
#import <UIKit/UIKit.h>


@interface YJUtilScanQRView : UIView

@property(nonatomic, assign) CGFloat    spacing;

- (instancetype)initWithFrame:(CGRect)frame withSpacing:(CGFloat)spacing;

- (void)stopShadeLineAnimation;
- (void)startShadeLineAnimation;

@end
