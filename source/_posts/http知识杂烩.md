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

## RequestBody拓展

requestBody的拓展其实比较有用，今次项目中用到，若不是不支持urlencode，获取也不会关注。

在okhttp里面加入一个继承自Interceptor的拦截器，将请求拦截下来，针对不同的请求进行操作，例如加上一个token，批量操作header等。

操作的过程就是对requestbody拓展的过程，就是将原有的src的requestbody，和extend的requestbody进行融合。

需要写三个方法，contentType、contentLength、writeTo。

<!-- contenttype是contenttype。contentlength是src.contentlength()+extend.contentlength()+1。writeto是写操作，先写src，后写extend，需要对不同的contenttype加上不同的连接符，sink.writeUtf8(",")或者sink.writeUtf8("&")等等。

如此便可以自由的截断和拓展相关requestbody了。 -->

对requestbody的拓展，如果是json有一个问题，就是}{这两个符号不好处理，暂时没有找到方法。

但是对于x-www-form-urlencoded这种连接的文本比较容易操作，中间加一个&即可。

## http url拓展

url的拓展主要是针对末尾增加query，或者parameter这种。

使用的方法也是差不多的方法，通过拦截器获取request，然后从request中取出url，对url进行拼装，之后在使用新的url来重新组装一个request，之后返回即可。

有一点需要注意的，不是所有的请求都会从url中获取参数，这个开发中需要注意。



