---
title: recyclerview源码学习
date: 2019-01-27 17:50:30
tags: android
---

# 绘制过程

绘制过程需要理解的是如何一个itemview一个itemview的绘制

## onMeasure

```
protected void onMeasure(int widthSpec, int heightSpec) {
        if (mLayout == null) {
            //layoutManager没有设置的话，直接走default的方法，所以会为空白
            defaultOnMeasure(widthSpec, heightSpec);
            return;
        }
        if (mLayout.mAutoMeasure) {
            final boolean skipMeasure = widthMode == MeasureSpec.EXACTLY
                    && heightMode == MeasureSpec.EXACTLY;
            //如果测量是绝对值，则跳过measure过程直接走layout
            if (skipMeasure || mAdapter == null) {
                return;
            }
            if (mState.mLayoutStep == State.STEP_START) {
                //mLayoutStep默认值是 State.STEP_START
                dispatchLayoutStep1();
                //执行完dispatchLayoutStep1()后是State.STEP_LAYOUT
            }
             ..........
            //真正执行LayoutManager绘制的地方
            dispatchLayoutStep2();
            //执行完后是State.STEP_ANIMATIONS
             ..........
            //宽高都不确定的时候，会绘制两次
            // if RecyclerView has non-exact width and height and if there is at least one child
            // which also has non-exact width & height, we have to re-measure.
            if (mLayout.shouldMeasureTwice()) {
             ..........
                dispatchLayoutStep2();
             ..........            }
        } else {
            if (mHasFixedSize) {
                mLayout.onMeasure(mRecycler, mState, widthSpec, heightSpec);
                return;
            }
             ..........
            mLayout.onMeasure(mRecycler, mState, widthSpec, heightSpec);
             ..........
            mState.mInPreLayout = false; // clear
        }
    }
--------------------- 
别人概括的measure过程
```

从这里大概分为三步，毕竟三个else

### layout == null

```
void defaultOnMeasure(int widthSpec, int heightSpec) {
        // calling LayoutManager here is not pretty but that API is already public and it is better
        // than creating another method since this is internal.
        final int width = LayoutManager.chooseSize(widthSpec,
                getPaddingLeft() + getPaddingRight(),
                ViewCompat.getMinimumWidth(this));
        final int height = LayoutManager.chooseSize(heightSpec,
                getPaddingTop() + getPaddingBottom(),
                ViewCompat.getMinimumHeight(this));
        setMeasuredDimension(width, height);
    }
```

```
public static int chooseSize(int spec, int desired, int min) {
            int mode = MeasureSpec.getMode(spec);
            int size = MeasureSpec.getSize(spec);
            switch(mode) {
            case -2147483648:
                return Math.min(size, Math.max(desired, min));
            case 0:
            default:
                return Math.max(desired, min);
            case 1073741824:
                return size;
            }
        }
```

默认情况下面其实是处理了一下最高度


























