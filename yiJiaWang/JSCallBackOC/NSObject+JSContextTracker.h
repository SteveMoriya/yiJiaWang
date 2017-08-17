//
//  NSObject+JSContextTracker.h
//  yiJiaWang
//
//  Created by kevin on 16/9/19.
//  Copyright © 2016年 zhuming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <UIKit/UIKit.h>
@interface NSObject (JSContextTracker)

+ (NSMapTable *)JSContextTrackerMap;

+ (JSContext *)contextForWebView:(UIWebView *)webView;

@end
