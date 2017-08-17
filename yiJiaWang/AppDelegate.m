//
//  AppDelegate.m
//  yiJiaWang
//
//  Created by kevin on 16/10/10.
//  Copyright © 2016年 kevin. All rights reserved.
//
#define AppStore_ID @"1107357472"

#import "AppDelegate.h"
#import "ViewController.h"
#import "JPUSHService.h"
#import "WXApi.h"
#import <UserNotifications/UserNotifications.h>
#import <UMSocialCore/UMSocialCore.h>

static NSString *UmengKey = @"58216cdcf29d9853c3000ab6";
static NSString *WechatId = @"wx4d919f8edee78307";
static NSString *WechatAppSecret = @"c7a79ffd6019548be55719673ada592c";
static NSString *QQAppId = @"1105782148";
static NSString *QQAppKey = @"KEYH2w1vvPU9YWkSiSm";
static NSString *sinaAppKey = @"3388640731";
static NSString *sinaAppSecret = @"34f84725d5c9ff06ed2d88d5bb1db2ab";

static NSString *BaseShareURL = @"https://itunes.apple.com/cn/app/com.yjw.yiJia/id1107357472?mt=8";

#define WX_APPID @"wx4d919f8edee78307"

@interface AppDelegate ()<JPUSHRegisterDelegate,WXApiDelegate>

@property (nonatomic, strong) ViewController *rootViewController;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //检查app是否需要更新
    //[self hsUpdateApp];
    
    //页面缓存策略
    [[NSUserDefaults standardUserDefaults] setInteger:2 forKey: @"WebKitCacheModelPreferenceKey"];
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey: @"WebKitMediaPlaybackAllowsInline"];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor redColor];
    
    self.rootViewController = [[ViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.rootViewController];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    self.reachability = [Reachability reachabilityWithHostname:@"https://www.baidu.com/"];
    
    [self registerAPNS:launchOptions];
    
    [self initUMParameter];
    
    [[UIApplication sharedApplication]setApplicationIconBadgeNumber:0];
    [application cancelAllLocalNotifications];
    [JPUSHService resetBadge];
    
    return YES;
}


- (void)initUMParameter
{
    // 设置友盟appKey、发送策略、渠道id(nil或者@""时默认渠道为@"App Store"渠道。)

    [[UMSocialManager defaultManager] openLog:YES];
    
    [[UMSocialManager defaultManager] setUmSocialAppkey:UmengKey];

    //设置微信AppId、appSecret,分享url
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:WechatId appSecret:WechatAppSecret redirectURL:BaseShareURL];
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatTimeLine appKey:WechatId appSecret:WechatAppSecret redirectURL:BaseShareURL];
    
    //设置QQId、appKey,分享url
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:QQAppId appSecret:QQAppKey redirectURL:BaseShareURL];
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Qzone appKey:QQAppId appSecret:QQAppKey redirectURL:BaseShareURL];
    
    //设置微博appKey,Appsecret
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:sinaAppKey appSecret:sinaAppSecret redirectURL:BaseShareURL];
    
    
    //注册微信支付
    [WXApi registerApp:WX_APPID];
}

- (void)registerAPNS:(NSDictionary *)launchOptions
{
    if (IOS10) {
        
        JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
        entity.types = UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound;
        [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    }
    else if (IOS8_10) {
        
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)
                                              categories:nil];
    }
    else {
        
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                    UIRemoteNotificationTypeSound |
                                                          UIRemoteNotificationTypeAlert)
                                              categories:nil];
    }
    
#ifdef DEBUG
    [JPUSHService setupWithOption:launchOptions appKey:@"225483c7cd20b1c9dfd0ce63" channel:@"JPush" apsForProduction:NO advertisingIdentifier:nil];
#else
    [JPUSHService setupWithOption:launchOptions appKey:@"225483c7cd20b1c9dfd0ce63" channel:@"appStore" apsForProduction:YES advertisingIdentifier:nil];
#endif

}

