---
title: "Proguard知识点汇总"
date: 2020-06-28T11:06:36+08:00
tags: android
---
# 使用proguard的好处

## 安全

使用混淆之后，被混淆的类/文件夹/对象，会变成a/b/c这种方式，直接解压看classes.dex的时候基本上无法阅读

## 优化

混淆可以通过分析字节码文件，进行了四个方面的优化

### 压缩(shrink)

移除了没有使用到的类、方法、字段、属性。
曾经有一次新建工程发现方法超过65535的限制，但是debug出问题，release没问题，后来就发现是混淆了之后方法就不足65535，因此release没问题导致的

### 优化字节码属性(optimize)

由于proguard的压缩是通过分析字节码进行的，因此也一定意义上去除了多余的字节码指令

### 混淆(obfuscate)

使用无意义的字母对类、方法、对象等重命名

### 预检验(preverify)

在java平台进行代码预检验，安卓是不需要这一步的

# 工作流程

Input jars、Library jars-shrink->Shrunk code-optimize->Optim.code-obfuscate->Obfusc.code-preverify->Output >jars、Library jars

# 混淆规则

## input/output options

输入输出的选项，基本上用不到，因为安卓的输入是固定的，输出也是基本上固定的，不需要更改太多

### include

```
-include fileName //递归引入目录的配置文件
```

### basedirectory

```
-basedirectory directoryName //输入文件目录
```

### injars

```
-injars classPath //指定应用程序要处理的jars包
```

### outjars

```
-outjars classPath //指定输出的名称
```

### libraryjars

```
-libraryjars classPath //不混淆指定的jar库
```

### skipnonpubliclibraryclasses 

```
-skipnonpubliclibraryclasses //不混淆指定jars中的非public calsses
```

### dontskipnonpubliclibraryclasses
和上条对应，为默认不设置的时候的配置，因此只需要配置上面一条即可

```
-dontskipnonpubliclibraryclasses //不忽略指定jars中的非public calsses 
```

### dontskipnonpubliclibraryclassmembers

```
-dontskipnonpubliclibraryclassmembers //不忽略指定类库的public类成员（变量和方法），默认情况下，ProGuard会忽略他们
```

### keepdirectories

```
-keepdirectories [directory_filter] //指定要保持的目录结构，默认情况下会删除所有目录以减小jar的大小。
```

## Keep options

### keep

```
-keep [,modifier，...] class_specification
//指定需要保留的类和类成员（作为公共类库，应该保留所有可公开访问的public方法）
```

### keepclassmembers

```
-keepclassmembers [,modifier，...] class_specification
//指定需要保留的类成员:变量或者方法
```

### keepclasseswithmembers

```
-keepclasseswithmembers [,modifier，...] class_specification
//指定保留的类和类成员，条件是所指定的类成员都存在（既在压缩阶段没有被删除的成员，效果和keep差不多）
```

### keepnames

```
-keepnames class_specification
//[-keep allowshrinking class_specification 的简写]
//指定要保留名称的类和类成员，前提是在压缩阶段未被删除。仅用于模糊处理
```

### keepclassmembernames

```
-keepclassmembernames class_specification
//[-keepclassmembers allowshrinking class_specification 的简写]
//指定要保留名称的类成员，前提是在压缩阶段未被删除。仅用于模糊处理
```

### keepclasseswithmembernames

```
-keepclasseswithmembernames class_specification
//[-keepclasseswithmembers allowshrinking class_specification 的简写]
//指定要保留名称的类成员，前提是在压缩阶段后所指定的类成员都存在。仅用于模糊处理
```

## others

### printseeds 

```
-printseeds [filename]
//把keep匹配的类和方法输出到文件中，可以用来验证自己设定的规则是否生效.
```

### dontshrink

```
-dontshrink
//指定不进行压缩.
```

### printusage

```
-printusage [filename]
//把没有使用的代码输出到文件中，方便查看哪些代码被压缩丢弃了。
```

### dontoptimize

```
-dontoptimize
//指定不对输入代码进行优化处理。优化选项是默认打开的。
```

### optimizations

```
-optimizations
//指定混淆是采用的算法，后面的参数是一个过滤器，这个过滤器是谷歌推荐的算法，一般不做更改
```

### optimizationpasses

```
-optimizationpasses n
//指定优化的级别，在0-7之间，默认为5.
```

### assumenosideeffects

```
-assumenosideeffects class_specification
//可以指定移除哪些方法没有副作用
```

### dontobfuscate

```
–dontobfuscate
//指定不进行混淆
```

### printmapping

```
-printmapping [filename]
//生成map文件，记录混淆前后的名称对应关系，注意，这个比较重要，因为混淆后运行的名称会变得不可读，只有依靠这个map文件来还原。
```

### dontusemixedcaseclassnames

```
-dontusemixedcaseclassnames
//不使用大小写混合类名，注意，windows用户必须为ProGuard指定该选项，因为windows对文件的大小写是不敏感的，也就是比如a.java和A.java会认为是同一个文件。如果不这样做并且你的项目中有超过26个类的话，那么ProGuard就会默认混用大小写文件名，导致class文件相互覆盖。
```

### dontpreverify

```
-dontpreverify
//指定不执行预检，安卓平台应该直接打开
```

### dontwarn

```
-dontwarn
//编译时代码偶尔提示"Warning: there were xxx unresolved references to classes or interfaces"然后中断编译
//此时就需要添加-dontwarn 类名的规则
```
# QA

## 反射的文件如何保留？

没有什么好方法，凡是使用到反射的，都需要找到写到清单里面进行keep

## 为啥需要混淆？

四大好处等

