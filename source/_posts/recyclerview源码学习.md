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

默认情况下面其实是处理了一下高度的问题，如果有padding的话，会将padding归入计算

### mlayout != null &&  mLayout.isAutoMeasureEnabled()

```
public boolean isAutoMeasureEnabled() {
            return mAutoMeasure;
        }
```

```
/**
         * Defines whether the measuring pass of layout should use the AutoMeasure mechanism of
         * {@link RecyclerView} or if it should be done by the LayoutManager's implementation of
         * {@link LayoutManager#onMeasure(Recycler, State, int, int)}.
         *
         * @param enabled <code>True</code> if layout measurement should be done by the
         *                RecyclerView, <code>false</code> if it should be done by this
         *                LayoutManager.
         *
         * @see #isAutoMeasureEnabled()
         *
         * @deprecated Implementors of LayoutManager should define whether or not it uses
         *             AutoMeasure by overriding {@link #isAutoMeasureEnabled()}.
         */
        @Deprecated
        public void setAutoMeasureEnabled(boolean enabled) {
            mAutoMeasure = enabled;
        }
```

这个api是deprecate的，其功能主要是设置自动测量

```
if (mLayout.mAutoMeasure) {
            final int widthMode = MeasureSpec.getMode(widthSpec);
            final int heightMode = MeasureSpec.getMode(heightSpec);
            final boolean skipMeasure = widthMode == MeasureSpec.EXACTLY
                    && heightMode == MeasureSpec.EXACTLY;
            mLayout.onMeasure(mRecycler, mState, widthSpec, heightSpec);
            if (skipMeasure || mAdapter == null) {
                return;
            }
            if (mState.mLayoutStep == State.STEP_START) {
                dispatchLayoutStep1();
            }
            // set dimensions in 2nd step. Pre-layout should happen with old dimensions for
            // consistency
            mLayout.setMeasureSpecs(widthSpec, heightSpec);
            mState.mIsMeasuring = true;
            dispatchLayoutStep2();

            // now we can get the width and height from the children.
            mLayout.setMeasuredDimensionFromChildren(widthSpec, heightSpec);

            // if RecyclerView has non-exact width and height and if there is at least one child
            // which also has non-exact width & height, we have to re-measure.
            if (mLayout.shouldMeasureTwice()) {
                mLayout.setMeasureSpecs(
                        MeasureSpec.makeMeasureSpec(getMeasuredWidth(), MeasureSpec.EXACTLY),
                        MeasureSpec.makeMeasureSpec(getMeasuredHeight(), MeasureSpec.EXACTLY));
                mState.mIsMeasuring = true;
                dispatchLayoutStep2();
                // now we can get the width and height from the children.
                mLayout.setMeasuredDimensionFromChildren(widthSpec, heightSpec);
            }
        }
```

1. 如果测量是绝对值，则不再进行measure而直接layout，毕竟EXACTLY是写死了面积了，recyclerview的父类会直接获取面积来摆放

2. STATE变量为start时

```
        static final int STEP_START = 1;
        static final int STEP_LAYOUT = 1 << 1;
        static final int STEP_ANIMATIONS = 1 << 2;
```

