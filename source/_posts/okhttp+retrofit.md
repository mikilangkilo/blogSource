---
title: okhttp+retrofit分析
date: 2019-01-02 22:45:01
tags: android
---

# retrofit的设计思路

retrofit自从接触的时候就知道是做了一层okhttp的封装，当时只知道retrofit做的，自己通过okhttp都可以做。但是细枝末节其实并未了解清楚。


## 使用retrofit的方式
```
webService = new Retrofit.Builder().baseUrl(config.getHost())
                .addConverterFactory(MyGsonConverterFactory.create(gson))
                .addCallAdapterFactory(RxJava2CallAdapterFactory.create())
                .client(builder.build())
                .build().create(WebService.class);
```
首先是使用如上的方式创建一个retrofit实例。其中baseUrl指明的是host，ConverterFactory是指明的json转换工具，一般是使用gson。callAdapterFactory是加上了Rxjava的封装。

client中的builder是一个oktthp的builder，设置了一个okhttp的client，其中设置了需要的okhttp的客户端的配置。

最后就是调用了build来build一个Retrofit的builder。同时通过create传入了webservice.class，这个类就是我们使用的retrofit web接口类，定义了我们项目中需要的网络接口。

## retrofit.builder().build()

```
 public Builder() {
      this(Platform.get());
    }
```

builder()是构造，其中只传入了一个platform，是选择平台

```
private static Platform findPlatform() {
    try {
      Class.forName("android.os.Build");
      if (Build.VERSION.SDK_INT != 0) {
        return new Android();
      }
    } catch (ClassNotFoundException ignored) {
    }
    try {
      Class.forName("java.util.Optional");
      return new Java8();
    } catch (ClassNotFoundException ignored) {
    }
    return new Platform();
  }
```
其功能就是选择是android平台还是java平台

```
public Retrofit build() {
      if (baseUrl == null) {
        throw new IllegalStateException("Base URL required.");
      }

      okhttp3.Call.Factory callFactory = this.callFactory;
      if (callFactory == null) {
        callFactory = new OkHttpClient();
      }

      Executor callbackExecutor = this.callbackExecutor;
      if (callbackExecutor == null) {
        callbackExecutor = platform.defaultCallbackExecutor();
      }

      // Make a defensive copy of the adapters and add the default Call adapter.
      List<CallAdapter.Factory> adapterFactories = new ArrayList<>(this.adapterFactories);
      adapterFactories.add(platform.defaultCallAdapterFactory(callbackExecutor));

      // Make a defensive copy of the converters.
      List<Converter.Factory> converterFactories = new ArrayList<>(this.converterFactories);

      return new Retrofit(callFactory, baseUrl, converterFactories, adapterFactories,
          callbackExecutor, validateEagerly);
    }
```
build的过程是将传入的参数进行赋值，如果没有传入okhttp的client会重新new一个。
其中的calldapter就是我们使用的rxjava2calladapter，convertfactories就是gsonconvertfactory。

```
public <T> T create(final Class<T> service) {
    Utils.validateServiceInterface(service);
    if (validateEagerly) {
      eagerlyValidateMethods(service);
    }
    return (T) Proxy.newProxyInstance(service.getClassLoader(), new Class<?>[] { service },
        new InvocationHandler() {
          private final Platform platform = Platform.get();

          @Override public Object invoke(Object proxy, Method method, @Nullable Object[] args)
              throws Throwable {
            // If the method is a method from Object then defer to normal invocation.
            if (method.getDeclaringClass() == Object.class) {
              return method.invoke(this, args);
            }
            if (platform.isDefaultMethod(method)) {
              return platform.invokeDefaultMethod(method, service, proxy, args);
            }
            ServiceMethod<Object, Object> serviceMethod =
                (ServiceMethod<Object, Object>) loadServiceMethod(method);
            OkHttpCall<Object> okHttpCall = new OkHttpCall<>(serviceMethod, args);
            return serviceMethod.callAdapter.adapt(okHttpCall);
          }
        });
  }
```
create的过程如上，需要逐条分析。

首先是
```
Utils.validateServiceInterface(service);
```
其功能就是分析该接口类是否有效，判断依据是否继承了额外的接口类，还有就是该类里面的接口方法数量是否大于0.

```
if (validateEagerly) {
      eagerlyValidateMethods(service);
    }
```
名字起的很奇特，功能就是预先加载传入的接口清单的接口。默认是不预先加载

## 动态代理全过程

首先是通过清单文件的classloader来进行hook这个清单文件，判断一下获取的class是否是object.class，就和一般的动态代理相同。

当确认hook的这个方法不是object.class的方法的时候，就会走一遍判断是否是该平台可用的method，不过这里默认都是返回false，貌似是准备后期扩展用。

万事具备之后，会走一次loadmethod，如果之前采取eagerlyValidateMethods的方式的话，此时是直接取出当时读出来的method，否则就是load一下。

```
ServiceMethod<?, ?> loadServiceMethod(Method method) {
    ServiceMethod<?, ?> result = serviceMethodCache.get(method);
    if (result != null) return result;

    synchronized (serviceMethodCache) {
      result = serviceMethodCache.get(method);
      if (result == null) {
        result = new ServiceMethod.Builder<>(this, method).build();
        serviceMethodCache.put(method, result);
      }
    }
    return result;
  }
```
load的方法很明显做了一个cache，此处**缓存下来了method和result**，划重点

在之后就是将获取的method和清单中的方法的参数传入okhttpcall中，创建一个okhttpcall，最后通过

```
serviceMethod.callAdapter.adapt(okHttpCall);
```
来返回一个和清单类型一模一样的类型。

至此，retrofit的代理过程就已经结束。

## calladapter

刚才传入的rxjava2calladapter有什么作用呢？

