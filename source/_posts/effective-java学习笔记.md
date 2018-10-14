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

标签类很少有适用的时候，当编写一个包含显式标签域的类时，应当考虑是否应该不使用标签类，而是将标签放到同一个层次的结构中去。

### 用函数对象表示策略

java虽然没有高阶语言的函数式编程，也没有c语言类似的函数指针，但是可以使用对象引用来实现同样的功能。

如
```
class StringLengthComparator{
	public int compare(String s1, String s2){
		return s1.length() - s2.length();
	}
}
```
改为

```
class StringLengthComparator{
	private StringLengthComparator(){};
	public static final StringLengthComparator INSTANCE = new StringLengthComparator();
	public int compare(String s1, String s2){
		return s1.length() - s2.length();
	}
}
```

典型的具体策略类，是无状态的，没有域，所以所有的实例在功能上面都是等价的。

### 优先考虑静态成员类

嵌套类是指被定义在另一个类的内部的类。嵌套类存在的目的应该只是为他的外围类提供服务。

嵌套类分为四种：静态成员类，非静态成员类，匿名类和局部类，除了第一种之外，其他三种都被称为内部类。

非静态成员类的每个实例都隐含着与外围类的一个外围实例相关联，创建需要外围类的存在。没有外围实例，想创建非静态成员类是基本上不存在的。

一般非静态成员类都是使用常见的adapter来实现，他允许外部类的实例被看做是另一个不相关的类的实例。

因此，成员类不要求访问外部实例，希望外部实例以外的对象调用，就需要将static修饰符放在声明中。

#### 私有静态成员类

私有静态成员类的一中常见用法是用来代表外围类所代表的对象的组件。

例如一个map实例，它把键和值对应起来，许多map实现的内部都有一个entry对象，对应于map中的每个键值对。虽然每个entry都与一个map关联，但是entry上的方法并不需要访问该map，因此，使用非静态成员来标识entry是很浪费的，如果不用static修饰，那么每个entry中将会包含一个指向该map的引用。

#### 匿名类

匿名类没有名字，他不是外围类的成员，他并不与其他的成员一起被申明，匿名类除了被申明的时候之外，是无法实例化的，无法进行instanceof测试，或者任何需要命名类的其他事情。

```
abstract class Father(){
....
}
public class Test{
   Father f1 = new Father(){ .... }  //这里就是有个匿名内部类
}
```

#### 局部类

局部类用的很少，局部类只在本地范围内有效。

```
public class Test {
    {
        class AA{}//块内局部类
    }
    public Test(){
        class AA{}//构造器内局部类
    }
    public static void main(String[] args){
    }
    public void test(){
        class AA{}//方法内局部类
    }
}
```
局部类最多只能有final修饰，但不同的是，块内局部类有enclose class属性，而构造器局部类有enclose constructor属性，方法局部类有enclose method属性，嘛，其实很好理解的吧，一看就知道。

## 泛型

### 请不要在新代码中使用原生态类型

每种范型其实都是一组参数化的类型，他是一种原生态类型（rawtype），即不带任何实际类型参数的泛型名称。

在不确定或者不在乎集合中元素类型的情况下，可以参考以下方式

```
static int numElementsInCommon(Set s1, Set s2){
	int result = 0;
	for (Object o1 : s1){
		if(s2.contains(o1)){
			result ++;
		}
	}
	return result;
}
```

使用原生类型是可以在不关心参数类型的情况下替代泛型，缺很危险，不过泛型也提供了一种安全的替代方式。

```
Set<E>   --->   Set<?> //可以持有任何集合
```

对于泛型使用instanceof的首选方法：
```
if (o instanceof Set){
	Set<?> m = (Set<?>)o;
	//一旦确定这个o是个set，就必须将它装换位通配符类型Set<?>而不是原生的Set，这是个受检的转换。
}
```

### 消除非受检警告

类似非受检警告如下：
```
Set<Lark> exaltation = new HashSet();

[unchecked] unchecked conversion
```

需要改为如下：
```
Set<Lark> exaltation = new HashSet<Lark>();
```

 无法消除的时候，可以使用注解来压制这条警告。但是压制的时候代表仍然可能是有问题的，所以最好做一些备注或者catch


