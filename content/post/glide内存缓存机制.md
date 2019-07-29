---
title: "Glide内存缓存机制"
date: 2019-07-29T09:50:23+08:00
---

```aidl
Glide.with(context)
    .load(url)
    .into(imageView);
```

基础的用法是上面这个

在with之后返回的是一个**RequestManager**

在load之后返回的是一个**RequestBuilder**



