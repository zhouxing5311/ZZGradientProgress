//
//  ZZGradientProgress.m
//  ZZGradientProgress
//
//  Created by 周兴 on 2018/2/6.
//  Copyright © 2018年 周兴. All rights reserved.
//
#define ZZCircleDegreeToRadian(d) ((d)*M_PI)/180.0
#define ZZCircleSelfWidth self.frame.size.width
#define ZZCircleSelfHeight self.frame.size.height

#import "ZZGradientProgress.h"

@interface ZZGradientProgress ()

@property (nonatomic, strong) CADisplayLink *playLink;
@property (nonatomic, assign) CGFloat fakeProgress;
@property (nonatomic, assign) CGFloat increaseValue;
@property (nonatomic, assign) BOOL isReverse;

@end

@implementation ZZGradientProgress

- (instancetype)init {
    if (self = [super init]) {
        [self initialization];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialization];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialization];
}

/**
 初始化
 
 @param frame 坐标
 @param startColor 开始颜色
 @param endColor 结束颜色
 @param startAngle 开始角度
 @param reduceAngle 缺少角度
 @param strokeWidth 线条宽度
 @return self
 */
- (instancetype)initWithFrame:(CGRect)frame
                   startColor:(UIColor *)startColor
                     endColor:(UIColor *)endColor
                   startAngle:(CGFloat)startAngle
                  reduceAngle:(CGFloat)reduceAngle
                  strokeWidth:(CGFloat)strokeWidth {
    
    if (self = [super initWithFrame:frame]) {
        
        [self initialization];
        
        _startColor = startColor;
        _endColor = endColor;
        _startAngle = ZZCircleDegreeToRadian(startAngle);
        _reduceAngle = ZZCircleDegreeToRadian(reduceAngle);
        _strokeWidth = strokeWidth;
    }
    return self;
}

- (void)initialization {
    
    self.backgroundColor = [UIColor clearColor];
    
    _startColor = [UIColor redColor];
    _endColor = [UIColor cyanColor];
    _pathBackColor = [UIColor lightGrayColor];
    _textColor = [UIColor blueColor];
    _textFont = [UIFont systemFontOfSize:0.15*ZZCircleSelfWidth];
    
    _strokeWidth = 10;
    _subdivCount = 64;
    _animationDuration = 2;
    _radius = MIN(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))/2.0;
    _startAngle = -ZZCircleDegreeToRadian(90);
    _reduceAngle = ZZCircleDegreeToRadian(0);
    
    _showProgressText = YES;
    _animationSameTime = YES;
    _colorGradient = YES;
    
    //获取图片资源
    NSBundle *mainBundle = [NSBundle bundleForClass:[self class]];
    NSBundle *resourcesBundle = [NSBundle bundleWithPath:[mainBundle pathForResource:@"ZZGradientProgress" ofType:@"bundle"]];
    _pointImage = [UIImage imageNamed:@"circle_point1" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
}
- (void)drawRect:(CGRect)rect {
    
    [self.backgroundColor set];
    
    CGRect r = self.bounds;
    
    if (r.size.width > r.size.height)
    r.size.width=r.size.height;
    else r.size.height=r.size.width;
    
    [self drawWithStartAngle:_startAngle
                    endAngle:_startAngle + _fakeProgress*(2*M_PI - _reduceAngle)
                      radius:_radius-_strokeWidth/2.0
                 subdivCount:_subdivCount<=5?5:_subdivCount
                      center:CGPointMake(CGRectGetMidX(r), CGRectGetMidY(r))];
    
}

