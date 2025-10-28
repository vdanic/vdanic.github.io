---
title: 快速排序算法分析
date: 2017-05-24 15:17:42
tags: ["算法", "排序"]
featured_image: "https://pic.danic.tech/blog/bg/bg-08.jpg"
---

 快速排序算法是一个很经典的算法，让我们一起来研究研究该算法的思想。

### 思路

 1. 在要被排序的数据集中，找出一个`基准`(pivot) <span style="color: #888"> // 一般会选择数据集中的第一个数或中间数作为基准</span>
 1. 将比`基准`小的数放在`基准`的左边，将比`基准`大的数放在`基准`的右边
 1. 递归地重复第一步和第二步，直到所以子集只剩下一个元素。

<!-- more -->


 ![Quick Sort](http://pic.danic.tech/sort/quicksort.png)

### 代码实现

```java

import java.util.Arrays;

public class QuickSort {

    public static void quickSort(int arr[]) {
        sort(arr, 0, arr.length - 1);
    }

    public static void sort(int arr[], int left, int right) {

        if(left >= right) {
            return;
        }

        int pivot = arr[left]; // 取子集中左边第一个数为基准
        int i = left;
        int j = right;

        while(i < j) {

            while(i < j && arr[j] >= pivot) {   // j从右边开始寻找一个比基准小的数
                j--;
            }

            if(i < j) { // 执行到这里，即j已经找到了一个数比基准小，且i和j未相遇
                arr[i++] = arr[j];    // 将j所指向的数，填入i所指向的格子
            }

            while(i < j && arr[i] < pivot) {    // i从左边开始寻找一个比基准大或等于基准的数
                i++;
            }

            if(i < j) { // 执行到这里，即i已经找到了一个数比基准大或相等，且i和j未相遇
                arr[j--] = arr[i];    // 将i所指向的数，填入j所指向的格子
            }

        }

        arr[i] = pivot;     // 将基准填回arr[i]
        sort(arr, left, i - 1);     // 对左边的子集进行递归排序
        sort(arr, i + 1, right);    // 对右边的子集进行递归排序

    }

    public static void main(String[] args) {

        int a[] = { 16, 23, 5, 15, 14, 16, 5, 33 }; // 输出 [5, 5, 14, 15, 16, 16, 23, 33]
        quickSort(a);
        System.out.println(Arrays.toString(a));
    }

}


```


### 为什么它会比较快？

 相比于冒泡排序的`相邻数比较大小并交换`，快速排序的交换是`跳跃进行`的。即在每次排序的时候，都设置一个基准，并将小于基准的数全部放到基准的左边，将大于等于基准的数全部放在基准右边，总的交换次数就少了，速度也会提升。但在最坏的情况下，还是需要相邻的两个数进行交换。因此快速排序的最坏时间复杂度和冒泡排序都是0(N2) ，平均时间复杂度为O(NlogN)。
