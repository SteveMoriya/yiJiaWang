//
//  NSObject+JSContextTracker.h
//  yiJiaWang
//
//  Created by kevin on 16/9/19.
//  Copyright © 2016年 zhuming. All rights reserved.
//

#import "YJBaseViewController.h"

@interface YJScanQRViewController : YJBaseViewController

//扫描区域据屏幕边缘间距
@property(nonatomic, assign) CGFloat spacing;

//扫描成功之后回调
@property (nonatomic, strong) void(^scanQRFinishedBlock)(NSString *url);

@end