- (void)drawWithStartAngle:(float)startAngle endAngle:(float)endAngle radius:(CGFloat)radius subdivCount:(int)subdivCount center:(CGPoint)center {
    
    if (_showPathBack) {
        //背景线条
        UIBezierPath *basePath = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:_startAngle endAngle:_startAngle+(2*M_PI-_reduceAngle) clockwise:YES];
        if (_roundStyle) {
            [basePath setLineCapStyle:kCGLineCapRound];
        }
        [basePath setLineWidth:_strokeWidth];
        [_pathBackColor setStroke];
        [basePath stroke];
        
    }
    
    for (int i = 0;i < subdivCount; i++) {
        float fraction = (float)i/subdivCount;
        float colorFraction = fraction;
        float itemAngle = (endAngle - startAngle)/subdivCount;
        
        if (!_colorGradient) {
            colorFraction = _fakeProgress*i/subdivCount;
        }
        
        UIColor *currentColor = [self getGradientColor:colorFraction];
        
        CGFloat nowStartAngle = startAngle+i*itemAngle;
        CGFloat nowEndAngle = startAngle+(i+1)*itemAngle;
        
        
        //当进度为0时和最后一个线条不加0.01。只有中间连接部分加
        if (itemAngle != 0) {
            
            //当roundstyle=YES时，i=0和i=subdivCount-1时需要处理连接部分的空余部分
            if (((i==subdivCount-1)&&(_roundStyle==YES)) || i!=subdivCount-1) {
                nowEndAngle += 0.01;
            }
            
            if (_roundStyle == YES && i==0) {
                nowStartAngle -= 0.01;
            }
        }
        
        //draw item path
        UIBezierPath *currentPath = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:nowStartAngle endAngle:nowEndAngle clockwise:YES];
        [currentPath setLineWidth:_strokeWidth];
        [currentColor setStroke];
        [currentPath stroke];
        
        if (_roundStyle && (i==0 || i==subdivCount-1) && nowStartAngle != nowEndAngle) {
            //画半圆
            UIBezierPath *halfCirclePath = [UIBezierPath bezierPath];
            if (i == 0) {
                //first
                CGPoint startCenter = CGPointMake(center.x+radius*cosf(startAngle+i*itemAngle), center.y+radius*sinf(startAngle+i*itemAngle));
                [halfCirclePath addArcWithCenter:startCenter radius:0.5*_strokeWidth startAngle:startAngle+i*itemAngle endAngle:startAngle+i*itemAngle+M_PI clockwise:NO];
            } else {
                //last
                CGPoint endCenter = CGPointMake(center.x+radius*cosf(startAngle+(i+1)*itemAngle), center.y+radius*sinf(startAngle+(i+1)*itemAngle));
                [halfCirclePath addArcWithCenter:endCenter radius:0.5*_strokeWidth startAngle:startAngle+(i+1)*itemAngle endAngle:startAngle+(i+1)*itemAngle+M_PI clockwise:YES];
            }
            
            [halfCirclePath closePath];
            [currentColor setFill];
            [halfCirclePath fill];
        }
        
        //画小圆点
        if (_showPoint && i == subdivCount-1) {
            CGPoint imageCenter = CGPointMake(center.x+radius*cosf(nowEndAngle), center.y+radius*sinf(nowEndAngle));
            [_pointImage drawInRect:CGRectMake(imageCenter.x-_strokeWidth/2.0, imageCenter.y-_strokeWidth/2.0, _strokeWidth, _strokeWidth)];
        }
        
        //画文字
        //文字为什么会有锯齿？ 不是frame size不是整数的问题
        if (_showProgressText) {
            NSString *currentText = [NSString stringWithFormat:@"%.2f%%",_fakeProgress*100];
            NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle alloc] init];
            textStyle.lineBreakMode = NSLineBreakByWordWrapping;
            textStyle.alignment = NSTextAlignmentCenter;
            
            NSDictionary *attributes = @{
                                         NSFontAttributeName:_textFont,
                                         NSForegroundColorAttributeName:_textColor,
                                         NSParagraphStyleAttributeName:textStyle
                                         };
            CGSize stringSize = [currentText sizeWithAttributes:attributes];
            //垂直居中
            CGRect r = CGRectMake((int)((ZZCircleSelfWidth-stringSize.width)/2.0), (int)((ZZCircleSelfHeight - stringSize.height)/2.0),(int)stringSize.width, (int)stringSize.height);
            [currentText drawInRect:r withAttributes:attributes];
        }
    }
    
}

