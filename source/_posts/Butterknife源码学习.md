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

当一个程序走到Butterknife.bind(this, rootview)的时候，此时正是编译时，annotation processing 会读取写出来的注解，生成新的代码，这时候就需要使用apt插件，apt插件会读取butterknife设置的一些注解