---
title: 数据结构 - LRU
date: 2022-01-26 0:20:59
description: "LRU算法(Least Recently Used)练手"
featured_image: "https://pic.danic.tech/blog/bg/bg-photo.jpg"
tags:	["算法", "数据结构"]
---

### 介绍

LRU算法(Least Recently Used)，即最近最少使用算法，一般用于缓存设计中，当内存用满时，将最少使用的缓存页给删除，然后再加载新的缓存页。

之前研究Java的LinkedHashMap，其内部也是实现了一套LRU算法，因此借鉴其代码并简化。

<!--more-->

### 代码

```go

type Node struct {
	Key int
	Value int
	// LRU链表的两个主要字段，在Node对象中维护这个链表
	Before *Node
	After *Node
}

// 断开当前节点的前后链
func (n *Node) Detach() {
	if n.After != nil {
		n.After.Before = n.Before
	}
	if n .Before != nil {
		n.Before.After = n.After
	}
	n.After = nil
	n.Before = nil
}

// 更新当前节点的使用情况
// 我们定义，在head后的节点为最近被使用过的节点
// 在head前的节点为最久未被使用的节点
func (n *Node) ReNew(head *Node) {
	// 先断链
	n.Detach()
	// 再在head后插入节点
	n.After = head.After
	n.After.Before = n
	n.Before = head
	n.Before.After = n
}

type LRUCache struct {
	Head *Node
	Entries map[int]*Node
	Length int
	Capacity int
}


func Constructor(capacity int) LRUCache {
	// 构造head，自身成环
	head := &Node{}
	head.Before = head
	head.After = head

	return LRUCache {
		Head: head,
		Entries: make(map[int]*Node),
		Length: 0,
		Capacity: capacity,
	}
}


func (this *LRUCache) Get(key int) int {
	// 如果存在则刷新使用情况并返回，反之返回-1
	if _, ok := this.Entries[key]; ok {
		n := this.Entries[key]
		n.ReNew(this.Head)
		return n.Value
	}
	return -1
}


func (this *LRUCache) Put(key int, value int)  {
	// 如果存在则更新数据，同时更新使用情况，反之插入数据
	if _, ok := this.Entries[key]; ok {
		n := this.Entries[key]
		n.Value = value
		n.ReNew(this.Head)
	} else {
		// 如果Cache大小刚到等于容量，那么新加入的节点势必会造成空间不足，删除最后未被使用的节点
		if this.Length == this.Capacity {
			removed := this.Head.Before
			removed.Detach()
			delete(this.Entries, removed.Key)
			this.Length--
		}

		n := &Node{Key: key, Value: value}
		n.ReNew(this.Head)
		this.Entries[key] = n
		this.Length++
	}

}
```



### 相关题目

[https://leetcode-cn.com/problems/lru-cache/](https://leetcode-cn.com/problems/lru-cache/)

LeetCode第146题

> #### [146. LRU 缓存](https://leetcode-cn.com/problems/lru-cache/)
>
> 难度中等1866收藏分享切换为英文接收动态反馈
>
> 请你设计并实现一个满足 [LRU (最近最少使用) 缓存](https://baike.baidu.com/item/LRU) 约束的数据结构。
>
> 实现 `LRUCache` 类：
>
> - `LRUCache(int capacity)` 以 **正整数** 作为容量 `capacity` 初始化 LRU 缓存
> - `int get(int key)` 如果关键字 `key` 存在于缓存中，则返回关键字的值，否则返回 `-1` 。
> - `void put(int key, int value)` 如果关键字 `key` 已经存在，则变更其数据值 `value` ；如果不存在，则向缓存中插入该组 `key-value` 。如果插入操作导致关键字数量超过 `capacity` ，则应该 **逐出** 最久未使用的关键字。
>
> 函数 `get` 和 `put` 必须以 `O(1)` 的平均时间复杂度运行。
>
>  
>
> **示例：**
>
> ```
> 输入
> ["LRUCache", "put", "put", "get", "put", "get", "put", "get", "get", "get"]
> [[2], [1, 1], [2, 2], [1], [3, 3], [2], [4, 4], [1], [3], [4]]
> 输出
> [null, null, null, 1, null, -1, null, -1, 3, 4]
> 
> 解释
> LRUCache lRUCache = new LRUCache(2);
> lRUCache.put(1, 1); // 缓存是 {1=1}
> lRUCache.put(2, 2); // 缓存是 {1=1, 2=2}
> lRUCache.get(1);    // 返回 1
> lRUCache.put(3, 3); // 该操作会使得关键字 2 作废，缓存是 {1=1, 3=3}
> lRUCache.get(2);    // 返回 -1 (未找到)
> lRUCache.put(4, 4); // 该操作会使得关键字 1 作废，缓存是 {4=4, 3=3}
> lRUCache.get(1);    // 返回 -1 (未找到)
> lRUCache.get(3);    // 返回 3
> lRUCache.get(4);    // 返回 4
> ```
>
>  
>
> **提示：**
>
> - `1 <= capacity <= 3000`
> - `0 <= key <= 10000`
> - `0 <= value <= 105`
> - 最多调用 `2 * 105` 次 `get` 和 `put