---
title: "DP - 数位DP模版"
date: 2022-08-30T22:57:00+08:00
description: "数位DP练习"
featured_image: "https://pic.danic.tech/blog/bg/bg-35.jpg"
tags: ["dp"]
---

# 介绍

数位DP的原理是将一个数字按照个、十、百、千等等位置拆分，然后逐位考虑不同case，最后汇总成一个总的结果的算法，这部分称为数位，由于算法使用了dp压缩剪枝，所以也叫做数位DP。

>引用自[OI-Wiki](https://oi-wiki.org/dp/number/)
>
>数位 DP：用来解决一类特定问题，这种问题比较好辨认，一般具有这几个特征：
>
>1.  要求统计满足一定条件的数的数量（即，最终目的为计数）；
>2.  这些条件经过转化后可以使用「数位」的思想去理解和判断；
>3.  输入会提供一个数字区间（有时也只提供上界）来作为统计的限制；
>4.  上界很大（比如 ），暴力枚举验证会超时。

模版参考自[LeetCode题解](https://leetcode.cn/problems/count-special-integers/solution/shu-wei-dp-mo-ban-by-endlesscheng-xtgx/)，代码根据题目[2376. 统计特殊整数](https://leetcode.cn/problems/count-special-integers/)编写。



# 代码

```go
func countSpecialNumbers(n int) int {
    // 转换成字符串，可以方便处理每一位数字
    s := strconv.Itoa(n)
    lens := len(s)

    // dp数组，用于记忆化剪枝，一般记忆化递归函数的非flag参数
    dp := make([][1<<10]int, lens)

    // 初始化dp数组
    for i := range dp {
        for j := range dp[i] {
            dp[i][j] = -1
        }
    }

    /*
     * i为遍历到的位数，从0到lens-1
     * mask为已遍历的集合，不同题目需要对应修改，例如此题不能出现重复数字
     * isLimit表示当前位置是否受限。例如n为123的场景，当第一位为0时，第二位可取0~9；当第一位为1时，便只能取0~2
     * isNumber表示之前有无填充过数字，若没填充过，则只能使用1~up的数字；若填充过便可以使用0~up的数字
    */
    var dfs func(i int, mask int, isLimit bool, isNumber bool) int
    dfs = func(i int, mask int, isLimit bool, isNumber bool) int {
        // 边界
        if i == lens {
            // 填充过数字，返回1
            if isNumber {
                return 1
            }
            // 未填充过，即0，需要根据题意判断是否返回，本题0无效
            return 0
        }

        // 当前位无限制，且此前(i, mask)的组合已经求过一次结果，则可使用记忆化的数据
        if !isLimit && dp[i][mask] != -1 {
            return dp[i][mask]
        }

        // 当前位数的结果
        res := 0
        // 若前面位跳过，则也可以选择跳过当前位
        // 例如n为123的场景，可跳过前两位，来到最后一位开始填充数字，并且无填充限制
        if !isNumber {
            res += dfs(i+1, mask, false, false)
        }

        // 可以填充的最大值，默认9
        up := 9
        // 若此位受限，更新up值
        if isLimit {
            up = int(s[i]-'0')
        }

        // 填充的起始数字
        d := 0
        // 若前面未填充过数字，则需要从1开始，即不能包含前导0（需要根据题意变更）
        if !isNumber {
            d = 1
        }

        for ; d <= up; d++ {
            // 若当前数字出现在之前的集合中，则跳过
            if mask >> d & 0b1 == 1 {
                continue
            }
            // 传入的isLimit需要由前一位以及当前位结合得出
            // 例如n为123的场景
            // 若第一位为1（受限），第二位为2（当前位最大值），则第三位受限
            // 若第一位为1（受限），第二位为1，则第三位不受限
            res += dfs(i+1, mask | (1<<d), isLimit && d == up, true)
        }
        // 加入dp数组
        dp[i][mask] = res
        return res
    }

    // 初始时传入的isLimit为true，因为第一位不能超过其最大值
    // 传入的isNum为false，因为前面未填入过数字
    return dfs(0, 0, true, false)
}

```



# 相关题目

>   [233  数字 1 的个数](https://leetcode.cn/problems/number-of-digit-one/)
>   
>   [面试题 17.06. 2出现的次数](https://leetcode.cn/problems/number-of-2s-in-range-lcci/)
>   
>   [600  不含连续1的非负整数](https://leetcode.cn/problems/non-negative-integers-without-consecutive-ones/)
>   
>   [902  最大为 N 的数字组合](https://leetcode.cn/problems/numbers-at-most-n-given-digit-set/)
>   
>   [1012  至少有 1 位重复的数字](https://leetcode.cn/problems/numbers-with-repeated-digits/)
>   
>   [1067  范围内的数字计数](https://leetcode.cn/problems/digit-count-in-range/)
>   
>   [1397  找到所有好字符串](https://leetcode.cn/problems/find-all-good-strings/)

