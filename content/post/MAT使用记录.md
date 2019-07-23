---
title: "MAT使用记录"
date: 2019-07-22T16:41:56+08:00
tags: mat
category: 性能
---

# 名词学习

Shallow Size - 对象自身占用的内存大小，不包括它引用的对象。 

Retained Size - 当前对象大小+当前对象可直接或间接引用到的对象的大小总和。

list objects -- with outgoing references : 查看这个对象持有的外部对象引用。

list objects -- with incoming references : 查看这个对象被哪些外部对象引用。

show objects by class  --  with outgoing references ：查看这个对象类型持有的外部对象引用

show objects by class  --  with incoming references ：查看这个对象类型被哪些外部对象引用