```
/**
     * The first step of a layout where we;
     * - process adapter updates
     * - decide which animation should run
     * - save information about current views
     * - If necessary, run predictive layout and save its information
     */
    private void dispatchLayoutStep1() {
        mState.assertLayoutStep(State.STEP_START);
        fillRemainingScrollValues(mState);
        mState.mIsMeasuring = false;
        startInterceptRequestLayout();
        mViewInfoStore.clear();
        onEnterLayoutOrScroll();
        processAdapterUpdatesAndSetAnimationFlags();
        saveFocusInfo();
        mState.mTrackOldChangeHolders = mState.mRunSimpleAnimations && mItemsChanged;
        mItemsAddedOrRemoved = mItemsChanged = false;
        mState.mInPreLayout = mState.mRunPredictiveAnimations;
        mState.mItemCount = mAdapter.getItemCount();
        findMinMaxChildLayoutPositions(mMinMaxLayoutPositions);

        if (mState.mRunSimpleAnimations) {
            // Step 0: Find out where all non-removed items are, pre-layout
            int count = mChildHelper.getChildCount();
            for (int i = 0; i < count; ++i) {
                final ViewHolder holder = getChildViewHolderInt(mChildHelper.getChildAt(i));
                if (holder.shouldIgnore() || (holder.isInvalid() && !mAdapter.hasStableIds())) {
                    continue;
                }
                final ItemHolderInfo animationInfo = mItemAnimator
                        .recordPreLayoutInformation(mState, holder,
                                ItemAnimator.buildAdapterChangeFlagsForAnimations(holder),
                                holder.getUnmodifiedPayloads());
                mViewInfoStore.addToPreLayout(holder, animationInfo);
                if (mState.mTrackOldChangeHolders && holder.isUpdated() && !holder.isRemoved()
                        && !holder.shouldIgnore() && !holder.isInvalid()) {
                    long key = getChangedHolderKey(holder);
                    // This is NOT the only place where a ViewHolder is added to old change holders
                    // list. There is another case where:
                    //    * A VH is currently hidden but not deleted
                    //    * The hidden item is changed in the adapter
                    //    * Layout manager decides to layout the item in the pre-Layout pass (step1)
                    // When this case is detected, RV will un-hide that view and add to the old
                    // change holders list.
                    mViewInfoStore.addToOldChangeHolders(key, holder);
                }
            }
        }
        if (mState.mRunPredictiveAnimations) {
            // Step 1: run prelayout: This will use the old positions of items. The layout manager
            // is expected to layout everything, even removed items (though not to add removed
            // items back to the container). This gives the pre-layout position of APPEARING views
            // which come into existence as part of the real layout.

            // Save old positions so that LayoutManager can run its mapping logic.
            saveOldPositions();
            final boolean didStructureChange = mState.mStructureChanged;
            mState.mStructureChanged = false;
            // temporarily disable flag because we are asking for previous layout
            mLayout.onLayoutChildren(mRecycler, mState);
            mState.mStructureChanged = didStructureChange;

            for (int i = 0; i < mChildHelper.getChildCount(); ++i) {
                final View child = mChildHelper.getChildAt(i);
                final ViewHolder viewHolder = getChildViewHolderInt(child);
                if (viewHolder.shouldIgnore()) {
                    continue;
                }
                if (!mViewInfoStore.isInPreLayout(viewHolder)) {
                    int flags = ItemAnimator.buildAdapterChangeFlagsForAnimations(viewHolder);
                    boolean wasHidden = viewHolder
                            .hasAnyOfTheFlags(ViewHolder.FLAG_BOUNCED_FROM_HIDDEN_LIST);
                    if (!wasHidden) {
                        flags |= ItemAnimator.FLAG_APPEARED_IN_PRE_LAYOUT;
                    }
                    final ItemHolderInfo animationInfo = mItemAnimator.recordPreLayoutInformation(
                            mState, viewHolder, flags, viewHolder.getUnmodifiedPayloads());
                    if (wasHidden) {
                        recordAnimationInfoIfBouncedHiddenView(viewHolder, animationInfo);
                    } else {
                        mViewInfoStore.addToAppearedInPreLayoutHolders(viewHolder, animationInfo);
                    }
                }
            }
            // we don't process disappearing list because they may re-appear in post layout pass.
            clearOldPositions();
        } else {
            clearOldPositions();
        }
        onExitLayoutOrScroll();
        stopInterceptRequestLayout(false);
        mState.mLayoutStep = State.STEP_LAYOUT;
    }
```

从备注的内容中可以知道，这个步骤有四个功能

- 处理adapter的更新
- 决定哪些动画需要执行
- 保存当前view的信息
- 如果必要的情况下，执行上一个layout的操作并且保存他的信息

该步骤只是做了准备工作

3. state不为start时

```
 /**
     * The second layout step where we do the actual layout of the views for the final state.
     * This step might be run multiple times if necessary (e.g. measure).
     */
    private void dispatchLayoutStep2() {
        startInterceptRequestLayout();
        onEnterLayoutOrScroll();
        mState.assertLayoutStep(State.STEP_LAYOUT | State.STEP_ANIMATIONS);
        mAdapterHelper.consumeUpdatesInOnePass();
        mState.mItemCount = mAdapter.getItemCount();
        mState.mDeletedInvisibleItemCountSincePreviousLayout = 0;

        // Step 2: Run layout
        mState.mInPreLayout = false;
        mLayout.onLayoutChildren(mRecycler, mState);

        mState.mStructureChanged = false;
        mPendingSavedState = null;

        // onLayoutChildren may have caused client code to disable item animations; re-check
        mState.mRunSimpleAnimations = mState.mRunSimpleAnimations && mItemAnimator != null;
        mState.mLayoutStep = State.STEP_ANIMATIONS;
        onExitLayoutOrScroll();
        stopInterceptRequestLayout(false);
    }
```

这里的分析需要细致一些，着重点在mLayout.onLayoutChildren()内，绘制的工作交给了layoutmanager

