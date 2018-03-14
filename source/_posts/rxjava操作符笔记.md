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

- Debounce

过滤掉了由Observable发射的速率过快的数据；如果在一个指定的时间间隔过去了仍旧没有发射一个，那么它将发射最后的那个。通常我们用来结合RxBinding(Jake Wharton大神使用RxJava封装的Android UI组件)使用，防止button重复点击。

- Distinct

distinct()的过滤规则是只允许还没有发射过的数据通过，所有重复的数据项都只会发射一次。 

- ElementAt

获取原始序列第n个元素，并作为唯一发射源进行发射

- Filter

用来过滤观察序列中我们不想要的值，只返回满足条件的值

```
Observable.from(communities)
        .filter(new Func1<Community, Boolean>() {
            @Override
            public Boolean call(Community community) {
                return community.houses.size()>10;
            }
        }).subscribe(new Action1<Community>() {
    @Override
    public void call(Community community) {
        System.out.println(community.name);
    }
});
```

- First

它是的Observable只发送观测序列中的第一个数据项。

- last

last()只发射观测序列中的最后一个数据项。 

- skip

忽略掉原始序列前n个元素

- skiplast

忽略掉原始序列最后n个元素

- take

发送原始序列中的前n个元素
```
Observable.from(communities)
        .take(10)
        .subscribe(new Action1<Community>() {
            @Override
            public void call(Community community) {
                System.out.println(community.name);
            }
        });
```

- takelast

发送原始序列中的最后n个元素

# combing observables(组合observable

- zip

zip(Observable, Observable, Func2)用来合并两个Observable发射的数据项，根据Func2函数生成一个新的值并发射出去。当其中一个Observable发送数据结束或者出现异常后，另一个Observable也将停在发射数据。

- merge

merge(Observable, Observable)将两个Observable发射的事件序列组合并成一个事件序列，就像是一个Observable发射的一样。你可以简单的将它理解为两个Obsrvable合并成了一个Observable，合并后的数据是无序的。

- startwith

startWith(T)用于在源Observable发射的数据前插入数据。使用startWith(Iterable<T>)我们还可以在源Observable发射的数据前插入Iterable。

- combinelatest

combineLatest(Observable, Observable, Func2)用于将两个Observale最近发射的数据已经Func2函数的规则进展组合

- join

join(Observable, Func1, Func1, Func2)我们先介绍下join操作符的4个参数：
Observable：源Observable需要组合的Observable,这里我们姑且称之为目标Observable；
Func1：接收从源Observable发射来的数据，并返回一个Observable，这个Observable的声明周期决定了源Obsrvable发射出来的数据的有效期；
Func1：接收目标Observable发射来的数据，并返回一个Observable，这个Observable的声明周期决定了目标Obsrvable发射出来的数据的有效期；
Func2：接收从源Observable和目标Observable发射出来的数据，并将这两个数据组合后返回。所以Join操作符的语法结构大致是这样的：onservableA.join(observableB, 控制observableA发射数据有效期的函数， 控制observableB发射数据有效期的函数，两个observable发射数据的合并规则)join操作符的效果类似于排列组合，把第一个数据源A作为基座窗口，他根据自己的节奏不断发射数据元素，第二个数据源B，每发射一个数据，我们都把它和第一个数据源A中已经发射的数据进行一对一匹配；举例来说，如果某一时刻B发射了一个数据“B”,此时A已经发射了0，1，2，3共四个数据，那么我们的合并操作就会把“B”依次与0,1,2,3配对，得到四组数据： [0, B][1, B] [2, B] [3, B]

- switchonnext

switchOnNext(Observable<? extends Observable<? extends T>>用来将一个发射多个小Observable的源Observable转化为一个Observable，然后发射这多个小Observable所发射的数据。如果一个小的Observable正在发射数据的时候，源Observable又发射出一个新的小Observable，则前一个Observable发射的数据会被抛弃，直接发射新 的小Observable所发射的数据。

# error handling operators(处理错误)

- catch

- retry

# 补充

- takeUtil

observable.takeUtil(condition),当condition == true时终止，且包含临界条件的item

- takeWhile

observable.takeWhile(condition),当condition == false时终止，不包含临界条件的item