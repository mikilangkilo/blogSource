---
title: 设计模式以及Android举例
date: 2019-02-15 00:13:47
tags: 设计模式
---

# 设计模式原则

- 开闭原则

对拓展开放，对修改关闭。

- 里氏替换原则

只有当衍生类可以替换掉基类，软件单位的功能不受到影响时，基类才能真正的被复用，而衍生类也能在基类的基础上增加新的行为。

- 依赖倒转原则

对接口编程，依赖于抽象而不依赖于具体。

- 接口隔离原则

使用多个隔离的接口来降低耦合度

- 迪米特法则

一个实体应该尽量少的与其他实体之间发生相互作用，使得系统功能模块相对独立

- 合成复用原则

尽量使用合成/聚合的方式，而不是使用继承，继承实际上破坏了类的封装性，超类的方法可能被子类修改

# 三大类

基于6个设计原则，衍生为3大类23种设计模式

## 创造型模式

- 工厂方法模式

- 抽象工厂模式

- 单例模式

- 建造者模式

- 原型模式

## 结构型模式

- 适配器模式

- 装饰器模式

- 代理模式

- 外观模式

- 桥接模式

- 组合模式

- 享元模式

## 行为型模式

- 策略模式

- 模版方法模式

- 观察者模式

- 迭代子模式

- 责任链模式

- 命令模式

- 备忘录模式

- 状态模式

- 访问者模式

- 中介者模式

- 解释器模式

# 详解

## 工厂模式

通过new创建一个对象，大部分时候需要传入构造参数，或者生成对象之前需要先生成一些辅助功能的对象。
这样可以抽象的认为一个对象的构建如同机器中的齿轮转动，最后通过生成了很多对象之后，生成了一个最终的对象。

### 解决的问题

不关心对象实例构造的细节和复杂过程，而轻松的创建实例

### 抽象工厂模式

实例构建过程
```
//声明抽象接口类
interface food{}

//需要的实体类需要继承该接口
class A implements food{}
class B implements food{}
```

工厂过程
```
interface produce{ food get();}

class FactoryForA implements produce{
    @Override
    public food get() {
        return new A();
    }
}
class FactoryForB implements produce{
    @Override
    public food get() {
        return new B();
    }
}
```

抽象工厂过程
```
public class AbstractFactory {
    public void ClientCode(String name){
        if(name.equals("A")){
            food x= new FactoryForA().get();
            x = new FactoryForB().get();
        }
    }
}
```

工厂模式的精髓在于**工厂模式**，就是把类型的定义过程和实例化过程分开

首先是定义过程，定义了一个产品如何创建，然后创建了一个创建这个产品的工厂，这一步是简单工厂，在之后创建了一个创建工厂的工厂，这个就是抽象工厂。
因为产品之间的构造可能有依赖，这个依赖需要通过简单工厂的协作来解决，因此需要一个抽象工厂来协助处理工厂之间的关系。

### 工厂模式进一步的优化

```
public class ConcreateFactory extends Factory{
    @Override
    public<T extends Product> T createProduct(Class<T> clz){
        Product p = null;
        try{
            p = (Product) class.forName(clz.getName()).newInstance();
        }catch(Exception e){
            e.printStackTrace();
        }
        return (T)p;
    }
}
```
这样的话只需要传入名字即可实例，对比new出来的，不需要代码的变化。

### 工厂模式在Android中的使用例子


#### collection

Collection接口继承自Iterable接口

```
public interface Iterable<T>{
    Iterator<T> iterator();
}
```

该接口的作用就是返回一个迭代器，这个iterator方法就相当于一个工厂方法，专门为new对象而生。

#### Activity.onCreate()

ActivityThread作为一个app的入口，自zygote孵化一个新的进程之后就会被调用。

ActivityThread会准备
在looplooper和消息队列，然后调用attach方法绑定到ActivityManagerService中，
之后就会不断的读取消息队列中的消息并分发消息。
looper准备之前，会调用attach，会将AMS与当前的athread绑定，AMS会调用attachApplication方法，
attachapplication中主要是做了bindApplication和attachApplicationlocked，会通过mStackSupervisor进行
realStartActivityLocked方法，该方法首先会准备启动activity的参数信息，准备完毕后会调用ApplicationThread
的scheduleLaunchActivity方法启动activity。
启动的过程是构造一个ActivityClientRecord对象，并将相关参数设置，最后通过sendMessage方法发送一个启动消息到消息队列，
由ActivityThread的handler处理启动。这也就是looper启动的时候做的事情。

