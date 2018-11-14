---
title: tree学习
date: 2018-11-12 13:36:55
tags: 数据结构
---

# tree

## 构造

树的构造很简单，节点的思想。

```
class TreeNode{
	Object element;
	TreeNode firstChild;
	TreeNode nextSibling;
}
```

## 示意图

![树示意图](/images/数据结构/tree图1.png)

## 先序遍历

先序遍历的思想是对节点的处理工作在他的子节点处理之前执行，显示结果为D->L->R
对示意图的先序遍历，结果为：ABDECFG


## 中序遍历

中序遍历的思想是先对左节点优先处理，之后在处理自己，最后处理右节点，显示结果为 L->D->R
对示意图的中序遍历，结果为：DBEAFCG

## 后序遍历

后序遍历的思想是优先处理子节点，最后处理自己，子节点的处理优先是左节点，显示结果为L->R->D
对示意图的后序遍历，结果为：DEBFGCA


