---
title: "Glide内存缓存机制"
date: 2019-07-29T09:50:23+08:00
---


# LruBitmapPool
```
/**
 * An {@link com.bumptech.glide.load.engine.bitmap_recycle.BitmapPool} implementation that uses an
 * {@link com.bumptech.glide.load.engine.bitmap_recycle.LruPoolStrategy} to bucket {@link Bitmap}s
 * and then uses an LRU eviction policy to evict {@link android.graphics.Bitmap}s from the least
 * recently used bucket in order to keep the pool below a given maximum size limit.
 */
```
 
从这段注释其实就可以了解，lrubitmappool是使用lrupoolstrategy来桶装bitmap的，使用的是lru的驱逐算法将最后一个驱逐来达到池子的容量和给定数量相同的目的。
提前说明，lrubitmappool并不是用于放专门的bitmap的，而是放bitmap区域。由于bitmap是连续的内存区块，因此需要使用到足够大的区域来放置，因此lrubitmappool的作用就是将之前用过的bitmap内存区块缓存下来，以备后续使用。
 
## 构造

```
 /**
   * Constructor for LruBitmapPool.
   *
   * @param maxSize The initial maximum size of the pool in bytes.
   */
  public LruBitmapPool(long maxSize) {
    this(maxSize, getDefaultStrategy(), getDefaultAllowedConfigs());
  }
``` 

无他，传入需要的size，至此，虽然我们代码没咋看，但是已经知道是lrucache的驱逐算法了，在我们本来就很了解lrucache的算法的基础上，我们很明显的就知道需要解决的问题是什么。

没错，怎么计算这个size，我们传入的size，究竟可以放多少bitmap？

## 探究size

```
LruBitmapPool(long maxSize, LruPoolStrategy strategy, Set<Bitmap.Config> allowedConfigs) {
    this.initialMaxSize = maxSize;
    this.maxSize = maxSize;
    this.strategy = strategy;
    this.allowedConfigs = allowedConfigs;
    this.tracker = new NullBitmapTracker();
  }
```

首先定义了initialMaxSize和maxSize为我们设置的size

### initialMaxSize
```
@Override
  public synchronized void setSizeMultiplier(float sizeMultiplier) {
    maxSize = Math.round(initialMaxSize * sizeMultiplier);
    evict();
  }
```
又提供了一个方法，设置maxsize为initialmaxsize的倍数，这个很有用
可以通过Glide.setMemoryCategory(new MemoryCategory(float));来进行这个区域的优化

```html
/**
   * Tells Glide's memory cache and bitmap pool to use at most half of their initial maximum size.
   */
  LOW(0.5f),
  /**
   * Tells Glide's memory cache and bitmap pool to use at most their initial maximum size.
   */
  NORMAL(1f),
  /**
   * Tells Glide's memory cache and bitmap pool to use at most one and a half times their initial
   * maximum size.
   */
  HIGH(1.5f);
```

官方大概思路是三个倍数关系。

往下走....

initialsize的作用结束了，之后就是maxsize发挥作用的场景了。

### maxSize

maxsize就是lrucache的size了，在put和evict的使用需要做基准线用

```
  @Override
  public synchronized void put(Bitmap bitmap) {
    if (bitmap == null) {
      throw new NullPointerException("Bitmap must not be null");
    }
    if (bitmap.isRecycled()) {
      throw new IllegalStateException("Cannot pool recycled bitmap");
    }
    if (!bitmap.isMutable() || strategy.getSize(bitmap) > maxSize
        || !allowedConfigs.contains(bitmap.getConfig())) {
      if (Log.isLoggable(TAG, Log.VERBOSE)) {
        Log.v(TAG, "Reject bitmap from pool"
                + ", bitmap: " + strategy.logBitmap(bitmap)
                + ", is mutable: " + bitmap.isMutable()
                + ", is allowed config: " + allowedConfigs.contains(bitmap.getConfig()));
      }
      bitmap.recycle();
      return;
    }

    final int size = strategy.getSize(bitmap);
    strategy.put(bitmap);
    tracker.add(bitmap);

    puts++;
    currentSize += size;

    if (Log.isLoggable(TAG, Log.VERBOSE)) {
      Log.v(TAG, "Put bitmap in pool=" + strategy.logBitmap(bitmap));
    }
    dump();

    evict();
  }
```
这是put过程，解释了什么情况下会将bitmap放入bitmappool中，这里也是优化的细节点

除了必要的不为空和没被回收之外，还有几个细节点

