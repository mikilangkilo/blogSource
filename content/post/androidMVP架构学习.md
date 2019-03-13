---
title: androidMVP架构学习
date: 2018-02-10 16:08:48
tags: 架构
---

MVP衍生自mvc，mvc中v层可以由model层进行操作，model将结果呈现于view，control获取反馈传给model，然后model可以进行一系列的操作。

mvp中的p代替了c，同时不允许m直接操作v了，所有的逻辑会落在p层里面，用户的操作反馈给p，p进行操作好之后传给m，m弄完之后仍然由p进行操作对v进行填充，这就导致了v层十分薄弱，大量的逻辑落在了p层。 
