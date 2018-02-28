---
title: Collection
date: 2018-02-28 23:14:41
tags: 数据结构
---

面试的时候问到了Collection和Collections的差别。当时有个浅薄的印象是Collection好像是个接口类，而Collections是个实体类。
回来翻书发现自己真是无知，回答的驴头不对马嘴。

# Collection

java.util.Collection是一个集合接口（集合类的一个顶级接口）。它提供了对集合对象进行基本操作的通用接口方法。Collection接口在java库中有很多基本的实现。

Collection接口最大的意义是为了各种具体的集合提供最大化的统一操作方式，其直接继承接口有List和set。

继承自list的有：LinkedList,ArrayList,Vector

继承自vector的有：stack

# Collections

java.util.Collections则是一个包装类（工具类/帮助类），包含各种有关集合操作的静态多态方法。不能被实例化，就像一个工具类，用于对集合中元素进行排序、搜索和线程安全等各种操作。