---
title: looper的message分发方式
date: 2019-01-16 18:47:19
tags: android
---

前一阵遇到一个问题，就是looper在循环调用messageQueue中的message的时候，如何判断message的来源，并分发到对应的handler对象中的？

当时认为是message中附带了对应的来源，或者说在发送message时使用了类似eventbus的方式进行了注册。

直到今天看了源码...

# loop()

```
for (;;) {
            Message msg = queue.next(); // might block
            if (msg == null) {
                // No message indicates that the message queue is quitting.
                return;
            }

            // This must be in a local variable, in case a UI event sets the logger
            final Printer logging = me.mLogging;
            if (logging != null) {
                logging.println(">>>>> Dispatching to " + msg.target + " " +
                        msg.callback + ": " + msg.what);
            }

            final long slowDispatchThresholdMs = me.mSlowDispatchThresholdMs;

            final long traceTag = me.mTraceTag;
            if (traceTag != 0 && Trace.isTagEnabled(traceTag)) {
                Trace.traceBegin(traceTag, msg.target.getTraceName(msg));
            }
            final long start = (slowDispatchThresholdMs == 0) ? 0 : SystemClock.uptimeMillis();
            final long end;
            try {
                msg.target.dispatchMessage(msg);
                end = (slowDispatchThresholdMs == 0) ? 0 : SystemClock.uptimeMillis();
            } finally {
                if (traceTag != 0) {
                    Trace.traceEnd(traceTag);
                }
            }
            if (slowDispatchThresholdMs > 0) {
                final long time = end - start;
                if (time > slowDispatchThresholdMs) {
                    Slog.w(TAG, "Dispatch took " + time + "ms on "
                            + Thread.currentThread().getName() + ", h=" +
                            msg.target + " cb=" + msg.callback + " msg=" + msg.what);
                }
            }

            if (logging != null) {
                logging.println("<<<<< Finished to " + msg.target + " " + msg.callback);
            }

            // Make sure that during the course of dispatching the
            // identity of the thread wasn't corrupted.
            final long newIdent = Binder.clearCallingIdentity();
            if (ident != newIdent) {
                Log.wtf(TAG, "Thread identity changed from 0x"
                        + Long.toHexString(ident) + " to 0x"
                        + Long.toHexString(newIdent) + " while dispatching to "
                        + msg.target.getClass().getName() + " "
                        + msg.callback + " what=" + msg.what);
            }

            msg.recycleUnchecked();
        }
```
loop的过程看起来还是比较简单的，核心在于一个时延和分发。

当检测到messagequeue中有消息的时候，会执行该消息的dispatchmessage()方法

# msg.target

该target对象是handler，也就是message中封了一个handler对像

# dispatchmessage()

```
public void dispatchMessage(Message msg) {
        if (msg.callback != null) {
            // 当 Message 存在回调方法，回调 msg.callback.run() 方法
            handleCallback(msg);
        } else {
            if (mCallback != null) {
                // 当 Handler 存在 Callback 成员变量时，回调方法 handleMessage()
                if (mCallback.handleMessage(msg)) {
                    return;
                }
            }
            // Handler 自身的回调方法 handleMessage()
            handleMessage(msg);
        }
    }
```

从这里可以看出，针对msg有三种处理方式

## 单独处理callback

当callback不为空的时候，会优先处理callback，这个callback的就是在post的时候的runnable对象

## 构造处理msg

当不是调用post方法进行的操作，会处理msg。如果构造的时候传入了callback，就会调用传入的callback方法的handlemessage方法

## 自身处理msg

如果没有传入callback，那么就会调用handler自身的hanldeMessage方法。

该方法默认是一个空方法，需要重写handlemessage方法。

## 总结

如果是直接post一个runnable对象的话，当处理这个massage的时候，会直接调用该msg携带的runnable直接进行。

如果是使用message方式来传递的话，需要处理该message，则需要两种方式

1.向Hanlder的构造函数传入一个Handler.Callback对象，并实现Handler.Callback的handleMessage方法
2.无需向Hanlder的构造函数传入Handler.Callback对象，但是需要重写Handler本身的handleMessage方法

# 总结

message分发判断是否传入到对应的handler中，其实是message自身携带的handler对象

```
 private static Message getPostMessage(Runnable r) {
        Message m = Message.obtain();
        m.callback = r;
        return m;
    }
```

post的时候会通过这个方法对runnable对象进行封装，这样就顺利的将一个runnable与message联系起来，之后looper执行的时候仍然可以以message为对象进行处理。