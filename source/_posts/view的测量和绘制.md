---
title: view的测量和绘制
date: 2018-01-02 12:38:03
tags:
---
系统绘制一个view，如同蒙着眼睛的小孩拿着笔在画板上画出一个指定的图案。因此需要一个人在旁边指导他如何去画。
Android就是那个蒙着眼睛画画的人，开发者需要告诉它如何去画。

# View的测量

去画一个图形，就必须知道它的大小和位置。
Android系统在绘制view之前，也必须对view进行测量，告诉系统该画一个多大的view。这个过程在onMeasure()中进行。

## MeasureSpec

measurespec是一个协助测量view的类。它是一个32位的int值，其中高2位为测量的模式，低30位为测量的大小。使用位运算是为了提高并优化效率。
测量的模式分为以下三种：

1. EXACTLY
精确模式，当我们将控件的layout_width属性或者layout_height属性指定为具体数值时，比如android:layout_height="100dp",或者指定为match_parent属性时，系统使用的是EXACTLY模式。

2. AT_MOST
最大值模式，当控件的layout_width属性或者layout_height属性指定为wrap_content时，控件的大小一般随着子控件或内容的变化而变化，此时控件的尺寸只要不超过父控件的最大尺寸即可。

3. UNSPECIFIED
不指定大小测量模式。view想多大就多大，通常在绘制自定义view时才使用。

View类默认的onMeasure()方法只能支持EXACTLY模式。如果要让自定义view支持wrap_content属性，必须重写onMeasure方法来指定wrap_content时的大小。

## 测量的步骤

1. 从MeasureSpec对象中提取具体的测量模式和大小

```
	int specMode = MeasureSpec.getMode(measureSpec);
	int specSize = MeasureSpec.getSize(measureSpec);

```

2. 通过判断测量的模式，给出不同的判断值。当specMode为EXACTLY时，直接使用指定的specSize即可；当specMode为其他两种模式时，需要给它一个默认的大小。特别的，如果指定wrap_content属性，即AT_MOST模式，需要取出我们制定的大小与specSize中最小的一个来作为最后的测量值。

```
private int measureWidth(int measureSpec){
	int result = 0;
	int specMode = MeasureSpec.getMode(measureSpec);
	int specSize = MeasureSpec.getSize(measureSpec);

	if(specMode == MeasureSpec.EXACTLY){
		result = specSize;
	}else{
		result = 200;
		if(specMpde == MeasureSpec.AT_MOST){
			result = Math.min(result, specSize);
		}
	}
	return result;
}
```

