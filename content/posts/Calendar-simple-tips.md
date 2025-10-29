---
title: Java 日期处理 - Calendar的简单使用
date: 2018-07-27 14:07:41
description: "Java中Calendar的简单使用"
tag: Java
featured_image: "https://pic.danic.tech/blog/bg/bg-02.jpg"
---

```java
Calendar cal = Calendar.getInstance(); // 获取当前的一个日历，结构如下图所示
// 第一个参数为计算的单位，当前是按秒计算，也可以按小时计算
// 得到当前时间的后一秒，+号即在原来基础上加指定数值，也可使用-号
cal.add(Calendar.SECOND, +1); 
// 格式化输出日期
SimpleDateFormat sf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
String date = sf.format(cal.getTime());
```

<!-- more -->

![Calendar 内部结构图](http://pic.danic.tech/Calendar-simple-tips/img1.png)

