---
title: merge标签的作用
date: 2018-10-22 21:09:18
tags: android
---

merge标签的作用是用于减少一层布局的。

事实上很多时候如果单控件的话，可以直接使用控件来当root使用。

但是一旦控件比较多的话，那就没办法了，此时就需要使用merge标签来减少一层布局了。

merge标签一般的作用就是替代framelayout，当绘制绘制到他的时候，会主动跳过布局而直接绘制其包含的内容。但是缺点或者说局限就是只能使用framelayout的布局来布局。

另外merge只能用作根布局，且如果想使用inflater来inflate的话，attachtoroot一定要写成true