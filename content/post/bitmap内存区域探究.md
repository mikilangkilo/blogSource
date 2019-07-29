---
title: "Bitmap内存区域探究"
date: 2019-07-26T11:24:53+08:00
---

# bitmap内存占用关系

## 始

以前查是否需要自己手动执行bitmap的recycle()的时候，网上很多博文都说Android2.2之后不需要手动回收。

这句话是对的，2.2之后不需要自己执行recycle()方法。

但是这句话又不对，之所以不执行recycle()方法，原因并不是图像buffer。

# bitmap内存结构







