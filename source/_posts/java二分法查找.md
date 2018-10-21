---
title: java二分法查找
date: 2018-02-21 23:05:47
tags: 算法
---
数据量很大的时候，且数据量有序不重复的情景下，可以使用二分查找法。

# 算法思想

假定在一串数组中，需要查找x，该数组升序，该数组长度为k，可以先比较x与中间位置及k/2-1处的值进行比对，相等则查找成功，不想等时，若x大于中间值，则从后半段进行相同操作。依次递归。

# 空间复杂度

o（n）

# 时间复杂度

最坏情况，第一个元素或者最后一个元素是需要查找的元素，时间复杂度为O(log2n)
最好情况，O(1)

# 算法实现思想

例：在有序的有N个元素的数组中查找用户输进去的数据x。
算法如下：
1.确定查找范围front=0，end=N-1，计算中项mid=（front+end）/2。
2.若a[mid]=x或front>=end,则结束查找；否则，向下继续。
3.若a[mid] < x,说明待查找的元素值只可能在比中项元素大的范围内，则把mid+1的值赋给front，并重新计算mid，转去执行步骤2；若a[mid]>x，说明待查找的元素值只可能在比中项元素小的范围内，则把mid-1的值赋给end，并重新计算mid，转去执行步骤2。


# java实现

```
public static int binary(int[] array, int value)
    {
        int low = 0;
        int high = array.length - 1;
        while(low <= high)
        {
            int middle = (low + high) / 2;
            if(value == array[middle])
            {
                return middle;
            }
            if(value > array[middle])
            {
                low = middle + 1;
            }
            if(value < array[middle])
            {
                high = middle - 1;
            }
        }
        return -1;
    }
```
