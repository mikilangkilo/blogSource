---
title: http知识杂烩
date: 2018-03-27 22:45:05
tags: http
---

今天被后台怼了，主要是没加
```
@Headers({"Content-Type: application/json"})
```

导致请求没有过到服务器，然后我还挺着老脸去问为啥没用。丢人呐。

所以今天开一个杂烩贴，用于将http遇到的问题总结下来。

## Content-Type

Content-Type，内容类型，一般是指网页中存在的Content-Type，用于定义网络文件的类型和网页的编码，决定文件接收方将以什么形式、什么编码读取这个文件

### application/json

application/json是一种正常的以json形式读取传输文件的方式。
json全名是javascript object notation，形式是{"key":"value"}的形式

对象表示为键值对
数据由逗号分隔
花括号保存对象
方括号保存数组

### application/x-www-form-urlencoded

首先，Content-Type 被指定为 application/x-www-form-urlencoded；其次，提交的数据按照 key1=val1&key2=val2 的方式进行编码，key 和 val 都进行了 URL 转码。大部分服务端语言都对这种方式有很好的支持。

### multipart/form-data

这是使用表单上传文件时必须的。

示例：
```
POST http://www.example.com HTTP/1.1
Content-Type:multipart/form-data; boundary=----WebKitFormBoundaryrGKCBY7qhFd3TrwA

------WebKitFormBoundaryrGKCBY7qhFd3TrwA
Content-Disposition: form-data; name="text"

title
------WebKitFormBoundaryrGKCBY7qhFd3TrwA
Content-Disposition: form-data; name="file"; filename="chrome.png"
Content-Type: image/png

PNG ... content of chrome.png ...
------WebKitFormBoundaryrGKCBY7qhFd3TrwA--
```

首先生成了一个 boundary 用于分割不同的字段，为了避免与正文内容重复，boundary 很长很复杂。然后 Content-Type 里指明了数据是以 multipart/form-data 来编码，本次请求的 boundary 是什么内容。消息主体里按照字段个数又分为多个结构类似的部分，每部分都是以 --boundary 开始，紧接着是内容描述信息，然后是回车，最后是字段具体内容（文本或二进制）。如果传输的是文件，还要包含文件名和文件类型信息。消息主体最后以 --boundary-- 标示结束。

### text/xml

示例：
```
POST http://www.example.com HTTP/1.1 
Content-Type: text/xml

<?xml version="1.0"?>
<methodCall>
    <methodName>examples.getStateName</methodName>
    <params>
        <param>
            <value><i4>41</i4></value>
        </param>
    </params>
</methodCall>
```

这个就和android里面的xml差不多，用途还挺多的，不过就是太大了，也能解析成类似于json的形式。