---
title: "Viewpager2与recycleview混用导致的滑动冲突解决"
date: 2020-05-07T15:55:45+08:00
---

项目升级到androidX有几个月了，别的都挺稳定的，也用了一些androidX真香的特性。

比如说viewpager2

viewpager2使用recyclerview来进行页面的切换，比老viewpager对于页面懒加载的支持性更好。同时也可以使用到recyclerview的特性。

但是也有缺点。

直接使用viewpager2，搭配子fragment内部使用的是recyclerview的话，则会直接导致子view的滑动事件被父事件屏蔽。

网上也有解决方法，由于viewpager2的recyclerview是一个final类无法继承，因此可以写一个recyclerview2，重写派发事件的方法。

```
public class RecyclerView2 extends RecyclerView {

    public RecyclerView2(@NonNull Context context) {
        super(context);
    }

    public RecyclerView2(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    public RecyclerView2(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    private int startX, startY;

    @Override
    public boolean dispatchTouchEvent(MotionEvent ev) {
        switch (ev.getAction()) {
            case MotionEvent.ACTION_DOWN:
                startX = (int) ev.getX();
                startY = (int) ev.getY();
                getParent().requestDisallowInterceptTouchEvent(true);
                break;
            case MotionEvent.ACTION_MOVE:
                int endX = (int) ev.getX();
                int endY = (int) ev.getY();
                int disX = Math.abs(endX - startX);
                int disY = Math.abs(endY - startY);
                if (disX > disY) {
                    Log.e("mikilangkilo", "RecyclerView2/dispatchTouchEvent: canScrollHorizontally ? "+canScrollHorizontally(startX - endX));
                    if (!canScrollHorizontally(startX - endX)){
                        Log.e("mikilangkilo", "RecyclerView2/dispatchTouchEvent: can not distance = "+(startX - endX)+",startX = "+startX +",endx = "+endX);
                    }else {
                        Log.e("mikilangkilo", "RecyclerView2/dispatchTouchEvent: can distance = "+(startX - endX) +",startX = "+startX +",endX = "+endX);
                    }
                    getParent()
                        .requestDisallowInterceptTouchEvent(canScrollHorizontally(startX - endX));
                } else {
                    getParent()
                        .requestDisallowInterceptTouchEvent(canScrollVertically(startY - endY));
                }
                break;
            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_CANCEL:
                getParent().requestDisallowInterceptTouchEvent(false);
                break;
            default:
                break;
        }
        return super.dispatchTouchEvent(ev);
    }

}
```

改了这个之后的确一定意义上是子view能够响应事件。

原理是通过requestDisallowInterceptTouchEvent这个方法

```
    @Override
    public void requestDisallowInterceptTouchEvent(boolean disallowIntercept) {

        if (disallowIntercept == ((mGroupFlags & FLAG_DISALLOW_INTERCEPT) != 0)) {
            // We're already in this state, assume our ancestors are too
            return;
        }

        if (disallowIntercept) {
            mGroupFlags |= FLAG_DISALLOW_INTERCEPT;
        } else {
            mGroupFlags &= ~FLAG_DISALLOW_INTERCEPT;
        }

        // Pass it up to our parent
        if (mParent != null) {
            mParent.requestDisallowInterceptTouchEvent(disallowIntercept);
        }
    }
```
改变了父类的FLAG_DISALLOW_INTERCEPT这个flag

在父类分发的时候，走下面这个

```
            if (actionMasked == MotionEvent.ACTION_DOWN
                    || mFirstTouchTarget != null) {
                final boolean disallowIntercept = (mGroupFlags & FLAG_DISALLOW_INTERCEPT) != 0;
                if (!disallowIntercept) {
                    intercepted = onInterceptTouchEvent(ev);
                    ev.setAction(action); // restore action in case it was changed
                } else {
                    intercepted = false;
                }
            }
```
不允许拦截的话，那么父类就会跳过拦截方法。

的确是一定意义上解决了这个问题。

但是在项目页面逐渐复杂之后，出现了一种横向viewpager2和横向recyclerview共存的现象，就是我们的主页。

发生一种情况，recyclerview滑动到边界的时候，触发了requestDisallowInterceptTouchEvent方法，导致父类开始进行拦截，但是同时recyclerview反向滑动，此时反向滑动事件本不应同时被拦截，也被拦截了。

