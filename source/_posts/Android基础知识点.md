---
title: Android基础知识点
date: 2018-02-06 18:49:15
tags: android
---

+ 为什么建议只使用默认的构造方法来创建 Fragment？

之所以建议只使用默认的构造方式来创建fragment，是为了避免构造的过程中进行数据的设置。我们在oncreate和oncreateview的过程中可以获取bundle，这个bundle在存储fragment的时候同样可以被存储，而假如构造的模式进行设置参数的话，这些值就不会被系统存储。并且fragment的创建，其实是由fragmentmanager来初始化的，其初始化过程依靠了反射，并且是无参数反射，因此若不使用默认的构造的话会直接编译报错。

+ 为什么 Bundle 被用来传递数据，为什么不能使用简单的 Map 数据结构？

Bundle内部是由ArrayMap实现的，ArrayMap的内部实现是两个数组，一个int数组是存储对象数据对应下标，一个对象数组保存key和value，内部使用二分法对key进行排序，所以在添加、删除、查找数据的时候，都会使用二分法查找，只适合于小数据量操作，如果在数据量比较大的情况下，那么它的性能将退化。而HashMap内部则是数组+链表结构，所以在数据量较少的时候，HashMap的Entry Array比ArrayMap占用更多的内存。因为使用Bundle的场景大多数为小数据量，我没见过在两个Activity之间传递10个以上数据的场景，所以相比之下，在这种情况下使用ArrayMap保存数据，在操作速度和内存占用上都具有优势，因此使用Bundle来传递数据，可以保证更快的速度和更少的内存占用。
另外一个原因，则是在Android中如果使用Intent来携带数据的话，需要数据是基本类型或者是可序列化类型，HashMap使用Serializable进行序列化，而Bundle则是使用Parcelable进行序列化。而在Android平台中，更推荐使用Parcelable实现序列化，虽然写法复杂，但是开销更小，所以为了更加快速的进行数据的序列化和反序列化，系统封装了Bundle类，方便我们进行数据的传输。

+ 什么是 JobScheduler ？

jobscheduler提供了一种不同于alarmmanager的唤醒app的方式，其主要工作场景：应用具有您可以推迟的非面向用户的工作。/应用具有当插入设备时您希望优先执行的工作。/应用具有需要访问网络或 Wi-Fi 连接的任务。/应用具有您希望作为一个批次定期运行的许多任务。

