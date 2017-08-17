//
//  ViewController.m
//  test4WKWebView
//
//  Created by Steve on 25/12/2016.
//  Copyright © 2016 Steve. All rights reserved.
//
#define AppStore_ID @"1107357472"

#import "AppDelegate.h"
#import "YJGuideView.h"
#import "JSCallbackOCMethods.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "YJScanQRViewController.h"
#import "YJAudioPlayManager.h"
#import "ViewController.h"
#import <WebKit/WebKit.h>
#import <UMSocialCore/UMSocialCore.h>
#import "CHShareView.h"
#import "JPUSHService.h"
#import "WXApi.h"

//注，这个地址是后台登录的地址
static NSString *homePageURL = @"app/initaction!loadappleftmenu.action?visitType=1";  //首页URL
static NSString *loginURL    = @"app/login.jsp";
static NSString *registerURL = @"app/register.jsp";

@interface ViewController ()<WKNavigationDelegate,WKScriptMessageHandler, UIScrollViewDelegate,CHShareViewDelegate,WXApiDelegate>

@property (nonatomic, strong) WKWebView                *webView;
@property (nonatomic, strong) YJGuideView              *guideView;
@property (nonatomic, strong)  AppDelegate             *appdelegate;
@property (nonatomic, strong) UIActivityIndicatorView  *indicatorView;
@property (nonatomic, copy)   NSString                 *homePageUrlString;
@property (nonatomic, strong) CHShareView              *shareView;

@property (nonatomic, strong) UIView                   *updateView; //升级提示视图

@property (nonatomic, copy) NSString                 *shareImgUrl;   //分享出去的图片
@property (nonatomic, copy) NSString                 *shareUrl;   //分享出去的url
@property (nonatomic, copy) NSString                 *shareTitle; //分享出去的标题
@property (nonatomic, copy) NSString                 *shareContent; //分享出去的内容


@end

@implementation ViewController

- (UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView) {
        
        _indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _indicatorView.center = self.view.center;
        _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self.view addSubview:_indicatorView];
    }
    return _indicatorView;
    
}

//- (void) viewWillAppear:(BOOL)animated {
//    self.navigationController.navigationBar.hidden = YES;
//}

//首次启动的欢迎视图
- (YJGuideView *)guideView
{
    if (!_guideView) {
        
        _guideView = [[YJGuideView alloc] initWithFrame:CGRectMake(0, 0, kDEVICEWIDTH, kDEVICEHEIGHT)];
        
        __weak typeof(self) weakSelf = self;
        _guideView.scrollFinishBlock = ^(){
            
            [weakSelf loadWebView:weakSelf.homePageUrlString];
            
        };
        
        
        _guideView.loginButtonOrRegisterButtonBlock = ^(NSInteger tag){
            
            NSString *urlString;
            if (tag==100) {
                
                urlString = [NSString stringWithFormat:@"%@%@?visitType=1",YJBaseURL, loginURL]; //点击引导页的登录按钮
            }
            else if (tag==101){
                
                urlString = [NSString stringWithFormat:@"%@%@?visitType=1",YJBaseURL, registerURL]; //点击引导页的注册按钮
            }
            [weakSelf loadWebView:urlString];
        };
        
        
        
    }
    return _guideView;
}

