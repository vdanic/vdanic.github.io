---
title: 数据结构 - 二叉堆（优先队列）
date: 2022-01-27T23:38:25+08:00
description: "二叉堆（优先队列）练手"
featured_image: "https://pic.danic.tech/blog/bg/bg-13.jpg"
tags:	["算法", "数据结构"]
---

### 介绍

二叉堆的特性

- 根节点的值要比所有子树的值都小（小顶堆）
- 每个节点的左子树及右子树都是二叉堆
- 是一棵完全二叉树，因此比较适合使用数组作为存储



基于二叉堆的特性，只要实现在插入节点及弹出节点时维护二叉堆的特性即可实现**优先队列**，可以通过以下步骤实现（均以小顶堆为例）。

**插入元素时**：在末尾插入，之后再一层一层往上比较插入的节点与其父节点的大小，若插入的元素更小，则和父元素交换，直到条件不满足。

**弹出节点时**：将堆顶节点与末尾节点交换，之后再一层一层往下比较堆顶元素与其左右节点值得大小，若存在比父节点值小的左右子节点，则交换之并继续往下比较，直到条件不满足



### 代码

```go
package main

import "fmt"

// 堆节点
type Node struct {
	Value int
}

// 使用数组实现二叉堆
type Heap struct {
	Tree []*Node
}

// 定义获取父节点下标
func (h *Heap) Parent(i int) int {
	if i == 0 {
		return -1
	}
	return (i - 1) / 2
}

// 定义获取左右子节点下标
func (h *Heap) Left(i int) int {
	left := i * 2 + 1
	if left > len(h.Tree) {
		return -1
	}
	return left
}

func (h *Heap) Right(i int) int {
	right := i * 2 + 2
	if right > len(h.Tree) {
		return -1
	}
	return right
}

// 通过下标交换两元素
func (h *Heap) Swap(i, j int) {
	if i >= len(h.Tree) || j >= len(h.Tree) {
		return
	}

	h.Tree[i], h.Tree[j] = h.Tree[j], h.Tree[i]
}

// 定义比较函数
func (h *Heap) Less(i, j int) bool {
	// 这里定义的逻辑是按照小顶堆定义的，将最小的元素放在堆顶
	return h.Tree[i].Value < h.Tree[j].Value
}

// 上浮，在插入节点后使用。
// 调用前需要先插入数据。
func (h *Heap) Swim() {
	var parent, cur int
	// 取末尾上浮
	cur = len(h.Tree) - 1
	for {
		parent = h.Parent(cur)
		// 通过Less函数比较当前节点与父节点的值，决定是否交换。
		if parent == -1 || !h.Less(cur, parent) {
			break
		}

		h.Swap(cur, parent)
		cur = parent
	}
}

// 下沉，在删除节点时使用。
// 调用前需先将末尾节点与堆顶交换，然后通过Less函数比较下沉堆顶节点。
func (h *Heap) Sink() {
	var l, r, target, cur, tail int
	cur = 0
	// 末尾节点下标，末尾节点不参与比较
	tail = len(h.Tree) - 1
	for {
		l, r = h.Left(cur), h.Right(cur)
		target = l
		// 由于二叉堆是完全二叉树，因此可以保证，当左子树不存在是，那么右子树也必定不存在
		// 即当前节点为叶子节点，可以退出下沉操作
		if l == -1 || l >= tail {
			break
		}
		if r != -1 && r < tail && h.Less(r, l) {
			// 当r比l更满足要求（Less函数）时，替换r
			target = r
		}
		// 当target比cur更满足需求（Less函数）时，表示需要下沉，反之退出循环
		if h.Less(target, cur) {
			h.Swap(target, cur)
			cur = target
		} else {
			break
		}
	}
}

// 插入数据
func (h *Heap) Push(value int) {
	// 插入时需要将节点放置树的末尾，然后让其上浮
	h.Tree = append(h.Tree, &Node{Value: value})
	h.Swim()
}

// 弹出数据
func (h *Heap) Pop() *Node {
	root, tail := 0, len(h.Tree) - 1
	h.Swap(root, tail)
	h.Sink()
	// 末尾节点即为需要出栈的元素
	n := h.Tree[tail]
	// 出栈后需要删除末尾节点
	h.Tree = h.Tree[:tail]
	return n
}

func main() {
	h := &Heap{Tree: make([]*Node, 0)}

	h.Push(10)
	h.Push(9)
	h.Push(7)
	h.Push(6)
	h.Push(6)
	h.Push(4)
	h.Push(8)

	for len(h.Tree) != 0 {
		fmt.Printf("%d ", h.Pop().Value)
	}
	fmt.Println()
}
```

执行后便可以看到元素按照从小到大的顺序输出`4 4 6 7 8 9 10`

如果想要实现大顶堆，则只需要修改Less函数的比较关系即可。



### 相关题目

[https://leetcode-cn.com/problems/sliding-window-maximum/](https://leetcode-cn.com/problems/sliding-window-maximum/)

LeetCode第239题

> #### [239. 滑动窗口最大值](https://leetcode-cn.com/problems/sliding-window-maximum/)
>
> 难度困难1377收藏分享切换为英文接收动态反馈
>
> 给你一个整数数组 `nums`，有一个大小为 `k` 的滑动窗口从数组的最左侧移动到数组的最右侧。你只可以看到在滑动窗口内的 `k` 个数字。滑动窗口每次只向右移动一位。
>
> 返回 *滑动窗口中的最大值* 。
>
>  
>
> **示例 1：**
>
> ```
> 输入：nums = [1,3,-1,-3,5,3,6,7], k = 3
> 输出：[3,3,5,5,6,7]
> 解释：
> 滑动窗口的位置                最大值
> ---------------               -----
> [1  3  -1] -3  5  3  6  7       3
>  1 [3  -1  -3] 5  3  6  7       3
>  1  3 [-1  -3  5] 3  6  7       5
>  1  3  -1 [-3  5  3] 6  7       5
>  1  3  -1  -3 [5  3  6] 7       6
>  1  3  -1  -3  5 [3  6  7]      7
> ```
>
> **示例 2：**
>
> ```
> 输入：nums = [1], k = 1
> 输出：[1]
> ```
>
>  
>
> **提示：**
>
> - `1 <= nums.length <= 105`
> - `-104 <= nums[i] <= 104`
> - `1 <= k <= nums.length



如题需要获取滑动窗口内的最大值，可以使用大顶堆去维护滑动窗口中出现过的值，然后每次滑动时去取堆顶元素即可。这里有一个需要注意的地方是，当堆顶元素位于滑动窗口外时，需要手动Pop掉。