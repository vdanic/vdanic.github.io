---
title: "排序算法 - Merge Sort（归并排序）"
date: 2022-02-09T22:51:03+08:00
description: "归并排序算法练手"
featured_image: "https://pic.danic.tech/blog/bg/bg-18.jpg"
tags:	["算法", "排序", "链表"]
---

### 介绍

归并排序的核心思想是**分治**，效率为O(n logn)。有一种很适用的场景为给链表排序，由于链表的长度未知，无法使用常规的排序算法，而归并排序采用分治的思想，不需要关心具体长度。

本次编码参考自[B站视频](https://www.bilibili.com/video/BV1Ma4y1n7E2?spm_id_from=333.999.0.0)



### 编码

对**数组**进行排序，时间复杂度O(n logn)，空间复杂度O(n)

```go

// 这里的l为闭区间，r为开区间
func MergeSort(arr []int, l, r int) {
	// 只有单个元素，无须排序直接返回
	if r - l <= 1 {
		return
	}

	// 找出中间点，划分区间对左右两个区间进行递归得排序
	mid := l + (r-l) >> 1
	MergeSort(arr, l, mid)
	MergeSort(arr, mid, r)
	Merge(arr, l, mid, r)
}

// 合并两个有序区间
func Merge(arr []int, l, mid, r int) {
	leftArr := make([]int, mid - l)
	rightArr := make([]int, r - mid)
	copy(leftArr, arr[l:mid])
	copy(rightArr, arr[mid:r])
	// 添加哨兵
	leftArr = append(leftArr, math.MaxInt)
	rightArr = append(rightArr, math.MaxInt)

	i, j := 0, 0
	k := l
	for k < r {
		// 一直取最小的元素，插入到原数组
		if leftArr[i] <= rightArr[j] {
			arr[k] = leftArr[i]
			i++
		} else {
			arr[k] = rightArr[j]
			j++
		}
		k++
	}
}

func main() {
	arr := []int{1,2,34,5,2,9,3,4,6,23,5,7,22,14,75,35} 
	MergeSort(arr, 0, len(arr))
	fmt.Println(arr) // 输出 [1 2 2 3 4 5 5 6 7 9 14 22 23 34 35 75]
}
```



对**链表**进行排序，时间复杂度O(n logn)，空间复杂度O(1)

```go
type Node struct {
	Value int
	Next *Node
}

func MergeSort(head *Node) *Node {
	if head.Next == nil {
		return head
	}

	// 快慢指针，用于确定链表中点
	slow, fast := head, head
	prev := slow
	for fast != nil && fast.Next != nil {
		prev = slow
		slow = slow.Next
		fast = fast.Next.Next
	}

	// 找到右区间后，保存并断链
	right := slow
	prev.Next = nil
	// 左区间为head
	left := head
	left = MergeSort(left)
	right = MergeSort(right)
	return Merge(left, right)
}

// 合并两个链表并返回头节点
func Merge(left *Node, right *Node) *Node {
	dummy := &Node{}
	p := dummy
	for left != nil && right != nil {
		if left.Value <= right.Value {
			p.Next = left
			left = left.Next
		} else {
			p.Next = right
			right = right.Next
		}
		p = p.Next
	}
	if left != nil {
		p.Next = left
	}
	if right != nil {
		p.Next = right
	}
	return dummy.Next
}

func main() {
	arr := []int{1,2,34,5,2,9,3,4,6,23,5,7,22,14,75,35}
	head := &Node{}
	p := head
	for _, v := range arr {
		p.Next = &Node{Value: v}
		p = p.Next
	}
	p = MergeSort(head)

	for p != nil {
		fmt.Printf("%d ", p.Value)
		p = p.Next
	}
	// 输出 [1 2 2 3 4 5 5 6 7 9 14 22 23 34 35 75]
	fmt.Println()
}
```



### 相关题目

> #### [剑指 Offer II 077. 链表排序](https://leetcode-cn.com/problems/7WHec2/)
>
> 给定链表的头结点 `head` ，请将其按 **升序** 排列并返回 **排序后的链表** 。
>
> 
>
>  
>
> **示例 1：**
>
> ![img](https://assets.leetcode.com/uploads/2020/09/14/sort_list_1.jpg)
>
> ```
> 输入：head = [4,2,1,3]
> 输出：[1,2,3,4]
> ```
>
> **示例 2：**
>
> ![img](https://assets.leetcode.com/uploads/2020/09/14/sort_list_2.jpg)
>
> ```
> 输入：head = [-1,5,3,4,0]
> 输出：[-1,0,3,4,5]
> ```
>
> **示例 3：**
>
> ```
> 输入：head = []
> 输出：[]
> ```