- (void) initUpdateView {
    
    _updateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kDEVICEWIDTH, kDEVICEHEIGHT)];
    _updateView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];
    
    UIImageView* tipsImg = [[UIImageView alloc] initWithFrame: CGRectMake(kDEVICEWIDTH / 8, (kDEVICEHEIGHT - kDEVICEWIDTH * 6/8 * 7/5)/2 , kDEVICEWIDTH * 6/8, kDEVICEWIDTH * 6/8 * 7/5)];
    tipsImg.image = [UIImage imageNamed:@"UpdateBGImg"];
    [_updateView addSubview:tipsImg];
    
    NSString *str = @"程序本次更新内容: \n1.优化了页面浏览效果 \n2.添加页面背景音乐 \n3.提高了页面的流畅度";
    UILabel *lb = [[UILabel alloc]initWithFrame:CGRectMake( kDEVICEWIDTH / 8 + 20, kDEVICEHEIGHT / 2 + 20 , kDEVICEWIDTH / 8 * 6  - 40 , kDEVICEHEIGHT/6)];
    lb.textColor = [UIColor darkGrayColor];
    lb.font = [UIFont systemFontOfSize:16];
    lb.text = str;
    lb.numberOfLines = 0; // 最关键的一句
    [_updateView addSubview:lb];
    
    UIButton* updateBtn = [[UIButton alloc] initWithFrame:CGRectMake(kDEVICEWIDTH / 8 + 20 , lb.frame.origin.y + lb.frame.size.height + 10, kDEVICEWIDTH / 8 * 6  - 40, (kDEVICEWIDTH / 8 * 6  - 40)/6 )];
    [updateBtn setBackgroundImage:[UIImage imageNamed:@"UPdateBtImg"] forState:UIControlStateNormal];
    [updateBtn addTarget:self action:@selector(updateAct) forControlEvents:UIControlEventTouchUpInside];
    [_updateView addSubview:updateBtn];
    
    UIButton* closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(kDEVICEWIDTH * 6/8 + 30, (kDEVICEHEIGHT - kDEVICEWIDTH * 6/8 * 7/5)/2 - 40, 40, 40)];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"CloseUpdateBtImg"] forState:UIControlStateNormal];
//    closeBtn.backgroundColor = [UIColor yellowColor];
    [closeBtn addTarget:self action:@selector(closeUpdateAct) forControlEvents:UIControlEventTouchUpInside];
    [_updateView addSubview:closeBtn];
    
    
}

- (void) updateAct {
    
    [_updateView removeFromSuperview];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/cn/app/yi-jia-wang/id%@?l=en&mt=8", AppStore_ID]];
    [[UIApplication sharedApplication] openURL:url];
    
}


- (void) closeUpdateAct {
    
    [_updateView removeFromSuperview];
}


- (void)initShareView
{
    _shareView = [[CHShareView alloc] initWithSharePlatfromTypeOptions:TFSharePlatformTypeWeiXin|TFSharePlatformTypeWeixinPengYouQuan|TFSharePlatformTypeQQ|TFSharePlatformTypeZone|TFSharePlatformTypeSinaWeibo];
    _shareView.title = @"分享到";
    _shareView.delegate = self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    
    //设置监听
    WKUserContentController* userContentController = [[WKUserContentController alloc] init];
    [userContentController addScriptMessageHandler:self name:@"app"];
    // 设置偏好设置
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.userContentController = userContentController;
    //解决音乐播放问题
    config.allowsInlineMediaPlayback = YES;
    config.mediaPlaybackRequiresUserAction = false;
    //    config.preferences = [[WKPreferences alloc] init]; // 默认为0
    //    config.preferences.minimumFontSize = 10; // 默认认为YES
    //    config.preferences.javaScriptEnabled = YES;
    
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0,  kDEVICEWIDTH, kDEVICEHEIGHT  ) configuration:config];
    [_webView sizeToFit];
    
    
    _webView.scrollView.bounces = YES;
    _webView.navigationDelegate = self;
    _webView.scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_webView];
    
    
    
    //页面加载逻辑
    NSString *userid = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
    if (userid) {
        _homePageUrlString = [NSString stringWithFormat:@"%@%@&userid=%@",YJBaseURL,homePageURL,userid];
    }
    else
    {
        _homePageUrlString = [NSString stringWithFormat:@"%@%@",YJBaseURL,homePageURL];
    }
    
    //首次安装启动展示引导图
    BOOL isFirstEnter = [[NSUserDefaults standardUserDefaults] boolForKey:@"FirstEnter"];
    if (!isFirstEnter) {
        
        [self.view addSubview:self.guideView];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FirstEnter"];
    }
    else
    {
        
        //[self loadWebView:_homePageUrlString];
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_homePageUrlString]]];
        
    }
    
    
    //检查app是否需要更新
    [self hsUpdateApp];
    
    
    //添加支付信息回调方法
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paySuccess) name:@"userPaySuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(payFailed) name:@"userPayFailed" object:nil];
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
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"版本有更新" message:[NSString stringWithFormat:@"检测到新版本(%@),是否更新?",appStoreVersion] delegate:self cancelButtonTitle:@"取消"otherButtonTitles:@"更新",nil];
//        [alert show];
        
