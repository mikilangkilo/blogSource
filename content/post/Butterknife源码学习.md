---
title: Butterknife源码学习
date: 2018-12-06 18:56:37
tags: android
---

项目中用的butterknife是8.8.1版本，引入了两个包，一个是Butterknife,一个是ButterKnife-Annotations。

# 基本原理

butterknife的基本原理其实很好理解，就是注入，通过代码中的注解，编译时进行解析，生成大量的代码，这些代码在运行时帮助提供对象

# 源码解析

```
  @NonNull @UiThread
  public static Unbinder bind(@NonNull Activity target) {
    View sourceView = target.getWindow().getDecorView();
    return createBinding(target, sourceView);
  }
```
这段代码是默认的绑定代码，其调用了
```
private static Unbinder createBinding(@NonNull Object target, @NonNull View source) {
    Class<?> targetClass = target.getClass();
    if (debug) Log.d(TAG, "Looking up binding for " + targetClass.getName());
    Constructor<? extends Unbinder> constructor = findBindingConstructorForClass(targetClass);

    if (constructor == null) {
      return Unbinder.EMPTY;
    }

    //noinspection TryWithIdenticalCatches Resolves to API 19+ only type.
    try {
      return constructor.newInstance(target, source);
    } catch (IllegalAccessException e) {
      throw new RuntimeException("Unable to invoke " + constructor, e);
    } catch (InstantiationException e) {
      throw new RuntimeException("Unable to invoke " + constructor, e);
    } catch (InvocationTargetException e) {
      Throwable cause = e.getCause();
      if (cause instanceof RuntimeException) {
        throw (RuntimeException) cause;
      }
      if (cause instanceof Error) {
        throw (Error) cause;
      }
      throw new RuntimeException("Unable to create binding instance.", cause);
    }
  }
```
这段话只是执行了findBindingConstructorForClass这个方法，返回了一个unbind

```
  @Nullable @CheckResult @UiThread
  private static Constructor<? extends Unbinder> findBindingConstructorForClass(Class<?> cls) {
    Constructor<? extends Unbinder> bindingCtor = BINDINGS.get(cls);
    if (bindingCtor != null) {
      if (debug) Log.d(TAG, "HIT: Cached in binding map.");
      return bindingCtor;
    }
    String clsName = cls.getName();
    if (clsName.startsWith("android.") || clsName.startsWith("java.")) {
      if (debug) Log.d(TAG, "MISS: Reached framework class. Abandoning search.");
      return null;
    }
    try {
      Class<?> bindingClass = cls.getClassLoader().loadClass(clsName + "_ViewBinding");
      //noinspection unchecked
      bindingCtor = (Constructor<? extends Unbinder>) bindingClass.getConstructor(cls, View.class);
      if (debug) Log.d(TAG, "HIT: Loaded binding class and constructor.");
    } catch (ClassNotFoundException e) {
      if (debug) Log.d(TAG, "Not found. Trying superclass " + cls.getSuperclass().getName());
      bindingCtor = findBindingConstructorForClass(cls.getSuperclass());
    } catch (NoSuchMethodException e) {
      throw new RuntimeException("Unable to find binding constructor for " + clsName, e);
    }
    BINDINGS.put(cls, bindingCtor);
    return bindingCtor;
  }

```
findBindingConstructorForClass这个方法通过一个map存储下来由cls作为key的Constructor。构建过程主要是通过classloader来创建一个带有_ViewBinding后缀的java文件，同时通过class的getConstructor方法，返回的是指定的，或者是cls的参数类型构造器，或者是View.class的参数类型构造器。然后在createBinding中会通过这个构造器来构造这个类。传入的参数就是我们在调用Butterknife.bind（）中传入的两个参数，当然也可能是一个。

# 总结一下

当一个程序走到Butterknife.bind(this, rootview)的时候，此时正是编译时，annotation processing 会读取写出来的注解，通过butterknife processor 生成一个对应于这个类名的viewbinder内部类，这个viewbinder类包含了所有的findviewbyid和onclicklistener等方法。然后在调用Bind方法的时候，butterknife会去加载对应的viewbinder类，并调用他们的bind方法。

# 疑惑

通过阅读butterknife的代码，发现一个问题，什么是butterknife processor，他是如何工作的，他在哪儿？

## annotation processor - 注解处理器

注解处理器(Annotation Processor)是javac内置的一个用于编译时扫描和处理注解(Annotation)的工具

由于注解处理器可以在程序编译阶段工作，所以我们可以在编译期间通过注解处理器进行我们需要的操作。比较常用的用法就是在编译期间获取相关注解数据，然后动态生成.java源文件

## 为什么butterknife processor 在项目中不存在

```
annotationProcessor 'com.jakewharton:butterknife-compiler:9.0.0-rc2'
```

这段话的意义是调用butterknife-compiler作为一个编译处理器。在编译的时候，会自动调用butterknife-compiler的代码，来协助进行编译。

由于调用的代码没有直接使用的意义，且没有提供开放的api，因此在studio中使用annotationprocessor，并不会看到相应的代码。

## butterknife processor 是在扫描完注解之后执行，还是在扫描注解之前执行

很明显，扫描完注解之后是生成viewbinder，这一步就已经用到了butterknife processor，而之后的bind，仅仅是调用了生成的代码类

# 通过annotation-processor来实现一个butterknife框架

自己实现原理也差不多，会加几层包装

[实现方式](https://blog.csdn.net/android_jianbo/article/details/79180907)



