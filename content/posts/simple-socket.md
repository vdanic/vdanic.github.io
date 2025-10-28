---
title: "Simple Socket"
date: 2023-02-07T22:41:41+08:00
description: ""
featured_image: "https://pic.danic.tech/blog/bg/bg-#num#.jpg"
tags: []
draft: true
---

# 简介

今天来学习一下Linux上的`socket`网络通信流程以及简易代码实现。

首先要弄清楚的是何为`socket`，当我们使用`man socket`命令查看`socket()`函数的手册时，可以看到对其的定义:

> DESCRIPTION
>      socket() creates an endpoint for communication and returns a descriptor.

这里可以理解成`socket`是通信两端的端点，并且是以文件描述符的形式存在（毕竟在Linux中，万物介文件）。从宏观角度看，对其中一端的`socket`文件描述符进行`write`操作，另外一端也可以从`socket`文件描述符中`read`出来，调用方完全不用操心网络传输的问题，只需要关注文件操作。

`socket`通信的状态转移流程如下：

## 函数分析

### socket函数

在创建`socket`时可以为其指定底层使用的传输层以及网络层协议，具体还是可以看`socket()`函数的手册。

`socket`函数签名如下：

```c++
#include <sys/socket.h>
int socket(int domain, int type, int protocol);
```

#### domain

第一个参数`domain`为协议族，用于指定socket通信时使用的地址类型，可选参数有下：

```c++
AF_LOCAL        // Host-internal protocols, formerly called AF_UNIX,
AF_UNIX         // Host-internal protocols, deprecated, use AF_LOCAL,
AF_INET         // Internet version 4 protocols,
AF_ROUTE        // Internal Routing protocol,
AF_KEY          // Internal key-management function,
AF_INET6        // Internet version 6 protocols,
AF_SYSTEM       // System domain,
AF_NDRV         // Raw access to network device,
AF_VSOCK        // VM Sockets protocols
```

有些地方也会把`AF`前缀写为`PF`前缀，其实两者是同一个意思，具体可以看头文件`socket.h`中的定义：

```c++
/*
 * Protocol families, same as address families for now.
 */
#define PF_UNSPEC       AF_UNSPEC
#define PF_LOCAL        AF_LOCAL
#define PF_UNIX         PF_LOCAL        /* backward compatibility */
#define PF_INET         AF_INET
...
```

常用的协议族有`AF_INET`(IPV4)、`AF_INET6`(IPV6)、`AF_LOCAL`等。

#### type

`type`为`socket`类型，可选参数如下

```c++
SOCK_STREAM			// 字节流传输，具有面向连接、可靠传输的特性
SOCK_DGRAM			// 数据报文传输，具有无连接、不保证可靠的特性
SOCK_RAW				// 原始网络协议
```

#### protocol

`protocol`用于指定`type`对应使用的协议，例如`IPPROTO_TCP`、`IPPROTO_UDP`等，由于绝大数`type`对应的协议都是固定的，因此可以传入`0`表示使用`type`默认支持的协议。

#### 例子

以下代码可以创建一个基于TCP/IP传输的`socket`，返回的参数为文件描述符。

```c++
int socketFd = socket(AF_INET, SOCK_STREAM, 0);
```