1. bitmap是不可变的(不能再次在bitmap上面做修改了！)
2. bitmap的size不能大于我们设置的size（重点！）
3. 前面有个allowedConfigs里面不能不包含这个bitmap的config（可以使用这个过滤我们缓存什么样的位图，可以缓存高精度的位图）

```
strategy.getSize(bitmap) > maxSize
```

```
private static LruPoolStrategy getDefaultStrategy() {
    final LruPoolStrategy strategy;
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
      strategy = new SizeConfigStrategy();
    } else {
      strategy = new AttributeStrategy();
    }
    return strategy;
  }
```

这里就能看到size的判断地点了，就是通过两个对象的getsize方法。

不过啃爹的是，两个getsize都是一个方法

```
  /**
   * Returns the in memory size of the given {@link Bitmap} in bytes.
   */
  @TargetApi(Build.VERSION_CODES.KITKAT)
  public static int getBitmapByteSize(@NonNull Bitmap bitmap) {
    // The return value of getAllocationByteCount silently changes for recycled bitmaps from the
    // internal buffer size to row bytes * height. To avoid random inconsistencies in caches, we
    // instead assert here.
    if (bitmap.isRecycled()) {
      throw new IllegalStateException("Cannot obtain size for recycled Bitmap: " + bitmap
          + "[" + bitmap.getWidth() + "x" + bitmap.getHeight() + "] " + bitmap.getConfig());
    }
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
      // Workaround for KitKat initial release NPE in Bitmap, fixed in MR1. See issue #148.
      try {
        return bitmap.getAllocationByteCount();
      } catch (@SuppressWarnings("PMD.AvoidCatchingNPE") NullPointerException e) {
        // Do nothing.
      }
    }
    return bitmap.getHeight() * bitmap.getRowBytes();
  }
```
指向util.getBitmapByteSize。

这里我们就知道了，其实就是bitmap的计算方法，K以上直接返回分配的字节内存，否则是每行字节和行数的结果。

## strategy.put(bitmap);

从上面的代码知道在K以上使用的strategy是SizeConfigStrategy，因此就着这个展开。

```
  @Override
  public void put(Bitmap bitmap) {
    int size = Util.getBitmapByteSize(bitmap);
    Key key = keyPool.get(size, bitmap.getConfig());

    groupedMap.put(key, bitmap);

    NavigableMap<Integer, Integer> sizes = getSizesForConfig(bitmap.getConfig());
    Integer current = sizes.get(key.size);
    sizes.put(key.size, current == null ? 1 : current + 1);
  }
```

这里可以看到key的生成方式和存储的容器groupedMap。

首先，groupedMap是一个自定义的容器，注释如下，类似于hashmap，具体的不看了。就是存储进来了。

```
/**
 * Similar to {@link java.util.LinkedHashMap} when access ordered except that it is access ordered
 * on groups of bitmaps rather than individual objects. The idea is to be able to find the LRU
 * bitmap size, rather than the LRU bitmap object. We can then remove bitmaps from the least
 * recently used size of bitmap when we need to reduce our cache size.
 *
 * For the purposes of the LRU, we count gets for a particular size of bitmap as an access, even if
 * no bitmaps of that size are present. We do not count addition or removal of bitmaps as an
 * access.
 */
```

其次，key有一套较为复杂的生成方法，抽象来看就是通过bitmap的内存大小，外加其配置是rgb565、888还是什么别的，最终生成的一个key实体类。

通过将这个key和bitmap对应存起来，就可以达到将这块内存区域的使用给保存下来的目的。

## final Bitmap result = strategy.get(width, height, config != null ? config : DEFAULT_CONFIG);

这里就是lrubitmappool获取bitmap内存区域的方法。也是通过strategy来获取的。

```
  @Override
  @Nullable
  public Bitmap get(int width, int height, Bitmap.Config config) {
    int size = Util.getBitmapByteSize(width, height, config);
    Key bestKey = findBestKey(size, config);

    Bitmap result = groupedMap.get(bestKey);
    if (result != null) {
      // Decrement must be called before reconfigure.
      decrementBitmapOfSize(bestKey.size, result);
      result.reconfigure(width, height,
          result.getConfig() != null ? result.getConfig() : Bitmap.Config.ARGB_8888);
    }
    return result;
  }

```

get的作用很简单，取出key，取出对应key的bitmap区域，降存，重新配置这块bitmap的属性，返回出去。

