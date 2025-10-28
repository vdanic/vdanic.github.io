---
title: 基于WebSocket的聊天功能(一)
date: 2017-03-20 20:07:41
tag: websocket
featured_image: "https://pic.danic.tech/blog/bg/bg-12.jpg"
---

 **最近比赛需要做一个聊天功能模块，然而用框架感觉太臃肿，正好接触了WebSockt协议，甚是有趣，赶紧学习学习。**


### 什么是WebSocket？

 WebSocket是Html5定义的一种在单个 TCP 连接上进行全双工通讯的协议。
 相比于使用ajax轮询进行信息推送，WebSocket具有以下特点

 - 较少的控制开销。

 - 更强的实时。

 - 保持连接状态。

 - 更好的二进制支持。


综合一点来说，在与服务器建立好连接后，传输所需的协议控制数据包头部相对与HTTP请求较小，因此开销就减少了。而且由于协议是全双工的，所以服务器可以随时随地骚扰客户端啦，然而在HTTP请求中，一个request只对应一个response，因此服务器无法主动发起请求，只能等待客户端的请求发出，才能做出响应，因此类似轮询的方式不是做到了真正的实时。

<!-- more -->


###  握手过程

然后，我们来看一下WebSocket的握手过程

 **客户端请求：**

	GET ws://localhost:8080/WebSocketServer HTTP/1.1
	Host: localhost:8080
	Connection: Upgrade
	Upgrade: websocket
	Sec-WebSocket-Version: 13
	Sec-WebSocket-Key: F/O2fhIx5D00uV0y+p9tVw==

 

 `GET ws://localhost:8080/WebSocketServer HTTP/1.1` 即方法名、主要参数和HTTP版本

` Host: localhost:8080` 即用户指定想访问的HTTP / IP 地址和端口

	Connection: Upgrade
	Upgrade: websocket

 以上俩句 **划重点**，表示客户端希望将连接升级，并且指定将其升级为WebSocket协议。

`Sec-WebSocket-Version: 13` 指定WebSocket的协议版本为13

`Sec-WebSocket-Key: F/O2fhIx5D00uV0y+p9tVw==` 浏览器随机产生，发送到服务器后，经计算将得出的结果作为“Sec-WebSocket-Accept”头的值，用于验证服务器返回的是否为一个WebSocket连接

<br/>

 **服务器返回：**

>	HTTP/1.1 101 Switching Protocols
	Server: Apache-Coyote/1.1
	Upgrade: websocket
	Connection: upgrade
	Sec-WebSocket-Accept: OnJWsXeO6Rr+uTDQYHxDo02jjFk=

`HTTP/1.1 101 Switching Protocols  ` 其中101是HTTP Upgrade响应的状态码，表示接下来就可以使用客户端要求的协议进行通信

	Upgrade: websocket
	Connection: upgrade

 这俩句告诉客户端，服务器升级的协议就是WebSocket协议

`Sec-WebSocket-Accept: OnJWsXeO6Rr+uTDQYHxDo02jjFk=` 由服务器加密产生，客户端会据此判断此次响应是否为普通HTTP请求

 ![websocket](http://pic.danic.tech/blog/websocket/websocket1.png)
