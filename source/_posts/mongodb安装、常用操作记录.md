---
title: mongodb安装、常用操作记录
date: 2018-05-29 18:07:21
tags: sql
---

由于阿里云服务器切成了centos，故需要重新部署数据库，之前部署的sqlite是在是太low了，拿不出手，这次搞mongodb。

# 安装

```
curl -O https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-3.0.6.tgz    # 下载
tar -zxvf mongodb-linux-x86_64-3.0.6.tgz                                   # 解压

mv  mongodb-linux-x86_64-3.0.6/ /usr/local/mongodb                         # 将解压包拷贝到指定目录
```

# 环境变量设置

```
export PATH=<mongodb-install-directory>/bin:$PATH
```

# 创建数据库目录

```
cd /
mkdir -p /data/db
``` 

# 命令行中运行 MongoDB 服务

```
mongod
```

如果环境变量没设需要到相关目录下执行

# 管理shell

```
mongo
```

环境变量问题同上。

# 基础知识

sql -> mongodb -> 意义

database -> databse -> 数据库

table -> collection -> 数据库表/集合

row -> document -> 数据记录行/文档

column -> field -> 数据字段/域

index -> index -> 索引

table joins  -> null -> 表连接

primary key -> primary key -> 主键，mongodb自动将_id设为主键

# 基础操作

## 展示所有的数据库

```
show dbs
```

## 显示当前使用的数据库

```
db
```

## 切换数据库

```
use db1
```

即可切换到db1数据库

### 数据库命名规则

1 不能是空字符串（"")。
2 不得含有' '（空格)、.、$、/、\和\0 (空字符)。
3 应全部小写。
4 最多64字节。

下列有特殊意义的数据库名字需要保留

1 admin： 从权限的角度来看，这是"root"数据库。要是将一个用户添加到这个数据库，这个用户自动继承所有数据库的权限。一些特定的服务器端命令也只能从这个数据库运行，比如列出所有的数据库或者关闭服务器。

2 local: 这个数据永远不会被复制，可以用来存储限于本地单台服务器的任意集合

3 config: 当Mongo用于分片设置时，config数据库在内部使用，用于保存分片的相关信息。

### 文档命名规则

1 键不能含有\0 (空字符)。这个字符用来表示键的结尾。
2 .和$有特别的意义，只有在特定环境下才能使用。
3 以下划线"_"开头的键是保留的(不是严格要求的)


几个注意点

1 文档中的键/值对是有序的。
2 文档中的值不仅可以是在双引号里面的字符串，还可以是其他几种数据类型（甚至可以是整个嵌入的文档)。
3 MongoDB区分类型和大小写。
4 MongoDB的文档不能有重复的键。
5 文档的键是字符串。除了少数例外情况，键可以使用任意UTF-8字符

### 集合命名规则

1 集合名不能是空字符串""。
2 集合名不能含有\0字符（空字符)，这个字符表示集合名的结尾。
3 集合名不能以"system."开头，这是为系统集合保留的前缀。
4 用户创建的集合名字不能含有保留字符。有些驱动程序的确支持在集合名里面包含，这是因为某些系统生成的集合中包含该字符。除非你要访问这种系统创建的集合，否则千万不要在名字里出现$。

capped collections

capped collections就是具有固定大小的collections。类似于队列，通过插入顺序来判断过期现象。

```
db.createCollection("mycoll", {capped:true, size:100000})
```

在capped collection中，你能添加新的对象。
能进行更新，然而，对象不会增加存储空间。如果增加，更新就会失败 。
数据库不允许进行删除。使用drop()方法删除collection所有的行。
注意: 删除之后，你必须显式的重新创建这个collection。
在32bit机器中，capped collection最大存储为1e9( 1X109)个字节。


### 元数据

数据库的信息是存储在集合中。它们使用了系统的命名空间：

```
dbname.system.*
```

dbname.system.namespaces -> 列出所有名字空间。

dbname.system.indexes -> 列出所有索引。

dbname.system.profile -> 包含数据库概要(profile)信息。

dbname.system.users	-> 列出所有可访问数据库的用户。

dbname.local.sources -> 包含复制对端（slave）的服务器信息和状态。

