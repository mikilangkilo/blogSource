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

- range

- repeat

- start

- timer

# transforming observables(转换observable)

# filtering observables(过滤observable)

# combing observables(组合observable)

# error handling operators(处理错误)
