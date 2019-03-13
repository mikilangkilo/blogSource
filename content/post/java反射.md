---
title: java反射
date: 2018-01-28 19:44:53
tags: java
---

# 什么是反射

反射是一种在程序运行时动态访问，修改某个类中任意属性(状态)和方法(行为)的机制

+ 在运行时判断任意一个对象所属的类

+ 在运行时构造任意一个类的对象

+ 在运行时判断任意一个类所具有的成员变量和方法

+ 在运行时调用任意一个对象的方法

设计到的四个核心类

+ java.lang.Class.java:类对象

+ java.lang.reflect.Constructor.java:类的构造器对象

+ java.lang.reflect.Method.java:类的方法对象

+ java.lang.reflect.Field.java:类的属性对象

# 反射有什么用？

+ 操作因访问权限限制的属性和方法

+ 实现自定义注解

+ 动态加载第三方jar包，解决android中方法数不能超过65536个的问题

+ 按需加载类，节省编译和初始化apk的时间

# 反射工作原理

当编完一个java项目之后，每个java文件都会被编译成一个.class文件，这些class对象继承了这个类的所有信息，包括父类、接口、构造函数、方法、属性等，这些class文件在程序运行时会被classloader加载到虚拟机中。当一类被加载以后，java虚拟机就会在内存中自动产生一个class对象。

反射的原理就是借助class.java， constructor.java, method.java, field.java四个类在程序运行时动态访问和修改任何类的行为和状态。

# 实例

+ 获取父类

```
	private void getSuperClass(){
        ProgramMonkey programMonkey = new ProgramMonkey("小明", "男", 12);
        Class<?> superClass = programMonkey.getClass().getSuperclass();
        while (superClass != null) {
            LogE("programMonkey's super class is : " + superClass.getName());
            // 再获取父类的上一层父类，直到最后的 Object 类，Object 的父类为 null
            superClass = superClass.getSuperclass();
        }
    }
```

+ 获取接口

```
	private void getInterfaces() {
        ProgramMonkey programMonkey = new ProgramMonkey("小明", "男", 12);
        Class<?>[] interfaceses = programMonkey.getClass().getInterfaces();
        for (Class<?> class1 : interfaceses) {
            LogE("programMonkey's interface is : " + class1.getName());
        }
    }
```

+ 获取当前类的所有的方法

```
	private void getCurrentClassMethods() {
        ProgramMonkey programMonkey = new ProgramMonkey("小明", "男", 12);
        Method[] methods = programMonkey.getClass().getDeclaredMethods();
        for (Method method : methods) {
            LogE("declared method name : " + method.getName());
        }

        try {
            Method getSalaryPerMonthMethod = programMonkey.getClass().getDeclaredMethod("getSalaryPerMonth");
            getSalaryPerMonthMethod.setAccessible(true);
            // 获取返回类型
            Class<?> returnType = getSalaryPerMonthMethod.getReturnType();
            LogE("getSalaryPerMonth 方法的返回类型 : " + returnType.getName());

            // 获取方法的参数类型列表
            Class<?>[] paramClasses = getSalaryPerMonthMethod.getParameterTypes() ;
            for (Class<?> class1 : paramClasses) {
                LogE("getSalaryPerMonth 方法的参数类型 : " + class1.getName());
            }

            // 是否是 private 函数，属性是否是 private 也可以使用这种方式判断
            LogE(getSalaryPerMonthMethod.getName() + " is private " + Modifier.isPrivate(getSalaryPerMonthMethod.getModifiers()));

            // 执行方法
            Object result = getSalaryPerMonthMethod.invoke(programMonkey);
            LogE("getSalaryPerMonth 方法的返回结果: " + result);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
```

+ 获取当前类和父类的所有公有方法

```
	private void getAllMethods() {
        ProgramMonkey programMonkey = new ProgramMonkey("小明", "男", 12);
        // 获取当前类和父类的所有公有方法
        Method[] methods = programMonkey.getClass().getMethods();
        for (Method method : methods) {
            LogE("method name : " + method.getName());
        }

        try {
            Method setmLanguageMethod = programMonkey.getClass().getMethod("setmLanguage", String.class);
            setmLanguageMethod.setAccessible(true);

            // 获取返回类型
            Class<?> returnType = setmLanguageMethod.getReturnType();
            LogE("setmLanguage 方法的返回类型 : " + returnType.getName());

            // 获取方法的参数类型列表
                        Class<?>[] paramClasses = setmLanguageMethod.getParameterTypes() ;
            for (Class<?> class1 : paramClasses) {
                LogE("setmLanguage 方法的参数类型 : " + class1.getName());
            }

            // 是否是 private 函数，属性是否是 private 也可以使用这种方式判断
            LogE(setmLanguageMethod.getName() + " is private " + Modifier.isPrivate(setmLanguageMethod.getModifiers()));

            // 执行方法
            Object result = setmLanguageMethod.invoke(programMonkey, "Java");
            LogE("setmLanguage 方法的返回结果: " + result);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
```

+ 获取当前类的所有实例

```
	private void getCurrentClassFields() {
        ProgramMonkey programMonkey = new ProgramMonkey("小明", "男", 12);
        // 获取当前类的所有属性
        Field[] publicFields = programMonkey.getClass().getDeclaredFields();
        for (Field field : publicFields) {
            LogE("declared field name : " + field.getName());
        }

        try {
            // 获取当前类的某个属性
            Field ageField = programMonkey.getClass().getDeclaredField("mAge");
            // 获取属性值
            LogE(" my age is : " + ageField.getInt(programMonkey));
            // 设置属性值
            ageField.set(programMonkey, 10);
            LogE(" my age is : " + ageField.getInt(programMonkey));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
```

+ 获取当前类和父类的所有公有属性

```
	private void getAllFields() {
        ProgramMonkey programMonkey = new ProgramMonkey("小明", "男", 12);
        // 得到当前类和父类的所有公有属性
        Field[] publicFields = programMonkey.getClass().getFields();
        for (Field field : publicFields) {
            LogE("field name : " + field.getName());
        }

        try {
            // 获取当前类和父类的某个公有属性
            Field ageField = programMonkey.getClass().getField("mAge");
            LogE(" age is : " + ageField.getInt(programMonkey));
            ageField.set(programMonkey, 8);
            LogE(" my age is : " + ageField.getInt(programMonkey));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
```