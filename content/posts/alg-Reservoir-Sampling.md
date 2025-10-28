---
title: "随机算法 - Reservoir Sampling（蓄水池抽样算法）"
date: 2022-02-07T23:17:46+08:00
description: "蓄水池抽样算法练手"
featured_image: "https://pic.danic.tech/blog/bg/bg-16.jpg"
tags:	["算法", "随机"]
---

### 介绍

蓄水池抽样算法一般用于样本大小未知或者超大样本的情况下，流式得进行随机抽样，空间复杂度为常量级，时间复杂度为n。本次代码编写参考自[B站视频](https://www.bilibili.com/video/BV17i4y1j7wE?spm_id_from=333.999.0.0)。



### 代码

跟随题目[382. 链表随机节点](https://leetcode-cn.com/problems/linked-list-random-node/)。

抽样数为一时的解法

```go
import "math/rand"

type ListNode struct {
 	Val int
  Next *ListNode
}

type Solution struct {
	Head *ListNode
}

func Constructor(head *ListNode) Solution {
	return Solution{Head: head}
}

func (this *Solution) GetRandom() int {
	ans := 0
	dummy := &ListNode{Next: this.Head}
	i := 0
	// 遍历链表
	for dummy.Next != nil {
		// 计算随机值
		r := rand.Intn(i+1)
		// 当随机值（ 随机范围为[0,i+1)左闭右开 ）与i相等时，表示需要将当前值替换成为ans，此概率为 1/i (i为遍历的元素个数)
		// 同时也隐性得表示了以 (i-1)/i 的概率决定是否要保留历史值
		if r == i {
			ans = dummy.Next.Val
		}
		i++
		dummy.Next = dummy.Next.Next
	}
	return ans
}
```

抽样数大于一时的解法

```go
import "math/rand"

type ListNode struct {
  Val int
  Next *ListNode
}

type Solution struct {
	Head *ListNode
}

func Constructor(head *ListNode) Solution {
	return Solution{Head: head}
}

func (this *Solution) GetRandomK(k int) []int {
	ans := make([]int, 0)
	dummy := &ListNode{Next: this.Head}
	i := 0
	// 遍历链表
	for dummy.Next != nil {
		// 前i个直接放入数组
		if i < k {
			ans = append(ans, dummy.Next.Val)
		} else {
			// 计算随机值
			r := rand.Intn(i+1)
			// 当随机值r（ 随机范围为[0,i+1)左闭右开 ）小于K时，表示需要将数组中第r个值替换为当前值，此概率为 K/i (i为遍历的元素个数)
			if r < k {
				ans[r] = dummy.Next.Val
			}
		}

		i++
		dummy.Next = dummy.Next.Next
	}
	return ans
}
```





### 相关题目

[LeetCode第28题](https://leetcode-cn.com/problems/linked-list-random-node/)

> #### [382. 链表随机节点](https://leetcode-cn.com/problems/linked-list-random-node/)
>
> 难度中等
>
> 给你一个单链表，随机选择链表的一个节点，并返回相应的节点值。每个节点 **被选中的概率一样** 。
>
> 实现 `Solution` 类：
>
> - `Solution(ListNode head)` 使用整数数组初始化对象。
> - `int getRandom()` 从链表中随机选择一个节点并返回该节点的值。链表中所有节点被选中的概率相等。
>
>  
>
> **示例：**
>
> ![img](https://assets.leetcode.com/uploads/2021/03/16/getrand-linked-list.jpg)
>
> ```
> 输入
> ["Solution", "getRandom", "getRandom", "getRandom", "getRandom", "getRandom"]
> [[[1, 2, 3]], [], [], [], [], []]
> 输出
> [null, 1, 3, 2, 2, 3]
> 
> 解释
> Solution solution = new Solution([1, 2, 3]);
> solution.getRandom(); // 返回 1
> solution.getRandom(); // 返回 3
> solution.getRandom(); // 返回 2
> solution.getRandom(); // 返回 2
> solution.getRandom(); // 返回 3
> // getRandom() 方法应随机返回 1、2、3中的一个，每个元素被返回的概率相等。
> ```
>
>  
>
> **提示：**
>
> - 链表中的节点数在范围 `[1, 104]` 内
> - `-104 <= Node.val <= 104`
> - 至多调用 `getRandom` 方法 `104` 次
>
>  
>
> **进阶：**
>
> - 如果链表非常大且长度未知，该怎么处理？
> - 你能否在不使用额外空间的情况下解决此问题？

