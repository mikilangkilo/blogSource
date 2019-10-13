---
title: "Android编译流程学习之aidl分析"
date: 2019-10-13T19:18:36+08:00
---

来了喜马拉雅车载部门之后，生产力工具其实很多都没有搭建好。

尤其是jenkins。

jenkins很有用，因为总有人找我们打包，而且打的包没有技术含量。

没有技术含量的活应该给jenkins去做。

然而在centos上面编译我们的项目却有问题，有一个aidl文件import了另外一个aidl接口，写法方面无任何问题，但是就是报错。

我试遍了网上所有的方法，基本都没有用。

只有一个说改一下framework.aidl这个靠谱点，改了之后不提示找不到了，提示unkown type了。X

对比了一下mac下的aidl 编译task的命令是

```
/Users/yinpengcheng/Library/Android/sdk/build-tools/28.0.3/aidl -p/Users/yinpengcheng/Library/Android/sdk/platforms/android-28/framework.aidl 
-o/Users/yinpengcheng/Desktop/ximalaya4.0/FrameWork/CarBusiness/build/generated/aidl_source_output_dir/release/compileReleaseAidl/out 
-I/Users/yinpengcheng/Desktop/ximalaya4.0/FrameWork/CarBusiness/src/release/aidl 
-I/Users/yinpengcheng/Desktop/ximalaya4.0/FrameWork/CarBusiness/src/main/aidl 
-I/Users/yinpengcheng/Desktop/ximalaya4.0/FrameWork/CarUIModule/build/intermediates/aidl_parcelable/release/compileReleaseAidl/out 
-I/Users/yinpengcheng/Desktop/ximalaya4.0/FrameWork/CarImageModule/build/intermediates/aidl_parcelable/release/compileReleaseAidl/out 
-I/Users/yinpengcheng/Desktop/ximalaya4.0/FrameWork/CarBuglyModule/build/intermediates/aidl_parcelable/release/compileReleaseAidl/out ‘-I/Users/yinpengcheng/Desktop/ximalaya4.0/FrameWork/CarOpenSDK/build/intermediates/aidl_parcelable/release/compileReleaseAidl/out 
-I/Users/yinpengcheng/Desktop/ximalaya4.0/FrameWork/CarInternalSDK/CarSDK/build/intermediates/aidl_parcelable/release/compileReleaseAidl/out 
-I/Users/yinpengcheng/Desktop/ximalaya4.0/FrameWork/CarBaseLib/build/intermediates/aidl_parcelable/release/compileReleaseAidl/out 
-I/Users/yinpengcheng/.gradle/caches/transforms-2/files-2.1/1b314f02aa912d06be179f17073a5e35/aidl 
-I/Users/yinpengcheng/.gradle/caches/transforms-2/files-2.1/14d64775f0eb483d42d80811a1967d95/aidl 
-I/Users/yinpengcheng/.gradle/caches/transforms-2/files-2.1/5a2dd18f51601a461c1de087067b2e4a/aidl 
-I/Users/yinpengcheng/.gradle/caches/transforms-2/files-2.1/232f1b77b064387690d91b855716da53/aidl 
-d/var/folders/0p/gp3qgy315j74qkgpz_zxy_lm0000gn/T/aidl4190506609100345238.d /Users/yinpengcheng/Desktop/ximalaya4.0/FrameWork/CarBusiness/src/main/aidl/com/ximalaya/ting/android/car/carbusiness/service/IControler.aidl
```

而centos上面是

```
/home/workspace/sdk/build-tools/28.0.3/aidl -p/home/workspace/sdk/platforms/android-28/framework.aidl 
-o/home/workspace/Android/FrameWork/CarBusiness/build/generated/aidl_source_output_dir/release/compileReleaseAidl/out 
-I/home/workspace/Android/FrameWork/CarBusiness/src/release/aidl 
-I/home/workspace/Android/FrameWork/CarBusiness/src/main/aidl 
-I/home/workspace/Android/FrameWork/CarUIModule/build/intermediates/aidl_parcelable/release/compileReleaseAidl/out 
-I/home/workspace/Android/FrameWork/CarImageModule/build/intermediates/aidl_parcelable/release/compileReleaseAidl/out 
-I/home/workspace/Android/FrameWork/CarBuglyModule/build/intermediates/aidl_parcelable/release/compileReleaseAidl/out 
-I/home/workspace/Android/FrameWork/CarOpenSDK/build/intermediates/aidl_parcelable/release/compileReleaseAidl/out 
-I/home/workspace/Android/FrameWork/CarInternalSDK/CarSDK/build/intermediates/aidl_parcelable/release/compileReleaseAidl/out 
-I/home/workspace/Android/FrameWork/CarBaseLib/build/intermediates/aidl_parcelable/release/compileReleaseAidl/out 
-I/root/.gradle/caches/transforms-2/files-2.1/606b07b73bdf754475a5547bd42f4f77/aidl 
-I/root/.gradle/caches/transforms-2/files-2.1/c7c3621e504cf3ee36f28c449c455bae/aidl 
-I/root/.gradle/caches/transforms-2/files-2.1/e299b68cba90dddc2342557a87520cce/aidl 
-I/root/.gradle/caches/transforms-2/files-2.1/d8039c641d3bdad5644cac85b710f413/aidl 
-d/tmp/aidl6132161123080299761.d /home/workspace/Android/FrameWork/CarBusiness/src/main/aidl/com/ximalaya/ting/android/car/carbusiness/service/IControler.aidl
```

对比一下其实是无任何差别的。

那么问题就知道了，是aidl流程方面的问题。

怎么处理还得看源码。因此也就开一篇博客专门整理一下aidl踩坑的过程吧。