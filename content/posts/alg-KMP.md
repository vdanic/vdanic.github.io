---
title: "字符串算法 - KMP"
date: 2022-01-31T23:09:00+08:00
description: "字符串搜索算法KMP练手"
featured_image: "https://pic.danic.tech/blog/bg/bg-14.jpg"
tags:	["算法", "字符串"]
---

### 介绍

KMP算法是一个高效的字符串子串搜索算法，其算法时间复杂度是O(n + m)，即原串长度+匹配串长度。其核心是通过一个**next**数组减少匹配次数（原理可以参考[宫水三叶大佬的文章](https://mp.weixin.qq.com/s?__biz=MzU4NDE3MTEyMA==&mid=2247486317&idx=1&sn=9c2ff2fa5db427133cce9c875064e7a4&chksm=fd9ca072caeb29642bf1f5c151e4d5aaff4dc10ba408b23222ea1672cfc41204a584fede5c05&scene=178&cur_album_id=1825717831221460994#rd)，讲得非常详细)。



### 代码

```go
func strStr(haystack string, needle string) int {
    if len(needle) == 0 {
        return 0
    }

    // 生成next数组
    next := make([]int, len(needle))
    i, j := 1, 0
    // 起始位置初始化为0
    next[0] = 0
    // 遍历needle字符串，生成i下标对应的回溯位置
    for ; i < len(needle); i++ {
        // 当下标i与下标j的元素值不匹配时，通过next数组回溯
        for j > 0 && needle[i] != needle[j] {
            j = next[j-1]
        }

        // 如果此时下标i与下标j的元素值可以匹配上，生成i下标对应的回溯位置(j+1)
        // 此处填入j+1表示，匹配时当匹配串与原串存在差异，匹配串可以从j+1处重新开始匹配(因为匹配串从0到j都可以认为默认匹配原串)，而原串无须移动下标
        if needle[i] == needle[j] {
            next[i] = j + 1
            // 匹配成功，j右移一位
            j++
        } else {
            // 反之表示没有相同前缀的子串，填入0
            next[i] = 0
        }
    }

    // 开始匹配逻辑
    i, j = 0, 0
    for ; i < len(haystack); i++ {
        // 当下标i与下标j的元素值不匹配时，通过next数组回溯
        for j > 0 && haystack[i] != needle[j] {
            j = next[j-1]
        }
        if haystack[i] == needle[j] {
            j++
        }

        // 当匹配到最后一个字符也成功时，返回下标
        if j == len(needle) {
            return i - j + 1
        }
    }

    return -1
}
```



### 相关题目

[https://leetcode-cn.com/problems/implement-strstr/submissions/](https://leetcode-cn.com/problems/implement-strstr/submissions/)

LeetCode第28题

> #### [28. 实现 strStr()](https://leetcode-cn.com/problems/implement-strstr/)
>
> 实现 [strStr()](https://baike.baidu.com/item/strstr/811469) 函数。
>
> 给你两个字符串 `haystack` 和 `needle` ，请你在 `haystack` 字符串中找出 `needle` 字符串出现的第一个位置（下标从 0 开始）。如果不存在，则返回 `-1` 。
>
>  
>
> **说明：**
>
> 当 `needle` 是空字符串时，我们应当返回什么值呢？这是一个在面试中很好的问题。
>
> 对于本题而言，当 `needle` 是空字符串时我们应当返回 0 。这与 C 语言的 [strstr()](https://baike.baidu.com/item/strstr/811469) 以及 Java 的 [indexOf()](https://docs.oracle.com/javase/7/docs/api/java/lang/String.html#indexOf(java.lang.String)) 定义相符。
>
>  
>
> **示例 1：**
>
> ```
> 输入：haystack = "hello", needle = "ll"
> 输出：2
> ```
>
> **示例 2：**
>
> ```
> 输入：haystack = "aaaaa", needle = "bba"
> 输出：-1
> ```
>
> **示例 3：**
>
> ```
> 输入：haystack = "", needle = ""
> 输出：0
> ```

