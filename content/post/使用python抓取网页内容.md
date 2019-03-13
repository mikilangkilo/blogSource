---
title: 使用python抓取网页内容
date: 2018-01-26 22:54:51
tags: python
---

进行爬虫抓取，有一个大致的思路。
首先是抓取当前页的关键内容，也就是我们需要的内容。
其次是抓取下一页的网址信息，也就是用于下一轮进行抓取的对象。

因此使用一个queue去存储抓取的网址信息，当queue不为空的时候执行轮次抓取关键信息的操作。
同时还有一个set去存储以抓取的网址的信息，确保不会重复查询某个网址。

```
queue Q
set S
StartPoint = "http://jecvay.com"
Q.push(StartPoint)  # 经典的BFS开头
S.insert(StartPoint)  # 访问一个页面之前先标记他为已访问
while (Q.empty() == false)  # BFS循环体
  T = Q.top()  # 并且pop
  for point in PageUrl(T)  # PageUrl(T)是指页面T中所有url的集合, point是这个集合中的一个元素.
    if (point not in S)
      Q.push(point)
      S.insert(point)
```

大致如这个伪代码。

queue初始化：
```
	queue = deque()
```
queue添加：
```
	queue.append(url)
```
queue出栈：
```
	queue.popleft()
```


set初始化：
```
	visited = set()
```
set添加：
```
	visited |= {url}
```

url抓取：
```
	urlop = urllib.requests.urlopen(url)
```

数据解析:
```
	data = urlop.read().decode('utf-8')
```