//        _UpdateView = [[UpdateGuideView alloc] initWithFrame:CGRectMake(0, 0,kDEVICEWIDTH , kDEVICEHEIGHT)];
//        [self.view addSubview:_UpdateView];
//        
//        [self.view bringSubviewToFront:_UpdateView];
        
        [self initUpdateView];
        [self.view addSubview:_updateView];
        
    }else{
        NSLog(@"版本号好像比商店大噢!检测到不需要更新");
    }
    
}



//如果不实现这个代理方法,默认会屏蔽掉打电话等url

- (void) webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    decisionHandler(WKNavigationActionPolicyAllow);
    
}


/// 2 页面开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"1");
    
    [self.indicatorView startAnimating];
    
    NetworkStatus status = _appdelegate.reachability.currentReachabilityStatus;
    [self showHUDWithReachabilityStatus:status];
    
    //关于拨打电话时的调用问题
    NSString *path= [webView.URL absoluteString];
    NSString * newPath = [path lowercaseString];
    
    if ([newPath hasPrefix:@"sms:"] || [newPath hasPrefix:@"tel:"]) {
        
        UIApplication * app = [UIApplication sharedApplication];
        if ([app canOpenURL:[NSURL URLWithString:newPath]]) {
            [app openURL:[NSURL URLWithString:newPath]];
        }
        
        [self.indicatorView stopAnimating];
        
        return;
    }
    
}

/// 4 开始获取到网页内容时返回
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    NSLog(@"2");
}

/// 5 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    NSLog(@"3");
    [self.indicatorView stopAnimating];
    
}


/// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"4");
    [self.indicatorView stopAnimating];
}

#pragma mark-- 执行网络判断
- (void)showHUDWithReachabilityStatus:(NetworkStatus)status
{
    if (status == NotReachable) {
        
        [self.indicatorView stopAnimating];
        
        UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:nil message:@"网络已断开，请检查网络！" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alterView show];
    }
}


#pragma mark-- 加载wkwebview 用于推送数据
- (void)loadWebView:(NSString *)urlString
{
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}


#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    
    //        message.body {
    //            content =     {
    //                content = "http://www.yjall.cn/image/globkey2.png";
    //                title = "\U6613\U5bb6\U7f51\U9001\U60a8100\U5143\U65b0\U7528\U6237\U5927\U793c\U5305\Uff01";
    //                url = "http://www.yjall.cn/app/invitationaction!invitation.action?invitationCode=whwouj";
    //            };
    //            function = showShareIos;
    //        }
    
    
    //        message.body {
    //            function = scanQRCode;
    //        }
    
    
    //    message.body {
    //        content = lastestOrder;
    //        function = playAudio;
    //    }
    
    
    //    message.body {
    //        content = "http://www.baidu.com/'";
    //        function = openUrl;
    //    }
    
    
    
    NSLog(@"message.name %@",message.name);
    NSLog(@"message.body %@",message.body);
    
    NSDictionary *dic = message.body;
    //    NSLog(@"dic %@",dic);
    //    NSLog(@"function  %@",dic[@"function"]);
    
    
    if ( [dic[@"function"] isEqualToString:@"scanQRCode"]) {
        
        YJScanQRViewController *scanQRViewController = [[YJScanQRViewController alloc] init];
        scanQRViewController.scanQRFinishedBlock = ^(NSString *url){
            
            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
        };
        [self.navigationController pushViewController:scanQRViewController animated:YES];
        
    }
    
    else if ([dic[@"function"] isEqualToString:@"playAudio"] ) {
        
        [[YJAudioPlayManager shareInstance] playAudioWithName:dic[@"content"]];
        
    }
    
    else if ([dic[@"function"] isEqualToString:@"openUrl"] ) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:dic[@"content"]]];
        
    }
    
    
    else if ([dic[@"function"] isEqualToString:@"showShareIos"] ) {
        
        NSDictionary* shareDic = dic[@"content"];
        
        _shareUrl = shareDic[@"url"];
        _shareTitle = shareDic[@"title"];
        _shareContent = shareDic[@"content"];
        _shareImgUrl = shareDic[@"pic"];
        
        [self initShareView];
        
        [_shareView showInView:self.view];
        
    }
    
    else if ([dic[@"function"] isEqualToString:@"getYijiawangUserId"] ) {
        
        NSString *userid = dic[@"content"];
        
        //设置别名和tag
        [JPUSHService setTags:[NSSet setWithObject:userid] alias:userid fetchCompletionHandle:^(int iResCode, NSSet *iTags, NSString *iAlias) {
            
            //NSLog(@"___%@",iAlias);
        }];
        
        [[NSUserDefaults standardUserDefaults] setObject:userid forKey:@"userid"];
        
    }
    
    
    else if ([dic[@"function"] isEqualToString:@"WXPay"]) {
        
        //准备开始调用微信支付
        NSDictionary* dictionary = dic[@"content"];
        
        NSString *timeStamp = dictionary[@"timeStamp"];
        PayReq *request = [[PayReq alloc] init];
        request.openID = dictionary[@"appid"];
        request.partnerId = dictionary[@"partnerId"];
        request.prepayId= dictionary[@"prepayId"];
        //request.package = dictionary[@"packages"];
        request.package = @"Sign=WXPay";
        request.nonceStr= dictionary[@"nonceStr"];
        request.timeStamp= timeStamp.intValue;
        request.sign= dictionary[@"sign"];
        
        [WXApi sendReq:request];
        
    }
    
    
}