```
public void onLayoutChildren(RecyclerView.Recycler recycler, RecyclerView.State state) {
        // layout algorithm:
        //找寻锚点
        // 1) by checking children and other variables, find an anchor coordinate and an anchor
        // item position.
        //两个方向填充，从锚点往上，从锚点往下
        // 2) fill towards start, stacking from bottom
        // 3) fill towards end, stacking from top
        // 4) scroll to fulfill requirements like stack from bottom.
        // create layout state
        ....
        // resolve layout direction
        //判断绘制方向,给mShouldReverseLayout赋值,默认是正向绘制，则mShouldReverseLayout是false
        resolveShouldLayoutReverse();
        final View focused = getFocusedChild();
        //mValid的默认值是false，一次测量之后设为true，onLayout完成后会回调执行reset方法，又变为false
        if (!mAnchorInfo.mValid || mPendingScrollPosition != NO_POSITION
                || mPendingSavedState != null) {
        ....
            //mStackFromEnd默认是false，除非手动调用setStackFromEnd()方法，两个都会false，异或则为false
            mAnchorInfo.mLayoutFromEnd = mShouldReverseLayout ^ mStackFromEnd;
            // calculate anchor position and coordinate
            //计算锚点的位置和偏移量
            updateAnchorInfoForLayout(recycler, state, mAnchorInfo);
        ....
        } else if (focused != null && (mOrientationHelper.getDecoratedStart(focused)
                >= mOrientationHelper.getEndAfterPadding()
                || mOrientationHelper.getDecoratedEnd(focused)
                <= mOrientationHelper.getStartAfterPadding())) {
         ....
        }
         ....
        //mLayoutFromEnd为false
        if (mAnchorInfo.mLayoutFromEnd) {
            //倒着绘制的话，先往上绘制，再往下绘制
            // fill towards start
            // 从锚点到往上
            updateLayoutStateToFillStart(mAnchorInfo);
            ....
            fill(recycler, mLayoutState, state, false);
            ....
            // 从锚点到往下
            // fill towards end
            updateLayoutStateToFillEnd(mAnchorInfo);
            ....
            //调两遍fill方法
            fill(recycler, mLayoutState, state, false);
            ....
            if (mLayoutState.mAvailable > 0) {
                // end could not consume all. add more items towards start
            ....
                updateLayoutStateToFillStart(firstElement, startOffset);
                mLayoutState.mExtra = extraForStart;
                fill(recycler, mLayoutState, state, false);
             ....
            }
        } else {
            //正常绘制流程的话，先往下绘制，再往上绘制
            // fill towards end
            updateLayoutStateToFillEnd(mAnchorInfo);
            ....
            fill(recycler, mLayoutState, state, false);
             ....
            // fill towards start
            updateLayoutStateToFillStart(mAnchorInfo);
            ....
            fill(recycler, mLayoutState, state, false);
             ....
            if (mLayoutState.mAvailable > 0) {
                ....
                // start could not consume all it should. add more items towards end
                updateLayoutStateToFillEnd(lastElement, endOffset);
                 ....
                fill(recycler, mLayoutState, state, false);
                ....
            }
        }
        ....
        layoutForPredictiveAnimations(recycler, state, startOffset, endOffset);
        //完成后重置参数
        if (!state.isPreLayout()) {
            mOrientationHelper.onLayoutComplete();
        } else {
            mAnchorInfo.reset();
        }
        mLastStackFromEnd = mStackFromEnd;
    }
```
摘抄了别人分析的内容，很明显，这是linearlayoutmanager一个完整的layout的过程，说实话真的很复杂。

```
先寻找页面当前的锚点 
以这个锚点未基准，向上和向下分别填充 
填充完后，如果还有剩余的可填充大小，再填充一次
```

从这个角度来讲，可以大致理解为绘制的顺序，是首先绘制可见区域及以下的内容，而后绘制可见区域以上的内容，这个上下会依据重心来变化

以前listview的绘制，大概也是差不多的，不过listview有个细节，是不设定数量的情况下，只绘制可见区域及上下加起来7个大小。分析recyclerview的源码发现，其绘制的区域仅仅是可见区域，如果需要预先绘制的话，需要自己制定预先加载的数量，其中的差别体现的还是比较明显的，因为layoutmanager需要考虑绘制的时候的动画。

### 最后一步

