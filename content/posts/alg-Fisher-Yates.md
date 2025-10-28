---
title: "随机算法 - Fisher-Yates（洗牌算法）"
date: 2022-02-08T22:59:21+08:00
description: "Fisher-Yates算法练手"
featured_image: "https://pic.danic.tech/blog/bg/bg-17.jpg"
tags:	["算法", "随机"]
---

### 介绍

Fisher-Yates算法常用于随机打乱一个数组，该算法保证数组中的每个元素的打乱概率是相等的，均为1/n（n为数组长度）。代码参考自[https://blog.csdn.net/qq_26399665/article/details/79831490](https://blog.csdn.net/qq_26399665/article/details/79831490)



### 代码

跟随题目[384. 打乱数组](https://leetcode-cn.com/problems/shuffle-an-array/)。

```go
import (
	"fmt"
	"math/rand"
)

type Solution struct {
	Origin []int
}


func Constructor(nums []int) Solution {
	return Solution{Origin: nums}
}


func (this *Solution) Reset() []int {
	return this.Origin
}

func (this *Solution) Shuffle() []int {
	random := make([]int, len(this.Origin))
	copy(random, this.Origin)
	n := len(random)

	// 遍历n次，保证每个元素都被覆盖到
	for i := n - 1; i >= 0; i-- {
		// 取[0,i+1)之间的随机数为r，该范围保证所有未被打乱的元素均能被选取到
		r := rand.Intn(i+1)
		// 交换数组的第r位与第i位
		random[i], random[r] = random[r], random[i]
	}

	return random
}
```



### 相关题目



> #### [384. 打乱数组](https://leetcode-cn.com/problems/shuffle-an-array/)
>
> 给你一个整数数组 `nums` ，设计算法来打乱一个没有重复元素的数组。打乱后，数组的所有排列应该是 **等可能** 的。
>
> 实现 `Solution` class:
>
> - `Solution(int[] nums)` 使用整数数组 `nums` 初始化对象
> - `int[] reset()` 重设数组到它的初始状态并返回
> - `int[] shuffle()` 返回数组随机打乱后的结果
>
>  
>
> **示例 1：**
>
> ```
> 输入
> ["Solution", "shuffle", "reset", "shuffle"]
> [[[1, 2, 3]], [], [], []]
> 输出
> [null, [3, 1, 2], [1, 2, 3], [1, 3, 2]]
> 
> 解释
> Solution solution = new Solution([1, 2, 3]);
> solution.shuffle();    // 打乱数组 [1,2,3] 并返回结果。任何 [1,2,3]的排列返回的概率应该相同。例如，返回 [3, 1, 2]
> solution.reset();      // 重设数组到它的初始状态 [1, 2, 3] 。返回 [1, 2, 3]
> solution.shuffle();    // 随机返回数组 [1, 2, 3] 打乱后的结果。例如，返回 [1, 3, 2]
> ```
>
>  
>
> **提示：**
>
> - `1 <= nums.length <= 200`
> - `-106 <= nums[i] <= 106`
> - `nums` 中的所有元素都是 **唯一的**
> - 最多可以调用 `5 * 104` 次 `reset` 和 `shuffle`