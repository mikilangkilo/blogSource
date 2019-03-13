---
title: java动态编程
date: 2018-01-29 22:21:09
tags: java
---

动态编程，常用到的是反射，但是反射开销性能大，上线的项目上面用反射不好。有另一种和反射功能相当的，但是比反射开销低的，就是javaassit

# 什么是javaassit

javaassit就是一个二方包，提供了运行时操作java字节码的方法。

# 使用javaassit

+ 更改某个类的父类

```
	ClassPool pool = ClassPool.getDefault();
	CtClass cc = pool.get("test.Rectangle");
	cc.setSuperclass(pool.get("test.Point"));
	cc.writeFile();
```

+ 获取字节码和加载字节码

```
	byte[] b = cc.toBytecode();
	Class clazz = cc.toClass();
```

+ 定义一个新类

```
	ClassPool pool = ClassPool.getDefault();
	CtClass cc = pool.makeClass("Point");
```

+ 通过CtMethod和CtField构造方法和成员甚至Annotation。

```
	ClassPool pool = ClassPool.getDefault();
	CtClass cc = pool.makeClass("foo");
	CtMethod mthd = CtNewMethod.make("public Integer getInteger() { return null; }", cc);
	cc.addMethod(mthd);
	CtField f = new CtField(CtClass.intType, "i", cc);
	point.addField(f);
	clazz = cc.toClass(); Object instance = class.newInstance();
```

+ Javassist不仅可以生成类、变量和方法，还可以操作现有的方法，这在AOP上非常有用，比如做方法调用的埋点

```
	// Point.java
	class Point {
    	int x, y;
    	void move(int dx, int dy) { x += dx; y += dy; }
	}

	// 对已有代码每次move执行时做埋点
	ClassPool pool = ClassPool.getDefault();
	CtClass cc = pool.get("Point");
	CtMethod m = cc.getDeclaredMethod("move");
	m.insertBefore("{ System.out.println($1); System.out.println($2); }");
	cc.writeFile();
```

其中$1和$2表示调用栈中的第一和第二个参数，写到磁盘后的class定义类似：

```
	class Point {
    	int x, y;
    	void move(int dx, int dy) {
        	{ System.out.println(dx); System.out.println(dy); }
        	x += dx; y += dy;
    	}
	}
```