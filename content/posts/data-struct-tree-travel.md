---
title: "数据结构 - 使用栈遍历二叉树"
date: 2022-02-12T22:20:13+08:00
description: "练手使用栈遍历二叉树"
featured_image: "https://pic.danic.tech/blog/bg/bg-24.jpg"
tags:	["算法", "数据结构"]
---

### 介绍

常见的二叉树遍历方式为递归实现先序、中序、后序遍历操作，比较容易理解并且编码，递归其实也是依赖系统提供的方法栈进行的操作。其实我们也可以自己维护一个栈，对二叉树进行遍历操作，且可以很方便得实现遍历流程的终止行为。



### 代码

```go

type Node struct {
	Left *Node
	Right *Node
	Value int
}

type Tree struct {
	Root *Node
}

// 使用栈模拟先根遍历
func (t *Tree) PreOrderTravel(cb func (*Node)) {
	stack := make([]*Node, 0)
	n := t.Root

	for len(stack) != 0 || n != nil {
		// 循环遍历左子树，将节点入栈
		for n != nil {
			stack = append(stack, n)
			// 此时可对加入的元素进行操作，即为先根操作
			cb(n)
			n = n.Left
		}
		// 此时栈顶的节点是没有左子树的
		// 取出并将指针指向右孩子
		top := stack[len(stack)-1]
		stack = stack[:len(stack)-1]
		n = top.Right
	}
}

// 使用栈模拟中根遍历
func (t *Tree) InOrderTravel(cb func (*Node)) {
	stack := make([]*Node, 0)
	n := t.Root

	for len(stack) != 0 || n != nil {
		// 循环遍历左子树，将节点入栈
		for n != nil {
			stack = append(stack, n)
			n = n.Left
		}
		// 此时栈顶的节点是没有左子树的
		// 取出后可做操作，此时为中根操作
		// 例如：对于叶子节点A来说，A是其父节点（根）的左孩子，因此在此步会先于父节点被取出操作，符合 左、根、右
		top := stack[len(stack)-1]
		stack = stack[:len(stack)-1]
		cb(top)
		// 操作结束后将指针指向右孩子
		n = top.Right
	}
}

// 使用栈模拟后根遍历
func (t *Tree) PostOrderTravel(cb func (*Node)) {
	stack := make([]*Node, 0)
	n := t.Root
	// 用于标记上一次遍历节点的指针
	var prev *Node

	for len(stack) != 0 || n != nil {
		// 循环遍历左子树，将节点入栈
		for n != nil {
			stack = append(stack, n)
			n = n.Left
		}
		// 查看栈顶节点，若其没有右孩子，或者右孩子已经遍历过了（prev指针标记），则从栈顶弹出
		// 弹出时可以对弹出的节点做后根操作
		top := stack[len(stack)-1]
		if top.Right == nil || top.Right == prev {
			stack = stack[:len(stack)-1]
			cb(top)
			// 标记当前节点的左右子树均已遍历过
			prev = top
		} else {
			// 存在右孩子且右孩子还未被遍历，则往右子树遍历
			n = top.Right
		}
	}

}

func main() {
	// 定义一个先根遍历时顺序为1,2,3,4,5,6,7的二叉树
	// 			 1
	// 		2		 5
	// 	3  4  6  7
	root := &Node{Value: 1, Left: &Node{Value: 2, Left: &Node{Value: 3}, Right: &Node{Value: 4}}, Right: &Node{Value: 5, Left: &Node{Value: 6}, Right: &Node{Value: 7}}}
	tree := &Tree{Root: root}
	// 定义遍历时的操作函数
	var print = func(n *Node) {
		fmt.Printf("%d ", n.Value)
	}

	// 先根遍历
	tree.PreOrderTravel(print) // 输出 1 2 3 4 5 6 7
	fmt.Println()

	// 中根遍历
	tree.InOrderTravel(print) // 输出 3 2 4 1 6 5 7
	fmt.Println()

	// 后根遍历
	tree.PostOrderTravel(print) // 输出 3 4 2 6 7 5 1
	fmt.Println()
}
```