```
            if (mHasFixedSize) {
                mLayout.onMeasure(mRecycler, mState, widthSpec, heightSpec);
                return;
            }
            // custom onMeasure
            if (mAdapterUpdateDuringMeasure) {
                startInterceptRequestLayout();
                onEnterLayoutOrScroll();
                processAdapterUpdatesAndSetAnimationFlags();
                onExitLayoutOrScroll();

                if (mState.mRunPredictiveAnimations) {
                    mState.mInPreLayout = true;
                } else {
                    // consume remaining updates to provide a consistent state with the layout pass.
                    mAdapterHelper.consumeUpdatesInOnePass();
                    mState.mInPreLayout = false;
                }
                mAdapterUpdateDuringMeasure = false;
                stopInterceptRequestLayout(false);
            } else if (mState.mRunPredictiveAnimations) {
                // If mAdapterUpdateDuringMeasure is false and mRunPredictiveAnimations is true:
                // this means there is already an onMeasure() call performed to handle the pending
                // adapter change, two onMeasure() calls can happen if RV is a child of LinearLayout
                // with layout_width=MATCH_PARENT. RV cannot call LM.onMeasure() second time
                // because getViewForPosition() will crash when LM uses a child to measure.
                setMeasuredDimension(getMeasuredWidth(), getMeasuredHeight());
                return;
            }

            if (mAdapter != null) {
                mState.mItemCount = mAdapter.getItemCount();
            } else {
                mState.mItemCount = 0;
            }
            startInterceptRequestLayout();
            mLayout.onMeasure(mRecycler, mState, widthSpec, heightSpec);
            stopInterceptRequestLayout(false);
            mState.mInPreLayout = false; // clear
        }
```
这一步是当recyclerview没有设置**mLayout.isAutoMeasureEnabled()**的时候出现的，默认情况下走的就是这一步。

这一步的含义是将绘制权直接交于layoutmanager来绘制，有个细节，就是如果期望绘制的过程由recyclerview内部来进行的话，就不要再重写layoutmanager的onmeasure了。不过对于我们这种大多数时候直接调用linearlayoutmanager的，平时不会太注意这个。

回到这一步上来，大概做了这样几件事

1. 当设置了hasfixedsize时

```
/**
     * RecyclerView can perform several optimizations if it can know in advance that RecyclerView's
     * size is not affected by the adapter contents. RecyclerView can still change its size based
     * on other factors (e.g. its parent's size) but this size calculation cannot depend on the
     * size of its children or contents of its adapter (except the number of items in the adapter).
     * <p>
     * If your use of RecyclerView falls into this category, set this to {@code true}. It will allow
     * RecyclerView to avoid invalidating the whole layout when its adapter contents change.
     *
     * @param hasFixedSize true if adapter changes cannot affect the size of the RecyclerView.
     */
```

也就是当item的大小是固定的，不会出现根据adapter的内容变化的布局，这样recyclerview就会依据某些参数固定下来他的尺寸，并不会在参考其内部数据变化而计算出来的尺寸。算是**优化**的一个注意点

设置了这个参数之后，就会直接甩手给layoutmanager进行onmeasure操作

2. 未设置hasfixedsize时 && adapter在onmeasure过程中正在更新

此时只会做一些状态的更改，lock的重入这样。其lock的标记位实在是太多了，不过的确没有做什么事情，不过此过程如果进行，会跳转到第四步继续下去

3. 未设置hasfixedsize时 && adapter 不在更新 && 目前的状态处在更新之前的动画时

此时会在更新完前一个item动画之后在更新自己，所以此时只做了一个动作，就是提前将宽高的measurespec设置完毕

4. 以上都没有的情况下

首先会调用layoutmanager的onmeasure，之后会清除状态位。

#### 最后一步的一个总结

为什么hasfixedsize起作用呢？

因为当未设置这个的时候，会等待adapter更新结束才会绘制，而adapter的更新会有一系列的等待，等待数据处理结束之后，才会再次做一个更新的操作。
而设置了hasfixedsize之后，就不会等待更新了，而是会直接进行绘制。

另外拷一份关于这个的别人的总结

```
总结：当我们确定Item的改变不会影响RecyclerView的宽高的时候可以设置setHasFixedSize(true)，并通过Adapter的增删改插方法去刷新RecyclerView，而不是通过notifyDataSetChanged()。（其实可以直接设置为true，当需要改变宽高的时候就用notifyDataSetChanged()去整体刷新一下）
--------------------- 
作者：wsdaijianjun 
来源：CSDN 
原文：https://blog.csdn.net/wsdaijianjun/article/details/74735039 
版权声明：本文为博主原创文章，转载请附上博文链接！
```

## onLayout