- (void)setProgress:(CGFloat)progress {
    
    if (progress>1.0 || progress<0.0) {
        return;
    }
    
    _fakeProgress = _increaseFromLast==YES?_progress:0.0;
    _isReverse = progress<_fakeProgress?YES:NO;
    
    _progress = progress;
    
    if (_notAnimated) {
        _fakeProgress = _progress;
        [self setNeedsDisplay];
    } else {
        
        if (_increaseFromLast) {
            //从上次开始动画
            if (_animationSameTime) {
                _increaseValue = (_progress - _fakeProgress)/(30.0*_animationDuration);
            } else {
                _increaseValue = _isReverse==YES?-1.0/(30.0*_animationDuration):1.0/(30.0*_animationDuration);
            }
        } else {
            //从新开始动画
            if (_animationSameTime) {
                _increaseValue = _progress/(30.0*_animationDuration);
            } else {
                _increaseValue = 1.0/(30.0*_animationDuration);
            }
        }
        
        if (self.playLink) {
            [self.playLink invalidate];
            self.playLink = nil;
        }
        
        CADisplayLink *playLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(countingAction)];
        if (@available(iOS 10.0, *)) {
            playLink.preferredFramesPerSecond = 30;
        } else {
            playLink.frameInterval = 2;//不可更改
        }
        [playLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [playLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:UITrackingRunLoopMode];
        self.playLink = playLink;
    }
    
}

- (void)countingAction {
    
    _fakeProgress += _increaseValue;
    [self setNeedsDisplay];
    
    if (_increaseFromLast) {
        if (_isReverse) {
            if (_fakeProgress <= _progress) {
                [self dealWithLast];
            }
        } else {
            if (_fakeProgress >= _progress) {
                [self dealWithLast];
            }
        }
    } else {
        if (_fakeProgress >= _progress) {
            [self dealWithLast];
        }
    }
    
}

- (void)dealWithLast {
    
    _fakeProgress = _progress;
    [self.playLink invalidate];
    self.playLink = nil;
    
    [self setNeedsDisplay];
}

//获取当前颜色
- (UIColor *)getGradientColor:(CGFloat)current {
    
    CGFloat c1[4];
    CGFloat c2[4];
    
    [_startColor getRed:&c1[0] green:&c1[1] blue:&c1[2] alpha:&c1[3]];
    [_endColor getRed:&c2[0] green:&c2[1] blue:&c2[2] alpha:&c2[3]];
    
    return [UIColor colorWithRed:current*c2[0]+(1-current)*c1[0] green:current*c2[1]+(1-current)*c1[1] blue:current*c2[2]+(1-current)*c1[2] alpha:current*c2[3]+(1-current)*c1[3]];
}

#pragma Set
- (void)setStartAngle:(CGFloat)startAngle {
    if (_startAngle != ZZCircleDegreeToRadian(startAngle)) {
        _startAngle = ZZCircleDegreeToRadian(startAngle);
        [self setNeedsDisplay];
    }
}

- (void)setReduceAngle:(CGFloat)reduceAngle {
    if (_reduceAngle != ZZCircleDegreeToRadian(reduceAngle)) {
        if (reduceAngle>=360) {
            return;
        }
        _reduceAngle = ZZCircleDegreeToRadian(reduceAngle);
        [self setNeedsDisplay];
    }
}

- (void)setStrokeWidth:(CGFloat)strokeWidth {
    if (_strokeWidth != strokeWidth) {
        _strokeWidth = strokeWidth;
        [self setNeedsDisplay];
    }
}

- (void)setPathBackColor:(UIColor *)pathBackColor {
    if (_pathBackColor != pathBackColor) {
        _pathBackColor = pathBackColor;
        [self setNeedsDisplay];
    }
}

- (void)setShowPoint:(BOOL)showPoint {
    if (_showPoint != showPoint) {
        _showPoint = showPoint;
        [self setNeedsDisplay];
    }
}

-(void)setShowProgressText:(BOOL)showProgressText {
    if (_showProgressText != showProgressText) {
        _showProgressText = showProgressText;
        [self setNeedsDisplay];
    }
}


@end
