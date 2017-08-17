//
//  YJGuideView.h
//  yiJiaWang
//
//  Created by kevin on 2016/10/14.
//  Copyright © 2016年 kevin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YJGuideView : UIView

@property (nonatomic, strong) void(^scrollFinishBlock)(void);
@property (nonatomic, strong) void(^loginButtonOrRegisterButtonBlock)(NSInteger buttonTag);
@end
