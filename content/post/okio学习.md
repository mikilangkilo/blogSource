---
title: okio学习
date: 2018-12-11 14:36:35
tags: android 
---

# io

io是java使用进行读取和写入的方式，i是input，o是output，走向是以内存为基准，内存中读数据是输入流，内存中往外写是输出流。

io又分为字节流和字符流。字节流是直接对文件进行读写，是不中断的操作，不关闭字节流的话，操作仍然可以成功。而字符流是将文件的读写进行在缓冲区，当关闭的时候才会进行操作。

字节流使用stream结尾，字符流使用reader和writer结尾。

## 缓冲区

缓冲区是一段内存区域，由于频繁的操作资源，会导致性能很低，而将数据存储到内存区域之后，之后的可以直接从区域中读取数据，读取内存数据的速度比较快，这样可以提升性能。

字符流由于所有的数据都是暂存在内存中，如果想要清空缓存区，需要使用到flush操作，flush操作可以强制清空缓存区，因此会将缓存区的数据全部取出进行操作后清空。

## 字节流和字符流优缺点

- 字节流优点

字节流的优点是使用到了缓存区，通过内存的使用加快了效率。字节流多用于处理图片，处理成为二进制字节。

- 字符流优点

字符流的优点是操作比较方便，提供了一些方便的例如readline这种功能。字符流多用于处理文字。

# nio

nio使用了缓存区、通道、管道来实现多线程io通信的问题

## 通道

通道的存在大大提升了对buffer区域的操作空间，获取buffer的操作不再是由buffer提供，而是由channel进行代理提供，类似于stream对象，但是channel是由selector管理的。selector提供了可以监听多个通道的功能，因此单线程中使用selector可以监听多个channel，而stream则需要每个开一个线程才能达到不阻塞的行为。这样就解决了需要多线程io的问题

## 管道

两个线程之间进行单项数据连接，会建立一个管道，数据被写到sink通道，读取的时候从source通道读取。

### 管道的原理

管道写函数时，通过将字节复制到VFS索引节点指向的物理内存而写入数据，管道读函数则通过复制物理内存中的字节而读出数据。缓冲区不需要很大，一般为4k大小，它被设计为环形的结构，以便能够循环利用，当管道没有信息的时候，从管道中读取的进程会等待，知道另一端的进程放入信息。当管道被放满信息的时候，放入信息的进程会等待，直到另一端的进程取出信息。

## selector

selector又被称为多路复用器，用于检查一个NIO channel的状态是否处于可读和可写。

与selector一起使用的channel必须是非阻塞模式的，filechannel和selector就不能一起使用

### selector原理

channel通过注册，使得selector可以统一管理多个channel，这样一个线程只需要通过一个selector就可以管理多个channel。注册是使用注册表的方式来进行。

### selector多路复用的机制

介于cpu目前多任务越来越快，因此selector效率也越来越高，多个任务同时触发，每个任务的阻塞设置超时时间，因此可以比较好的实现多路复用的机制

# okio

okio和nio的原理差不多，加上了buffer,信道，但是进行了优化，另外由于okio是设计用于网络请求的，所以加上了超时机制

## sink构造

sink是okio的信道,用于写入

```
private static Sink sink(final OutputStream out, final Timeout timeout) {
    if (out == null) throw new IllegalArgumentException("out == null");
    if (timeout == null) throw new IllegalArgumentException("timeout == null");

    return new Sink() {
      @Override public void write(Buffer source, long byteCount) throws IOException {
        checkOffsetAndCount(source.size, 0, byteCount);
        while (byteCount > 0) {
          timeout.throwIfReached();
          Segment head = source.head;
          int toCopy = (int) Math.min(byteCount, head.limit - head.pos);
          out.write(head.data, head.pos, toCopy);

          head.pos += toCopy;
          byteCount -= toCopy;
          source.size -= toCopy;

          if (head.pos == head.limit) {
            source.head = head.pop();
            SegmentPool.recycle(head);
          }
        }
      }

      @Override public void flush() throws IOException {
        out.flush();
      }

      @Override public void close() throws IOException {
        out.close();
      }

      @Override public Timeout timeout() {
        return timeout;
      }

      @Override public String toString() {
        return "sink(" + out + ")";
      }
    };
  }
```

