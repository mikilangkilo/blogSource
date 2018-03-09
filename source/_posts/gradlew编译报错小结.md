---
title: gradlew编译报错小结
date: 2018-03-09 11:34:35
tags: 日常bug
---

出现了一个问题，使用gradlew进行分渠道打包编译的时候，报错。
但是直接使用build，assemblebuild等操作都是可以的。
排查发现网上有个相同的问题，回答者说是java9不稳定。
因此需要替换一下jdk版本。


编译的时候需要修改gradle.properties
增加一行：org.gradle.java.home=/Library/Java/JavaVirtualMachines/jdk1.8.0_161.jdk/Contents/Home
用于表明编译使用的jdk版本

即可