回到刚才划重点的地方，缓存下来了method和result，result怎么来的呢？

```
result = new ServiceMethod.Builder<>(this, method).build();
```

```
	Builder(Retrofit retrofit, Method method) {
      this.retrofit = retrofit;
      this.method = method;
      this.methodAnnotations = method.getAnnotations();
      this.parameterTypes = method.getGenericParameterTypes();
      this.parameterAnnotationsArray = method.getParameterAnnotations();
    }

    public ServiceMethod build() {
      callAdapter = createCallAdapter();
      responseType = callAdapter.responseType();
      if (responseType == Response.class || responseType == okhttp3.Response.class) {
        throw methodError("'"
            + Utils.getRawType(responseType).getName()
            + "' is not a valid response body type. Did you mean ResponseBody?");
      }
      responseConverter = createResponseConverter();

      for (Annotation annotation : methodAnnotations) {
        parseMethodAnnotation(annotation);
      }

      if (httpMethod == null) {
        throw methodError("HTTP method annotation is required (e.g., @GET, @POST, etc.).");
      }

      if (!hasBody) {
        if (isMultipart) {
          throw methodError(
              "Multipart can only be specified on HTTP methods with request body (e.g., @POST).");
        }
        if (isFormEncoded) {
          throw methodError("FormUrlEncoded can only be specified on HTTP methods with "
              + "request body (e.g., @POST).");
        }
      }

      int parameterCount = parameterAnnotationsArray.length;
      parameterHandlers = new ParameterHandler<?>[parameterCount];
      for (int p = 0; p < parameterCount; p++) {
        Type parameterType = parameterTypes[p];
        if (Utils.hasUnresolvableType(parameterType)) {
          throw parameterError(p, "Parameter type must not include a type variable or wildcard: %s",
              parameterType);
        }

        Annotation[] parameterAnnotations = parameterAnnotationsArray[p];
        if (parameterAnnotations == null) {
          throw parameterError(p, "No Retrofit annotation found.");
        }

        parameterHandlers[p] = parseParameter(p, parameterType, parameterAnnotations);
      }

      if (relativeUrl == null && !gotUrl) {
        throw methodError("Missing either @%s URL or @Url parameter.", httpMethod);
      }
      if (!isFormEncoded && !isMultipart && !hasBody && gotBody) {
        throw methodError("Non-body HTTP method cannot contain @Body.");
      }
      if (isFormEncoded && !gotField) {
        throw methodError("Form-encoded method must contain at least one @Field.");
      }
      if (isMultipart && !gotPart) {
        throw methodError("Multipart method must contain at least one @Part.");
      }

      return new ServiceMethod<>(this);
    }

```
可以看出来,builder()是将注释，方法，方法的形式参数类型和方法的形式参数注释类型给记录下来。

build()的操作需要仔细分析

第一步创建calladapter

```
private CallAdapter<T, R> createCallAdapter() {
      Type returnType = method.getGenericReturnType();
      if (Utils.hasUnresolvableType(returnType)) {
        throw methodError(
            "Method return type must not include a type variable or wildcard: %s", returnType);
      }
      if (returnType == void.class) {
        throw methodError("Service methods cannot return void.");
      }
      Annotation[] annotations = method.getAnnotations();
      try {
        //noinspection unchecked
        return (CallAdapter<T, R>) retrofit.callAdapter(returnType, annotations);
      } catch (RuntimeException e) { // Wide exception range because factories are user code.
        throw methodError(e, "Unable to create call adapter for %s", returnType);
      }
    }
```
创建的过程就是将参数传入，通过调用retrofit这个实例的calladapter方法

```
public CallAdapter<?, ?> callAdapter(Type returnType, Annotation[] annotations) {
    return nextCallAdapter(null, returnType, annotations);
  }
```

其中calladapter又调用了nextCallAdapter方法

```
public CallAdapter<?, ?> nextCallAdapter(@Nullable CallAdapter.Factory skipPast, Type returnType,
      Annotation[] annotations) {
    checkNotNull(returnType, "returnType == null");
    checkNotNull(annotations, "annotations == null");

    int start = adapterFactories.indexOf(skipPast) + 1;
    for (int i = start, count = adapterFactories.size(); i < count; i++) {
      CallAdapter<?, ?> adapter = adapterFactories.get(i).get(returnType, annotations, this);
      if (adapter != null) {
        return adapter;
      }
    }

    StringBuilder builder = new StringBuilder("Could not locate call adapter for ")
        .append(returnType)
        .append(".\n");
    if (skipPast != null) {
      builder.append("  Skipped:");
      for (int i = 0; i < start; i++) {
        builder.append("\n   * ").append(adapterFactories.get(i).getClass().getName());
      }
      builder.append('\n');
    }
    builder.append("  Tried:");
    for (int i = start, count = adapterFactories.size(); i < count; i++) {
      builder.append("\n   * ").append(adapterFactories.get(i).getClass().getName());
    }
    throw new IllegalArgumentException(builder.toString());
  }
```
到这里就可以发现，通过adapterFactories将我们之前放入的rxjava2adapter给取出来了

第二步，取出了rxjava2adapter的responseType()，这个type可以从rxjava2adapter里面查到，这里不追溯。

第三步，创建了responseConverter,就是通过我们传入的gsonconverter来构建解析器

第四步，逐个读取该方法的注释。

第五步，进行一系列的检查，检查request的参数是否正确

最后一步

```
return new ServiceMethod<>(this);
```

可以看出，这个result，其实就是通过将接口的方法进行整合，最后生成的一个结果。这个结果和方法共同被存储下来

**切记，这里并没有缓存response，缓存的是result，result是对method的一个处理结果，调用的其实是rxjava2factory和gsonconvertfactory来配合处理的**






















