---
title: "Recyclerview优化小结"
date: 2019-06-12T14:41:42+08:00
description : "
总结一些recyclerview的优化策略
"
---

该篇不讨论源码，只总结优化的trick

# convert的时候不执行耗时操作

一般在convert的时候是数据已经异步拉好了，一般这时候直接进行数据填充。

但是数据填充绘制的部分仍然会卡顿，此时仍需要异步处理，比较好的方式是item内部也做一个loading动画，数据填充放在子线程，填充完毕将viewholder切到主线程进行加载，同时隐藏loading。

# 填充部分数据的时候使用insert而不是notifyall

这里不单单是单个数据的填充，事实上分页加载也需要使用insert。

# 使用new View()的方式创建，而不是inflate

这里也就是复杂的view尽量不要在convert的时候使用inflate，因为inflate会有io同步，使用new一个自定义view的方式来优化这种行为

# 数据预取Prefetch

数据预取需要recyclerview升级到25.1.0以上

recyclerview加载视图的过程中ui线程并非一直卡顿中，因此基于ui线程空闲时设计了一套数据预取的机制，优化了流畅性

原理参考这篇文章[数据预取](https://juejin.im/entry/58a3f4f62f301e0069908d8f)

# 设置RecyclerView.setHasFixedSize(true)

当item的高度不会根据数据变化而变化的时候，设置固定高度，以防再次requestlayout

# 滑动过程中停止加载的操作

设置 RecyclerView.addOnScrollListener(listener); 来对滑动过程中停止加载的操作。

# 不需要动画则关闭动画

((SimpleItemAnimator) rv.getItemAnimator()).setSupportsChangeAnimations(false); 把默认动画关闭来提升效率。

# textview的部分优化点

对 TextView 使用 String.toUpperCase 来替代 android:textAllCaps="true"。
对 TextView 使用 [StaticLayout](http://www.jcodecraeer.com/a/anzhuokaifa/androidkaifa/2014/0915/1682.html) 或者 [DynamicLayout](https://blog.csdn.net/bigjeffwind/article/details/8608595) 的自定义 View 来代替它。

# 重写 RecyclerView.onViewRecycled(holder) 来回收资源。

这一步主要是防止不希望recyclerview回收部分holder，因此代码部分做缓存，需要的时候在添加进去

# 提前进行缓存加载

一般会使用RecycleView.setItemViewCacheSize(size)来设置增加缓存的数量

另外可以使用layoutmanager的getExtraLayoutSpace来设置预加载的空间，该空间是可见区域以外的。

# 嵌套recyclerview的优化

如果多个 RecycledView 的 Adapter 是一样的，比如嵌套的 RecyclerView 中存在一样的 Adapter，可以通过设置 RecyclerView.setRecycledViewPool(pool); 来共用一个 RecycledViewPool。

# 对item设置监听器，使用统一的onclicklistener

防止创建多个onclicklistener，如果自定义view的话，设置callback也一样的

# Todo:待续