#pragma mark - 支付回调方法

- (void)paySuccess {
    
    NSString *urlString;
    urlString = [NSString stringWithFormat:@"%@%@",YJBaseURL, @"/app/topayAction!alipaySuccessAPP.action?resultCode=1"];
     [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    
}

- (void)payFailed {
    
    NSString *urlString;
    urlString = [NSString stringWithFormat:@"%@%@",YJBaseURL, @"/app/topayAction!alipaySuccessAPP.action?resultCode=0"];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    
}


#pragma mark-- CHShareViewDelegate
- (void)didShareButtonClick:(TFSharePlatformTypeOptions)TFSharePlatformType
{
    UIImage *shareImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_shareImgUrl]]];
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    UMShareWebpageObject  *shareObject = [UMShareWebpageObject shareObjectWithTitle:_shareTitle descr:_shareContent thumImage:shareImage];
    shareObject.webpageUrl = _shareUrl;
    
    messageObject.shareObject = shareObject;
    messageObject.text = [NSString stringWithFormat:@"%@%@",_shareContent,_shareUrl];
    
    if (TFSharePlatformType == TFSharePlatformTypeWeiXin)
    {
        [[UMSocialManager defaultManager] shareToPlatform:UMSocialPlatformType_WechatSession messageObject:messageObject currentViewController:self completion:^(id result, NSError *error) {
            
            
        }];
    }
    else if (TFSharePlatformType == TFSharePlatformTypeWeixinPengYouQuan)
    {
        [[UMSocialManager defaultManager] shareToPlatform:UMSocialPlatformType_WechatTimeLine messageObject:messageObject currentViewController:self completion:^(id result, NSError *error) {
            
            
        }];
    }
    else if (TFSharePlatformType == TFSharePlatformTypeZone)
    {
        
        [[UMSocialManager defaultManager] shareToPlatform:UMSocialPlatformType_Qzone messageObject:messageObject currentViewController:self completion:^(id result, NSError *error) {
            
        }];
        
    }
    else if (TFSharePlatformType == TFSharePlatformTypeQQ)
    {
        [[UMSocialManager defaultManager] shareToPlatform:UMSocialPlatformType_QQ messageObject:messageObject currentViewController:self completion:^(id result, NSError *error) {
            
            
        }];
    }
    else if (TFSharePlatformType == TFSharePlatformTypeSinaWeibo){
        
        [[UMSocialManager defaultManager] shareToPlatform:UMSocialPlatformType_Sina messageObject:messageObject currentViewController:self completion:^(id result, NSError *error) {
            
        }];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
