---
title: "字符串算法 - Rabin Karp（字符串哈希）"
date: 2022-02-06T23:00:37+08:00
description: "字符串搜索算法Rabin Karp（字符串哈希）练手"
featured_image: "https://pic.danic.tech/blog/bg/bg-15.jpg"
tags:	["算法", "字符串"]
---

### 介绍

**拉宾-卡普算法**，也称字符串哈希，通过滑动地比较匹配串的Hash与原串相同长度的子串Hash，从而达到子串匹配的目的。

虽然存在一定的冲突概率且效率相对较低，但相对KMP算法也具备一定的优势。

> 拉宾-卡普算法在单模式搜索方面不如[Knuth–Morris–Pratt算法](https://zh.wikipedia.org/wiki/克努斯-莫里斯-普拉特算法)、[Boyer-Moore字符串搜索算法](https://zh.wikipedia.org/wiki/Boyer-Moore字符串搜索算法)和其他较快的单模式[字符串搜索算法](https://zh.wikipedia.org/wiki/字串搜尋演算法)，因为它的最坏情况行为很慢。然而，它是多模式搜索的首选算法。

本次代码编写参考自[https://leetcode-cn.com/problems/longest-duplicate-substring/solution/wei-rao-li-lun-rabin-karp-er-fen-sou-suo-3c22/](https://leetcode-cn.com/problems/longest-duplicate-substring/solution/wei-rao-li-lun-rabin-karp-er-fen-sou-suo-3c22/)



### 代码

```go
func strStr(haystack string, needle string) int {
    if len(needle) == 0 {
        return 0
    }

    // 使用uint64存储数据，解决hash加法过程中溢出问题
    var haystackHash uint64 = 0
    var needleHash uint64 = 0
    // 取一质数为底
    var p uint64 = 31
    // 与字符串首位对应的乘数
    var prime uint64 = 1

    // 先计算一遍needle的Hash
    for i := 0; i < len(needle); i++ {
        needleHash = needleHash * p + uint64(needle[i]-'a')
    }

    // 再计算一遍haystack的Hash，目前只需要计算到len(needle)的倒数第二位
    for i := 0; i < len(haystack) && i < len(needle) - 1; i++ {
        haystackHash = haystackHash * p + uint64(haystack[i]-'a')
        prime *= p
    }

    // 开始匹配逻辑
    for i := len(needle) - 1; i < len(haystack); i++ {
        haystackHash = haystackHash * p + uint64(haystack[i]-'a')
        // 可以匹配上
        if haystackHash == needleHash {
            return i - len(needle) + 1
        }
        // 减去首位的乘积
        haystackHash = haystackHash - uint64(haystack[i-len(needle)+1]-'a') * prime
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