#pragma mark-- 处理推送
- (void)handleRemoteNotification:(NSDictionary *)launchOptions
{
    //判断是否点击了apns才导致启动app
    NSDictionary *remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotification) {
        
        YJLog(@"__%@",remoteNotification);
        [self remoteNotificationWithUserInfo:remoteNotification];
    }
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    YJLog(@"注册APNs成功并上报DeviceToken");
    [JPUSHService registerDeviceToken:deviceToken];
    
    NSLog(@"____%@",[JPUSHService registrationID]);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
  
    YJLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
   
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
   
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler();
    
    //iOS10 处理远程推送消息
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive) {
        
        NSDictionary *userInfo = response.notification.request.content.userInfo;
        [self remoteNotificationWithUserInfo:userInfo];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    [JPUSHService handleRemoteNotification:userInfo];
    
//    [[UIApplication sharedApplication]setApplicationIconBadgeNumber:0];
//    [application cancelAllLocalNotifications];
//    [JPUSHService resetBadge];
    
    completionHandler(UIBackgroundFetchResultNewData);
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive) {
        
        [self remoteNotificationWithUserInfo:userInfo];
  }
}

#pragma mark-- 处理推送过来的链接
- (void)remoteNotificationWithUserInfo:(NSDictionary *)userInfo{
    
    if (userInfo) {
        NSString *urlString = [[userInfo objectForKey:@"extras"]objectForKey:@"linkUrl"];
        if (urlString) {
            
            NSString *userid = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
            urlString = [NSString stringWithFormat:@"%@&visitType=1&userid=%@",urlString,userid];
            [self.rootViewController loadWebView:urlString];
        }
    }
    
}

//网页直接跳转app支持,添加微信支付回调
- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    if ([[NSString stringWithFormat:@"%@",url] rangeOfString:[NSString stringWithFormat:@"%@://pay",WX_APPID]].location != NSNotFound) {
        return  [WXApi handleOpenURL:url delegate:self];
    }
    
    if (!url) {
        return NO;
    } else  {
        return YES;
    }
    return YES;
    
}

- (BOOL) application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    ////????
    
    if ([[NSString stringWithFormat:@"%@",url] rangeOfString:[NSString stringWithFormat:@"%@://pay",WX_APPID]].location != NSNotFound) {
        return  [WXApi handleOpenURL:url delegate:self];
    }
    
    
    if (!url) {
        return NO;
    } else  {
        
        NSString* urlString = [url absoluteString];
        [self.rootViewController loadWebView:urlString];
        
        return YES;
    }
    
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    return [WXApi handleOpenURL:url delegate:self];
}


//微信回调方法
-(void)onResp:(BaseResp*)resp {
    //这里判断回调信息是否为 支付
    if([resp isKindOfClass:[PayResp class]]) {
        switch (resp.errCode) {
            case WXSuccess:
                //如果支付成功的话发送一个通知，支付成功
                [[NSNotificationCenter defaultCenter] postNotificationName:@"userPaySuccess" object:nil];
                break;
            default:
                //如果支付失败的话，全局发送一个通知，支付失败
                [[NSNotificationCenter defaultCenter] postNotificationName:@"userPayFailed" object:nil];
                break;
        }
    }
}



/**
 *  天朝专用检测app更新
 */
-(void)hsUpdateApp
{
    //2先获取当前工程项目版本号
    NSDictionary *infoDic=[[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion=infoDic[@"CFBundleShortVersionString"];
    
    //3从网络获取appStore版本号
    NSError *error;
    NSData *response = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/cn/lookup?id=%@",AppStore_ID]]] returningResponse:nil error:nil];
    if (response == nil) {
        NSLog(@"你没有连接网络哦");
        return;
    }
    NSDictionary *appInfoDic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
    if (error) {
        NSLog(@"hsUpdateAppError:%@",error);
        return;
    }
    NSArray *array = appInfoDic[@"results"];
    NSDictionary *dic = array[0];
    NSString *appStoreVersion = dic[@"version"];
    //打印版本号
    NSLog(@"当前版本号:%f\n商店版本号:%f",[currentVersion floatValue],[appStoreVersion floatValue]);
    //4当前版本号小于商店版本号,就更新
    if([currentVersion floatValue] < [appStoreVersion floatValue])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"版本有更新" message:[NSString stringWithFormat:@"检测到新版本(%@),是否更新?",appStoreVersion] delegate:self cancelButtonTitle:@"取消"otherButtonTitles:@"更新",nil];
        [alert show];
    }else{
        NSLog(@"版本号好像比商店大噢!检测到不需要更新");
    }
    
}


- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //5实现跳转到应用商店进行更新
    if(buttonIndex==1)
    {
        //6此处加入应用在app store的地址，方便用户去更新，一种实现方式如下：
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/cn/app/yi-jia-wang/id%@?l=en&mt=8", AppStore_ID]];
        [[UIApplication sharedApplication] openURL:url];
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    [[UIApplication sharedApplication]setApplicationIconBadgeNumber:0];
    [application cancelAllLocalNotifications];
    [JPUSHService resetBadge];
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
