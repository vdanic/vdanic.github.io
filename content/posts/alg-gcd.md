---
title: "数学算法 - 求最大公约数GCD"
date: 2022-02-10T23:15:57+08:00
description: "最大公约数GCD求解算法练手"
featured_image: "https://pic.danic.tech/blog/bg/bg-19.jpg"
tags:	["算法", "数学"]
---

### 介绍

两数`a, b`的最大公约数`gcd`可采用**辗转相除法**求得，且最大公倍数求解公式为`lcm = a*b/gcd`。

代码参考自[wiki](https://zh.wikipedia.org/wiki/%E6%9C%80%E5%A4%A7%E5%85%AC%E5%9B%A0%E6%95%B8)。



### 代码

```go
func gcd(a, b int) int {
	for b != 0 {
		a, b = b, a%b
	}
	return a
}

func lcm(a, b int) int {
	return a * b / gcd(a, b)
}

func main() {
	a, b := 12, 8
	fmt.Printf("%d和%d的最大公约数为 %d\n", a, b, gcd(a, b)) // 输出 "12和8的最大公约数为 4"
	fmt.Printf("%d和%d的最大公倍数为 %d\n", a, b, lcm(a, b)) // 输出 "12和8的最大公倍数为 24"
}
```



### 相关题目

> #### [1447. 最简分数](https://leetcode-cn.com/problems/simplified-fractions/)
>
> 给你一个整数 `n` ，请你返回所有 0 到 1 之间（不包括 0 和 1）满足分母小于等于 `n` 的 **最简** 分数 。分数可以以 **任意** 顺序返回。
>
>  
>
> **示例 1：**
>
> ```
> 输入：n = 2
> 输出：["1/2"]
> 解释："1/2" 是唯一一个分母小于等于 2 的最简分数。
> ```
>
> **示例 2：**
>
> ```
> 输入：n = 3
> 输出：["1/2","1/3","2/3"]
> ```
>
> **示例 3：**
>
> ```
> 输入：n = 4
> 输出：["1/2","1/3","1/4","2/3","3/4"]
> 解释："2/4" 不是最简分数，因为它可以化简为 "1/2" 。
> ```
>
> **示例 4：**
>
> ```
> 输入：n = 1
> 输出：[]
> ```
>
>  
>
> **提示：**
>
> - `1 <= n <= 100`



解

```go
func gcd(a, b int) int {
    for b != 0 {
        a, b = b, a % b
    }
    return a
}

func simplifiedFractions(n int) []string {
    ans := make([]string, 0)
    // 从2开始遍历到n
    for i := 2; i <= n; i++ {
        for j := 1; j < i; j++ {
            // 最大公约数为1，表示无法再精简，加入答案数组
            if gcd(i, j) == 1 {
                ans = append(ans, fmt.Sprintf("%d/%d", j, i))
            }
        }
    }
    return ans
}
```

