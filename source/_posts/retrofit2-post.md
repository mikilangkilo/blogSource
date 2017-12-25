---
title: retrofit2 post
date: 2017-12-21 15:53:25
tags:
---

# retrofit的post方法

## 简单的双参数上传，结果是ResponseBody
```
	@FormUrlEncoded
	@POST("xxx.com")
	Observable<ResponseBody> login(
		@Field("no") String no,
		@Field("pass") String pass);
```

## 文件上传 （ 多文件上传,使用 @PartMap Map<String, RequestBody> params 要注意在设置每一个RequestBody文件的时候，数组名不能一致，否则会覆 盖。）
```
	@Multipart
    @POST("xxx.com")
    Observable<ResponseBody> uploadFile(
        @Part("file\"; filename=\"test.png") RequestBody file
     );

```

## 单文件上传
```
	@Multipart
    @POST("xxx.com")
    Observable<ResponseBody> uploadFile(
            @Part MultipartBody.Part file );
```

## 多文件上传
```
	@Multipart
    @POST("xxx.com")
    Observable<ResponseBody> uploadFile(
            @Part() List<MultipartBody.Part> files );
```

## 文件和参数共同上传  (参数也需要封装成MultipartBody.Part这样的类型，不然传递会出错，这个类型其实就是将这些数据封装成表单的类型，因为在这里不能使用FormUrlEncoded进行处理)
```
	@Multipart
    @POST("xxx.com")
    Observable<ResponseBody> uploadFile(
         @Part() List<MultipartBody.Part > files );
```