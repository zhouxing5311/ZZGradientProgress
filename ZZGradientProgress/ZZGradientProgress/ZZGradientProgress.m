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

-(void)drawRect:(CGRect)rect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [self.backgroundColor set];
    
    UIRectFill(self.bounds);
    
    CGRect r = self.bounds;
    
    if (r.size.width > r.size.height)
        r.size.width=r.size.height;
    else r.size.height=r.size.width;
    
    [self drawGradientInContext:ctx
                  startingAngle:_startAngle
                       endAngle:_startAngle + _fakeProgress*(2*M_PI - _reduceAngle)
                      intRadius:_radius - _strokeWidth
                      outRadius:_radius - 1
                     withSubdiv:_subdivCount<=5?5:_subdivCount
                     withCenter:CGPointMake(CGRectGetMidX(r), CGRectGetMidY(r))];
    
}

- (void)drawGradientInContext:(CGContextRef)ctx startingAngle:(float)startAngle endAngle:(float)endAngle intRadius:(CGFloat)intRadius outRadius:(CGFloat)outRadius withSubdiv:(int)subdivCount withCenter:(CGPoint)center {
    
    if (_showPathBack) {
        //背景线条
        UIBezierPath *basePath = [UIBezierPath bezierPathWithArcCenter:center radius:outRadius-_strokeWidth/2.0 + 0.5 startAngle:_startAngle endAngle:_startAngle + 2*M_PI - _reduceAngle clockwise:YES];
        CGContextSetLineWidth(ctx, _strokeWidth);
        if (_roundStyle) {
            CGContextSetLineCap(ctx, kCGLineCapRound);
        }
        [_pathBackColor setStroke];
        CGContextAddPath(ctx, basePath.CGPath);
        CGContextStrokePath(ctx);
    }
    
    float angleDelta = (endAngle - startAngle)/subdivCount;//每一块的角度
    
    CGPoint p0,p1,p2,p3;
    
    float currentAngle = startAngle;
    p0 = [self pointForTrapezoidWithAngle:currentAngle andRadius:intRadius forCenter:center];
    p3 = [self pointForTrapezoidWithAngle:currentAngle andRadius:outRadius forCenter:center];
    CGMutablePathRef innerEnveloppe = CGPathCreateMutable(),
    outerEnveloppe = CGPathCreateMutable();
    
    CGPathMoveToPoint(outerEnveloppe, 0, p3.x, p3.y);
    CGPathMoveToPoint(innerEnveloppe, 0, p0.x, p0.y);
    CGContextSaveGState(ctx);
    CGContextSetLineWidth(ctx, 1);
    
    for (int i = 0;i < subdivCount; i++) {
        float fraction = (float)i/subdivCount;
        float colorFraction = fraction;
        
        if (!_colorGradient) {
            colorFraction = _fakeProgress*i/subdivCount;
        }
        
        UIColor *currentColor = [self getGradientColor:colorFraction];
        
        currentAngle = startAngle + fraction*(endAngle - startAngle);
        CGMutablePathRef trapezoid = CGPathCreateMutable();
        
        p1 = [self pointForTrapezoidWithAngle:currentAngle + angleDelta andRadius:intRadius forCenter:center];
        p2 = [self pointForTrapezoidWithAngle:currentAngle + angleDelta andRadius:outRadius forCenter:center];
        
        CGPathMoveToPoint(trapezoid, 0, p0.x, p0.y);
        CGPathAddLineToPoint(trapezoid, 0, p1.x, p1.y);
        CGPathAddLineToPoint(trapezoid, 0, p2.x, p2.y);
        CGPathAddLineToPoint(trapezoid, 0, p3.x, p3.y);
        CGPathCloseSubpath(trapezoid);
        
        CGPoint centerofTrapezoid = CGPointMake((p0.x + p1.x + p2.x + p3.x)/4, (p0.y + p1.y + p2.y + p3.y)/4);
        
        CGAffineTransform t = CGAffineTransformMakeTranslation(-centerofTrapezoid.x, -centerofTrapezoid.y);
        CGAffineTransform s = CGAffineTransformMakeScale(1, 1);
        CGAffineTransform concat = CGAffineTransformConcat(t, CGAffineTransformConcat(s, CGAffineTransformInvert(t)));
        CGPathRef scaledPath = CGPathCreateCopyByTransformingPath(trapezoid, &concat);
        
        CGContextAddPath(ctx, scaledPath);
        CGContextSetFillColorWithColor(ctx, currentColor.CGColor);
        CGContextSetStrokeColorWithColor(ctx, currentColor.CGColor);
        CGContextSetMiterLimit(ctx, 0);
        
        CGContextDrawPath(ctx, kCGPathFillStroke);
        
        CGPathRelease(trapezoid);
        
        if (_roundStyle) {
            //画半圆
            if (i == 0) {
                
                CGPoint roundCenter = CGPointMake((p0.x+p3.x)/2.0, (p0.y+p3.y)/2.0);
                
                CGMutablePathRef halfCircle = CGPathCreateMutable();
                CGPathAddArc(halfCircle, &concat, roundCenter.x, roundCenter.y, (outRadius-intRadius)/2.0, M_PI-currentAngle, 2*M_PI-currentAngle, 1);
                
                CGContextSetFillColorWithColor(ctx, currentColor.CGColor);
                CGContextSetStrokeColorWithColor(ctx, currentColor.CGColor);
                
                CGPathCloseSubpath(halfCircle);
                
                CGPathRef halfCirclePath = CGPathCreateCopyByTransformingPath(halfCircle, &concat);
                
                CGContextAddPath(ctx, halfCirclePath);
                CGContextDrawPath(ctx, kCGPathFillStroke);
                CGPathRelease(halfCircle);
            } else if (i == subdivCount-1) {
                
                //最后一个梯形
                CGPoint roundCenter = CGPointMake((p1.x+p2.x)/2.0, (p1.y+p2.y)/2.0);
                
                CGMutablePathRef halfCircle = CGPathCreateMutable();
                CGPathAddArc(halfCircle, &concat, roundCenter.x, roundCenter.y, (outRadius-intRadius)/2.0, M_PI+currentAngle+angleDelta, 2*M_PI+currentAngle+angleDelta, 1);
                
                CGContextSetFillColorWithColor(ctx, currentColor.CGColor);
                CGContextSetStrokeColorWithColor(ctx, currentColor.CGColor);
                
                CGPathCloseSubpath(halfCircle);
                
                CGPathRef halfCirclePath = CGPathCreateCopyByTransformingPath(halfCircle, &concat);
                
                CGContextAddPath(ctx, halfCirclePath);
                CGContextDrawPath(ctx, kCGPathFillStroke);
                CGPathRelease(halfCircle);
                
                
            }
        }
        
        //画小圆点
        if (_showPoint && i == subdivCount-1) {
            CGPoint imageCenter = CGPointMake((p1.x+p2.x)/2.0, (p1.y+p2.y)/2.0);
            CGContextDrawImage(ctx, CGRectMake(imageCenter.x-0.5*_strokeWidth, imageCenter.y-0.5*_strokeWidth, _strokeWidth, _strokeWidth), _pointImage.CGImage);
        }
        
        //画文字
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
        
        p0=p1;
        p3=p2;
        
        CGPathAddLineToPoint(outerEnveloppe, 0, p3.x, p3.y);
        CGPathAddLineToPoint(innerEnveloppe, 0, p0.x, p0.y);
    }
    
    CGPathRelease(innerEnveloppe);
    CGPathRelease(outerEnveloppe);
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

//获取点
- (CGPoint)pointForTrapezoidWithAngle:(float)a andRadius:(float)r forCenter:(CGPoint)p {
    return CGPointMake(p.x + r*cos(a), p.y + r*sin(a));
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
