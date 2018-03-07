---
title: clean架构学习
date: 2018-03-07 09:50:22
tags: 架构
---

# clean架构图

![clean架构图](/images/架构/clean架构图.jpg)

# 核心思想

内层不能依赖外层，即内层不知道有关外层的任何事情，所以这个架构是向内依赖的。

# 特性

Clean架构可以使你的代码有如下特性：

- 独立于架构

- 易于测试

- 独立于UI

- 独立于数据库

- 独立于任何外部类库

# clean在android中的体现

- 外层：实现层

- 中层：接口适配层

- 内层：逻辑层

接口实现层是体现架构细节的地方。实现架构的代码是所有不用来解决问题的代码，这包括所有与安卓相关的东西，比如创建Activity和Fragment，发送Intent以及其他联网与数据库的架构相关的代码。

添加接口适配层的目的就是桥接逻辑层和架构层的代码。

最重要的是逻辑层，这里包含了真正解决问题的代码。这一层不包含任何实现架构的代码，不用模拟器也应能运行这里的代码。这样一来你的逻辑代码就有了易于测试、开发和维护的优点。这就是Clean架构的一个主要的好处。

# 结构

一般来说一个安卓应用的结构如下：

外层项目包：UI，Storage，Network等等。

中层项目包：Presenter，Converter。

内层项目包：Interactor，Model，Repository，Executor。

## 外层

外层体现了框架的细节。

UI – 包括所有的Activity，Fragment，Adapter和其他UI相关的Android代码。

Storage – 用于让交互类获取和存储数据的接口实现类，包含了数据库相关的代码。包括了如ContentProvider或DBFlow等组件。

Network – 网络操作。

## 中层

桥接实现代码与逻辑代码的Glue Code。

Presenter – presenter处理UI事件，如单击事件，通常包含内层Interactor的回调方法。

Converter – 负责将内外层的模型互相转换。

## 内层

内层包含了最高级的代码，里面都是POJO类，这一层的类和对象不知道外层的任何信息，且应能在任何JVM下运行。

Interactor – Interactor中包含了解决问题的逻辑代码。这里的代码在后台执行，并通过回调方法向外层传递事件。在其他项目中这个模块被称为用例Use Case。一个项目中可能有很多小Interactor，这符合单一职责原则，而且这样更容易让人接受。

Model – 在业务逻辑代码中操作的业务模型。

Repository – 包含接口让外层类实现，如操作数据库的类等。Interactor用这些接口的实现类来读取和存储数据。这也叫资源库模式Repository Pattern。

Executor – 通过Worker Thread Executor让Interactor在后台执行。一般不需要修改这个包里的代码。