对于修改系统集合中的对象有如下限制。

在{{system.indexes}}插入数据，可以创建索引。但除此之外该表信息是不可变的(特殊的drop index命令将自动更新相关信息)。

{{system.users}}是可修改的。 {{system.profile}}是可删除的。

### MongoDB 数据类型

String -> 字符串。存储数据常用的数据类型。在 MongoDB 中，UTF-8 编码的字符串才是合法的。

Integer -> 整型数值。用于存储数值。根据你所采用的服务器，可分为 32 位或 64 位。

Boolean -> 布尔值。用于存储布尔值（真/假）。

Double -> 双精度浮点值。用于存储浮点值。

Min/Max keys -> 将一个值与 BSON（二进制的 JSON）元素的最低值和最高值相对比。

Array -> 用于将数组或列表或多个值存储为一个键。

Timestamp -> 时间戳。记录文档修改或添加的具体时间。

Object -> 用于内嵌文档。

Null -> 用于创建空值。

Symbol -> 符号。该数据类型基本上等同于字符串类型，但不同的是，它一般用于采用特殊符号类型的语言。

Date -> 日期时间。用 UNIX 时间格式来存储当前日期或时间。你可以指定自己的日期时间：创建 Date 对象，传入年月日信息。

Object ID -> 对象 ID。用于创建文档的 ID。

Binary Data -> 二进制数据。用于存储二进制数据。

Code -> 代码类型。用于在文档中存储 JavaScript 代码。

Regular expression -> 正则表达式类型。用于存储正则表达式。

#### ObjectId

1 前 4 个字节表示创建 unix时间戳,格林尼治时间 UTC 时间，比北京时间晚了 8 个小时
2 接下来的 3 个字节是机器标识码
3 紧接的两个字节由进程 id 组成 PID
4 最后三个字节是随机数

#### 字符串

BSON 字符串都是 UTF-8 编码。

#### 时间戳

BSON 有一个特殊的时间戳类型用于 MongoDB 内部使用，与普通的 日期 类型不相关。 时间戳值是一个 64 位的值。其中：

前32位是一个 time_t 值（与Unix新纪元相差的秒数）
后32位是在某秒中操作的一个递增的序数
在单个 mongod 实例中，时间戳值通常是唯一的。

#### 日期

```
> Date()
Sun Mar 04 2018 15:02:59 GMT+0000 (UTC)   
```

# 数据库连接

## 使用默认端口来连接 MongoDB 的服务。

```
mongodb://localhost
```

## 通过 shell 连接 MongoDB 服务：

```
$ ./mongo
MongoDB shell version: 3.0.6
connecting to: test
...
```

# 创建数据库

```
use DATABASE_NAME
```

# 删除数据库

```
db.dropDatabase()
```



# 创建集合

```
db.createCollection(name, options)
```

name: 要创建的集合名称
options: 可选参数, 指定有关内存大小及索引的选项

options可选：
capped -> 为true则是固定集合，需要同时指定size
autoIndexId -> 为true自动在 _id 字段创建索引。默认为 false。
size -> （可选）为固定集合指定一个最大值（以字节计）。如果 capped 为 true，也需要指定该字段。
max -> （可选）指定固定集合中包含文档的最大数量。


# 删除集合

```
db.collection.drop()
```

# 插入文档

```
db.COLLECTION_NAME.insert(document)
```

```
>db.col.insert({title: 'MongoDB 教程', 
    description: 'MongoDB 是一个 Nosql 数据库',
    by: '菜鸟教程',
    url: 'http://www.runoob.com',
    tags: ['mongodb', 'database', 'NoSQL'],
    likes: 100
})
```

```
> document=({title: 'MongoDB 教程', 
    description: 'MongoDB 是一个 Nosql 数据库',
    by: '菜鸟教程',
    url: 'http://www.runoob.com',
    tags: ['mongodb', 'database', 'NoSQL'],
    likes: 100
});
> db.col.insert(document)
```

# 更新文档

## update

```
db.collection.update(
   <query>,
   <update>,
   {
     upsert: <boolean>,
     multi: <boolean>,
     writeConcern: <document>
   }
)
```