### 列表优先于数组

数组是covariant的，代表如果某个对象a是对象b的子类型，那么a[]也一定是b[]的子类型。

而数组就是invariant的，对于任意两个不同的类型ab，并不能说a的list是b的list的子类，也不能说b的list是a的list的父类。

事实上，本来就应该是如同list这样，数组这样反而是有缺陷的。

数组会在运行时才知道并检查他们的类型，而泛型则是通过擦除来实现的。正因如此，泛型可以与没有使用泛型的代码随意进行互用。

而泛型数组则是不建议创建的，每个不可具化的数组会得到一条警告，除了禁止并且避免在api中混合使用泛型和可变参数之外，别无他法。

创建泛型数组，可以使用
```
elements = (E[]) new Object[DEFAULT_INITIAL_CAPACITY];
```

### 优先使用泛型

使用泛型的步骤，可以先使用object，在不使用任何object内在方法以及实例方法的时候，可以完整实现一个类，即可替换使用泛型。

### 优先考虑泛型方法

核心步骤是使用泛型单例工厂方法，不单单可以通过泛型进行类型擦除，也适配了针对不同对象进行不同创建的问题

```
public interface Comparable<T>{
	int compareTo(T o);
}
```


```
public static <T extends Comparable<T>> T max(List<T> list){
	....
}
```

类似上述这种，就解决了不同类型的对象比较的问题，所需要的对象仅仅需要在编译过程中实现了comparable，即可参与到比较中来。而回避了类似string和int之间的比较类型。

### 利用有限的通配符来提升api的灵活性

在部分情况下面，使用<? extends E>的方式来进行处理参数类型，有效的避免了部分不兼容接口的数据问题。和上一章讲的类似。
```
public void pushAll(Iterable<? extends E> src){
	for (E e: src){
		push(e);
	}
}
```
另外提到了一个<? super E>的方式，同上面的不同，这种方式是指?是E的超类
对应的方法就是popAll
```
public void popAll(Collection<? super E> dst){
	while(!isEmpty()){
		dst.add(pop());
	}
}
```
需要记得步骤PECS： producer-extends, consumer-super

针对既可以消费，也可以生产的，可以使用下述方式
```
	static <E> E reduce(List<? extends E> list, Function<E> f, E initVal);
```
这样基本上可以确保，list的值可以被f消费，同时list又可以作为一个消费者返回正确的结果。

ps:

```
   static <E> E reduce(List<E> list, Function<? super E> f, E initVal);
```
应该也是可以的，相同的意义

### 优先考虑类型安全的异构容器

一般来讲，泛型用于实现一些容器，这些容器大部分包含了单个参数或者类似map的2个参数。如果想要实现更多参数，就需要使用到这章的内容。

实现一个简单的多参数泛型结构

```
public class Favorites{
	public <T> void putFavourite(Class<T> type, T instance);
	public <T> getFavourite(Class<T> type);
}
```
使用的方法如下：
```
public static void main(String[] args){
	Favourite f = new Favourites();
	f.putFavourite(String.class, "Java");
	f.putFavourite(Integer.class, 0x000fffff);
	f.putFavourite(Class.class, Favourite.class);
	String favouritString = f.getFavourite(String.class);
	int favouriteInteger = f.getFavourite(Integer.class);
	Class<?> favouritClass = f.getFavourite(Class.class);
	System.out.printf("%s %x %s %n", favouritString, favouriteInteger, favouritClass.getName());
}
```

其中涉及到了Favourites的实现

```
public class Favourites{
	private Map<Class<?>, Object> favourites = new HashMap<Class<?>, Object>();

	public <T> void putFavourite(Class<T> type, T instance){
		if(type == null){
			throw new NullPointerException("Type is null");
		}
		favourites.put(type, instance);
	}

	public <T> T getFavourite(Class<T> type){
		return type.cast(favourites.get(type));
	}
}
```

这种模式是单key的，所以一个类，只可以对应一个值，实现一个数据库的单列是可以的

其中注意到一点，type.cast()方法，是Class的方法，通过这个方法基本上可以活用泛型。这种type被称为类型，type token被称为类型令牌

