---
title: Android绘图机制与处理技巧
date: 2018-01-16 21:53:31
tags: android
---

本章用于做群英传第六章《Android绘图机制与处理技巧》的学习笔记。主要是整理自己不熟悉的知识点。

# 屏幕的尺寸信息

1. 屏幕大小

屏幕大小指对角线的长度，一般使用寸来度量，寸指英寸，一英寸为2.54cm

2. 分辨率

分辨率指手机屏幕的像素点个数。1920*1080指宽有1920个像素点，高有1080个像素点

3. ppi

pixel per inch，每英寸像素，又称为dpi，为对角线的像素点除以屏幕大小得到。

# 系统屏幕密度

根据dpi大小来进行设置，系统定义了几个标准的dpi值。

120: ldpi
160: mdpi
240: hdpi
320: xhdpi
480: xxhdpi

# 独立像素密度 dp

在mdpi，即dpi为160时， 1dp = 1px。之后顺推即可，xxhdpi为160的3倍，即1dp = 3px

dp涉及到像素工具类的使用。

```
public class DisplayUtil{

	public static int px2dp(Context context, float px){
		final float scale = context.getResource().getDisplayMetrics().density;
		return (int)(px/scale + 0.5f);
	}

	public static int dp2px(Context context, float dp){
		final float scale = context.getResource().getDisplayMetrics().density;
		return (int)(dp*scale + 0.5f);
	}

	public static int px2sp(Context context, float px){
		final float fontScale = context.getResource().getDisplayMetrics().scaledDensity;
		return (int)(px/fontScale + 0.5f);
	}

	public static int sp2dp(Context context, float sp){
		final float fontScale = context.getResource().getDisplayMetrics().scaledDensity;
		return (int)(sp*fontScale + 0.5f);
	}

	//以上为使用公式进行换算的
	//还可以使用TypedValue进行换算

	public static int dp2px(int dp){
		return (int)TypedValue.applyDimension(
			TypedValue.COMPLEX_UNIT_DIP,
			dp,
			getResources().getDisplayMetrics());
	}

	public static int sp2px(int sp){
		return (int)TypeValue.applyDimension(
			TypedValue.COMPLEX_UNIT_SP,
			sp,
			getResources().getDisplayMetrics());
	}

}
```

# 2D绘图基础

2d绘图即使用系统提供的Canvas对象来提供绘图方法，该章主要是复习一些常用的api。

1. paint

setAntiAlias():设置抗锯齿效果
setColor():设置画笔的颜色
setARGB():设置画笔的啊a,r,g,b值
setAlpha():设置画笔透明度
setTextSize():设置字体的尺寸
setStyle():设置画笔的风格（空心或者实心）
setStrokeWidth():设置空心边框的宽度

2. canvas

canvas.drawPoint(x, y, paint): 绘制点

canvas.drawLine(startX, startY, endX, endY, paint): 绘制直线

```
	float[] pts = {
		startX1, startY1, endX1, endY1,
		... ...
		startXn, startYn, endXn, endYn
	};
	canvas.drawLines(pts, paint);
	//画多条直线
```

canvas.drawRect(left, top, right, bottom, paint): 绘制矩形

canvas.drawRoundRect(left, top, right, bottom, radiusX, radiuxY, paint):绘制圆角矩形

canvas.drawCircle(circleX, circleY, radius, paint):绘制圆

canvas.drawArc(left, top, right, bottom, startAngle, sweepAngle, useCenter, paint):绘制弧形，扇形，区别在于useCenter

canvas.drawOval(left, top, right, bottom, paint):画椭圆

canvas.drawText(text, startX, startY, paint):绘制文本

canvas.drawPosText(text, new float[]{X1, Y1, X2, Y2... ... Xn, Yn}, paint):在制定位置绘制文本

canvas.drawPath(path, paint):绘制路径

# Android xml绘图

1. Bitmap

在xml中使用bitmap
```
<?xml version="1.0" encoding="utf-8"?>
<bitmap xmlns:android="http://schemas.android.com/apk/res/android"
	android:src="@drawable/ic_launcher"/>
```

2. Shape

```
<shape xmlns:android:"http://schemas.android.com/apk/res/android"
	android:shape=["rectangle" | "oval" | "line" | "ring"]>
	//默认为rectangle
	<corners //shape = "rectangle" 有用
		// 半径，会被后面的单个半径属性覆盖，默认为1dp
		android:radius="integer"
		android:topLeftRadius="integer"
		android:topRightRadius="integer"
		android:bottomLeftRadius="integer"
		android:bottomRightRadius="integer"/>
	<gradient //渐变
		android:angle="integer"
		android:centerX="integer"
		android:centerY="integer"
		android:centerColor="integer"
		android:endColor="color"
		android:gradientRadius="integer"
		android:startColor="color"
		android:type=["linear"| "radius" | "sweep"]
		android:useLevel=["true" | "false"]/>
	<padding
		android:left="integer"
		android:top="integer"
		android:right="integer"
		android:bottom="integer"/>
	<size // 指定大小，一般用在imageview配合scaletype属性使用
		android:width="integer"
		android:height="integer"/>
	<solid // 填充颜色
		android:color="color"/>
	<stroke //指定边框
		android:width="integer"
		android:color="color"
		android:dashWidth="integer" //虚线宽度
		android:dashGap="integer" // 虚线间隔宽度
		/>
</shape>
```

3. Layer

layer中可以使用层级来进行叠加，主要是用item，item可以使用drawable，也可使用shape

4. Selector

Selector用于帮开发者实现静态绘图中的事件反馈，通过不同的事件设置不同的图像。

```
<?xml version="1.0" encoding="utf-8" ?>
<selector xmlns:android="http://schemas.android.com/apk/res/android">
	//默认时的背景图片
	<item android:drawable="@drawable/x1"/>
	//没有焦点时的图片
	<item android:state_window_focused="false" android:drawable="@drawable/x2"/>
	//非触摸模式下获得焦点并单击时的背景图片
	<item android:state_focuse="true" android:state_pressed="true" android:drawable="@drawable/x3"/>
	//触摸模式下单击时的背景图片
	<item android:state_focuse="false" android:state_pressed="true" android:drawable="@drawable/x4"/>
	//选中时的背景图片
	<item android:state_selected="true" android:drawable="@drawable/x5"/>
	//获得焦点时的背景图片
	<item android:state_focused="true" android:drawable="@drawable/x6"/>
</selector>
```

以上可以用于制作view的触摸反馈。

# android 绘图技巧

之上的是基本绘图技巧，之下的是常用绘图技巧

1. Canvas

Canvas.save(): 将之前的所有绘制图像保存起来，之后的操作就好像在一个新的图层上面操作一样。

Canvas.restore(): 用于合并图层，可以用于将save之后绘制的所有图像与save之前的图像合并

Canvas.translate():调用translate(x, y)操作可以将原点(0, 0)移动到(x, y)之后的所有操作都将以(x, y)为原点执行

Canvas.rotate():调用rotate(degree)之后可以将canvas调转一定的角度。