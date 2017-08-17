//
//  AppDelegate.h
//  yiJiaWang
//
//  Created by kevin on 16/10/10.
//  Copyright © 2016年 kevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) Reachability *reachability;

@end

