---
title: "MAT使用记录"
date: 2019-07-22T16:41:56+08:00
tags: mat
category: 性能
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
5.在bitmap对象列表页->右键想看的bitmap对象->copy->Save Value To File -> 保存到本地
6.鼠标切回刚才的bitmap，打开inspector，可以看到宽高（buffer区有内存的实际大小，就是宽*高*2(rgb565就是2，rgb8888就是4)）
7.根据记录的宽高，可以
