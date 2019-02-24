---
title: tinker机制学习
date: 2019-01-28 13:06:52
tags: android
---

# tinker作用

tinker一般可以用作热修复，其作为热修复java方案的代表，日常工作也经常用到。

其原理是参考自instant run 的方案，通过生成patch包，不过是通过网络下发，然后在本地进行处理。

# instant run

基于提升平时打包的速度，instant run 需要

- 只对代码改变部分做构建和部署
- 不重新安装应用
- 不重启应用
- 不重启activity

从其官方图中可以看出，针对上面四个需求，生成了三种插拔机制。

![swap](/images/android/instantRunSwapImage.webp)

- 热插拔：代码改变被应用、投射到app上面，不需要重启应用，不需要重建activity
- 温插拔：activity需要被重启才能看到所需更改
- 冷插拔：app需要被重启（不需要重新安装）

## 原理

![原理](/images/android/instantRunApkMarker.webp)

从这个图可以看出来，APK的生成分为两个部分。
第一个部分是通过aapt生成res，第二部分是通过javaC生成dex文件

不涉及instantrun的话，编译也就上述几个步骤。打包的话会有签名和对齐动作。

打开instant run 开关，会有所变化

![打开instant run的编译效果](/images/android/instantRunOpenApkMarker.webp)

打开开关后，会新增一个appserver.class类编译进dex，同时会有一个新的application类。

新的application类注入了一个新的自定义类加载器，同时该application类会启动我们所需的新注入的
appserver，该application是原生application类的一个代理类。这样instantrun就跑起来了。

（该appserver主要是检测app是否在前台，以及是否是对应与android studio的appserver）

### 热插拔

热插拔主要体现在一个ui不变化，即时响应。

其步骤：
1. 首先通过gradle生成增量dex文件

```
Gradle Incremental Build
```

gradle会通过增量编译脚本，将dex文件最小化的进行更改
2. 更改完的dex文件会发送到appserver中，发送到appserver

3. appserver接收到dex后，会重写类文件。
appserver是保持活跃的，所以一旦有新的dex发来，就会立即执行处理任务。这里就体现了热插拔的效果。

instant run 热插拔的局限性：只能适用于简单改变，类似于方法上面的修改，或者变量值修改。

### 温插拔

温插拔体现在activity需要被重启才能看到修改

从上面的app构建图可以看出来，资源文件这种在activity创建时加载的内容，需要重启activity才能重新加载。

其步骤和热插拔几乎相同，唯一不同是修改了资源文件之后会走这步，发送的是资源文件的增量包，同时附带一个重启栈顶activity的指令

温插拔的局限性：只能适用于资源文件的更改，不包括manifest，架构，结构的变化。

### 冷插拔

基于art虚拟机的模式，工程会被拆分成10个部分，每个部分拥有自己的dex文件，然后所有的类会根据包名被分配给对应的dex文件。

结构更改产生的变化，此时带来dex的变化，这个变化不是增量变化，而是单纯的变化，这种变化需要重新替换dex文件

替换dex需要自定义类加载器选择性的加载新的dex，因此必须要重启app才能走到这一步。

冷插拔在art虚拟机上面是有效的，但是dalvik中则不行 api-21以上才有效。

## 注意点

instant run 只能在主进程运行，多进程模式下，所有的温插拔都会变为冷插拔。
不可以多台部署，只可以通过gradle生成增量包，jack编译器不行。

# tinker

## applicationlike

tinker 目前的版本已经支持反射模式修改application，不需要像以前那样傻乎乎的继承一个applicationlike。

而applicationlike是干嘛的？

从上面分析instantrun知道了，在开启instantrun之后，build的过程在dex生成过程中增加了application和appserver。
添加的自定义application主要是做了一个自定义类加载器的作用。

我们来看一下tinker中是如何做的。

```
public abstract class ApplicationLike implements ApplicationLifeCycle {
    private final Application application;
    private final Intent      tinkerResultIntent;
    private final long        applicationStartElapsedTime;
    private final long        applicationStartMillisTime;
    private final int         tinkerFlags;
    private final boolean     tinkerLoadVerifyFlag;

    public ApplicationLike(Application application, int tinkerFlags, boolean tinkerLoadVerifyFlag,
                           long applicationStartElapsedTime, long applicationStartMillisTime, Intent tinkerResultIntent) {
        this.application = application;
        this.tinkerFlags = tinkerFlags;
        this.tinkerLoadVerifyFlag = tinkerLoadVerifyFlag;
        this.applicationStartElapsedTime = applicationStartElapsedTime;
        this.applicationStartMillisTime = applicationStartMillisTime;
        this.tinkerResultIntent = tinkerResultIntent;
    }

    ...
}
```

```
public interface ApplicationLifeCycle {

    /**
     * Same as {@link Application#onCreate()}.
     */
    void onCreate();

    /**
     * Same as {@link Application#onLowMemory()}.
     */
    void onLowMemory();

    /**
     * Same as {@link Application#onTrimMemory(int level)}.
     * @param level
     */
    void onTrimMemory(int level);

    /**
     * Same as {@link Application#onTerminate()}.
     */
    void onTerminate();

    /**
     * Same as {@link Application#onConfigurationChanged(Configuration newconfig)}.
     */
    void onConfigurationChanged(Configuration newConfig);

    /**
     * Same as {@link Application#attachBaseContext(Context context)}.
     */
    void onBaseContextAttached(Context base);
}
```