```
    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        ...
        dispatchLayout();
        ...
    }
```
```
/**
     * Wrapper around layoutChildren() that handles animating changes caused by layout.
     * Animations work on the assumption that there are five different kinds of items
     * in play:
     * PERSISTENT: items are visible before and after layout
     * REMOVED: items were visible before layout and were removed by the app
     * ADDED: items did not exist before layout and were added by the app
     * DISAPPEARING: items exist in the data set before/after, but changed from
     * visible to non-visible in the process of layout (they were moved off
     * screen as a side-effect of other changes)
     * APPEARING: items exist in the data set before/after, but changed from
     * non-visible to visible in the process of layout (they were moved on
     * screen as a side-effect of other changes)
     * The overall approach figures out what items exist before/after layout and
     * infers one of the five above states for each of the items. Then the animations
     * are set up accordingly:
     * PERSISTENT views are animated via
     * {@link ItemAnimator#animatePersistence(ViewHolder, ItemHolderInfo, ItemHolderInfo)}
     * DISAPPEARING views are animated via
     * {@link ItemAnimator#animateDisappearance(ViewHolder, ItemHolderInfo, ItemHolderInfo)}
     * APPEARING views are animated via
     * {@link ItemAnimator#animateAppearance(ViewHolder, ItemHolderInfo, ItemHolderInfo)}
     * and changed views are animated via
     * {@link ItemAnimator#animateChange(ViewHolder, ViewHolder, ItemHolderInfo, ItemHolderInfo)}.
     */
    void dispatchLayout() {
        if (mAdapter == null) {
            Log.e(TAG, "No adapter attached; skipping layout");
            // leave the state in START
            return;
        }
        if (mLayout == null) {
            Log.e(TAG, "No layout manager attached; skipping layout");
            // leave the state in START
            return;
        }
        mState.mIsMeasuring = false;
        if (mState.mLayoutStep == State.STEP_START) {
            dispatchLayoutStep1();
            mLayout.setExactMeasureSpecsFrom(this);
            dispatchLayoutStep2();
        } else if (mAdapterHelper.hasUpdates() || mLayout.getWidth() != getWidth()
                || mLayout.getHeight() != getHeight()) {
            // First 2 steps are done in onMeasure but looks like we have to run again due to
            // changed size.
            mLayout.setExactMeasureSpecsFrom(this);
            dispatchLayoutStep2();
        } else {
            // always make sure we sync them (to ensure mode is exact)
            mLayout.setExactMeasureSpecsFrom(this);
        }
        dispatchLayoutStep3();
    }
```

onlayout的过程相对比较简单，即是直接通过state的状态，来设置目前需要走到哪一步。其中dispatchlayoutstep1和dispatchlayoutstep2都是onmeasure过程中使用到的。

唯一不知道的是dispatchlayoutstep3

```
 /**
     * The final step of the layout where we save the information about views for animations,
     * trigger animations and do any necessary cleanup.
     */
    private void dispatchLayoutStep3() {
        mState.assertLayoutStep(State.STEP_ANIMATIONS);
        eatRequestLayout();
        onEnterLayoutOrScroll();
        mState.mLayoutStep = State.STEP_START;
        if (mState.mRunSimpleAnimations) {
            // Step 3: Find out where things are now, and process change animations.
            // traverse list in reverse because we may call animateChange in the loop which may
            // remove the target view holder.
            for (int i = mChildHelper.getChildCount() - 1; i >= 0; i--) {
                ViewHolder holder = getChildViewHolderInt(mChildHelper.getChildAt(i));
                if (holder.shouldIgnore()) {
                    continue;
                }
                long key = getChangedHolderKey(holder);
                final ItemHolderInfo animationInfo = mItemAnimator
                        .recordPostLayoutInformation(mState, holder);
                ViewHolder oldChangeViewHolder = mViewInfoStore.getFromOldChangeHolders(key);
                if (oldChangeViewHolder != null && !oldChangeViewHolder.shouldIgnore()) {
                    // run a change animation

                    // If an Item is CHANGED but the updated version is disappearing, it creates
                    // a conflicting case.
                    // Since a view that is marked as disappearing is likely to be going out of
                    // bounds, we run a change animation. Both views will be cleaned automatically
                    // once their animations finish.
                    // On the other hand, if it is the same view holder instance, we run a
                    // disappearing animation instead because we are not going to rebind the updated
                    // VH unless it is enforced by the layout manager.
                    final boolean oldDisappearing = mViewInfoStore.isDisappearing(
                            oldChangeViewHolder);
                    final boolean newDisappearing = mViewInfoStore.isDisappearing(holder);
                    if (oldDisappearing && oldChangeViewHolder == holder) {
                        // run disappear animation instead of change
                        mViewInfoStore.addToPostLayout(holder, animationInfo);
                    } else {
                        final ItemHolderInfo preInfo = mViewInfoStore.popFromPreLayout(
                                oldChangeViewHolder);
                        // we add and remove so that any post info is merged.
                        mViewInfoStore.addToPostLayout(holder, animationInfo);
                        ItemHolderInfo postInfo = mViewInfoStore.popFromPostLayout(holder);
                        if (preInfo == null) {
                            handleMissingPreInfoForChangeError(key, holder, oldChangeViewHolder);
                        } else {
                            animateChange(oldChangeViewHolder, holder, preInfo, postInfo,
                                    oldDisappearing, newDisappearing);
                        }
                    }
                } else {
                    mViewInfoStore.addToPostLayout(holder, animationInfo);
                }
            }

            // Step 4: Process view info lists and trigger animations
            mViewInfoStore.process(mViewInfoProcessCallback);
        }

        mLayout.removeAndRecycleScrapInt(mRecycler);
        mState.mPreviousLayoutItemCount = mState.mItemCount;
        mDataSetHasChangedAfterLayout = false;
        mState.mRunSimpleAnimations = false;

        mState.mRunPredictiveAnimations = false;
        mLayout.mRequestedSimpleAnimations = false;
        if (mRecycler.mChangedScrap != null) {
            mRecycler.mChangedScrap.clear();
        }
        if (mLayout.mPrefetchMaxObservedInInitialPrefetch) {
            // Initial prefetch has expanded cache, so reset until next prefetch.
            // This prevents initial prefetches from expanding the cache permanently.
            mLayout.mPrefetchMaxCountObserved = 0;
            mLayout.mPrefetchMaxObservedInInitialPrefetch = false;
            mRecycler.updateViewCacheSize();
        }

        mLayout.onLayoutCompleted(mState);
        onExitLayoutOrScroll();
        resumeRequestLayout(false);
        mViewInfoStore.clear();
        if (didChildRangeChange(mMinMaxLayoutPositions[0], mMinMaxLayoutPositions[1])) {
            dispatchOnScrolled(0, 0);
        }
        recoverFocusFromState();
        resetFocusInfo();
    }
```

