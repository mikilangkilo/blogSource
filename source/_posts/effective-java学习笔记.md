---
title: effective-java学习笔记
date: 2018-05-07 16:45:46
tags: java
---

## 创建和销毁对象。

### 使用静态工厂方法代替构造器

优势：

1 - 静态工厂方法与构造器不同的第一大优势：它们有名称。

由于一个类只能有一个指定签名的构造器，及时我们使用替换顺序来构造不同的构造器，也会产生困扰，不知道该使用哪个。但是静态工厂方法则可以代替构造器，使用不同的名称以显示不同的区别。

2 - 静态工厂方法与构造器不同的第二大优势：不必在每次调用它们的时候都创建一个新的对象。

静态工厂方法可以使用预先构建好的实例，或者将实例缓存起来，进行重复利用。如果程序进场请求创建相同的对象，并且创建对象的代价很高的话，可以考虑使用该方法。

3 - 静态工厂方法与构造器不同的第三大优势：它们可以返回原返回类型的任何子类型的对象。

api可以返回对象，又不会使对象的类变成公有的，类的实现在客户端看来是不可见的。

由于静态工厂方法返回的对象所属的类，在编写包含该静态方法的类时可以不必存在。因此衍生了“服务提供者框架”。

服务提供者框架有三个重要的组件：服务接口，提供者注册api，服务访问api。第四个组件可选，是服务提供者接口。这些提供者负责创建其服务实现的实例，如果没有服务提供者接口，实现就按照类名称注册，并通过反射方式进行实例化。

4 - 静态工厂方法的第四大优势：在创建参数化类型实例的时候，它们使代码变得更加简洁。

例如
```
Map<String, List<String>> m = new HashMap<String, List<String>>();
```

可以通过
```
public static <K, V> HashMap<K, V> newInstance(){
	return new HashMap<K, V>();
}
```

改成
```
Map<String, List<String>> m = HashMap.newInstance();
```

缺点：

1 - 类如果不含公有的或者受保护的构造器，就不能子类化。

针对这一条，“复合“好过”继承“

2 - 它们与其他的静态方法实际上没有任何区别。

由于不是构造器，因此没有办法像构造器一样明确标识出来。因此对于提供了静态工厂方法而不是构造器的类来讲，想要查明如何实例化一个类，比较困难。

我们需要遵守一些惯用名称：

- valueOf ---- 该方法返回的实例与他的参数具有相同的值，这样的静态工厂方法世纪上是类转换的方法。

- of ---- valueOf的另一个更加简洁的方法

- getInstance ---- 返回的实例是通过方法的参数来描述的，但是不能说与参数具有相同的值。对于singleton来说，该方法没有参数，并返回唯一的实例。

- newInstance ---- newinstance能够确保返回的每个实例都与所有的其他实例不同

- getType ---- 像getinstance一样，但是gettype表示返回的使用类型。

- newType ---- 和gettype一样。

### 遇到多个构造器参数时要考虑使用构建器

静态工厂和构造器有个共同的局限性，它们都不能很好的扩展到大量的可选参数。

构建器就是使用set方法来设置参数，不过是build模式的。可以利用单个builder构建多个对象，builder的参数可以在创建对象期间进行调整，也可以随着不同的对象而改变。builder可以自动填充某些域，例如每次创建对象时自动增加序列号。

### 用私有构造器或者枚举类型强化singleton属性

- 使用公有静态域

```
public class Elvis{
	public static final Elvis INSTANCE = new Elvis();
	private Elvis(){
		...
	}
}
```

该方法确保只有一个全局变量，但是该方法容易被反射。

- 使用静态工厂方法来实现singleton

```
public class Elvis{
	private static final Elvis INSTANCE = new Elvis();
	private Elvis{
		...
	}
	public static Elivs getInstance(){
		return INSTANCE;
	}
}
```

getInstance()方法的所有调用都会返回同一个对象引用，所以永远不会创建别的对象。

工厂方法的优势在于提供了灵活性，不改变api的前提下，可以改变该类是否是singleton的想法，可序列化但是维护singleton的话需要申明所有实例域是瞬时的，并且要提供一个readResolve方法

```
private Object readResolve(){
	return Instance;
}
```

- 编写一个包含单个元素的枚举类型

```
public enum Elvis {
	INSTANCE;
}
```

该方法在功能上与公有域相近，但是更加简洁，并且无偿的提供了序列化机制，绝对防止多次实例化，哪怕是反射的时候。

### 通过私有化构造器强化不可实例化的能力

对于类似于Collections这种，不需要也不希望实例化的类，避免自动构建其无参构造，可以使用以下方法。

```
public class UtilityClass{
	private UtilityClass(){
		throw new AssertionError();
	}
}
```

该方法会导致子类没有构造器。

### 避免创建不必要的对象

对于同时提供静态方法和构造器的不可变类，通常可以使用静态工厂方法而不是构造器，以避免创建不必要的对象。例如Boolean.valueOf(String)几乎总是优先于构造器Boolean(String)。这是由于构造器每次构造的时候都会创建一个对象，而静态方法则不会。

除了重用这种方法之外，还可以重用已知的不会修改的可变对象。

```
public class Person{
	
	private final Date birthDate;

	public boolean isBabyBoomer(){
		Calendar gmtCal = Calendar.getInstance(TimeZone.getTimeZone("GMT"));
		gmtCal.set(1946, Calendar.JANUARY, 1, 0, 0, 0);
		Date boomStart = gmtCal.getTime();
		gmtCal.set(1956, Calendar.JANUARY, 1, 0, 0, 0);
		Date boomEnd = gmtCal.getTime();
		return birthDate.compare(boomStart) >= 0 && birthDate.compare(boomEnd) < 0;
	}

}
```

如上方法，每次调用都会新建一个Calendar, 一个TimeZone, 和两个Date实例。

```
class Person{
	private final Date birthDate;

	private static final Date BOOM_START;
	private static final Date BOOM_END;

	static{
		Calendar gmtCal = Calendar.getInstance(TimeZone.getTimeZone("GMT"));
		gmtCal.set(1946, Calendar.JANUARY, 1, 0, 0, 0);
		BOOM_START = gmtCal.getTime();
		gmtCal.set(1956, Calendar.JANUARY, 1, 0, 0, 0);
		BOOM_END = gmtCal.getTime();
	}

	public boolean isBabyBoomer(){
		return birthDate.compare(BOOM_START) >= 0 && birthDate.compare(BOOM_END) < 0;
	}

}
```

改进后只会创建一个Calendar, 一个TimeZone和一个Date

另外关于基本类型和装箱基本类型之前的变换，如今有自动拆箱和自动拆箱，不过在需要的时候，使用基本类型总是效率好过装箱类型，要小心无意识的自动装箱行为。

### 消除过期的对象引用

该题主要针对内存泄漏现象的分析，对过期引用的分析处理主要在清空引用方法。在android方面的分析处理看着的话用处不大。

仍然是缓存和监听器回调泄漏这些方面。

### 避免使用终结（finalizer）方法

终结方法通常不可预测，一般不可使用。

jvm正确的执行对象的终结方法是顺利的回收。但是由于jvm不同，很有可能在不同的平台上不同的算法不同，导致产生的现象大相庭径。

终结方法是以队列的形式进行回收，但是由于终结方法的优先级很低，不确定哪些线程会执行终结方法。因此会造成在终结方法中执行方法的速度小于进入终结方法的速度，会导致大量的回收对象堆积，以此产生oom。


2018-05-08















