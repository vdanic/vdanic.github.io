---
title: "数据结构 - 线段树 动态开点"
date: 2022-07-20T22:55:03+08:00
description: "线段树（动态开点）练手"
featured_image: "https://pic.danic.tech/blog/bg/bg-26.jpg"
tags:	["数据结构", "树", "区间问题"]
---

### 介绍

正常线段树写法都需要为区间范围内的数据创建`4*n`大小的空间，当遇到某些数据范围超大的场景的，可能会造成内存爆掉的问题，因此可以采用动态开点的方式编写线段树，使空间动态增长，其原理主要是使用`懒标记`与`标记下推`的技巧，代码参考自[Leetcode题解](https://leetcode.cn/problems/range-sum-query-mutable/solution/by-lfool-v3x9/)。



### 代码

```go
package main

import "fmt"
type Node struct {
	// 左右区间
	left *Node
	right *Node

	value int
	// 懒标记
	add int
}

// 懒标记下推
func (n *Node) PushDown(leftCnt, rightCnt int) {
	// 若不存在左右节点，创建之
	if n.left == nil {
		n.left = &Node{}
	}
	if n.right == nil {
		n.right = &Node{}
	}

	// 若不存在懒标记，退出
	if n.add == 0 {
		return
	}

	// 存在懒标记，下推至左右节点，并清除自身的懒标记
  // 若是区间覆盖操作，则value与add都不需要累加
  // 若是区间加减操作，则value与add都需要累加
	n.left.value += n.add * leftCnt // 求区间和时，需要给value加上对应区间节点个数*懒标记值。若求最值，则只需加上懒标记值
	n.right.value += n.add * rightCnt
	n.left.add += n.add
	n.right.add += n.add
	n.add = 0
}

// 数据聚合
func (n *Node) PushUp() {
	// 可根据【求区间和】或【求区间最值】的场景更换代码
	n.value = n.left.value + n.right.value
}

// 区间更新操作，delta为对区间的操作数值
func (n *Node) _update(l, r int, delta int, s, e int) {
	// 若当前段（[s,e]）位于更新区间（[l,r]），则直接更新value、add
	if s >= l && e <= r {
    // 若是区间覆盖操作，则value与add都不需要累加
    // 若是区间加减操作，则value与add都需要累加
		n.value += delta * (e-s+1) // 求区间和时，需要加上区间内节点数量*delta。若是求区间最值，则只需要加delta
		n.add += delta
		return
	}
	m := s + (e-s) >> 1
	// 尝试下推，左区间节点数为m-s+1，右区间节点数为e-m
	n.PushDown(m-s+1, e-m)
	// 更新左区间
	if l <= m {
		n.left._update(l, r, delta, s, m)
	}
	// 更新右区间
	if r > m {
		n.right._update(l, r, delta, m+1, e)
	}
	// 数据聚合
	n.PushUp()
}

// 区间查询操作
func (n *Node) _query(l, r int, s, e int) int {
	// 若当前段（[s,e]）位于查询区间（[l,r]），则直接返回
	if s >= l && e <= r {
		return n.value
	}
	m := s + (e-s) >> 1
	// 尝试下推，左区间节点数为m-s+1，右区间节点数位e-m
	n.PushDown(m-s+1, e-m)
	sum := 0
	// 查询左区间
	if l <= m {
		sum += n.left._query(l, r, s, m) // 若求最值，需替换逻辑
	}
	if r > m {
		sum += n.right._query(l, r, m+1, e)
	}
	return sum
}

func (n *Node) Update(l, r int, delta int) {
	n._update(l, r, delta, 0, int(1e9))
}

func (n *Node) Query(l, r int) int {
	return n._query(l, r, 0, int(1e9))
}

func Constructor(nums []int) Node {
	n := Node{}
	for i := range nums {
		n.Update(i,i, nums[i])
	}
	return n
}

func main() {
	root := Constructor([]int{1,2,3,4,5})
	fmt.Println(root.Query(0,4)) // 输出15
	root.Update(0, 2, 1)
	fmt.Println(root.Query(0,4)) // 输出18
	fmt.Println(root.Query(0,2)) // 输出9
}
```



### 相关题目

> #### [732. 我的日程安排表 III](https://leetcode.cn/problems/my-calendar-iii/)
>
> 
>
> 当 `k` 个日程安排有一些时间上的交叉时（例如 `k` 个日程安排都在同一时间内），就会产生 `k` 次预订。
>
> 给你一些日程安排 `[start, end)` ，请你在每个日程安排添加后，返回一个整数 `k` ，表示所有先前日程安排会产生的最大 `k` 次预订。
>
> 实现一个 `MyCalendarThree` 类来存放你的日程安排，你可以一直添加新的日程安排。
>
> - `MyCalendarThree()` 初始化对象。
> - `int book(int start, int end)` 返回一个整数 `k` ，表示日历中存在的 `k` 次预订的最大值。
>
>  
>
> **示例：**
>
> ```
> 输入：
> ["MyCalendarThree", "book", "book", "book", "book", "book", "book"]
> [[], [10, 20], [50, 60], [10, 40], [5, 15], [5, 10], [25, 55]]
> 输出：
> [null, 1, 1, 2, 3, 3, 3]
> 
> 解释：
> MyCalendarThree myCalendarThree = new MyCalendarThree();
> myCalendarThree.book(10, 20); // 返回 1 ，第一个日程安排可以预订并且不存在相交，所以最大 k 次预订是 1 次预订。
> myCalendarThree.book(50, 60); // 返回 1 ，第二个日程安排可以预订并且不存在相交，所以最大 k 次预订是 1 次预订。
> myCalendarThree.book(10, 40); // 返回 2 ，第三个日程安排 [10, 40) 与第一个日程安排相交，所以最大 k 次预订是 2 次预订。
> myCalendarThree.book(5, 15); // 返回 3 ，剩下的日程安排的最大 k 次预订是 3 次预订。
> myCalendarThree.book(5, 10); // 返回 3
> myCalendarThree.book(25, 55); // 返回 3
> ```
>
>  
>
> **提示：**
>
> - `0 <= start < end <= 109`
> - 每个测试用例，调用 `book` 函数最多不超过 `400`次