//
//  YJAudioPlayManager.m
//  yiJiaWang
//
//  Created by kevin on 2016/10/17.
//  Copyright © 2016年 kevin. All rights reserved.
//

#import "YJAudioPlayManager.h"
#import <AVFoundation/AVFoundation.h>

@interface YJAudioPlayManager ()<AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end

static YJAudioPlayManager *audioPlayManager = nil;
static dispatch_once_t once;

@implementation YJAudioPlayManager

- (AVAudioPlayer *)audioPlayer:(NSString *)audioName
{
    NSString *path = [[NSBundle mainBundle] pathForResource:audioName ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:path];
    if (url) {
        
        if ([_audioPlayer isPlaying]) {
            
            [self stopPlay];
        }
        NSError *error;
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        _audioPlayer.volume = 1.0;
        _audioPlayer.numberOfLoops = 0;
        _audioPlayer.delegate = self;
        [_audioPlayer prepareToPlay];
    }
    return _audioPlayer;
}

+ (YJAudioPlayManager *)shareInstance
{
   dispatch_once(&once, ^{
      
       audioPlayManager = [[YJAudioPlayManager alloc]init];
       
   });
    return audioPlayManager;
}

- (void)playAudioWithName:(NSString *)audioName
{
    _audioPlayer = [self audioPlayer:audioName];
    
    [_audioPlayer play];
   
}

- (void)stopPlay
{
    [_audioPlayer  stop];
    _audioPlayer = nil;
}

#pragma mark-- AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self stopPlay];
}

@end
