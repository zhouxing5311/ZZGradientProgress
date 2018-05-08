//
//  ViewController.m
//  ZZGradientProgress
//
//  Created by 周兴 on 2018/2/6.
//  Copyright © 2018年 周兴. All rights reserved.
//

#import "ViewController.h"
#import "ZZGradientProgress.h"

#define ZZRGB(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

@interface ViewController ()

@end

@implementation ViewController
{
    ZZGradientProgress *circle1;
    ZZGradientProgress *circle2;
    ZZGradientProgress *circle3;
    ZZGradientProgress *circle4;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:233/255.0 green:231/255.0 blue:234/255.0 alpha:1];
    
    [self initCircles];
    
}

//初始化
- (void)initCircles {
    
    CGFloat xCrack = ([UIScreen mainScreen].bounds.size.width-150*2)/3.0;
    CGFloat yCrack = ([UIScreen mainScreen].bounds.size.height-150*2)/3.0;
    CGFloat itemWidth = 150;
    
    //1.默认状态
    circle1 = [[ZZGradientProgress alloc] initWithFrame:CGRectMake(xCrack, yCrack, itemWidth, itemWidth) startColor:[UIColor redColor] endColor:[UIColor greenColor] startAngle:-90 reduceAngle:0 strokeWidth:10];

    circle1.progress = 0.6;
    [self.view addSubview:circle1];
    UILabel *label1 = [[UILabel alloc] init];
    label1.text = @"红绿渐变";
    [label1 sizeToFit];
    [label1 setCenter:CGPointMake(CGRectGetMidX(circle1.frame), CGRectGetMaxY(circle1.frame)+10)];
    [self.view addSubview:label1];
    
    
    
    //2.半径自定义、两端圆角、不显示文本、显示背景线条、渐变颜色两端固定
    circle2 = [[ZZGradientProgress alloc] initWithFrame:CGRectMake(xCrack*2+itemWidth, yCrack, itemWidth, itemWidth) startColor:[UIColor orangeColor] endColor:[UIColor blueColor] startAngle:0 reduceAngle:0 strokeWidth:10];
    circle2.backgroundColor = [UIColor colorWithRed:180/255.0 green:230/255.0 blue:222/255.0 alpha:1];
    circle2.radius = 50;
    circle2.roundStyle = YES;
    circle2.showProgressText = NO;
    circle2.showPathBack = YES;
    circle2.pathBackColor = [UIColor lightGrayColor];
    circle2.colorGradient = NO;

    circle2.progress = 0.6;
    [self.view addSubview:circle2];
    UILabel *label2 = [[UILabel alloc] init];
    label2.text = @"橙蓝渐变";
    [label2 sizeToFit];
    [label2 setCenter:CGPointMake(CGRectGetMidX(circle2.frame), CGRectGetMaxY(circle2.frame)+10)];
    [self.view addSubview:label2];



    //3.自定义动画时长、不同进度动画时间相同、进度从上次开始变化、自定义进度文本、显示默认小圆点
    circle3 = [[ZZGradientProgress alloc] initWithFrame:CGRectMake(xCrack, yCrack*2+itemWidth, itemWidth, itemWidth) startColor:[UIColor yellowColor] endColor:[UIColor blueColor] startAngle:-255 reduceAngle:30 strokeWidth:10];
    circle3.animationDuration = 3;
    circle3.animationSameTime = YES;
    circle3.increaseFromLast = YES;
    circle3.textColor = [UIColor redColor];
    circle3.textFont = [UIFont systemFontOfSize:14];
    circle3.showPoint = YES;

    circle3.progress = 0.6;
    [self.view addSubview:circle3];
    UILabel *label3 = [[UILabel alloc] init];
    label3.text = @"黄蓝渐变";
    [label3 sizeToFit];
    [label3 setCenter:CGPointMake(CGRectGetMidX(circle3.frame), CGRectGetMaxY(circle3.frame)+10)];
    [self.view addSubview:label3];



    //4.自定义动画时长、进度越大动画时长越久、自定义小圆点图片
    circle4 = [[ZZGradientProgress alloc] initWithFrame:CGRectMake(xCrack*2+itemWidth, yCrack*2+itemWidth, itemWidth, itemWidth) startColor:ZZRGB(175, 202, 238) endColor:ZZRGB(4, 103, 238) startAngle:-90 reduceAngle:0 strokeWidth:20];
    circle4.animationDuration = 3;
    circle4.animationSameTime = NO;
    circle4.showPoint = YES;
    circle4.pointImage = [UIImage imageNamed:@"ball"];

    circle4.progress = 0.6;
    [self.view addSubview:circle4];
    UILabel *label4 = [[UILabel alloc] init];
    label4.text = @"浅蓝深蓝渐变";
    [label4 sizeToFit];
    [label4 setCenter:CGPointMake(CGRectGetMidX(circle4.frame), CGRectGetMaxY(circle4.frame)+10)];
    [self.view addSubview:label4];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    circle1.progress = arc4random()%101/100.0;
    circle2.progress = arc4random()%101/100.0;
    circle3.progress = arc4random()%101/100.0;
    circle4.progress = arc4random()%101/100.0;
}


@end
