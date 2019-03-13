---
title: viewstub的作用
date: 2018-10-22 23:53:18
tags: android
---

viewstub和merge标签基本上都属于android开发强求优化的时候需要注意的事情。

viewstub的大致作用是用于替换布局。与include这种将布局模块化的不同，viewstub主要的场景是用于分布加载，或者说延迟加载。

```
<ViewStub
        android:id="@+id/map_stub"
        android:layout_width="fill_parent"
        android:layout_height="fill_parent"
        android:inflatedId="@+id/map_view"
        android:layout="@layout/map" />
```

一般来讲viewstub就是这样，包含一个inflatedid，和一个layout，当viewstub被inflate时或者被设置为visiable时，viewstub属性就会消失，取而代之的是layout，并且此时viewstub的id也会消失，新的布局的id就是inflatedid，之后如果在要使用viewstub的布局的话，就需要直接调inflatedid了。viewstub老的id寻找的布局将为null
