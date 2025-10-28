---
title: 数据结构 - Huffman Tree
description: "Huffman Tree练手"
date: 2022-01-25 00:06:56
tags: ["算法", "数据结构", "树"]
featured_image: "https://pic.danic.tech/blog/bg/bg-03.jpg"
---

### 介绍

霍夫曼树一般用于两种场景

- 加解密文，通过霍夫曼树可以生成一个字典，然后通过字典对内容进行加密与解密
- 压缩算法，根据词频生成一个霍夫曼树，其特点是出现次数越多的词，他的路径是最短的，从而起到压缩作用

其他霍夫曼树的介绍及原理可以参考[https://oi-wiki.org/ds/huffman-tree/](https://oi-wiki.org/ds/huffman-tree/)

<!--more-->

### 代码

使用优先队列创建霍夫曼树，使用栈模拟后根遍历生成编码。

```golang
package main

import (
	"container/heap"
	"fmt"
	"strings"
)

type Node struct {
	Left *Node
	Right *Node
	Weight int
	Word byte
}

// 用于构造小顶堆
type Nodes []*Node

func (ns Nodes) Len() int {
	return len(ns)
}

func (ns Nodes) Swap(i, j int) {
	ns[i], ns[j] = ns[j], ns[i]
}

func (ns Nodes) Less(i, j int) bool {
	return ns[i].Weight < ns[j].Weight
}

func (ns *Nodes) Push(v interface{}) {
	*ns = append(*ns, v.(*Node))
}

func (ns *Nodes) Pop() (v interface{}) {
	old := *ns
	n := len(old)
	v, *ns = old[n-1], old[:n-1]
	return
}

type HuffTree struct {
	Root *Node
	WordDict map[byte]string
}

func (ht *HuffTree) Initialize(freqDict map[byte]int) {
	ns := &Nodes{}
	// 压入堆
	for word, freq := range freqDict {
		heap.Push(ns, &Node{
			Weight: freq,
			Word: word,
		})
	}
	// 取最小的两个节点，拼接组合成新节点，并重新入堆
	for ns.Len() > 1 {
		top1 := heap.Pop(ns).(*Node)
		top2 := heap.Pop(ns).(*Node)
		heap.Push(ns, &Node{
			Left: top1,
			Right: top2,
			Weight: top1.Weight + top2.Weight,
		})
	}

	// 最后取得的即Root节点
	ht.Root = heap.Pop(ns).(*Node)
	ht.GenDict()
	for k, v := range ht.WordDict {
		fmt.Printf("%s:%s ", string(k), v)
	}
	fmt.Println()
}

// 根据哈夫曼树生成字典
func (ht *HuffTree) GenDict() {
	if ht.Root == nil {
		return
	}

	// 通过栈后序遍历的方式生成字典
	stack := make([]*Node, 0)
	n := ht.Root
	var prev *Node

	// 当前的哈夫曼编码
	code := make([]byte, 0)
	for len(stack) != 0 || n != nil {
		// 左子树一直入队
		for n != nil {
			stack = append(stack, n)
			n = n.Left

			// 此路径为左侧路径，编码追加0
			// 当n不等于nil，才追加，因为两个节点间只有一条边，以此类推，三个节点只有两条边
			if n != nil {
				code = append(code, '0')
			}
		}

		// 此时栈top节点没有左子树
		top := stack[len(stack)-1]
		// 如果不存在右子树，或者右子树已经被遍历过（prev标记），弹出栈顶节点
		if top.Right == nil || prev == top.Right {
			// 弹出，此时可以做后序遍历的操作
			stack = stack[:len(stack)-1]
			// 如果弹出的节点为叶子节点，生成字符对应的编码
			if top.Left == nil && top.Right == nil {
				ht.WordDict[top.Word] = string(code)
			}
			// 根节点就不弹了
			if len(code) != 0 {
				// 将编码的最后一位也一并弹出，回到父节点的编码状态
				code = code[:len(code)-1]
			}
			// 标记当前节点的左右子树均已经遍历
			prev = top
		} else {
			// 走右侧追加1
			code = append(code, '1')
			n = top.Right
		}
	}
}

func (ht *HuffTree) EncodeString(str string) string {
	s := strings.Builder{}
	for i := range str {
		if _, ok := ht.WordDict[str[i]]; !ok {
			fmt.Println("None exist word[", str[i], "]")
			return ""
		}
		s.WriteString(ht.WordDict[str[i]])
	}
	return s.String()
}

func (ht *HuffTree) DecodeString(str string) string {
	s := strings.Builder{}
	for i := 0; i < len(str); {
		n := ht.Root
		for i < len(str) && n.Left != nil && n.Right != nil {
			if str[i] == '0' {
				// 往左走
				n = n.Left
			} else if str[i] == '1' {
				// 往右走
				n = n.Right
			} else {
				fmt.Println("Error.")
				return ""
			}
			i++
		}
		s.WriteString(string(n.Word))
	}
	return s.String()
}

func main() {
	words := "Hello worlddddddddddddddd."
	dict := make(map[byte]int)
	// 同级词频
	for _, v := range words {
		dict[byte(v)]++
	}

	ht := &HuffTree{
		WordDict: make(map[byte]string),
	}
	// 初始化霍夫曼树
	ht.Initialize(dict)
	// 编码
	encoded := ht.EncodeString(words)
	fmt.Println("Encoded:", encoded)
	// 解码
	decoded := ht.DecodeString(encoded)
	fmt.Println("Decoded:", decoded)
}
```



程序运行后的输出如下，可正常编解码

> .:01111  :01100 H:0010 e:0011 l:010 r:01101 w:01110 d:1 o:000 
> Encoded: 0010001101001000001100011100000110101011111111111111101111
> Decoded: Hello worlddddddddddddddd.



### 衍生题目

https://leetcode-cn.com/problems/concatenated-words/

LeetCode第472题

> #### [472. 连接词](https://leetcode-cn.com/problems/concatenated-words/)
>
> 难度困难235收藏分享切换为英文接收动态反馈
>
> 给你一个 **不含重复** 单词的字符串数组 `words` ，请你找出并返回 `words` 中的所有 **连接词** 。
>
> **连接词** 定义为：一个完全由给定数组中的至少两个较短单词组成的字符串。
>
>  
>
> **示例 1：**
>
> ```
> 输入：words = ["cat","cats","catsdogcats","dog","dogcatsdog","hippopotamuses","rat","ratcatdogcat"]
> 输出：["catsdogcats","dogcatsdog","ratcatdogcat"]
> 解释："catsdogcats" 由 "cats", "dog" 和 "cats" 组成; 
>      "dogcatsdog" 由 "dog", "cats" 和 "dog" 组成; 
>      "ratcatdogcat" 由 "rat", "cat", "dog" 和 "cat" 组成。
> ```
>
> **示例 2：**
>
> ```
> 输入：words = ["cat","dog","catdog"]
> 输出：["catdog"]
> ```
>
>  
>
> **提示：**
>
> - `1 <= words.length <= 104`
> - `0 <= words[i].length <= 1000`
> - `words[i]` 仅由小写字母组成
> - `0 <= sum(words[i].length) <= 105`



可使用字典树解题。

```go
// 节点对象
type Node struct {
    Nexts [26]*Node
    IsEnd bool
}

// 字典树对象
type Dict struct {
    Root *Node
}

// 构造路径
func (d *Dict) Push(s string) {
    n := d.Root
    for i := range s {
        c := s[i] - 'a'
        if n.Nexts[c] == nil {
            n.Nexts[c] = &Node{}
        }
        n = n.Nexts[c]
    }
    n.IsEnd = true
}

// 递归搜索传入word是否可由已有的字符串组成
func (d *Dict) Dfs(visited []bool, word string, start int) bool {
    // 如果已经到达尾部，返回True
    if start == len(word) {
        return true
    }
    // 如果已经遍历过了，则直接返回false，因为前面此路径已经被尝试过了，且未成功
    if visited[start] {
        return false
    }
    visited[start] = true
    n := d.Root
    for i := start; i < len(word); i++ {
        n = n.Nexts[word[i]-'a']
        if n == nil {
            return false
        }
        // 找到一个单词了，再次递归看后续部分能否由已有的字符串组成
        if n.IsEnd && d.Dfs(visited, word, i+1) {
            return true
        }
    }
    return false
}

func findAllConcatenatedWordsInADict(words []string) (ans []string) {
    // 排序words数组，贪心，长度小的单词应该有些判断
    sort.Slice(words, func(i, j int) bool {
        return len(words[i]) < len(words[j])
    })

    dt := &Dict{
        Root: &Node{},
    }
    // 遍历排序后的数组，如果发现可以由已有部分组成一个完整的单词，则加入答案，反正加入字典树
    for _, word := range words {
        // 过滤空串
        if len(word) == 0 {
            continue
        }
        if dt.Dfs(make([]bool, len(word)), word, 0) {
            ans = append(ans, word)
        } else {
            dt.Push(word)
        }
    }
    return ans
}
```



