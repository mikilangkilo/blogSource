---
title: "Io复用三大将poll,select,epoll"
date: 2020-04-21T16:29:38+08:00
---

```
1.select/poll
老李去火车站买票，委托黄牛，然后每隔6小时电话黄牛询问，黄牛三天内买到票，然后老李去火车站交钱领票。
耗费：打电话
2.epoll
老李去火车站买票，委托黄牛，黄牛买到后即通知老李去领，然后老李去火车站交钱领票。
耗费：无需打电话



作者：凉拌姨妈好吃
链接：https://www.jianshu.com/p/6a6845464770
来源：简书
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
```

哈哈，通俗点讲就是这样啊。

# select

初次接触select还是学习okhttp之okio的时候学习的，依稀还记得channel，selector之类的名词

但事实上select作为同步io的一种实现方式，和okio的异步io还是有差别的

## select 构造

```
int select(int nfds, fd_set *readfds, fd_set *writefds, fd_set *exceptfds, struct timeval *timeout);
```