在looper调用该消息的时候，会针对flag做各种处理。比如说启动activity的flag为LAUNCH_ACTIVITY，处理的过程在activitythread中
复写的handler对象，其接受到了msg之后会触发performLaunchActivity方法，该方法为具体的启动Activity逻辑

从mInstrumentation.callActivityOnCreate()之中就可以看到其调用了activity的oncreate，
做了activity.performCreate()的操作

```
final void performCreate(Bundle icicle, PersistableBundle persistentState) {
        mCanEnterPictureInPicture = true;
        restoreHasCurrentPermissionRequest(icicle);
        if (persistentState != null) {
            onCreate(icicle, persistentState);
        } else {
            onCreate(icicle);
        }
        mActivityTransitionState.readState(icicle);

        mVisibleFromClient = !mWindow.getWindowStyle().getBoolean(
                com.android.internal.R.styleable.Window_windowNoDisplay, false);
        mFragments.dispatchActivityCreated();
        mActivityTransitionState.setEnterActivityOptions(this, getActivityOptions());
    }
```

activity的performCreate事实上就是执行了oncreate操作。

说上面这么一大段是什么意思呢?oncreate里面只是通过了setContentView便可以创建出不同的View，可以说是工厂模式的一种

### 总结

#### 优点

- 降低了对象之间的耦合度，代码结构清晰，对调用者隐藏了产品的生产过程，生产过程改变后，调用者不用做什么改变，易于修改。
- 易于拓展，要增加工厂和产品都非常方便，直接实现接口，不用修改之前的代码。

#### 缺点

- 系统结构复杂化，非常简单的系统不需要这样了。

## 策略模式

根据不同的情况选择不同的策略的模式，称为策略模式。

例如根据排序算法在不同数量级的优越性，根据数据的数量来安排适用的算法，但是这样会导致封装的类太过臃肿，违背了OCP原则和单一职责原则。
不过如果将需要的算法和策略抽象出来，提供一个统一的接口，由客户端注入不同的实现对象或者策略的动态替换，这种模式的可拓展性、可维护性更高。

### 定义

策略模式定义了一系列算法，并将每个算法封装起来，而且还可以使他们互相替换，策略模式让算法独立于使用她的客户而独立变化。

### 使用场景

- 针对同一类型问题的多种处理方式，仅仅是具体行为上有差别。
- 需要安全的封装多种同一类型的操作
- 出现同一个抽象类有多个子类，而又需要使用if-else或者switch-case来具体选择子类时。

### 简单实现


接口的实现
```
public interface CalculateStrategy{
    int calculatePrice(int km);
}
```
计算公交车费的实体类

```
public class BusStrategy implements CalculateStrategy{
    @Override
    public int calculatePrice(int km){
        ....
    }
}
```
计算地铁费的实体类
```
public class SubwayStrategy implements CalculateStrategy{
    @Override
    public int calculatePrice(int km){
        ...
    }
}
```
计算总费用的实体类
```
public class TranficCalculator{
    CalculateStrategy mStrategy;
    
    public void setStrategy(Calculategy strategy){
        this.mStrategy = strategy;
    }
    
    public int calculatePrice(int km){
        return mStrategy.calculatePrice(km);
    }

    public static void main(String[] args){
        TranficCalculator tc = new TranficCalculator();
        tc.setStrategy(new BusStrategy);
        System.out.println(tc.calculatePrice(16))
    }
}
```

如上，虽然写法比较繁琐，但是去掉了ifelse语句，相对来讲清晰很多很多。

如果想计算别的条件的话，比如说计算texi的价格，只需要增加一个texi的calculator，之后将其注入到TranficCalculator中即可。

对比ifelse的话，需要增加一个else语句，而设计原则是针对扩展开放，针对修改关闭。

### Android中的实现

安卓中针对策略模式的实现还是很多的。

动画的时间插值器，能有线性的，能有加减速的。recyclerview的layoutmanager，有GridLayoutManager，有LinearLayoutManager都是这种。

从客户端的角度来看，如果他不通过这种方式开放的话，其实对使用者很不友好，需要修改源码，而正是套用了策略模式，所以对使用者来说拓展很方便。

### 优点

- 结构清晰明了、使用简单直观
- 耦合度相对来讲很低，扩展方便
- 操作封装也更为彻底，数据更为安全

### 缺点

- 随着策略的增加，子类也变得繁多（事实上策略的增多必然会带来代码的冗余，但是修改if-else的接口对比增加子类来讲更加有缺点）





