source是用于读取的信道

```
private static Source source(final InputStream in, final Timeout timeout) {
    if (in == null) throw new IllegalArgumentException("in == null");
    if (timeout == null) throw new IllegalArgumentException("timeout == null");

    return new Source() {
      @Override public long read(Buffer sink, long byteCount) throws IOException {
        if (byteCount < 0) throw new IllegalArgumentException("byteCount < 0: " + byteCount);
        if (byteCount == 0) return 0;
        try {
          timeout.throwIfReached();
          Segment tail = sink.writableSegment(1);
          int maxToCopy = (int) Math.min(byteCount, Segment.SIZE - tail.limit);
          int bytesRead = in.read(tail.data, tail.limit, maxToCopy);
          if (bytesRead == -1) return -1;
          tail.limit += bytesRead;
          sink.size += bytesRead;
          return bytesRead;
        } catch (AssertionError e) {
          if (isAndroidGetsocknameError(e)) throw new IOException(e);
          throw e;
        }
      }

      @Override public void close() throws IOException {
        in.close();
      }

      @Override public Timeout timeout() {
        return timeout;
      }

      @Override public String toString() {
        return "source(" + in + ")";
      }
    };
  }
```
这种信道机制都是队列模式，关于超时判定永远在最先，超时是不在乎io的速度，而只关注io开始时是否超时，而这种读取和写入的方法都基本是一层while搞定。

从source和sink可以看出来，okio通过Segment来做数据的处理单元，这是一种双链表结构。写入的时候将依照节点顺序写入，读的时候也是从缓存池里面取出头节点进行读取。

```
final class SegmentPool {
  /** The maximum number of bytes to pool. */
  // TODO: Is 64 KiB a good maximum size? Do we ever have that many idle segments?
  static final long MAX_SIZE = 64 * 1024; // 64 KiB.

  /** Singly-linked list of segments. */
  static @Nullable Segment next;

  /** Total bytes in this pool. */
  static long byteCount;

  private SegmentPool() {
  }

  static Segment take() {
    synchronized (SegmentPool.class) {
      if (next != null) {
        Segment result = next;
        next = result.next;
        result.next = null;
        byteCount -= Segment.SIZE;
        return result;
      }
    }
    return new Segment(); // Pool is empty. Don't zero-fill while holding a lock.
  }

  static void recycle(Segment segment) {
    if (segment.next != null || segment.prev != null) throw new IllegalArgumentException();
    if (segment.shared) return; // This segment cannot be recycled.
    synchronized (SegmentPool.class) {
      if (byteCount + Segment.SIZE > MAX_SIZE) return; // Pool is full.
      byteCount += Segment.SIZE;
      segment.next = next;
      segment.pos = segment.limit = 0;
      next = segment;
    }
  }
}
```

整个缓存池并不知道能不能说是一个池，说是一个管理类感觉更好点，读取的时候通过sink.writableSegment(1)来获取,这是通过操作sink的buffer来做的处理

```
Segment writableSegment(int minimumCapacity) {
    if (minimumCapacity < 1 || minimumCapacity > Segment.SIZE) throw new IllegalArgumentException();

    if (head == null) {
      head = SegmentPool.take(); // Acquire a first segment.
      return head.next = head.prev = head;
    }

    Segment tail = head.prev;
    if (tail.limit + minimumCapacity > Segment.SIZE || !tail.owner) {
      tail = tail.push(SegmentPool.take()); // Append a new empty segment to fill up.
    }
    return tail;
  }
```

这里比较抽象，有部分的操作是进行链表的判空等，空链表做了一些处理，最终返回的是可处理的队列的尾部（其实是指向队列头的引用，不过由于是push方式，所以头在底下，因此叫做尾部）

获取了尾部之后就开始通过io进行读取，这就是读取的过程。

相对于io来讲，这部分由于使用了自己的缓存，缓存直接取出来使用，对比拷贝效率更高效一些。

## 总结一下

okio在最终的写入和读出上面，都使用的原生io机制，但是okio维护了自己的buffer，这个buffer相对于原生来讲不需要在source时进行拷贝，也就是直接使用引用，效果更快。另外okio是针对网络相关的，所以okio增加了超时机制也是比原生更有优势的地方。