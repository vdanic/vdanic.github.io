---
title: MySql 选择性得插入数据
date: 2017-03-03 20:50:16
description: "MySql小技巧"
tags: MySql
featured_image: "https://pic.danic.tech/blog/bg/bg-07.jpg"
---

## 导语
SQL编程中，如何做到有条件的插入，即无则插入，有则跳过呢？

## 动机
 之前在用Java做微信公众开发的时候，遇到一个需求，即用户点击功能按钮时，如何判断下一次输入的数据对应的是用户刚才点击的功能按钮，因为两次动作都会发送一个xml格式数据给服务器，并无关联。


 所以想到了在数据库中记录下用户的动作(action)，在用户第一次关注公众号时就插入一条记录，之后的所有操作都是对这条记录进行更改。


 但是考虑到一个用户对应的记录是唯一的，加上可能会出现插入多条同一用户的记录，所以需要在插入一条记录时判断用户是否已经在表中存在记录。

<!-- more -->

## 加工
 预先放出本期结果，然后我们一一分解！
`INSERT INTO wx_action(action_name, fromuser, is_active) SELECT 'none', ?, 0 FROM DUAL WHERE NOT EXIST(SELECT fromuser FROM wx_action WHERE fromuser = ?)`


	select 'none', ?, 0 from DUAL
首先，解释一下DUAL是什么！来看一看官方文档做出的释义。
> You are allowed to specify DUAL as a dummy table name in situations where no tables are referenced:
mysql> SELECT 1 + 1 FROM DUAL;  
> DUAL is purely for the convenience of people who require that all SELECT statements should have FROM and possibly other clauses. MySQL may ignore the clauses. MySQL does not require FROM DUAL if no tables are referenced.

 简而言之，DUAL表是一个虚拟表，用来防止某些时刻SELECT没有FROM从句时会报错的现象发生。
 如果执行`select 'none', '123', 0 from DUAL` 则会返回一条记录，如图所示


 ![img1](http://pic.danic.tech/blog/MySql-judge-before-inserting-data/img1.png)

	 select 'none', ?, 0 from DUAL where not exists(select fromuser from wx_action where fromuser = ?)
 这句话的意思是如果表中不存在指定用户的话则会返回带数据记录，反之，返回一条空记录


 执行`select 'none', '111', 0 from DUAL where not exists(select fromuser from wx_action where fromuser = '111')` ，如图所示


 ![img2](http://pic.danic.tech/blog/MySql-judge-before-inserting-data/img2.png)


  所以一整句SQL语句的释义就是，在表中不存在指定用户时，便将结果插入表中。

  执行
    
    
 ![img3](http://pic.danic.tech/blog/MySql-judge-before-inserting-data/img3.png)

   插入记录之前
 ![img4](http://pic.danic.tech/blog/MySql-judge-before-inserting-data/img4.png)

   插入记录之后
 ![img5](http://pic.danic.tech/blog/MySql-judge-before-inserting-data/img5.png)

   再次执行SQL语句
 ![img6](http://pic.danic.tech/blog/MySql-judge-before-inserting-data/img6.png)

## 总结
 这回知道了，原来通过SELECT查询语句得出来的结果也能当做插入的值
