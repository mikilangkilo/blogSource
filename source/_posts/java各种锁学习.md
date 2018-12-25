---
title: java各种锁学习
date: 2018-12-13 12:13:59
<<<<<<< HEAD
tags:
---
=======
tags: java
---
和同事吃饭的时候聊到了锁的问题，java中有很多很多种锁。锁在单线程，多线程，单核多核都具有不同的种类。本次主要针对各种锁进行一次学习。

# 公平锁/非公平锁

区分公平和非公平，是通过线程是否对资源有公平加锁权来看的，对于非公平锁来讲，不同的线程对锁拥有不同的优先权。

- 优缺点

公平锁处理问题按次序，因此吞吐量大，而非公平锁则因为线程优先级造成部分资源浪费，但是有优先级调度的锁应该是日常需要的。

- 实现方式

非公平锁和公平锁的队列都基于锁内部的维护的一个双向链表，表节点node的值就是每一个请求当前锁的线程，公平锁就是每次都是一次从队首取值。

通过reentrantLock方式来进行加锁处理，reentrantLock被称为重进入锁，其内部实现了两个Sync,一个是FairSync,一个是NonfairSync，默认情况下是非公平锁

```
//非公平锁的实现
 static final class NonfairSync extends Sync {
        private static final long serialVersionUID = 7316153563782823691L;

        /**
         * Performs lock.  Try immediate barge, backing up to normal
         * acquire on failure.
         */
        final void lock() {
            if (compareAndSetState(0, 1))
                setExclusiveOwnerThread(Thread.currentThread());
            else
                acquire(1);
        }

        protected final boolean tryAcquire(int acquires) {
            return nonfairTryAcquire(acquires);
        }
    }
```
- lock

lock的地方主要是判断是否曾经持有过，如果compareAndSetState(0, 1)返回的是true，代表CAS操作成功，该线程未持有过锁，此时会设置ExclusiveOwnerThread为当前线程，该对象表示持有锁的线程。否则就是CAS失败了，此时就会执行acquire再次请求锁

```
/**
     * Acquires in exclusive mode, ignoring interrupts.  Implemented
     * by invoking at least once {@link #tryAcquire},
     * returning on success.  Otherwise the thread is queued, possibly
     * repeatedly blocking and unblocking, invoking {@link
     * #tryAcquire} until success.  This method can be used
     * to implement method {@link Lock#lock}.
     *
     * @param arg the acquire argument.  This value is conveyed to
     *        {@link #tryAcquire} but is otherwise uninterpreted and
     *        can represent anything you like.
     */
    public final void acquire(int arg) {
        if (!tryAcquire(arg) &&
            acquireQueued(addWaiter(Node.EXCLUSIVE), arg))
            selfInterrupt();
    }
```

acquire的功能如同备注所说，请求独占的锁，并且忽略中断，执行至少一次tryacquire成功，否则线程就会排队，从阻塞和非阻塞之间切换，不停地调用tryacquire直到成功

- tryAcquire

```
 final boolean nonfairTryAcquire(int acquires) {
            final Thread current = Thread.currentThread();
            int c = getState();
            if (c == 0) {
                if (compareAndSetState(0, acquires)) {
                    setExclusiveOwnerThread(current);
                    return true;
                }
            }
            else if (current == getExclusiveOwnerThread()) {
                int nextc = c + acquires;
                if (nextc < 0) // overflow
                    throw new Error("Maximum lock count exceeded");
                setState(nextc);
                return true;
            }
            return false;
        }
```
c == 0的时候和之前的一样，当c不等于0的时候，如果当前线程拥有锁，会设置一下同步的状态，每次发现当前线程拥有锁，就会将unlock值加1，避免了轻量级锁每次必然CAS的操作，而只通过设置状态，这种也被称为偏向锁。好处是这样可以重复加锁而不会死锁。

```
公平锁的实现方式
/**
     * Sync object for fair locks
     */
    static final class FairSync extends Sync {
        private static final long serialVersionUID = -3000897897090466540L;

        final void lock() {
            acquire(1);
        }

        /**
         * Fair version of tryAcquire.  Don't grant access unless
         * recursive call or no waiters or is first.
         */
        protected final boolean tryAcquire(int acquires) {
            final Thread current = Thread.currentThread();
            int c = getState();
            if (c == 0) {
                if (!hasQueuedPredecessors() &&
                    compareAndSetState(0, acquires)) {
                    setExclusiveOwnerThread(current);
                    return true;
                }
            }
            else if (current == getExclusiveOwnerThread()) {
                int nextc = c + acquires;
                if (nextc < 0)
                    throw new Error("Maximum lock count exceeded");
                setState(nextc);
                return true;
            }
            return false;
        }
    }
```
公平锁在实现上，当资源状态为0的时候，会检查一下是否有等待队列，如果有的话，就不会进行抢占资源的操作。

## 公平锁非公平锁小结

从其构造上，公平锁是在引用的时候进行一次查询，而非公平锁则是随机抢占，不过通过reentrantlock实现的都是可重用锁，两个也都是偏向锁。

# 自旋锁

自旋锁也是资源锁的一种，为了避免处理器资源过多应用于处理中断恢复现场。如果自旋锁被别的单元保持，调用者就会一直循环看是否该自旋锁的保持者已经释放了锁。

- 优点

不会如同互斥锁一样使得处理器过多的消耗在处理中断和恢复现场中

- 缺点

递归自旋锁会导致死锁，很容易理解，因为不是偏向锁

过多占用cpu资源，


>>>>>>> b118970018c3a2c7fcdae0b7c13c257f3c14c202
