---
title: "数据结构 - 线段树"
date: 2022-04-06T23:12:19+08:00
description: "线段树练手"
featured_image: "https://pic.danic.tech/blog/bg/bg-45.jpg"
tags:	["算法", "数据结构", "树"]
---

### 介绍

线段树是的用来维护 **区间信息** 的数据结构。

线段树可以在O(logn)的时间复杂度内实现单点修改、区间修改、区间查询（区间求和，求区间最大值，求区间最小值）等操作。

代码参考自[博客](https://oi-wiki.org/ds/seg/)、[Leetcode官解方法二](https://leetcode-cn.com/problems/range-sum-query-mutable/solution/qu-yu-he-jian-suo-shu-zu-ke-xiu-gai-by-l-76xj/)。



### 代码

```go
package main

import "fmt"

type SegmentTree []int

// 获取左孩子下标
func (st SegmentTree) Left(i int) int {
	v := i * 2 + 1
	if v >= len(st) {
		return -1
	}
	return v
}

// 获取右孩子下标
func (st SegmentTree) Right(i int) int {
	v := i * 2 + 2
	if v >= len(st) {
		return -1
	}
	return v
}

// 更新线段树
func (st SegmentTree) change(node int, index int, value int, s, e int) {
	if s == e {
		st[node] = value
		return
	}
	mid := s + (e-s)/2
	// 按照范围区间选择左右子树
	if index <= mid {
		st.change(st.Left(node), index, value, s, mid)
	} else {
		st.change(st.Right(node), index, value, mid + 1, e)
	}
	st[node] = st[st.Left(node)] + st[st.Right(node)]
}

// 范围查询
func (st SegmentTree) range_(node int, left, right int, s, e int) int {
	// 如果查询范围与当前的遍历范围匹配，则直接返回
	if left == s && right == e {
		return st[node]
	}

	mid := s + (e-s)/2
	// 若查询范围位于mid左侧（包含mid），则只需要遍历左子树
	if right <= mid {
		return st.range_(st.Left(node), left, right, s, mid)
	}
	// 若查询范围位于mid右侧（不包含mid），则只需要遍历右子树
	if left > mid {
		return st.range_(st.Right(node), left, right, mid + 1, e)
	}
	// 分段遍历，将结果相加后返回
	return st.range_(st.Left(node), left, mid, s, mid) + st.range_(st.Right(node), mid + 1, right, mid + 1, e)
}

func (st SegmentTree) build(nums []int, node int, s, e int) {
	if s == e {
		st[node] = nums[s]
		return
	}
	mid := s + (e-s)/2
	left := st.Left(node)
	right := st.Right(node)
	st.build(nums, left, s, mid)
	st.build(nums, right, mid + 1, e)
	st[node] = st[left] + st[right]
}

func (st SegmentTree) Update(index int, value int) {
	st.change(0, index, value, 0, len(st)/4-1)
}

func (st SegmentTree) Range(left, right int) int {
	return st.range_(0, left, right, 0, len(st)/4-1)
}

func (st SegmentTree) LevelTravel() {
	fmt.Println("层序遍历线段树: ")
	q := make([]int, 0)
	q = append(q, 0)
	depth := 0
	for len(q) != 0 {
		length := len(q)
		fmt.Printf("%d: ", depth)
		for ; length > 0; length-- {
			head := q[0]
			fmt.Printf("%d ", st[head])
			q = q[1:]
			if st.Left(head) != -1 {
				q = append(q, st.Left(head))
			}
			if st.Right(head) != -1 {
				q = append(q, st.Right(head))
			}
		}
		depth++
		fmt.Println()
	}
	fmt.Println()
}

func InitializeSegmentTree(nums []int) SegmentTree {
	n := len(nums)
	st := SegmentTree{}
	st = make([]int, 4 * n)
	st.build(nums, 0, 0, n - 1)
	return st
}

func main() {
	nums := []int{1,2,3,4,5,6,7}
	fmt.Println("初始化数组:", nums, "\n")
	st := InitializeSegmentTree(nums)
	st.LevelTravel()
	fmt.Println("[0,3]范围和:", st.Range(0, 3))
	fmt.Println("修改[1]为20后: ")
	st.Update(1, 20)
	st.LevelTravel()
	fmt.Println("[0,3]范围和:", st.Range(0, 3))
}
```



最后通过输出可以看到线段树的基本功能均可正常使用

> 初始化数组: [1 2 3 4 5 6 7] 
>
> 层序遍历线段树: 
> 0: 28 
> 1: 10 18 
> 2: 3 7 11 7 
> 3: 1 2 3 4 5 6 0 0 
> 4: 0 0 0 0 0 0 0 0 0 0 0 0 0 
>
> [0,3]范围和: 10
> 修改[1]为20后: 
> 层序遍历线段树: 
> 0: 46 
> 1: 28 18 
> 2: 21 7 11 7 
> 3: 1 20 3 4 5 6 0 0 
> 4: 0 0 0 0 0 0 0 0 0 0 0 0 0 
>
> [0,3]范围和: 28



### 相关题目

> #### [307. 区域和检索 - 数组可修改](https://leetcode-cn.com/problems/range-sum-query-mutable/)
>
> 难度中等482
>
> 给你一个数组 `nums` ，请你完成两类查询。
>
> 1. 其中一类查询要求 **更新** 数组 `nums` 下标对应的值
> 2. 另一类查询要求返回数组 `nums` 中索引 `left` 和索引 `right` 之间（ **包含** ）的nums元素的 **和** ，其中 `left <= right`
>
> 实现 `NumArray` 类：
>
> - `NumArray(int[] nums)` 用整数数组 `nums` 初始化对象
> - `void update(int index, int val)` 将 `nums[index]` 的值 **更新** 为 `val`
> - `int sumRange(int left, int right)` 返回数组 `nums` 中索引 `left` 和索引 `right` 之间（ **包含** ）的nums元素的 **和** （即，`nums[left] + nums[left + 1], ..., nums[right]`）
>
>  
>
> **示例 1：**
>
> ```
> 输入：
> ["NumArray", "sumRange", "update", "sumRange"]
> [[[1, 3, 5]], [0, 2], [1, 2], [0, 2]]
> 输出：
> [null, 9, null, 8]
> 
> 解释：
> NumArray numArray = new NumArray([1, 3, 5]);
> numArray.sumRange(0, 2); // 返回 1 + 3 + 5 = 9
> numArray.update(1, 2);   // nums = [1,2,5]
> numArray.sumRange(0, 2); // 返回 1 + 2 + 5 = 8
> ```
>
>  
>
> **提示：**
>
> - `1 <= nums.length <= 3 * 104`
> - `-100 <= nums[i] <= 100`
> - `0 <= index < nums.length`
> - `-100 <= val <= 100`
> - `0 <= left <= right < nums.length`
> - 调用 `update` 和 `sumRange` 方法次数不大于 `3 * 104`