这里看上去，能了解几个信息点，首先是处理了动画，在然后是reset了一些状态。这一步和布局没有什么必然的关系。

## 全布局总结

这里我就直接抄了，我的言语也最多总结成这样。


第一步：
处理Adapter的更新
决定哪些动画播放
保存当前View的信息
如果有必要的话再进行上一布局操作，并保存它的信息
```
private void dispatchLayoutStep1() {
    …… // 省略代码，该部分判断状态和更改状态以及保存一些信息
    // 下面这个方法很重要，那么我们先略过，看下下面的内容。哎~我就这么调皮!哈哈，
    // 其实是，在没有讲动画流程之前，根本讲不清。这个是动画流程的中间过程。所以
    // ，在这里只要先知道，这里是处理Adapter更新，并计算动画类型的即可。
    processAdapterUpdatesAndSetAnimationFlags();
    …… // 设置一些状态，保存一些信息。

    // 下面的内容是需要运行动画的情况下进行的，主要做的事情就是找出那些要需要进
    // 行上一布局操作的ViewHolder，并且保存它们的边界信息。如果有更新操作(这个更新
    // 指的是内容的更新，不是插入删除的这种更新)，然后保存这些更新的ViewHolder
    if (mState.mRunSimpleAnimations) {
        …… // 看上面的解释，这里代码都是和动画相关的，暂时懒得放，太占地方
    }
    // 下面的内容是需要在布局结束之后运行动画的情况下执行的。主要做的事情就是
    // 执行上一布局操作，上一布局操作其实就是先以上一次的状态执行一边LayoutManager
    // 的onLayoutChildren方法，其实RecyclerView的布局策略就是在
    // LayoutManager的onLayoutChildren方法中。执行一次它就获得了所有
    // ViewHolder的边界信息。只不过，这次获得的是之前状态下的ViewHolder的
    // 边界信息。不过这个应该是要在LayoutManager中，根据state的isPreLayout
    // 的返回值，选择使用新的还是旧的position。但我在系统给的几个LayoutManager中
    // 都没有看到。
    if (mState.mRunPredictiveAnimations) {
        …… 
        mLayout.onLayoutChildren(mRecycler, mState);
        ……
    }
    …… //恢复状态
}
```


第二步：真正的布局

```
private void dispatchLayoutStep2() {
    …… // 设置状态
    mState.mInPreLayout = false; // 更改此状态，确保不是会执行上一布局操作
    // 真正布局就是这一句话，布局的具体策略交给了LayoutManager，哈哈!这篇的主角讲完了!
    mLayout.onLayoutChildren(mRecycler, mState);
    …… // 设置和恢复状态
}
```

第三步：

保存信息，触发动画，清除垃圾
```
private void dispatchLayoutStep3() {
    …… // 设置状态
    if (mState.mRunSimpleAnimations) {
        …… // 需要动画的情况。找出ViewHolder现在的位置，并且处理改变动画。最后触发动画。
    }

    …… // 清除状态和清除无用的信息
    mLayout.onLayoutCompleted(mState); // 给LayoutManager的布局完成的回调
    …… // 清除状体和清楚无用的信息，最后在恢复一些信息信息，比如焦点。
}
```

