//
//  NSObject+JSContextTracker.h
//  yiJiaWang
//
//  Created by kevin on 16/9/19.
//  Copyright © 2016年 zhuming. All rights reserved.
//

#import "YJScanQRViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "YJUtilScanQRView.h"

@interface YJScanQRViewController ()<AVCaptureMetadataOutputObjectsDelegate>
{
    AVCaptureDevice         *device;
    AVCaptureDeviceInput    *input;
    AVCaptureMetadataOutput *output;
    AVCaptureSession        *session;
    AVCaptureVideoPreviewLayer *preview;
    
    UIView                  *focusView;
    YJUtilScanQRView        *scanBorder;
}

@end

@implementation YJScanQRViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addDefaultBackButton];
    [self setNavBarWithTitle:@"扫一扫"];
    
    if (_spacing == 0)
    {
        _spacing = 38;
    }
    [self initAVCaptures];
    [self initBorderScanView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [session startRunning];
    [scanBorder startShadeLineAnimation];
}

- (void)initBorderScanView
{
    scanBorder = [[YJUtilScanQRView alloc] initWithFrame:self.view.frame withSpacing:_spacing == 0 ? 38 : _spacing];
    [self.view addSubview:scanBorder];
    [self.view insertSubview:scanBorder atIndex:1];

    CGFloat sideLen = kDEVICEWIDTH-_spacing*2;
    focusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sideLen, sideLen)];
    focusView.hidden = YES;
    [self.view addSubview:focusView];
}



- (void)initAVCaptures
{
    // 检查是否有相机权限
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"没有摄像头的权限" message:@"请在设备的设置-隐私-相机中允许访问相机" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    else if (status == AVAuthorizationStatusNotDetermined)
    {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            
        }];
    }
    
    device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    input = [[AVCaptureDeviceInput alloc]initWithDevice:device error:&error];
    // Output
    output = [[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    // Session
    session = [[AVCaptureSession alloc] init];
    if ([session canSetSessionPreset:AVCaptureSessionPresetHigh])
    {
        session.sessionPreset = AVCaptureSessionPresetHigh;
    }
    if ([session canAddInput:input])
    {
        [session addInput:input];
    }
    if ([session canAddOutput:output])
    {
        [session addOutput:output];
    }
    output.metadataObjectTypes = [NSArray arrayWithObjects:AVMetadataObjectTypeQRCode, nil];
    
    CGFloat sideLen = kDEVICEWIDTH-_spacing*2;
    CGRect cropRect = CGRectMake(_spacing, kDEVICEHEIGHT*148/667, sideLen, sideLen);
    CGFloat p1 = kDEVICEHEIGHT/kDEVICEWIDTH;
    CGFloat p2 = 1920.0/1080;
    if (p1 < p2)
    {
        CGFloat fixHeight = kDEVICEWIDTH*p2;
        CGFloat fixPadding = (fixHeight - kDEVICEHEIGHT)/2;
        output.rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding)/fixHeight,
                                           cropRect.origin.x/kDEVICEWIDTH,
                                           cropRect.size.height/fixHeight,
                                           cropRect.size.width/kDEVICEWIDTH);
    }
    else
    {
        CGFloat fixWidth = kDEVICEHEIGHT/p2;
        CGFloat fixPadding = (fixWidth - kDEVICEWIDTH)/2;
        output.rectOfInterest = CGRectMake(cropRect.origin.y/kDEVICEHEIGHT,
                                           (cropRect.origin.x + fixPadding)/fixWidth,
                                           cropRect.size.height/kDEVICEHEIGHT,
                                           cropRect.size.width/fixWidth);
    }
    // PreView
    preview = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    preview.frame = self.view.layer.bounds;
    [self.view.layer insertSublayer:preview atIndex:0];
    
    // Start
    [session startRunning];
    
    CGPoint focusPoint = CGPointMake((kDEVICEHEIGHT*148/667+sideLen/2)/kDEVICEHEIGHT, 0.5);
    [device lockForConfiguration:&error];
    if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
    {
        device.focusPointOfInterest = focusPoint;
        device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
    }
    [device unlockForConfiguration];

}

- (void)focusAtPoint
{
    CGFloat sideLen = kDEVICEWIDTH-_spacing*2;
    focusView.center = CGPointMake(0.5*kDEVICEWIDTH, kDEVICEHEIGHT*148/667+sideLen/2);
    focusView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        focusView.transform = CGAffineTransformMakeScale(1.5, 1.5);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            focusView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            focusView.hidden = YES;
        }];
    }];
}

//MARK: AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects.count > 0)
    {
        [session stopRunning];
        [scanBorder stopShadeLineAnimation];
        // 处理逻辑
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects firstObject];
        NSString *stringValue = metadataObject.stringValue;

        if (stringValue.length>0) {
            
            if (_scanQRFinishedBlock) {
                _scanQRFinishedBlock(stringValue);
            }
            [self backButtonAction:nil];
        }
    }
}

- (void)backButtonAction:(UIButton *)sender
{
    [session stopRunning];
    session = nil;
    [scanBorder stopShadeLineAnimation];
    scanBorder = nil;
    focusView = nil;
    [self.navigationController popViewControllerAnimated:NO];
}


@end
