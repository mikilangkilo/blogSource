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


## 对于所有对象都通用的方法

这一章是针对Object类

### 覆盖equals是遵守通用约定

#### 针对以下四点，不应该覆盖equals方法，同时不能让其他人调用使用

1. 类的每个实例本质上都是唯一的：对于代表活动实体而不是值的类来说，object提供的equals是正确的。

2. 不关心类是否提供了“逻辑相等”的测试功能：

3. 超类已经覆盖了equals，从超类继承过来的行为对于子类也是合适的

4. 类是私有的或是包级私有的，可以确定它的equals方法永远不会被调用：此时需要覆盖以防被意外调用。

```
@Override
public boolean equals(Object o ){
	throw new AssertionError();
}
```

#### 如果需要覆盖时，需要遵守以下的规范，来自JavaSE6

1. 自反性：对于任何非null的引用值x，x.equals(x)必须返回true

2. 对称性：对于任何非null的引用值x,y,z，如果x.equals(y) == true, 那么y.equals(x) == true也必须成立

3. 传递性：对于任何非null的引用值x,y,z，如果x.equals(y) == true, y.equals(z) == true,那么x.equals(z) == true也必须成立

4. 一致性：对于任何非null的引用值x，y，只要equals的比较操作在对象中所用的信息没有被修改，那么无论调用多少次equals，返回结果必须是一样的

5. 非空性：对于任何非null的引用值x，x.equals(null)必须返回false

#### 根据以上两个原则以及引申出来的原则，总结实现equals的窍门

1. 使用 == 操作符检查“参数是否为这个对象的引用”

2. 使用 instanceof 操作符检查“参数是否为正确的类型”

3. 把参数转换成正确的类型

4. 对于该类中的每个“关键”域，检查参数中的域是否与该对象中对应的域相匹配（不能只针对某些关键条件来判断，而不是全部关键条件）

5. 当编写完equals方法之后，应该检查对称性、传递性、一致性。

### 覆盖equals时总要覆盖hashcode

由于HashMap,HashSet和HashTable这些散列集合。

散列集合的关键域，就有hashcode，若不覆盖的话，就会产生问题。例如由于hashcode不同，导致两个equals为true的对象，放到了不同的散列桶中，因此导致get出来的值是不同的，违反了上面的规则。

#### 覆盖hashcode的方法

1. 将某个非零的常数值，保存在名为result的int类型的变量中。

2. 对于对象中每个关键域f，完成以下步骤：

	a. 为该域计算int类型的散列码c：
		i. f类型是boolean，则计算f?1:0
		ii. 如果该域是byte，char，short或者int类型，则计算(int)f
		iii. 如果该域是long类型，则计算(int)(f^(f>>32))
		iv. 如果该域是float类型，则计算Float.floatToIntBits(f)
		v. 如果该域是double类型，则计算Double.doubleToLongBits(f),然后跳到iii
		vi. 如果是对象引用，可以设计一个范式，针对这个范式来计算hashcode
		vii. 如果该域是一个数组，需要针对每一个元素计算一下，然后依据b来计算
	b. 按照 result = result * 31 + c

### 始终覆盖toString

使用tostring来进行关键的提示

### 谨慎的覆盖clone

克隆部分主要是针对object的clone来进行浅克隆的缺点分析，和深克隆的优点介绍。

提供了一种不断调用构造器来进行clone的深克隆方法。事实上目前深克隆有了更好的stream方法，所以略过不讲。

之前说过的newinstance方法，其实就是浅克隆

### 考虑实现comparable接口

类实现了comparable接口，可以与许多泛型算法，以及依赖于该接口的集合实现进行协作。不过也同样要遵从自反性，对称性和传递性。

由于类可能有很多个关键域，因此需要由最关键的域开始进行比较，直到所有的域都比较结束，才能算一个comparable接口实现结束

## 类和接口

### 使类和成员的可访问性最小化

出于“封装”的特性，需要将类的方法进行访问性变更，仅仅暴露出一些需要暴露的方法进行模块间的沟通。

有几个规定

实例域不可公有，对于非final的实例域不可公有主要是针对线程安全。另外对于静态final域的对象来讲，需要确保其引用对象不是可变对象，否则也不可公有

长度非0的数组，无论如何声明，也是可变的，因此对于数组的静态域返回，需要使用如下方法。

```
private final static Thing[] PRIVATE_VALUES = {...};
public static final Thing[] values(){
	return PRIVATE_VALUES.clone();
}
```

### 在公有域方法中使用访问方法，而不是公有域

这就是使用get set等方法，而不是直接暴露出参数，来使用公有域。由于使用这种方法，可以确保通过自设的一些限制，确保返回的参数和自己需要的参数条件相当。

### 使可变性最小化

该例主要是针对不可变类的处理。不可变类是第一次构造时就赋予内部参数的类，类似String类。

使类变成不可变类，需要遵循五条规则：

1. 不要提供任何会修改对象状态的方法

2. 保证类不会被扩展：防止子类化，一般可以将这个类做成final的

3. 使所有的域都是final的：使用系统的强制方式，可以清楚的表明意图

4. 使所有的域都成为私有的：防止客户端获得访问可变对象的权限，并防止客户端直接修改这些对象。

5. 确保对于任何可变组件的互斥访问：如果类具有指向可变对象的域，必须确保该类的客户端无法获得指向这些对象的引用。因此如果需要修改对象，提供set方法。


不可变对象比较简单，只有一种状态，即被创建时的状态，本质上是线程安全的，它们不要求同步。并发访问时不会破坏属性，因此可以被自由的共享，同时也不需要进行保护性拷贝。

不仅可以共享不可变对象，甚至也可以共享它们的内部信息。

不可变对象的唯一的缺点是，对于每个不同的值都要一个单独的对象。由于创建对象的代价可能很大，对于大型的对象，这样操作实在是损耗太大。

```
public class Complex{
	private final double re;
	private final double im;

	private Complex(double re, double im){
		this.re = re;
		this.im = im;
	}

	public static Complex valueOf(double re, double im){
		return new Complex(re, im);
	}
}
```

### 复合优先于继承

继承打破了封装性，当版本的升级导致父类的变化，会造成子类的破坏。因此需要进行复合。

复合的意义是：不拓展现有的类，而是在新的类中增加一个私有域，它引用现有类的一个实例，这种设计被称作复合。

现有的类变成了新类的一个组件，新类的每个实例方法都可以调用被包含的现有实例中对应的方法，并返回他的结果，这种方式称为转发。新的类被称为包装类。

缺点：包装类不适合用于回调框架

### 要么为继承而设计，并提供文档说明，要么就禁止继承

不是为了继承而设计，并且没有文档说明，会导致子类的继承出现破坏性的问题。

文档必须要精确的描述覆盖每个方法所带来的影响。


### 接口优于抽象类

1. 现有的类可以很容易被更新，以实现新的接口

2. 接口是定义mixin(混合类型)的理想选择

3. 接口允许构造非层次接口的类型框架

鉴于上上条“复合优先于继承”，如果使用接口的方式实现，包装类仍然完美使用

### 接口只用于定义类型

接口仅仅用于定义引用这个实例的类型，因此除此之外的接口都是不恰当的。

### 类层次由于标签类

标签类很少有适用的时候，当编写一个包含显式标签域的类时，英国考虑	



















