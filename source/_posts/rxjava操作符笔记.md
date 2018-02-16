---
title: rxjava操作符笔记
date: 2018-02-15 19:43:10
tags: android
---

对rxjava的操作符进行一些笔记。

# creating observables(创建observable)

- create

最基本的创建操作

```
OObservable.create(new ObservableOnSubscribe<String>() {
            @Override
            public void subscribe(ObservableEmitter<String> emitter) throws Exception {
                //上游操作发射
            }
        }).subscribe(new Subject<String>() {
            @Override
            public boolean hasObservers() {
                return false;
            }

            @Override
            public boolean hasThrowable() {
                return false;
            }

            @Override
            public boolean hasComplete() {
                return false;
            }

            @Override
            public Throwable getThrowable() {
                return null;
            }

            @Override
            protected void subscribeActual(Observer<? super String> observer) {

            }

            @Override
            public void onSubscribe(Disposable d) {

            }

            @Override
            public void onNext(String s) {

            }

            @Override
            public void onError(Throwable e) {

            }

            @Override
            public void onComplete() {

            }
        });
```

- just

just就是对create的简写

```
Observable.just('1','2').subscribe(new Consumer<Character>() {
            @Override
            public void accept(Character character) throws Exception {
                
            }
        });
```

- from

from可以接受一个创建了的列表作为输入,可以接受不少的类型，列表，迭代器,future,publisher等等

```
List<String> source = new ArrayList();
        source.add("1");
        source.add("2");
        Observable.fromArray(source).subscribe(new Consumer<List<String>>() {
            @Override
            public void accept(List<String> strings) throws Exception {
                
            }
        });
```

- defer

defer是当观察者订阅被观察者的时候，才会开始创建一个observable，其余操作和from，just差不多。

- empty/never/throw

empty是生成一个空的观察对象，never是生成一个不会向下游发送执行命令的对象，throw会生成一个不会向下游发送执行命令，但是会以一个error终止的对象。

- interval

interval是起到了定时器功能，根据给定的时间间隔上游来发送数据。

```
Observable.interval(10, TimeUnit.SECONDS).just("1","2").subscribe(new Consumer<String>() {
            @Override
            public void accept(String s) throws Exception {
                
            }
        });
```

- range

创建在一个范围之类的数据类型，上游依次发送这个范围内的数据。

- repeat

多次重复的发送一个数据。

- start

创建发射一个函数的返回值的observable

- timer

创建在一个指定的延时之后发射单个数据的observable

# transforming observables(转换observable)

- map

将一个对象转换为另一个对象。

```
	Observable.just(1,2,3).map(new Function<Integer, String>() {
            @Override
            public String apply(Integer integer) throws Exception {
                return integer.toString();
            }
        }).subscribe(new Consumer<String>() {
            @Override
            public void accept(String s) throws Exception {
                
            }
        });
    //简单的例子，将发射为int的字节转换成为string类型的observable
```

- flatmap

flatmap是一个一对多的转换对象。

```
	Observable.just(1,2,3,4).flatMap(new Function<Integer, ObservableSource<? extends String>>() {
            @Override
            public ObservableSource<? extends String> apply(Integer integer) throws Exception {
                return Observable.just(integer+"");
            }
        }).subscribe(new Consumer<String>() {
            @Override
            public void accept(String s) throws Exception {

            }
        });
```

- groupby

group是一个分组行为，根据指定的规则将上游进行分组归类，然后发送至下游时会夹带分组信息

- buffer

缓存，定期的从observable收集数据到一个集合，然后打包发送，而不是一次发送一个

- scan

扫描，对observable发射的每一项数据应用一个函数，然后按照顺序发射这些值

- window

定期将来自observable的数据拆分成一个个的observable窗口，然后发射这些窗口，而不是每次发射一项，类似于buffer， 不过window发射的是observable

# filtering observables(过滤observable)

# combing observables(组合observable)

# error handling operators(处理错误)
