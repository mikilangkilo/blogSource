---
title: "音视频-HLS"
date: 2020-08-10T21:59:56+08:00
tag : "音视频"
category : "HLS"
---

HLS是apple的动态码率自适应技术，主要包括一个m3u(8)的索引文件，ts媒体分片文件和key加密串文件

# HLS详述

HLS广泛使用基于HTTP的内容分发网络来传输媒体流。其通过将整个流分为一个个小的基于HTTP的文件来下载，每次只下载一些。

HLS协议由三部分组成：HTTP,M3U8,TS。

# M3U(8)

```
https://live.xmcdn.com/live/94/24.m3u8
```
这个是一个m3u8地址，下载下来是一个M3U8文件，这个文件通过记事本打开，内容如下

```
#EXTM3U
#EXT-X-VERSION:3
#EXT-X-TARGETDURATION:7
#EXT-X-MEDIA-SEQUENCE:22439254
#EXTINF:7,
http://live.xmcdn.com/192.168.3.136/live/94/24/200810_073046_c60.aac
#EXTINF:7,
http://live.xmcdn.com/192.168.3.136/live/94/24/200810_073046_c61.aac
#EXTINF:7,
http://live.xmcdn.com/192.168.3.136/live/94/24/200810_073046_c62.aac
```

这就是M3U8协议生成的文件，和M3U的差别在于，这是一个UTF-8编码的文件。

## 文件格式简介(复制自网上，可能有误)

文件播放列表格式定义：播放列表（Playlist，也即 m3u8 文件） 内容需严格满足规范定义所提要求。下面罗列一些主要遵循的条件：

### 1、文件播放列表格式定义：播放列表（Playlist，也即 m3u8 文件） 内容需严格满足规范定义所提要求。下面罗列一些主要遵循的条件：

1、 m3u8 文件必须以 utf-8 进行编码，不能使用 Byte Order Mark（BOM）字节序， 不能包含 utf-8 控制字符（U+0000 ~ U_001F 和 U+007F ~ u+009F）。

2、 m3u8 文件的每一行要么是一个 URI，要么是空行，要么就是以 # 开头的字符串。不能出现空白字符，除了显示声明的元素。