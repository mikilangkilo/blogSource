---
title: tinker机制学习
date: 2019-01-28 13:06:52
tags: android
---

# tinker作用

tinker一般可以用作热修复，其作为热修复java方案的代表，日常工作也经常用到。

其原理是参考自instant run 的方案，通过生成patch包，不过是通过网络下发，然后在本地进行处理。

# instant run

基于提升平时打包的速度，instant run 需要

- 只对代码改变部分做构建和部署
- 不重新安装应用
- 不重启应用
- 不重启activity

从其官方图中可以看出，针对上面四个需求，生成了三种插拔机制。

![swap](/images/android/instanctRunSwapImage.webp)

- 热插拔：代码改变被应用、投射到app上面，不需要重启应用，不需要重建activity
- 温插拔：activity需要被重启才能看到所需更改
- 冷插拔：app需要被重启（不需要重新安装）

## 原理

![原理](/images/android/instantRunApkMarker.webp)

从这个图可以看出来，APK的生成分为两个部分