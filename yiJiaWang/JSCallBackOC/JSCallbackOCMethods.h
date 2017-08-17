//
//  NSObject+JSContextTracker.h
//  yiJiaWang
//
//  Created by kevin on 16/9/19.
//  Copyright © 2016年 zhuming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

typedef void(^scanQRCodeMethodBlock)();
typedef void(^playAudioMethodBlock)(NSString *audioName);
typedef void(^openURLBySystemBrowserMethodBlock)(NSString *url);
typedef void(^getYijiawangUserIdMethodBlock)(NSString *userid);
typedef void(^showShareViewMethodBlock)(NSString *shareContent);

@protocol JSCallbackOCMethodsProtocol <JSExport>

- (void)scanQRCode;

- (void)playAudio:(NSString *)audioName;

- (void)openUrl:(NSString *)urlString;

- (void)getYijiawangUserId:(NSString *)userid;

- (void)showShareView:(NSString *)shareContent;
@end

@interface JSCallbackOCMethods : NSObject <JSCallbackOCMethodsProtocol>

+ (JSCallbackOCMethods *)sharedInstance;

//跳转扫一扫
@property (nonatomic, strong) scanQRCodeMethodBlock myBlcok;

//播放声音
@property (nonatomic, strong) playAudioMethodBlock  playAudioBlcok;

//唤起系统浏览器进行打开网页
@property (nonatomic, strong) openURLBySystemBrowserMethodBlock openURLBlock;

//获取userid
@property (nonatomic, strong) getYijiawangUserIdMethodBlock     getUseridBlock;

//调用分享
@property (nonatomic, strong) showShareViewMethodBlock          showShareViewBlcok;
@end

