---
title: "Bitmap内存区域探究"
date: 2019-07-26T11:24:53+08:00
tags: bitmap
category: 性能
---

# bitmap内存占用关系

## 始

以前查是否需要自己手动执行bitmap的recycle()的时候，网上很多博文都说Android2.2之后不需要手动回收。

这句话是对的，2.2之后不需要自己执行recycle()方法。

但是这句话又不对，之所以不执行recycle()方法，原因并不是图像buffer。

# bitmap内存结构

因为不同版本的代码不同，在android O有个变化，之前的是一批，也是目前处理内存问题遇到比较多的地方。

以下是api19的bitmap的成员变量

```
    /**
     * Indicates that the bitmap was created for an unknown pixel density.
     *
     * @see Bitmap#getDensity()
     * @see Bitmap#setDensity(int)
     */
    public static final int DENSITY_NONE = 0;
    
    /**
     * Note:  mNativeBitmap is used by FaceDetector_jni.cpp
     * Don't change/rename without updating FaceDetector_jni.cpp
     * 
     * @hide
     */
    public final int mNativeBitmap;

    /**
     * Backing buffer for the Bitmap.
     * Made public for quick access from drawing methods -- do NOT modify
     * from outside this class
     *
     * @hide
     */
    @SuppressWarnings("UnusedDeclaration") // native code only
    public byte[] mBuffer;

    @SuppressWarnings({"FieldCanBeLocal", "UnusedDeclaration"}) // Keep to finalize native resources
    private final BitmapFinalizer mFinalizer;

    private final boolean mIsMutable;

    /**
     * Represents whether the Bitmap's content is expected to be pre-multiplied.
     * Note that isPremultiplied() does not directly return this value, because
     * isPremultiplied() may never return true for a 565 Bitmap.
     *
     * setPremultiplied() does directly set the value so that setConfig() and
     * setPremultiplied() aren't order dependent, despite being setters.
     */
    private boolean mIsPremultiplied;
    private byte[] mNinePatchChunk;   // may be null
    private int[] mLayoutBounds;   // may be null
    private int mWidth;
    private int mHeight;
    private boolean mRecycled;

    // Package-scoped for fast access.
    int mDensity = getDefaultDensity();

    private static volatile Matrix sScaleMatrix;

    private static volatile int sDefaultDensity = -1;
```

这里可以看到，bitmap重要的byte[]数组只有两个一个是buffer，这个也就是存储使用的，内存中的像素点，另一个是点9图块，而且备注的很清楚，点9块可能不存在

其中这个buffer就是存放像素点的字段，byte是1字节，argb8888表示一个像素使用四个byte，rgb565则表示使用了2个byte

附录一下转换的方式

RGB 8888 - RGB 565

```
1.取RGB888中第一个字节的高5位作为转换后的RGB565的第二个字节的高5位
2.取RGB888中第二个字节的高3位作为转换后的RGB565第二个字节的低3位
3.取RGB888中第二个字节的第4--6位，作为转换后的RGB565第一个字节的高3位
4.取RGB888中第二个字节的第三个字节的高5位作为转换后的RGB565第一个字节的低5位
```

RGB 565 - RGB 8888
```
1.取RGB565第一个字节中低5位作为RGB888的高5位
2.取RGB565第二个字节中的低3位，将其左移5位，作为RGB888第二个字节的高5位
3.取RGB565第一个字节的高3位将其右移3位，作为RGB888第二个字节的4--6位
4.取RGB565第二个字节中的高5位作为RGB888第三个字节。
```

由于这个buffer是私有的，因此计算大小还是用的谷歌推荐的宽高成像素比特在成尺寸。但是其实这个buffer的写入的数据我们是可以读出来的

使用

```
    /** 
     * 把Bitmap转Byte 
     */  
    public static byte[] Bitmap2Bytes(Bitmap bm){  
        ByteArrayOutputStream baos = new ByteArrayOutputStream();  
        bm.compress(Bitmap.CompressFormat.PNG, 100, baos);  
        return baos.toByteArray();  
    }  

```
读取的过程会走nativecompress






