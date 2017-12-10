//
//  MRBulletView.m
//  MRBullet
//
//  Created by Roy on 2017/12/10.
//  Copyright © 2017年 Roy. All rights reserved.
//

#import "MRBulletView.h"

@interface MRBulletView()

@property(nonatomic, strong) UILabel *lbCommentLabel;

@end

CGFloat static kBulletLabelPadding = 10;

@implementation MRBulletView

// 初始化弹幕
- (instancetype)initWithComment:(NSString *)comment
{
    if(self = [super init])
    {
        self.backgroundColor = [UIColor redColor];
        
        // 计算弹幕文字实际宽度
        NSDictionary *attr = @{
                               NSFontAttributeName:[UIFont systemFontOfSize:14.f]
                               };
        CGSize bulletTextSize = [comment sizeWithAttributes:attr];
        
        self.bounds = CGRectMake(0, 0, bulletTextSize.width + 2*kBulletLabelPadding, bulletTextSize.height + kBulletLabelPadding);
        
        self.lbCommentLabel.text = comment;
        self.lbCommentLabel.frame = CGRectMake(kBulletLabelPadding, kBulletLabelPadding/2, bulletTextSize.width, bulletTextSize.height);
    }
    return self;
}

// 开始动画
- (void)startAnimation
{
    // 根据弹幕长度执行动画效果
    // 根据 v = s/t, 时间固定情况下，距离越长，速度越快，保证长的弹幕速度快
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat duration = 4.f;
    CGFloat wholeWidth = screenWidth + CGRectGetWidth(self.bounds);
    
    // 弹幕开始
    if(self.moveStatusBlock)
    {
        self.moveStatusBlock(Start);
    }
    
    // 弹幕完全进入屏幕
    // 根据公式t = s/v， 计算时间
    CGFloat speed = wholeWidth/duration;
    CGFloat enterDuration = (CGRectGetWidth(self.bounds)+50)/speed;
    [self performSelector:@selector(bulletEnterScrren) withObject:nil afterDelay:enterDuration];
    
    // 根据动画改变自身的frame 坐标
    __block CGRect frame = self.frame;
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        frame.origin.x -= wholeWidth;
        self.frame = frame;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        
        // 调用回调告诉外部状态，方便做下一步处理
        if(self.moveStatusBlock)
        {
            self.moveStatusBlock(Exit);
        }
    }];
}

// 结束动画
- (void)stopAnimation
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.layer removeAllAnimations];
    [self removeFromSuperview];
}

// 弹幕完全进入屏幕
- (void)bulletEnterScrren
{
    if(self.moveStatusBlock)
    {
        self.moveStatusBlock(Enter);
    }
}

#pragma lazy-load

- (UILabel *)lbCommentLabel
{
    if(!_lbCommentLabel)
    {
        _lbCommentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _lbCommentLabel.font = [UIFont systemFontOfSize:14.f];
        _lbCommentLabel.textColor = [UIColor whiteColor];
        _lbCommentLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_lbCommentLabel];
    }
    return _lbCommentLabel;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