```
@SuppressWarnings("unchecked")
public T cast(Object obj) {
    if (obj != null && !isInstance(obj))
        throw new ClassCastException(cannotCastMsg(obj));
    return (T) obj;
}
```
ps: Class类中自带了很多有用的方法，有空的时候可以看看

## 枚举和注解

枚举和注解都是jdk1.5发布的

### 用enum代替int常量

一般情况下使用int常量来做flag，会出现常量重复的现象，尤其是自己不注意的时候，可能两个命名不同的变量，却有相同的int值。在部分情况下会导致判断失误的现象

而采用枚举类型则可以完全避免这些问题

```
public enum Apple{ FUJI, PIPPIN, GRANNY_SMITH }

public enum Orange{ NAVEL, TEMPLE, BLOOD }
```

枚举的本质是通过公有的静态final域为每个枚举常量导出类型的类，由于没有可以访问的构造器，枚举类型是真正的final，并且是实例受控的，不可能进行拓展。他们是单例的泛型化，本质上是单元素的枚举

枚举还提供了多个同名常量的在多个枚举类型中可以有自己的命名空间，可以和平相处。

一个正常的有些复杂度的枚举类型：

```
public enum Planet{
	MERCURY(3.302e+23, 2.439e6),
	VENUS(4.869e+24, 6.052e6),
	EARTH(5.975e+24, 6.378e6);
	private final double mass;
	private final double radius;
	private final double surfaceGravity;
	private static final double G = 6.67300e-11;

	Planet(double mass, double radius){
		this.mass = mass;
		this.radius = radius;
		surfaceGravity = G * mass / (radius * radius);
	}

	public double mass(){
		return mass;
	}

	public double radius(){
		return radius;
	}

	public double surfaceGravity(){
		return surfaceGravity;
	}

	public double surfaceWeight(double mass){
		return mass * surfaceGravity;
	}
}
```
使用的方法如下：

```
public class WeightTable{
	public static void main(String[] args){
		double earthWeight = Double.parseDouble(args[0]);
		double nass = earthWeight/ Planet.EARTH.surfaceGravity();
		for  (Planet p : Planet.values()){
			System.out.printf("Weight on %s is %f%n",p, p.surfaceWeight(mass));
		}
	}
}
```

另外枚举类覆盖toString方法，亦可以直接在String中进行处理，这样在算术表达式中比较好处理

ps:尝试了一下，枚举类也可以有多态构造方法，内部类也是可以的，但是枚举实例只能放在头部。

### 用实例域代替序数

所有的枚举都有一个方法，叫做ordinal(),代表每个枚举常量在类型中的数字位置。

但是实现的时候不能滥用这个方法，我们假如构造一个枚举类，千万不要无参，而通过这个方法来获取位置。而最起码应该带有一个数字参数

### 用EnumSet代替位域

用位域的好处是可以比较好的使用flag，类似经常用到的比如说intent的flag，textview的flag。

位域有一系列的缺点，尤其是当打印出来的时候，这个我深受其害，在观察view的tree结构时，很多状态位看不懂，还需要翻代码对比才能看出来。

使用enumset代替的确有规避这方面的好处，自己写代码的时候可以注意一下，但是framework的代码其实很难更改这个了。

### 用EnumMap代替序数索引

之前讲过用ordinal方法来进行索引，但是若是出现多个数组的情况，单ordinal就不满足了，需要进行状态的保存。

enummap可以规避这个问题，但是看起来其实可用性不是很高。map的使用场景在android里面不如list。不过在构造容器的时候，使用enummap比较好

### 用接口模拟可伸缩的枚举

通过接口使得枚举拓展化，通过枚举来实现接口，这样使得枚举可以伸缩，虽然无法编写可拓展的枚举类型，但是这样却可以进行枚举的模拟

## 注解优先于命名模式

命名模式有几个缺点:
1 文字拼写错误会导致失败，比如说测试用例需要test开头，这样就会导致写错test就失败

2 无法确保他们只用于相应的元素上面

3 没有提供参数值与程序元素关联起来的好方法

通过注解可以完美的处理上述问题


























