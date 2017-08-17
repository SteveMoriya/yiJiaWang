//
//  CHShareView.m
//  TransfarDriver
//
//  Created by Kevin on 15/7/16.
//  Copyright (c) 2015年 Transfar. All rights reserved.
//

#import "CHShareView.h"
#import "YJTool.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import "WXApi.h"
#import "WeiboSDK.h"

#define buttonHeight 50
#define iconWidth 56
#define iconHeight 56

@interface CHShareItem : NSObject
@property (nonatomic, copy) NSString                     *shareIconName;
@property (nonatomic, copy) NSString                     *sharePlatformTitle;
@property (nonatomic, assign) TFSharePlatformTypeOptions SharePlatformType;

@end

@implementation CHShareItem
@synthesize sharePlatformTitle, shareIconName;

@end


@interface CHShareView ()<CHShareViewDelegate>

@property (nonatomic, strong) NSMutableArray      *shreArray;

@end

@implementation CHShareView

- (NSMutableArray *)shreArray
{
    if (!_shreArray) {
        
        _shreArray = [[NSMutableArray alloc] init];
    }
    return _shreArray;
}

- (id)initWithSharePlatfromTypeOptions:(TFSharePlatformTypeOptions)options
{
    self = [super init];
    
    if (self) {
        
        self.frame = CGRectMake(0, 0, kDEVICEWIDTH, kDEVICEHEIGHT);
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCancel)]];
        
        if (options & TFSharePlatformTypeWeiXin) {
            
            if ([WXApi isWXAppInstalled]) {
                
                CHShareItem *shareItem = [[CHShareItem alloc] init];
                shareItem.sharePlatformTitle = @"微信";
                shareItem.shareIconName = @"icon-fenxiang-weixin";
                shareItem.SharePlatformType = TFSharePlatformTypeWeiXin;
                [self.shreArray addObject:shareItem];
            }
        }
        
        if (options & TFSharePlatformTypeWeixinPengYouQuan)
        {
            if ([WXApi isWXAppInstalled]) {
                
                CHShareItem *shareItem = [[CHShareItem alloc] init];
                shareItem.sharePlatformTitle = @"朋友圈";
                shareItem.shareIconName = @"icon-fenxiang-pengyouquan";
                shareItem.SharePlatformType = TFSharePlatformTypeWeixinPengYouQuan;
                [self.shreArray addObject:shareItem];
            }
            
        }
        
        if (options & TFSharePlatformTypeQQ){
            
            if ([QQApiInterface isQQInstalled]) {
                
                CHShareItem *shareItem = [[CHShareItem alloc] init];
                shareItem.sharePlatformTitle = @"QQ好友";
                shareItem.shareIconName = @"icon-fenxiang-QQ";
                shareItem.SharePlatformType = TFSharePlatformTypeQQ;
                [self.shreArray addObject:shareItem];
            }
        }
        
        if ( options & TFSharePlatformTypeZone) {
            
            if ([QQApiInterface isQQInstalled]) {
                
                CHShareItem *shareItem = [[CHShareItem alloc] init];
                shareItem.sharePlatformTitle = @"QQ空间";
                shareItem.shareIconName = @"icon-fenxiang-zone";
                shareItem.SharePlatformType = TFSharePlatformTypeZone;
                [self.shreArray addObject:shareItem];
            }
        }
        
        if (options & TFSharePlatformTypeSinaWeibo){

            if ([WeiboSDK isWeiboAppInstalled]) {
                
                CHShareItem *shareItem = [[CHShareItem alloc] init];
                shareItem.sharePlatformTitle = @"新浪微博";
                shareItem.shareIconName = @"share_xinlang";
                shareItem.SharePlatformType = TFSharePlatformTypeSinaWeibo;
                [self.shreArray addObject:shareItem];
            }
        }
        
        if(options & TFSharePlatformTypeCopy){
            
            CHShareItem *shareItem = [[CHShareItem alloc] init];
            shareItem.shareIconName = @"share_copy";
            shareItem.sharePlatformTitle = @"复制链接";
            shareItem.SharePlatformType = TFSharePlatformTypeCopy;
            [self.shreArray addObject:shareItem];
        }
        
        if (options & TFSharePlatformTypeMessage) {
            
            CHShareItem *shareItem = [[CHShareItem alloc] init];
            shareItem.shareIconName = @"share_message";
            shareItem.sharePlatformTitle = @"短信";
            shareItem.SharePlatformType = TFSharePlatformTypeMessage;
            [self.shreArray addObject:shareItem];
        }

        [self creatShareSubsViewWithShareArray:self.shreArray];
    }
    return self;
    
}

