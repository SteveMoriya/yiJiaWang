//
//  NSObject+JSContextTracker.m
//  yiJiaWang
//
//  Created by kevin on 16/9/19.
//  Copyright © 2016年 zhuming. All rights reserved.
//

#import "NSObject+JSContextTracker.h"
#import "JSCallbackOCMethods.h"
@implementation NSObject (JSContextTracker)

+ (NSMapTable *)JSContextTrackerMap {
    static NSMapTable *contextTracker;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        contextTracker = [NSMapTable strongToWeakObjectsMapTable];
    });
    return contextTracker;
}

- (void)webView:(id)unused didCreateJavaScriptContext:(JSContext *)ctx forFrame:(id)alsoUnused {
    NSAssert([ctx isKindOfClass:[JSContext class]], @"bad context");
    if (!ctx)
        return;
    NSMapTable *map = [NSObject JSContextTrackerMap];
    static long contexts = 0;
    NSString *contextKey = [NSString stringWithFormat:@"jsctx_%@", @(contexts++)];
    [map setObject:ctx forKey:contextKey];
    ctx[@"JSContextTrackerMapKey"] = contextKey; // store the key to the map in the context itself
    //实现JS回调OC函数
    JSCallbackOCMethods *tf56 = [JSCallbackOCMethods sharedInstance];
    ctx[@"tf56"] = tf56;
}

+ (JSContext *)contextForWebView:(UIWebView *)webView {
    // this will trigger didCreateJavaScriptContext if it hasn't already been called
    //    NSString *contextKey = [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%lu", (unsigned long)webView.hash]];
    JSContext *ctx = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    JSCallbackOCMethods *tf56 = [JSCallbackOCMethods sharedInstance];
    ctx[@"tf56"] = tf56;
    return ctx;
}


@end
