//
//  JSCallbackOCMethods.m
//  yiJiaWang
//
//  Created by kevin on 16/9/19.
//  Copyright © 2016年 zhuming. All rights reserved.
//

#import "JSCallbackOCMethods.h"

static JSCallbackOCMethods *CallBackOCMethod = nil;
static dispatch_once_t  onceToken;

@implementation JSCallbackOCMethods

+ (JSCallbackOCMethods *)sharedInstance
{
  dispatch_once(&onceToken, ^{
     
      CallBackOCMethod = [[JSCallbackOCMethods alloc]init];
  });
    return CallBackOCMethod;
}

- (void)scanQRCode
{
    if (_myBlcok) {
        _myBlcok();
    }
}

- (void)playAudio:(NSString *)audioName
{
    if (_playAudioBlcok) {
        
        _playAudioBlcok(audioName);
    }
}

- (void)openUrl:(NSString *)urlString
{
    if (_openURLBlock) {
        
        _openURLBlock(urlString);
    }
}

- (void)getYijiawangUserId:(NSString *)userid
{
    if (_getUseridBlock) {
        _getUseridBlock(userid);
    }
}

- (void)showShareView:(NSString *)shareContent
{
    if (_showShareViewBlcok) {
        _showShareViewBlcok(shareContent);
    }
}

@end
