---
title: "搜索算法 - 数组中的第K个最大元素（快速选择算法）"
date: 2022-02-13T23:31:48+08:00
description: "快速选择算法练手"
featured_image: "https://pic.danic.tech/blog/bg/bg-20.jpg"
tags:	["算法", "搜索"]
---

### 介绍

若需要获取`数组中的第K个最大元素`，一般需要先排序，然后通过下标获取第K个最大元素。但其实可以基于快排的二分思路（即每次递归时都会将数组分为两个区间，且各区间都一定大于或小于中点），在排序选择中就可以确定第K个最大的元素。

代码参考自[https://labuladong.github.io/algo/4/31/128/](https://labuladong.github.io/algo/4/31/128/)。



### 代码

跟随题目[215. 数组中的第K个最大元素](https://leetcode-cn.com/problems/kth-largest-element-in-an-array/)。

```go
func shuffle(arr []int) {
    var r int
    for i := len(arr) - 1; i >= 0; i-- {
        r = rand.Intn(i+1)
        arr[i], arr[r] = arr[r], arr[i]  
    }
}

func findKthLargest(nums []int, k int) int {
    var partition func(arr []int, left, right int)

    ans := -1

    partition = func(arr []int, left, right int) {
        p := arr[left]
        i := left
        j := right
        for {
            for i < j && arr[j] < p {
                j--
            }
            for i < j && arr[i] >= p {
                i++
            }
            if i >= j {
                break
            }
            arr[i], arr[j] = arr[j], arr[i]
        }
        arr[j], arr[left] = arr[left], arr[j]
      
        if j == k - 1 {
            ans = arr[j]
        } else if j > k - 1 {
            partition(arr, left, j-1)
        } else {
            partition(arr, j+1, right)
        }
    }

    // 打乱数组，防止时间复杂度恶化至n方
    shuffle(nums)
    partition(nums, 0, len(nums)-1)
    return ans
}
```



### 相关题目

> [215. 数组中的第K个最大元素](https://leetcode-cn.com/problems/kth-largest-element-in-an-array/)
>
> 给定整数数组 `nums` 和整数 `k`，请返回数组中第 `**k**` 个最大的元素。
>
> 请注意，你需要找的是数组排序后的第 `k` 个最大的元素，而不是第 `k` 个不同的元素。
>
>  
>
> **示例 1:**
>
> ```
> 输入: [3,2,1,5,6,4] 和 k = 2
> 输出: 5
> ```
>
> **示例 2:**
>
> ```
> 输入: [3,2,3,1,2,4,5,5,6] 和 k = 4
> 输出: 4
> ```
>
>  
>
> **提示：**
>
> - `1 <= k <= nums.length <= 104`
> - `-104 <= nums[i] <= 104`