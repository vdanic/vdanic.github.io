---
title: "分类算法 - Three Way Partition(三分法)"
date: 2022-02-16T23:16:30+08:00
description: "Three Way Partition(三分法)算法练手"
featured_image: "https://pic.danic.tech/blog/bg/bg-21.jpg"
tags:	["算法", "分类"]
---

### 介绍

**Three Way Partition(三分法)**可以在O(n)的时间复杂度内将一个数据分为3个部分，需要注意的是**三分法**是分类，并不是排序，例如有一个数组为`3, 5, 2, 7, 6, 4, 2, 8, 8, 9, 0`，可以以`4`为中间值，将数组分为两个部分`3, 2, 0, 2, 4, | 8, 7, 8, 9, 6, 5`，也可以以`4-7`大小范围的值作为中间值，将数组分为三个部分`3, 2, 0, 2, | 4, 6, 5, 7, | 8, 8, 9`。

代码参考自[StackOverflow](https://stackoverflow.com/questions/941447/quicksort-with-3-way-partition)、[LeetCode题解](https://leetcode-cn.com/problems/wiggle-sort-ii/solution/)。



### 代码

```go
func ThreeWayPartition(arr []int, midLeft int, midRight int) {
	// 定义三个指针
  // i用于标记处于中间范围的值，即 midLeft <= arr[i] <= midRight
	i, j, k := 0, 0, len(arr)-1
  
  // 过程类似快排，保证所有元素都遍历过去
  for j <= k {
    if arr[j] > midRight {
    	// 若j指向的值大于中间范围，则和k进行交换，保证大于范围的值位于右侧
      arr[j], arr[k] = arr[k], arr[j]
      // 这里只移动k，不移动j，目的是为了能在下一次循环中比较从k换过来的值
      k--
    } else if arr[j] < midLeft {
      // 若j指向的值小于中间范围，则和i进行交换，保证小于范围的值位于左侧
      arr[j], arr[i] = arr[i], arr[j]
      // 此时可以确认i是小于范围的，自信++
      i++
      // 换上来的数据也肯定是经过筛选，不用再次参与循环，自信++
      j++
    } else {
      // 若j指向的值位于中间范围，跳过
      j++
    }
  }
}

func main() {
	nums := []int{1,2,6,3,7,8,3,9,3,2}
	fmt.Println(nums) // 输出 1 2 6 3 7 8 3 9 3 2
	ThreeWayPartition(nums, 3, 6)
	fmt.Println(nums) // 输出 1 2 2 3 6 3 3 9 8 7
}
```

可以看到，分类后的数据被划分成三个区间`1,2,2,|3,6,3,3|,9,8,7`。

如果只是想将数据分为两部分，且中间部分的值保持一致，例如将`1,2,6,3,7,8,3,9,3,2`，划分为`1,2,2,|3,3,3|,9,8,7,6`，则可以将传参的边界值都改为`3`。



### 相关题目

> #### [324. 摆动排序 II](https://leetcode-cn.com/problems/wiggle-sort-ii/)
>
> 难度中等
>
> 给你一个整数数组 `nums`，将它重新排列成 `nums[0] < nums[1] > nums[2] < nums[3]...` 的顺序。
>
> 你可以假设所有输入数组都可以得到满足题目要求的结果。
>
>  
>
> **示例 1：**
>
> ```
> 输入：nums = [1,5,1,1,6,4]
> 输出：[1,6,1,5,1,4]
> 解释：[1,4,1,5,1,6] 同样是符合题目要求的结果，可以被判题程序接受。
> ```
>
> **示例 2：**
>
> ```
> 输入：nums = [1,3,2,2,3,1]
> 输出：[2,3,1,3,1,2]
> ```
>
>  
>
> **提示：**
>
> - `1 <= nums.length <= 5 * 104`
> - `0 <= nums[i] <= 5000`
> - 题目数据保证，对于给定的输入 `nums` ，总能产生满足题目要求的结果
>
>  
>
> **进阶：**你能用 O(n) 时间复杂度和 / 或原地 O(1) 额外空间来实现吗？

解：

```go
// 快速选择算法
func partition (nums []int, k, left, right int) int {
	if left == right {
		return nums[left]
	}
	l, r := left, right
	p := nums[left]

	for l < r {
		// 右侧找比p小的值
		for l < r && nums[r] > p {
			r--
		}
		for l < r && nums[l] <= p {
			l++
		}
		if l >= r {
			break
		}
		nums[l], nums[r] = nums[r], nums[l]
	}

	nums[l], nums[left] = nums[left], nums[l]

	if l == k {
		return nums[l]
	} else if l < k {
		return partition(nums, k, l+1, right)
	} else {
		return partition(nums, k, left, l-1)
	}
}

// 使用快速选择算法返回第K大的数(K从0开始计数)
func KMax(nums []int, k int) int {
	return partition(nums, k, 0, len(nums)-1)
}

// 使用三分法将数组分为三份
func ThreeWayPartition(nums []int, target int) {
	i, j, k := 0, 0, len(nums)-1
	for j <= k {
		if nums[j] > target {
			nums[j], nums[k] = nums[k], nums[j]
			k--
		} else if nums[j] < target {
			nums[j], nums[i] = nums[i], nums[j]
			i++
			j++
		} else {
			j++
		}
	}
	return
}

func wiggleSort(nums []int)  {
	ans := make([]int, 0)
	// 向下取中间的序号，6取2、7取3这样
	midIndex := (len(nums) - 1) / 2
	// 获取中间元素
	midNum := KMax(nums, midIndex)
	// 以mid为中心三分数组
	ThreeWayPartition(nums, midNum)
	// 以中间序号为切分点，切分成两个数组，倒序插入两个数组的元素
	l, r := midIndex, len(nums) - 1
	for l >= 0 || r > midIndex {
		if l >= 0 {
			ans = append(ans, nums[l])
			l--
		}
		if r > midIndex {
			ans = append(ans, nums[r])
			r--
		}
	}

	copy(nums, ans)
}
```

