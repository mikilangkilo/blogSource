---
title: Collection
date: 2018-02-28 23:14:41
tags: 数据结构
---

面试的时候问到了Collection和Collections的差别。当时有个浅薄的印象是Collection好像是个接口类，而Collections是个实体类。
回来翻书发现自己真是无知，回答的驴头不对马嘴。

# Collection

java.util.Collection是一个集合接口（集合类的一个顶级接口）。它提供了对集合对象进行基本操作的通用接口方法。Collection接口在java库中有很多基本的实现。

Collection接口最大的意义是为了各种具体的集合提供最大化的统一操作方式，其直接继承接口有List和set等等。

![Collection子类](/images/数据结构/Java集合框架.jpg)


## Collection源码解析

```
/*
*首先，继承了Iterable类，同时指定了范型
*/
public interface Collection<E> extends Iterable<E> {
	/*
	*返回集合中数组的元素数量
	*/
	int size();

	/*
	*集合中没有元素就返回true
	*/
	boolean isEmpty();

	/*
	*集合中有这个元素就返回true
	*/
	boolean contains(Object o);

	/*
	*返回集合元素的迭代器
	*/
	Iterator<E> iterator();

	/*
	*返回一个包含集合中所有元素的数组，数组类型是object
	*这个方法是数组和集合中的桥梁
	*/
	Object[] toArray();

	/*
	*上个api的多态方法，将集合转为一个指定的数组，类型必须是运行中指定的类型
	*倘若集合的元素数量小于数组，那么数组没有元素的空间会被设为null
	*假如集合需要保证元素的顺序，则转换为数组时也需要保证相应的顺序
	*例：String[] y = x.toArray(new String[0]);
	*toArray(new Object[0])就等于toArray()
	*/
	<T> T[] toArray(T[] a);

	<-- 以下是修改操作 -->

	/*
	*首先要确保集合中没有该需要添加的元素
	*返回true，当集合对这次请求进行了自己的改变
	*返回false，当集合没有允许重复添加已有的元素
	*假如一个集合拒绝添加一个元素，需要抛出异常而不是返回false
	*/
	boolean add(E e);

	/*
	*从集合中移除一个存在的单一对象
	*集合中如果拥有一个或多个该元素，将会移除一个或者其中的一个元素
	*对该请求进行操作之后，的确拥有该元素（或者说有个元素和它equal），会移除该元素并且返回true
	*/
	boolean remove(Object o);

	<-- 以下是批量操作 -->

	/*
	*假如集合中包含该指定集合的所有的元素，就返回true
	*/
	boolean containsAll(Collection<?> c);

	/*
	*将指定集合中的所有元素添加到集合中
	*该操作在操作进行中时是不明确的。因此表明了该操作在添加的集合就是自身时，其实是不明确的。
	*/
	boolean addAll(Collection<? extends E> c);

	/*
	*移除指定集合和原有集合中同时拥有的元素，操作结束之后原有集合和指定集合将在无相同的元素
	*/
	boolean removeAll(Collection<?> c);

	/*
	*只保存和指定集合共同拥有的元素，即是移除所有指定集合中不包含的元素。
	*/
	boolean retainAll(Collection<?> c);

	/*
	*移除集合中所有的元素，集合在操作之后将为空
	*/
	void clear();

	<-- 以下是比较和哈希 -->

	/*
	*将制定的对象与集合进行平等性的比较
	*
	*当集合的接口没有添加类似equal的操作，程序员需要小心的复写Object.equal的操作。
	*最简单的是直接依赖Object的接口
	*/
	boolean equals(Object o);

	/*
	*返回集合的hash码，当集合的接口没有添hashcode的操作的时候，程序员需要注意任何类一旦复写了equal，也将复写hashcode，这是为了保证基础的对比。
	*
	*/
	int hashCode();
}
```

# Collections

java.util.Collections则是一个包装类（工具类/帮助类），包含各种有关集合操作的静态多态方法。不能被实例化，就像一个工具类，用于对集合中元素进行排序、搜索和线程安全等各种操作。

