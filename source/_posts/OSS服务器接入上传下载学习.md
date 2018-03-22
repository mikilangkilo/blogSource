---
title: OSS服务器接入上传下载学习
date: 2018-03-22 15:20:50
tags: android
---

主要是针对oss初始化的几种方式进行一个总结，下载上传部分精细的地方暂时不用深入（也没时间深入 lol）

# 初始化

## sts鉴权模式

直接进行token的设置，即时自己单开一个请求获取ststoken，获取了token之后，将token的AccessKeyId，SecretKeyId，SecurityToken三个参数设置于OSSStsTokenCredentialProvider，然后用于初始化OSSCredentialProvider。之后便可以实例OSS的客户端了。

该方法亦可以通过在OSSCredentialProvider的多态方法中加入token的回调接口，然后直接将这个参数进行oss的初始化。

## 通过自签名模式进行初始化。

自签名是将secretkeyid和secretkeyscret放在服务器端，然后请求的时候返回

```
signature = "OSS " + AccessKeyId + ":" + base64(hmac-sha1(AccessKeySecret, content))
```

本地重构一下OSSCredentialProvider的多态方法

```
String endpoint = "http://oss-cn-hangzhou.aliyuncs.com";
credentialProvider = new OSSCustomSignerCredentialProvider() {
    @Override
    public String signContent(String content) {
        // 您需要在这里依照OSS规定的签名算法，实现加签一串字符内容，并把得到的签名传拼接上AccessKeyId后返回
        // 一般实现是，将字符内容post到您的业务服务器，然后返回签名
        // 如果因为某种原因加签失败，描述error信息后，返回nil
        // 以下是用本地算法进行的演示
        return "OSS " + AccessKeyId + ":" + base64(hmac-sha1(AccessKeySecret, content));
    }
};
OSS oss = new OSSClient(getApplicationContext(), endpoint, credentialProvider);
```

亦可以进行token的设置。

## 直传模式

后端返回policy，OSSAccessKeyId，Signature，然后组装body，带上file和filename，然后直接post给阿里云的服务器。

简单粗暴，但是整个sdk基本上就没有使用了，sdk的分布下载，断点重传功能等等就白白浪废了。

这个模式给web端用比较好。