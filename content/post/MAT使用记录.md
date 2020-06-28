---
title: "MAT使用记录"
date: 2019-07-22T16:41:56+08:00
tags: android
---

# 名词学习

Shallow Size - 对象自身占用的内存大小，不包括它引用的对象。 

Retained Size - 当前对象大小+当前对象可直接或间接引用到的对象的大小总和。

list objects -- with outgoing references : 查看这个对象持有的外部对象引用。

list objects -- with incoming references : 查看这个对象被哪些外部对象引用。

show objects by class  --  with outgoing references ：查看这个对象类型持有的外部对象引用

show objects by class  --  with incoming references ：查看这个对象类型被哪些外部对象引用、

# 自动化导出并转化

```aidl
#!/bin/bash
yourdate=`date +%m-%d-%H-%M-%S`
adb shell am dumpheap com.ximalaya.ting.android.car /data/local/tmp/tingcar.hprof;
sleep 5;
adb pull /data/local/tmp/tingcar.hprof $yourdate.hprof;
mkdir $yourdate;
hprof-conv $yourdate.hprof $yourdate/$yourdate.hprof;
rm $yourdate.hprof;
adb shell rm /data/local/tmp/tingcar.hprof;
```

# 方法学习

## 查bitmap图

1.导出heap
2.转化heap
3.搜索Bitmap(注意大小写)
4.右键bitmap类->list object -> with outgoing reference
5.在bitmap对象列表页->右键想看的bitmap对象->copy->Save Value To File -> 保存到本地，文件名为XXX.data
6.鼠标切回刚才的bitmap，打开inspector，可以看到宽高（buffer区有内存的实际大小，就是宽*高*2(rgb565就是2，rgb8888就是4)）
7.使用gimp打开刚才保存下来的data文件，同时配置上面记录的宽高，在色值那里控制一下argb，即可看到内存区域中的图了。

## 检查gc引用链

对怀疑的对象，右键，有个merge shortest paths to gc root,这里选用exclude all，即可看到正确的gc引用链情况。

## 排查app内对象是否泄漏

在上方工具区域有个文件夹样式的按钮，点击之后选择group by package。即可看到按照包名分配的对象表。。

其中如果是XXX$1，这种，代表是XXX的内部类。

## 不可达对象列表

在overview页面就有一个unreachable objects histogram，点击即可看到不可达对象
