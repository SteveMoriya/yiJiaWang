//
//  YJAudioPlayManager.h
//  yiJiaWang
//
//  Created by kevin on 2016/10/17.
//  Copyright © 2016年 kevin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YJAudioPlayManager : NSObject

+ (YJAudioPlayManager *)shareInstance;

- (void)playAudioWithName:(NSString *)audioName;
@end