从这里可以看出，这个applicationlike并不是一个application，而是一个代理类，application通过构造器构造的方式添加的。

其生命周期略过不表，毕竟我也没怎么在这里面改过东西。。

我从项目里面没找到tinkerapplication，从网上抄下来了。。

```
public abstract class TinkerApplication extends Application {
    ...

    private ApplicationLike applicationLike = null;
    /**
     * current build.
     */
    protected TinkerApplication(int tinkerFlags) {
        this(tinkerFlags, "com.tencent.tinker.loader.app.DefaultApplicationLike", TinkerLoader.class.getName(), false);
    }

    /**
     * @param delegateClassName The fully-qualified name of the {@link ApplicationLifeCycle} class
     *                          that will act as the delegate for application lifecycle callbacks.
     */
    protected TinkerApplication(int tinkerFlags, String delegateClassName,
                                String loaderClassName, boolean tinkerLoadVerifyFlag) {
        this.tinkerFlags = tinkerFlags;
        this.delegateClassName = delegateClassName;
        this.loaderClassName = loaderClassName;
        this.tinkerLoadVerifyFlag = tinkerLoadVerifyFlag;

    }

    protected TinkerApplication(int tinkerFlags, String delegateClassName) {
        this(tinkerFlags, delegateClassName, TinkerLoader.class.getName(), false);
    }

    private ApplicationLike createDelegate() {
        try {
            // 通过反射创建ApplicationLike对象
            Class<?> delegateClass = Class.forName(delegateClassName, false, getClassLoader());
            Constructor<?> constructor = delegateClass.getConstructor(Application.class, int.class, boolean.class,
                long.class, long.class, Intent.class);
            return (ApplicationLike) constructor.newInstance(this, tinkerFlags, tinkerLoadVerifyFlag,
                applicationStartElapsedTime, applicationStartMillisTime, tinkerResultIntent);
        } catch (Throwable e) {
            throw new TinkerRuntimeException("createDelegate failed", e);
        }
    }

    private synchronized void ensureDelegate() {
        if (applicationLike == null) {
            applicationLike = createDelegate();
        }
    }


    private void onBaseContextAttached(Context base) {
        applicationStartElapsedTime = SystemClock.elapsedRealtime();
        applicationStartMillisTime = System.currentTimeMillis();
        //先调用了tinker进行patch等操作
        loadTinker();
       //再创建ApplicationLike对象
        ensureDelegate();
       //最后再执行ApplicationLike的生命周期
        applicationLike.onBaseContextAttached(base);
        ...
    }

    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        Thread.setDefaultUncaughtExceptionHandler(new TinkerUncaughtHandler(this));
        onBaseContextAttached(base);
    }

    private void loadTinker() {
        //disable tinker, not need to install
        if (tinkerFlags == TINKER_DISABLE) {
            return;
        }
        tinkerResultIntent = new Intent();
        try {
            //反射调用TinkLoader的tryLoad方法
            Class<?> tinkerLoadClass = Class.forName(loaderClassName, false, getClassLoader());

            Method loadMethod = tinkerLoadClass.getMethod(TINKER_LOADER_METHOD, TinkerApplication.class, int.class, boolean.class);
            Constructor<?> constructor = tinkerLoadClass.getConstructor();
            tinkerResultIntent = (Intent) loadMethod.invoke(constructor.newInstance(), this, tinkerFlags, tinkerLoadVerifyFlag);
        } catch (Throwable e) {
            //has exception, put exception error code
            ShareIntentUtil.setIntentReturnCode(tinkerResultIntent, ShareConstants.ERROR_LOAD_PATCH_UNKNOWN_EXCEPTION);
            tinkerResultIntent.putExtra(INTENT_PATCH_EXCEPTION, e);
        }
    }

    @Override
    public void onCreate() {
        super.onCreate();
        ensureDelegate();
        applicationLike.onCreate();
    }

    @Override
    public void onTerminate() {
        super.onTerminate();
        if (applicationLike != null) {
            applicationLike.onTerminate();
        }
    }

    @Override
    public void onLowMemory() {
        super.onLowMemory();
        if (applicationLike != null) {
            applicationLike.onLowMemory();
        }
    }

    @TargetApi(14)
    @Override
    public void onTrimMemory(int level) {
        super.onTrimMemory(level);
        if (applicationLike != null) {
            applicationLike.onTrimMemory(level);
        }
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        if (applicationLike != null) {
            applicationLike.onConfigurationChanged(newConfig);
        }
    }

  ...
}
```
其中过程在onBaseContextAttached中做了比较全的概括，loadtinker之所以在applicationlike创立之前创建，就是为了能够修改application的内容

## hotfix

替换patch的方法在tinker类中

```
public class Tinker {
    ...
    final PatchListener listener;
    final LoadReporter  loadReporter;
    final PatchReporter patchReporter;
    ...
}
```

其成员变量就三个

```
if (loadReporter == null) {
                loadReporter = new DefaultLoadReporter(context);
            }

            if (patchReporter == null) {
                patchReporter = new DefaultPatchReporter(context);
            }

            if (listener == null) {
                listener = new DefaultPatchListener(context);
            }
```

### 准备补丁