- (UIView *)backGroundView
{
    if (!_backGroundView) {
        _backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, kDEVICEHEIGHT, kDEVICEWIDTH, 0)];
        _backGroundView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.backGroundView];
    }
    return _backGroundView;
}

- (UILabel *)titleLab
{
    if (!_titleLab) {
        
        self.titleLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 9, _backGroundView.frame.size.width-40, 20)];
        self.titleLab.textColor = [YJTool colorWithHexString:@"68758e"];
        self.titleLab.font = [UIFont boldSystemFontOfSize:14];
        self.titleLab.text = _title;
    }
    return _titleLab;
}

- (UIButton *)cancelButton
{
    if (!_cancelButton) {
        
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.layer.cornerRadius = 4.0;
        _cancelButton.layer.borderWidth = 0.5;
        _cancelButton.backgroundColor = [YJTool colorWithHexString:@"f7f7f7"];
        _cancelButton.layer.borderColor = [YJTool colorWithHexString:@"dfdfdf"].CGColor;
        [_cancelButton setTitleColor:[YJTool colorWithHexString:@"68758e"] forState:UIControlStateNormal];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:17];
        [_cancelButton addTarget:self action:@selector(hideView) forControlEvents:UIControlEventTouchUpInside];
        [self.backGroundView addSubview:_cancelButton];
    }
    return _cancelButton;
}


- (void)creatShareSubsViewWithShareArray:(NSArray *)itemArray{
    
    [self.backGroundView addSubview:self.titleLab];
    
    float temp = (kDEVICEWIDTH-4*iconWidth-40)/3.0;   //每个图标间的间隙
    for (int i=0; i<itemArray.count; i++) {
        
        CHShareItem *item = itemArray[i];
        
        int rows = [[NSString stringWithFormat:@"%d",i/4] intValue];  //行数
        int locs = [[NSString stringWithFormat:@"%d",i%4] intValue];  //列数
        UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];

        shareBtn.frame = CGRectMake(20+(iconWidth+temp)*locs, CGRectGetMaxY(self.titleLab.frame)+10+(iconHeight+46)*rows, iconWidth, iconHeight);
        [shareBtn setImage:[UIImage imageNamed:item.shareIconName] forState:UIControlStateNormal];
        [shareBtn setBackgroundColor:[UIColor clearColor]];
        shareBtn.titleLabel.font = [UIFont systemFontOfSize:11];
        [shareBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        shareBtn.tag = i;
        [shareBtn addTarget:self action:@selector(shareBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.backGroundView addSubview:shareBtn];
        
        UILabel *titleLab = [[UILabel alloc] init];
        titleLab.frame = CGRectMake(CGRectGetMinX(shareBtn.frame)-5, CGRectGetMaxY(shareBtn.frame)+8, CGRectGetWidth(shareBtn.frame)+10, 20);
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.textColor = [YJTool colorWithHexString:@"666666"];
        titleLab.font = [UIFont boldSystemFontOfSize:14];
        titleLab.text = item.sharePlatformTitle;
        titleLab.backgroundColor = [UIColor clearColor];
        [self.backGroundView addSubview:titleLab];
    }
    
    CGFloat lastLableY = CGRectGetMaxY(self.titleLab.frame) + 10 + (56 + 46) * (itemArray.count / 4 + ((itemArray.count / 4 == 0) ? 1 : (itemArray.count % 4 == 0) ? 0 : 1));

     self.cancelButton.frame = CGRectMake(12, lastLableY+10, CGRectGetWidth(self.backGroundView.frame)-24, 48);
    
    [UIView animateWithDuration:0.25 animations:^{
        
        CGFloat height = CGRectGetMaxY(self.cancelButton.frame)+20;
        [self.backGroundView setFrame:CGRectMake(0, kDEVICEHEIGHT-height, kDEVICEWIDTH, height)];
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLab.text = title;
}

- (void)showInView:(UIView *)view
{
     [view addSubview:self];
}

- (void)tappedCancel
{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        [weakSelf.backGroundView setFrame:CGRectMake(0, kDEVICEHEIGHT, kDEVICEWIDTH, 0)];
        weakSelf.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            
            _titleLab = nil;
            _backGroundView = nil;
            _shreArray = nil;
            [weakSelf removeFromSuperview];
        }
    }];
}

- (void)hideView
{
    [self tappedCancel];
}

- (void)shareBtnClick:(UIButton *)button
{
    [self hideView];
    CHShareItem *item = _shreArray[button.tag];
    if (_delegate && [_delegate respondsToSelector:@selector(didShareButtonClick:)]) {
        
        [_delegate didShareButtonClick:item.SharePlatformType];
    }
}

- (UIView *)generalView
{
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [YJTool colorWithHexString:@"dfdfdf"];
    [self.backGroundView addSubview:view];
    return view;
}

@end
