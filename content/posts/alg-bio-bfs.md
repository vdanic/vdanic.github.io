---
title: "搜索算法 - 双向BFS"
date: 2022-04-13T00:10:43+08:00
description: "双向BFS练手"
featured_image: "https://pic.danic.tech/blog/bg/bg-25.jpg"
tags:	["算法", "搜索", "图"]
---

### 介绍

朴素搜索算法存在搜索空间爆炸的问题，因为从单点能发散出来很多节点，可能是指数级别的增长。在知道起始与目的的时候，可以使用双向BFS，减少空间消耗。跟随题目[开密码锁](https://leetcode-cn.com/problems/zlDJc7/)，练习一下双向BFS，代码参考自[三叶大佬](https://juejin.cn/post/6977640016436527117)

> #### [剑指 Offer II 109. 开密码锁](https://leetcode-cn.com/problems/zlDJc7/)
>
> 一个密码锁由 4 个环形拨轮组成，每个拨轮都有 10 个数字： `'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'` 。每个拨轮可以自由旋转：例如把 `'9'` 变为 `'0'`，`'0'` 变为 `'9'` 。每次旋转都只能旋转一个拨轮的一位数字。
>
> 锁的初始数字为 `'0000'` ，一个代表四个拨轮的数字的字符串。
>
> 列表 `deadends` 包含了一组死亡数字，一旦拨轮的数字和列表里的任何一个元素相同，这个锁将会被永久锁定，无法再被旋转。
>
> 字符串 `target` 代表可以解锁的数字，请给出解锁需要的最小旋转次数，如果无论如何不能解锁，返回 `-1` 。
>
>  
>
> **示例 1:**
>
> ```
> 输入：deadends = ["0201","0101","0102","1212","2002"], target = "0202"
> 输出：6
> 解释：
> 可能的移动序列为 "0000" -> "1000" -> "1100" -> "1200" -> "1201" -> "1202" -> "0202"。
> 注意 "0000" -> "0001" -> "0002" -> "0102" -> "0202" 这样的序列是不能解锁的，因为当拨动到 "0102" 时这个锁就会被锁定。
> ```
>
> **示例 2:**
>
> ```
> 输入: deadends = ["8888"], target = "0009"
> 输出：1
> 解释：
> 把最后一位反向旋转一次即可 "0000" -> "0009"。
> ```
>
> **示例 3:**
>
> ```
> 输入: deadends = ["8887","8889","8878","8898","8788","8988","7888","9888"], target = "8888"
> 输出：-1
> 解释：
> 无法旋转到目标数字且不被锁定。
> ```
>
> **示例 4:**
>
> ```
> 输入: deadends = ["0000"], target = "8888"
> 输出：-1
> ```
>
>  
>
> **提示：**
>
> - `1 <= deadends.length <= 500`
> - `deadends[i].length == 4`
> - `target.length == 4`
> - `target` **不在** `deadends` 之中
> - `target` 和 `deadends[i]` 仅由若干位数字组成



### 代码

```go
func update(q *[]string, src map[string]int, dst map[string]int) int {
    // 从队首开始发散
    old := *q
    top := []byte(old[0])
    topd := src[old[0]]
    for i := 0; i < 4; i++ {
        // 记录原数值
        origin := top[i]
        for j := -1; j <= 1; j++ {
            if j == 0{
                continue
            }
            top[i] += uint8(j)
            if top[i] < '0' {
                top[i] = '9'
            } else if top[i] > '9' {
                top[i] = '0'
            }

            next := string(top)
            top[i] = origin
            // 如果src[next]已经遍历过或是dead状态，则跳过
            if d, ok := src[next]; ok || d == -1 {
                continue
            }
            // 距离+1
            src[next] = topd + 1
            // 如果与另一个方向的遍历存在交集，则说明找到了最短路径，可直接返回
            if _, ok := dst[next]; ok {
                return src[next] + dst[next]
            }
            // 未找到，入队继续参与搜索
            old = append(old, next)
        }
    }
    *q = old[1:]
    return -1
}

func openLock(deadends []string, target string) int {
    // 目的为起点"0000"，则直接返回
    start := "0000"
    if target == start {
        return 0
    }

    // 表示距离，-1为dead
    dist1 := make(map[string]int)
    dist2 := make(map[string]int)

    // BFS数组
    q1 := make([]string, 0)
    q2 := make([]string, 0)

    // 标识dead
    for _, dead := range deadends {
        // 开局锁死
        if dead == start {
            return -1
        }
        dist1[dead] = -1
        dist2[dead] = -1
    }

    // 设置起点
    q1 = append(q1, start)
    dist1[start] = 0
    q2 = append(q2, target)
    dist2[target] = 0

    // 临时变量
    flag := 0

    // 开始双向BFS，终止条件为其中一个队列为空。
    // 如果其中一个队列为空，则说明起点与目的不存在连通的路
    for len(q1) != 0 && len(q2) != 0 {
        // 从队列短的一端开始搜索
        if len(q1) < len(q2) {
            flag = update(&q1, dist1, dist2)
        } else {
            flag = update(&q2, dist2, dist1)
        }
        // 找到则直接返回
        if flag != -1 {
            return flag
        }
    }

    // 未找到
    return -1
}
```