# 缓存机制

recyclerview的缓存主要在view的复用

其依赖于
```
final View view = recycler.getViewForPosition(mCurrentPosition);
```

该方法获取了viewholder的itemview

```
/**
         * Obtain a view initialized for the given position.
         *
         * This method should be used by {@link LayoutManager} implementations to obtain
         * views to represent data from an {@link Adapter}.
         * <p>
         * The Recycler may reuse a scrap or detached view from a shared pool if one is
         * available for the correct view type. If the adapter has not indicated that the
         * data at the given position has changed, the Recycler will attempt to hand back
         * a scrap view that was previously initialized for that data without rebinding.
         *
         * @param position Position to obtain a view for
         * @return A view representing the data at <code>position</code> from <code>adapter</code>
         */
        public View getViewForPosition(int position) {
            return getViewForPosition(position, false);
        }

        View getViewForPosition(int position, boolean dryRun) {
            return tryGetViewHolderForPositionByDeadline(position, dryRun, FOREVER_NS).itemView;
        }

        /**
         * Attempts to get the ViewHolder for the given position, either from the Recycler scrap,
         * cache, the RecycledViewPool, or creating it directly.
         * <p>
         * If a deadlineNs other than {@link #FOREVER_NS} is passed, this method early return
         * rather than constructing or binding a ViewHolder if it doesn't think it has time.
         * If a ViewHolder must be constructed and not enough time remains, null is returned. If a
         * ViewHolder is aquired and must be bound but not enough time remains, an unbound holder is
         * returned. Use {@link ViewHolder#isBound()} on the returned object to check for this.
         *
         * @param position Position of ViewHolder to be returned.
         * @param dryRun True if the ViewHolder should not be removed from scrap/cache/
         * @param deadlineNs Time, relative to getNanoTime(), by which bind/create work should
         *                   complete. If FOREVER_NS is passed, this method will not fail to
         *                   create/bind the holder if needed.
         *
         * @return ViewHolder for requested position
         */
        @Nullable
        ViewHolder tryGetViewHolderForPositionByDeadline(int position,
                boolean dryRun, long deadlineNs) {
            if (position < 0 || position >= mState.getItemCount()) {
                throw new IndexOutOfBoundsException("Invalid item position " + position
                        + "(" + position + "). Item count:" + mState.getItemCount()
                        + exceptionLabel());
            }
            boolean fromScrapOrHiddenOrCache = false;
            ViewHolder holder = null;
            // 0) If there is a changed scrap, try to find from there
            if (mState.isPreLayout()) {
                holder = getChangedScrapViewForPosition(position);
                fromScrapOrHiddenOrCache = holder != null;
            }
            // 1) Find by position from scrap/hidden list/cache
            if (holder == null) {
                holder = getScrapOrHiddenOrCachedHolderForPosition(position, dryRun);
                if (holder != null) {
                    if (!validateViewHolderForOffsetPosition(holder)) {
                        // recycle holder (and unscrap if relevant) since it can't be used
                        if (!dryRun) {
                            // we would like to recycle this but need to make sure it is not used by
                            // animation logic etc.
                            holder.addFlags(ViewHolder.FLAG_INVALID);
                            if (holder.isScrap()) {
                                removeDetachedView(holder.itemView, false);
                                holder.unScrap();
                            } else if (holder.wasReturnedFromScrap()) {
                                holder.clearReturnedFromScrapFlag();
                            }
                            recycleViewHolderInternal(holder);
                        }
                        holder = null;
                    } else {
                        fromScrapOrHiddenOrCache = true;
                    }
                }
            }
            if (holder == null) {
                final int offsetPosition = mAdapterHelper.findPositionOffset(position);
                if (offsetPosition < 0 || offsetPosition >= mAdapter.getItemCount()) {
                    throw new IndexOutOfBoundsException("Inconsistency detected. Invalid item "
                            + "position " + position + "(offset:" + offsetPosition + ")."
                            + "state:" + mState.getItemCount() + exceptionLabel());
                }

                final int type = mAdapter.getItemViewType(offsetPosition);
                // 2) Find from scrap/cache via stable ids, if exists
                if (mAdapter.hasStableIds()) {
                    holder = getScrapOrCachedViewForId(mAdapter.getItemId(offsetPosition),
                            type, dryRun);
                    if (holder != null) {
                        // update position
                        holder.mPosition = offsetPosition;
                        fromScrapOrHiddenOrCache = true;
                    }
                }
                if (holder == null && mViewCacheExtension != null) {
                    // We are NOT sending the offsetPosition because LayoutManager does not
                    // know it.
                    final View view = mViewCacheExtension
                            .getViewForPositionAndType(this, position, type);
                    if (view != null) {
                        holder = getChildViewHolder(view);
                        if (holder == null) {
                            throw new IllegalArgumentException("getViewForPositionAndType returned"
                                    + " a view which does not have a ViewHolder"
                                    + exceptionLabel());
                        } else if (holder.shouldIgnore()) {
                            throw new IllegalArgumentException("getViewForPositionAndType returned"
                                    + " a view that is ignored. You must call stopIgnoring before"
                                    + " returning this view." + exceptionLabel());
                        }
                    }
                }
                if (holder == null) { // fallback to pool
                    if (DEBUG) {
                        Log.d(TAG, "tryGetViewHolderForPositionByDeadline("
                                + position + ") fetching from shared pool");
                    }
                    holder = getRecycledViewPool().getRecycledView(type);
                    if (holder != null) {
                        holder.resetInternal();
                        if (FORCE_INVALIDATE_DISPLAY_LIST) {
                            invalidateDisplayListInt(holder);
                        }
                    }
                }
                if (holder == null) {
                    long start = getNanoTime();
                    if (deadlineNs != FOREVER_NS
                            && !mRecyclerPool.willCreateInTime(type, start, deadlineNs)) {
                        // abort - we have a deadline we can't meet
                        return null;
                    }
                    holder = mAdapter.createViewHolder(RecyclerView.this, type);
                    if (ALLOW_THREAD_GAP_WORK) {
                        // only bother finding nested RV if prefetching
                        RecyclerView innerView = findNestedRecyclerView(holder.itemView);
                        if (innerView != null) {
                            holder.mNestedRecyclerView = new WeakReference<>(innerView);
                        }
                    }

                    long end = getNanoTime();
                    mRecyclerPool.factorInCreateTime(type, end - start);
                    if (DEBUG) {
                        Log.d(TAG, "tryGetViewHolderForPositionByDeadline created new ViewHolder");
                    }
                }
            }
```

