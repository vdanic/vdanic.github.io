---
title: "数据结构 - 跳表"
date: 2022-07-26T23:26:19+08:00
description: "跳表 练手"
featured_image: "https://pic.danic.tech/blog/bg/bg-27.jpg"
tags:	["数据结构", "跳表", "Redis"]
---

### 介绍

跳表的特性是利用空间复杂度换时间复杂度，其性能与红黑树、AVL树差距不大，且编码原理易懂。原理与编码可参考[Leetcode题解](https://leetcode.cn/problems/design-skiplist/solution/she-ji-tiao-biao-by-leetcode-solution-e8yh/)。

### 代码

```go
type Node struct {
	value int
	level int
	forwards []*Node
}

// 创建节点
func CreateNode(value int, level int) *Node {
	return &Node{value, level, make([]*Node, level)}
}

const (
	MAX_LEVEL = 32
	P_FACTOR = 0.25
)

type Skiplist struct {
	head *Node
	// 当前跳表的层级
	level int
}

func Constructor() Skiplist {
	return Skiplist{CreateNode(math.MinInt32, MAX_LEVEL), 1}
}

func (s *Skiplist) Add(value int) {
	cur := s.head
	update := make([]*Node, MAX_LEVEL)
	// 由于插入的节点level是随机的，因此update需要初始化加入head对象
	for i := range update {
		update[i] = s.head
	}

	// 从当前层级往下遍历
	for i := s.level - 1; i >= 0; i-- {
		// 遍历直到当前指针的下一跳指向nil或者下一跳数值大于等于传入值
		for cur.forwards[i] != nil && cur.forwards[i].value < value {
			cur = cur.forwards[i]
		}
		// 记录当前层走过的节点，即cur，随后往下一层走
		update[i] = cur
	}

	// 生成随机层数
	level := 1
	for i := 1; i < MAX_LEVEL; i++ {
		if rand.Float64() < P_FACTOR {
			level++
		}
	}
	// 更新当前跳表层级
	if level > s.level {
		s.level = level
	}

	// 创建新节点
	newNode := CreateNode(value, level)

	// 将新节点插入跳表中
	for i := newNode.level - 1; i >= 0; i-- {
		update[i].forwards[i], newNode.forwards[i] = newNode, update[i].forwards[i]
	}
}

func (s *Skiplist) Erase(value int) bool {
	cur := s.head
	update := make([]*Node, MAX_LEVEL)

	// 从当前层级往下遍历
	for i := s.level; i >= 0; i-- {
		// 遍历直到当前指针的下一跳指向nil或者下一跳数值大于等于传入值
		for cur.forwards[i] != nil && cur.forwards[i].value < value {
			cur = cur.forwards[i]
		}

		update[i] = cur
	}

	// 移位到下一跳，因为下一跳必定满足cur.forwards[i] == nil || cur.forwards[i].value >= value
	cur = cur.forwards[0]
	// 若不存在或不匹配，返回false
	if cur == nil || cur.value != value {
		return false
	}

	// 删除节点
	for i := cur.level - 1; i >= 0; i-- {
		update[i].forwards[i] = cur.forwards[i]
	}

	// 更新当前跳表的level
	for s.level > 1 && s.head.forwards[s.level - 1] == nil {
		s.level--
	}
	return true
}

func (s *Skiplist) Search(value int) bool {
	cur := s.head

	// 从当前层级往下遍历
	for i := s.level - 1; i >= 0; i-- {
		// 遍历直到当前指针的下一跳指向nil或者下一跳数值大于等于传入值
		for cur.forwards[i] != nil && cur.forwards[i].value < value {
			cur = cur.forwards[i]
		}
		// 找到了，返回true
		if cur.forwards[i] != nil && cur.forwards[i].value == value {
			return true
		}
	}
	return false
}
```



### 相关题目

> #### [1206. 设计跳表](https://leetcode.cn/problems/design-skiplist/)
>
> 难度困难208收藏分享切换为英文接收动态反馈
>
> 不使用任何库函数，设计一个 **跳表** 。