而取出key的过程，就是使用findbestkey。上面我们知道，存储的时候key其实是根据配置和大小来生成的，获取的时候其实也是当差不差。

```
  private Key findBestKey(int size, Bitmap.Config config) {
    Key result = keyPool.get(size, config);
    for (Bitmap.Config possibleConfig : getInConfigs(config)) {
      NavigableMap<Integer, Integer> sizesForPossibleConfig = getSizesForConfig(possibleConfig);
      Integer possibleSize = sizesForPossibleConfig.ceilingKey(size);
      if (possibleSize != null && possibleSize <= size * MAX_SIZE_MULTIPLE) {
        if (possibleSize != size
            || (possibleConfig == null ? config != null : !possibleConfig.equals(config))) {
          keyPool.offer(result);
          result = keyPool.get(possibleSize, possibleConfig);
        }
        break;
      }
    }
    return result;
  }
```

这里不在深究，会找到一个比较适合的内存区域，也可能找不到，找不到的话就会返回空

```
  @Override
  @NonNull
  public Bitmap get(int width, int height, Bitmap.Config config) {
    Bitmap result = getDirtyOrNull(width, height, config);
    if (result != null) {
      // Bitmaps in the pool contain random data that in some cases must be cleared for an image
      // to be rendered correctly. we shouldn't force all consumers to independently erase the
      // contents individually, so we do so here. See issue #131.
      result.eraseColor(Color.TRANSPARENT);
    } else {
      result = createBitmap(width, height, config);
    }

    return result;
  }
```

回到lrucache的get中，能知道了，找得到这块内存区域，就擦为空，然后复用，否则，就create一个bitmap。（划重点！内存区域的获取，是从这边create的！）

```
  @NonNull
  private static Bitmap createBitmap(int width, int height, @Nullable Bitmap.Config config) {
    return Bitmap.createBitmap(width, height, config != null ? config : DEFAULT_CONFIG);
  }
```

createbitmap就是原生的味道..


# LruResourceCache

```
/**
 * An LRU in memory cache for {@link com.bumptech.glide.load.engine.Resource}s.
 */
```

从注释可以看出来，lruresourceCache是一个放Resource的容器。

```java
package com.bumptech.glide.load.engine;

import android.support.annotation.NonNull;

/**
 * A resource interface that wraps a particular type so that it can be pooled and reused.
 *
 * @param <Z> The type of resource wrapped by this class.
 */
public interface Resource<Z> {

  /**
   * Returns the {@link Class} of the wrapped resource.
   */
  @NonNull
  Class<Z> getResourceClass();

  /**
   * Returns an instance of the wrapped resource.
   *
   * <p> Note - This does not have to be the same instance of the wrapped resource class and in fact
   * it is often appropriate to return a new instance for each call. For example,
   * {@link android.graphics.drawable.Drawable Drawable}s should only be used by a single
   * {@link android.view.View View} at a time so each call to this method for Resources that wrap
   * {@link android.graphics.drawable.Drawable Drawable}s should always return a new
   * {@link android.graphics.drawable.Drawable Drawable}. </p>
   */
  @NonNull
  Z get();

  /**
   * Returns the size in bytes of the wrapped resource to use to determine how much of the memory
   * cache this resource uses.
   */
  int getSize();

  /**
   * Cleans up and recycles internal resources.
   *
   * <p> It is only safe to call this method if there are no current resource consumers and if this
   * method has not yet been called. Typically this occurs at one of two times:
   * <ul>
   *   <li>During a resource load when the resource is transformed or transcoded before any consumer
   *   have ever had access to this resource</li>
   *   <li>After all consumers have released this resource and it has been evicted from the cache
   *   </li>
   * </ul>
   *
   * For most users of this class, the only time this method should ever be called is during
   * transformations or transcoders, the framework will call this method when all consumers have
   * released this resource and it has been evicted from the cache. </p>
   */
  void recycle();
}
```

resource就是上面这个类，是个很简单的类，其主要的作用类似于一个reference，提供了一些get方法和recycle方法

我们来看看在哪里使用到了LruResourcecache的方法的

首先是GlideBuilder中提供了set的方法和初始化的默认构造，其次是将其塞入Engine中，Engine中调用了lruresourcecache的put和remove方法。

因此我们在这里需要明白resource的指责，和存储删除的时机，这也是engine中流程中需要了解的目标

# engine

```
/**
 * Responsible for starting loads and managing active and cached resources.
 */
```
engine类就是用作加载和管理可用和缓存resource的类。

其作用发生在load完资源之后

