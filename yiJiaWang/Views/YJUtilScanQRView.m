//
//  NSObject+JSContextTracker.h
//  yiJiaWang
//
//  Created by kevin on 16/9/19.
//  Copyright © 2016年 zhuming. All rights reserved.
//

#import "YJUtilScanQRView.h"

typedef NS_OPTIONS(NSUInteger, CruralOptions)
{
    CruralOptionsLeftTop = 1 << 0,
    CruralOptionsRightTop = 1 << 1,
    CruralOptionsLeftBottom = 1 << 2,
    CruralOptionsRightBottom = 1 << 3
};

@interface YJUtilScanQRView()
{
    UIView *shadeView;
}

@end

@implementation YJUtilScanQRView

- (instancetype)init
{
    return [self initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame withSpacing:38];
}

- (instancetype)initWithFrame:(CGRect)frame withSpacing:(CGFloat)spacing
{
    self = [super initWithFrame:frame];
    if (self) {
        self.spacing = spacing;
        self.backgroundColor = [UIColor clearColor];
        CGFloat sideLen = frame.size.width-_spacing*2;
        [self hollowView:CGRectMake(_spacing, frame.size.height*148/667, sideLen, sideLen)];
    }
    return self;
}

- (void)hollowView:(CGRect)hollowFrame
{
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
    [path appendPath:[[UIBezierPath bezierPathWithRect:hollowFrame] bezierPathByReversingPath]];
    CAShapeLayer *shape = [[CAShapeLayer alloc] init];
    shape.fillColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
    shape.path = path.CGPath;
    [shape addSublayer:[self cruralLine:hollowFrame cruralLocation:CruralOptionsLeftTop]];
    [shape addSublayer:[self cruralLine:hollowFrame cruralLocation:CruralOptionsRightTop]];
    [shape addSublayer:[self cruralLine:hollowFrame cruralLocation:CruralOptionsRightBottom]];
    [shape addSublayer:[self cruralLine:hollowFrame cruralLocation:CruralOptionsLeftBottom]];
    [self shadeLine:hollowFrame];

    [self.layer addSublayer:shape];
    
    UILabel *hintText = [[UILabel alloc] initWithFrame:CGRectMake(hollowFrame.origin.x, CGRectGetMaxY(hollowFrame)+12, hollowFrame.size.width, 16)];
    hintText.text = @"将二维码放入框内，即可自动扫描";
    hintText.textColor = [UIColor grayColor];
    hintText.font = [UIFont systemFontOfSize:14];
    hintText.textAlignment = NSTextAlignmentCenter;
    [self addSubview:hintText];
}

- (CAShapeLayer *)cruralLine:(CGRect)hollowFrame cruralLocation:(CruralOptions)cruralLocation
{
    CGFloat cruralLen = 16;
    CGFloat lineWidth = 2;
    CGRect newHollowFrame = CGRectMake(CGRectGetMinX(hollowFrame)+lineWidth/4, CGRectGetMinY(hollowFrame)+lineWidth/4, hollowFrame.size.width-lineWidth/2, hollowFrame.size.height-lineWidth/2);
    CGPoint originPoint = CGPointMake(((CruralOptionsLeftTop | CruralOptionsLeftBottom) & cruralLocation) ? 0 : newHollowFrame.size.width, ((CruralOptionsLeftTop | CruralOptionsRightTop) & cruralLocation) ? 0 : newHollowFrame.size.height);
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointMake(originPoint.x == 0 ? CGRectGetMinX(newHollowFrame)+cruralLen : CGRectGetMaxX(newHollowFrame)-cruralLen, CGRectGetMinY(newHollowFrame)+originPoint.y)];
    [path addLineToPoint:CGPointMake(CGRectGetMinX(newHollowFrame)+originPoint.x, CGRectGetMinY(newHollowFrame)+originPoint.y)];
    [path addLineToPoint:CGPointMake(CGRectGetMinX(newHollowFrame)+originPoint.x, originPoint.y == 0 ? CGRectGetMinY(newHollowFrame)+cruralLen : CGRectGetMaxY(newHollowFrame)-cruralLen)];
    CAShapeLayer *shape = [[CAShapeLayer alloc] init];
    shape.fillColor = [UIColor clearColor].CGColor;
    shape.strokeColor = [UIColor blueColor].CGColor;
    shape.lineWidth = lineWidth;
    shape.path = path.CGPath;
    return shape;
}

- (void)shadeLine:(CGRect)hollowFrame
{
    shadeView = [[UIView alloc] init];
    shadeView.frame = hollowFrame;
    shadeView.clipsToBounds = true;
    UIImageView *shadeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scanborder.png"]];
    shadeImage.frame = CGRectMake(0, -hollowFrame.size.height, hollowFrame.size.width, hollowFrame.size.height);
    [shadeView addSubview:shadeImage];
    [self addSubview:shadeView];
    [self shadeAnimate:hollowFrame imageView:shadeImage];
}

- (void)shadeAnimate:(CGRect)hollowFrame imageView:(UIImageView *)imageView
{
    [UIView animateWithDuration:1.5 animations:^{
        
        [imageView setCenter:CGPointMake(imageView.center.x, imageView.center.y+hollowFrame.size.height)];
        
    } completion:^(BOOL finished) {
        
        [imageView setCenter:CGPointMake(imageView.center.x, imageView.center.y-hollowFrame.size.height)];
        [self shadeAnimate:hollowFrame imageView:imageView];
    }];
}

//MARK: API
- (void)stopShadeLineAnimation
{
    shadeView.hidden = true;
}
- (void)startShadeLineAnimation
{
    shadeView.hidden = false;
}


@end
