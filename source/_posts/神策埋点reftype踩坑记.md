---
title: 神策埋点reftype踩坑记
date: 2019-01-16 15:30:27
tags: android
---

项目需要上报埋点，但是部分埋点需要携带reftype，而reftype却需要从上个页面报到下个页面来。

从安卓上面来讲，一个页面是一个activity的形式，而reftype需要传递，有两种方式，一种是reftype以intent的bundle参数传入，第二种是在长于activity的生命周期保存这个reftype实现存储存取方式。

第一种可以完全完美的解决的问题，但是带来的是过于繁琐的步骤，每个启动的intent都需要加，这样十分复杂，在新加的页面中这样写start()函数还是可以的，但是在我们这种有多路径，而且很多老页面中无法这样使用。

