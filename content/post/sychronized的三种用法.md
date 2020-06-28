---
title: "Sychronized的三种用法"
date: 2019-05-21T00:43:56+08:00
tags: java
---

# public void sychronized foo(){}

作用于实例方法上面的同步，事实上只是拿了该示例方法的对象作为锁的对象。

等同于

```
public void foo(){
    sychronized(this){
    
    }
}
```

好处是不需要自己加锁的对象，坏处呢，是假如有多个方法同时使用了sychronized，那么这些方法事实上是拿了同一个对象。
也就是这些方法假如同时进行的话，需要一个等一个这样，不够异步，无法达到性能最大化。
好处其实还不止这个，我们想arraylist的add和remove同步的话，需要如果使用Collections.sychronizedCollections方法。
其实也就是在每个方法前面加了一个锁，这样能保证每个方法都同步，这也是悲观锁的一种体现方式。

# sychronized(obj){}

即作用域代码块，这里就需要对比obj是否是同一个了，对同一个obj事实上都需要等待obj的锁释放。

```
public void foo(){
    Object obj = new Object();
    sychronized(obj){
        ...
    }
}
```

这是一个很无聊的写法，按理说省略号的部分没有栈调用这个方法的话，这个基本上是没有用的。

# public static sychronized void foo(){}

这个写法其实类似于

```
public class O{
    public static void foo(){
        sychronized(O.class){
            ...
        }
    }
}
```

不同于上面的this，因为static中无法拿到this。所以事实上锁住的是class对象。

效果呢其实类似于第一种，不过有点区分，就是假如第一种也在这个类里面的话，两个事实上锁住的是不同的对象。


以前面试小米的时候被问到过，今天刚好看到一篇写的比较详细的，以前和进奎也为这个问题讨论过。特此总结一下。
