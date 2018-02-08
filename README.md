# ZZGradientProgress
通过Quartz2D实现的一款颜色曲线渐变的进度条。在Stack Overflow [alecail](https://stackoverflow.com/questions/11783114/draw-outer-half-circle-with-gradient-using-core-graphics-in-ios)的思路下实现了此进度条。如果你使用过ZZCircleProgress，那么ZZCircleProgress所实现的功能我已经全部集成到了此款渐变色进度条。

**主要特色**
```
1.颜色严格曲线渐变，目前只支持两种颜色之间渐变。`startColor`、`endColor`
2.自定义起始角度。`startAngle`、`reduceAngle`
3.自定义线宽。`strokeWidth`
4.自定义动画时长。`animationDuration`
5.自定义进度条的平滑度。`subdivCount`
6.自定义是否显示背景线条及设置其颜色。`showPathBack`、`pathBackColor`
7.自定义是否显示进度文本及设置其字体颜色。`showProgressText`、`textColor`、`textFont`
8.自定义是否显示进度条终点的小圆点及自定义它的图片。`showPoint`、`pointImage`
9.自定义进度条两端是否是圆角样式。
10.自定义是否动画、是否从上次进度开始动画、每次动画的时长是相等还是进度越大动画越长。`notAnimated`、`increaseFromLast`、`animationSameTime`
```

**使用示例**

```
ZZGradientProgress *circle3 = [[ZZGradientProgress alloc] initWithFrame:CGRectMake(xCrack, yCrack*2+itemWidth, itemWidth, itemWidth) startColor:[UIColor yellowColor] endColor:[UIColor blueColor] startAngle:-255 reduceAngle:30 strokeWidth:10];
circle3.animationDuration = 3;
circle3.animationSameTime = YES;
circle3.increaseFromLast = YES;
circle3.textColor = [UIColor redColor];
circle3.textFont = [UIFont systemFontOfSize:14];
circle3.showPoint = YES;
circle3.pointImage = [UIImage imageNamed:@"ball"];

circle3.progress = 0.6;
[self.view addSubview:circle3];

```

**部分样式**
![demo](https://github.com/zhouxing5311/ZZGradientProgress/blob/master/images/demo.png)

年后更新渐变进度条的实现过程及相关问题。