这段代码写的还是比较容易懂得，其实就是按照顺序去缓存里面寻找viewholder。

缓存的顺序是

1. 状态为预加载时：

    getChangedScrapViewForPosition() -> 从mChangedScrap中找

2. 没找着或者压根没走预加载：

    getScrapOrHiddenOrCachedHolderForPosition() -> 
        从mAttachedScrap中找layoutposition等于该position的
        ->还没找着->从mCachedViews中寻找

3. 还没找着：

    adapter里面有stable id：
        getScrapOrCachedViewForId() -> 从mAttachedScrap中找itemid等于id的
    没找着或adapter里面没有stable id:
        mViewCacheExtension.getViewForPositionAndType() -> 在viewCacheExtension存在的前提下，从对用户扩展的viewCacheExtension中找
    还没找着：
        getRecycledViewPool().getRecycledView() -> 从循环view池里面获取被循环的viewholder，这个循环view池默认也就存5个
    再没找着：
        mAdapter.createViewHolder() ->创建一个viewholder

//吐槽一下：明明是一个问题，为什么if还不嵌套...

![缓存的顺序图，copy自bugly](/images/recyclerview缓存模型.jpg)

## 总结一下：三层缓存

View的detach和remove: 

**detach**: 在ViewGroup中的实现很简单，只是将ChildView**从ParentView的ChildView数组中移除，ChildView的mParent设置为null, 可以理解为轻量级的临时remove, 因为View此时和View树还是藕断丝连, 这个函数被经常用来改变ChildView在ChildView数组中的次序。**View被detach一般是临时的，在后面会被重新attach。

**remove**: 真正的移除，不光被从ChildView数组中除名，其他和View树各项联系也会被彻底斩断(不考虑Animation/LayoutTransition这种特殊情况)， 比如焦点被清除，从TouchTarget中被移除等。


>> Scrap View指的是在RecyclerView中，处于根据数据刷新界面等行为, ChildView被detach(注意这个detach指的是1中介绍的detach行为，而不是RecyclerView一部分注释中的”detach”，RecyclerView一部分注释中的”detach”其实指得是上面的remove)，并且被存储到了Recycler中，这部分ChildView就是Scrap View。


1. 第一级缓存

Scrap View: mAttachedScrap和mChangedScrap
Removeed View: mCachedViews

2. 第二级缓存

ViewCacheExtension(可选可配置)： 供使用者自行扩展，让使用者可以控制缓存

3. 第三级缓存

RecycledViewPool(可配置): RecyclerView之间共享ViewHolder的缓存池













