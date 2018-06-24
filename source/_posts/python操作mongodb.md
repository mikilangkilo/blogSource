---
title: python操作mongodb
date: 2018-06-06 11:35:26
tags: python
---

# 连接mongodb

```
#!/usr/bin/env python
# -*- coding:utf-8 -*-

from pymongo import MongoClient

conn = MongoClient('192.168.0.113', 27017)
db = conn.mydb  ##连接mydb数据库，没有则自动创建
my_set = db.test_set  # 使用test_set集合，没有则自动创建
```

# 插入数据

```
my_set.insert({"name":"zhangsan","age":18})

# 或

my_set.save({"name":"zhangsan","age",18})
```

#插入多条

```
users=[{"name":"zhangsan","age":18},{"name":"lisi","age":18}]
my_set.insert(users)

# 或

my_set.save(users)
```

# 查询数据

```
# 查询全部
for i in my_set.find():
	print(i)

# 查询name = zhangsan 的

for i in my_set.find({"name":"zhangsan"}):
	print(i)
print(my_set.find_one({"name":"zhangsan"}))

```

# 更新数据

```
my_set.update(
	<query>,  #查询条件
	<update>,  #update的对象和一些更新操作符
	{
		upsert: <boolean> # 如果不存在update的记录，是否插入
		multi: <boolean> # 可选，mongodb默认是false，只更新找到的第一条记录
		writeConcern: <document> # 可选，抛出异常的级别
	}
)
```

```
my_set.update({"name":"zhangsan"},{'$set':{"age":20}})
```

# 删除数据

```
my_set.remove(
	<query>,  # 可选：删除的文档的条件
	{
		justOne: <boolean>
		writeConcern: <document>
	}
)
```

```
# 删除name = lisi的全部记录
my_set.remove({'name':'zhangsan'})

# 删除name=lisi的某个id的记录
id = my_set.find_one({"name":"zhangsan"})["_id"]
my_set.remove(id)

# 删除集合里的所有记录
db.users.remove()
```







































