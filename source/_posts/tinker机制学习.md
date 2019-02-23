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

从这个图可以看出来，APK的生成分为两个部分。
第一个部分是通过aapt生成res，第二部分是通过javaC生成dex文件

不涉及instantrun的话，编译也就上述几个步骤。打包的话会有签名和对齐动作。

打开instant run 开关，会有所变化

![打开instant run的编译效果](/images/android/instantRunOpenApkMarker.webp)

打开开关后，会新增一个appserver.class类编译进dex，同时会有一个新的application类。

新的application类注入了一个新的自定义类加载器，同时该application类会启动我们所需的新注入的
appserver，该application是原生application类的一个代理类。这样instantrun就跑起来了。

（该appserver主要是检测app是否在前台，以及是否是对应与android studio的appserver）

### 热插拔

热插拔主要体现在一个ui不变化，即时响应。

其步骤：
1. 首先通过gradle生成增量dex文件

```
Gradle Incremental Build
```

gradle会通过增量编译脚本，将dex文件最小化的进行更改
2. 更改完的dex文件会发送到appserver中，发送到appserver

3. appserver接收到dex后，会重写类文件。
appserver是保持活跃的，所以一旦有新的dex发来，就会立即执行处理任务。这里就体现了热插拔的效果。

instant run 热插拔的局限性：只能适用于简单改变，类似于方法上面的修改，或者变量值修改。

### 温插拔

温插拔体现在activity需要被重启才能看到修改

从上面的app构建图可以看出来，资源文件这种在activity创建时加载的内容，需要重启activity才能重新加载。

其步骤和热插拔几乎相同，唯一不同是修改了资源文件之后会走这步，发送的是资源文件的增量包，同时附带一个重启栈顶activity的指令

温插拔的局限性：只能适用于资源文件的更改，不包括manifest，架构，结构的变化。

### 冷插拔

基于art虚拟机的模式，工程会被拆分成10个部分，每个部分拥有自己的dex文件，然后所有的类会根据包名被分配给对应的dex文件。

结构更改产生的变化，此时带来dex的变化，这个变化不是增量变化，而是单纯的变化，这种变化需要重新替换dex文件

替换dex需要自定义类加载器选择性的加载新的dex，因此必须要重启app才能走到这一步。

冷插拔在art虚拟机上面是有效的，但是dalvik中则不行 api-21以上才有效。

## 注意点

instant run 只能在主进程运行，多进程模式下，所有的温插拔都会变为冷插拔。
不可以多台部署，只可以通过gradle生成增量包，jack编译器不行。