1 query : update的查询条件，类似sql update查询内where后面的。
2 update : update的对象和一些更新的操作符（如$,$inc...）等，也可以理解为sqlupdate查询内set后面的
3 upsert : 可选，这个参数的意思是，如果不存在update的记录，是否插入objNew,true为插入，默认是false，不插入。
4 multi : 可选，mongodb 默认是false,只更新找到的第一条记录，如果这个参数为true,就把按条件查出来多条记录全部更新。
5 writeConcern :可选，抛出异常的级别。

tip : 3.2之后可用下面方法
```
db.test_collection.updateOne({"name":"abc"},{$set:{"age":"28"}})
```

```
db.test_collection.updateMany({"age":{$gt:"10"}},{$set:{"status":"xyz"}})
```

## save

```
db.collection.save(
   <document>,
   {
     writeConcern: <document>
   }
)
```

1 document : 文档数据。
2 writeConcern :可选，抛出异常的级别。

1 WriteConcern.NONE:没有异常抛出
2 WriteConcern.NORMAL:仅抛出网络错误异常，没有服务器错误异常
3 WriteConcern.SAFE:抛出网络错误异常、服务器错误异常；并等待服务器完成写操作。
4 WriteConcern.MAJORITY: 抛出网络错误异常、服务器错误异常；并等待一个主服务器完成写操作。
5 WriteConcern.FSYNC_SAFE: 抛出网络错误异常、服务器错误异常；写操作等待服务器将数据刷新到磁盘。
6 WriteConcern.JOURNAL_SAFE:抛出网络错误异常、服务器错误异常；写操作等待服务器提交到磁盘的日志文件。
7 WriteConcern.REPLICAS_SAFE:抛出网络错误异常、服务器错误异常；等待至少2台服务器完成写操作。

# 删除文档

```
db.collection.remove(
   <query>,
   <justOne>
)
```

2.6以后

```
db.collection.remove(
   <query>,
   {
     justOne: <boolean>,
     writeConcern: <document>
   }
)
```

query :（可选）删除的文档的条件。
justOne : （可选）如果设为 true 或 1，则只删除一个文档。
writeConcern :（可选）抛出异常的级别。


想只删除找到的第一条

```
db.COLLECTION_NAME.remove(DELETION_CRITERIA,1)
```

想删除所有
```
db.col.remove({})
```

# 查询文档

```
db.collection.find(query, projection)
```

1 query ：可选，使用查询操作符指定查询条件
2 projection ：可选，使用投影操作符指定返回的键。查询时返回文档中所有键值， 只需省略该参数即可（默认省略）。

```
db.col.find().pretty()
```

格式化显示

## where 操作

### 等于

```
db.col.find({"by":"菜鸟教程"}).pretty()
```

等同于

```
where by = '菜鸟教程'
```

### 小于

```
db.col.find({"likes":{$lt:50}}).pretty()
```

等同于

```
where likes < 50
```

### 小于等于

```
db.col.find({"likes":{$lte:50}}).pretty()
```

等同于

```
where likes <= 50
```

### 大于

```
db.col.find({"likes":{$gt:50}}).pretty()
```

等同于

```
where likes > 50
```

### 大于或等于

```
db.col.find({"likes":{$gt:50}}).pretty()
```

等同于

```
where likes > 50
```

### 不等于

```
db.col.find({"likes":{$ne:50}}).pretty()
```

等同于

```
where likes != 50
```

## and操作

```
db.col.find({key1:value1, key2:value2}).pretty()
```

```
db.col.find({"by":"菜鸟教程", "title":"MongoDB 教程"}).pretty()
```

等同于

```
WHERE by='菜鸟教程' AND title='MongoDB 教程'
```

## or操作

```
db.col.find(
   {
      $or: [
         {key1: value1}, {key2:value2}
      ]
   }
).pretty()
```

```
db.col.find({$or:[{"by":"菜鸟教程"},{"title": "MongoDB 教程"}]}).pretty()
```

## and 和 or 同时

```
db.col.find({"likes": {$gt:50}, $or: [{"by": "菜鸟教程"},{"title": "MongoDB 教程"}]}).pretty()
```


























