---
title: 幂等性(Idempotent)
date: 2019-10-15 17:58:41
description: "幂等性的概念学习"
tag: ["网络", "Http"]
featured_image: "https://pic.danic.tech/blog/bg/bg-04.jpg"
---
### 释义

> Methods can also have the property of "idempotence" in that (aside from error or expiration issues) the side-effects of N > 0 identical requests is the same as for a single.          《rfc2616 - 9.1.2 Idempotent Methods》

以上是摘自HTTP1.1标准中有关幂等性的介绍，大致内容为，**除开网络错误以及请求超时的问题，请求同一个接口多次和单次，对资源所造成的影响是一致的**。

这里需要注意的是，幂等性关注的是对**资源**造成的影响，而非请求返回的结果。

例如我们设计了一个`GET`接口`api/getSystemTime`，用于返回服务器的实时时间，虽然每次返回的结果都是不一样的，但是对服务器来说并没有发生资源变动，所以也是幂等的。

一般来说，`GET`、`OPTIONS`、`HEAD`、`DELETE`这些请求方法都是幂等的，因为对服务器资源都是没有影响的，或是产生的影响是一致的。像`POST`、`PUT`、`PATCH`这些请求方法一般都是非幂等的。

当然，有一些业务场景下，我们需要用到`POST`接口，同时也要保证幂等性，我们也可以自己实现接口的幂等性。

<!--more-->

### 场景

一般我们定义**幂等性**接口的使用场景是防止出现多次请求而导致的服务结果不一致的情况。例如付款场景，用户在前端可能因为点击多次，发起了多次请求，如果这个时候接口不做好幂等性的话，可能会出现多次付款的情况。



### 思路

###### Token方式

实现幂等性可以从控制资源访问的次数下手。

即使有多个请求过来需要请求支付，我们只需要允许其中一次请求进行完整的支付流程，其他请求均放弃即可。

这样我们可以延伸出`token`的概念。

假设我们的系统由订单系统和支付系统两部分组成，当我们提交订单后，由订单系统向支付系统申请一个`token`，支付系统在生成后返回这个`token`，同时将`token`存至Redis缓存中。这样当我们向支付系统发起支付请求时，带上这个`token`，支付系统需要先判断一下在缓存中是否存在这个`token`，如果存在则删除这个`token`，同时继续执行支付逻辑；如果缓存中不存在这个`token`，则返回业务错误。

这里的`token`类似于一个信物，只有持有这个信物的人才允许被放行，放行后，这个信物也不再被信任，下次即使有携带相同信物来的人，也不给放行。



### 题外话

写到最后，突然想起来为啥要研究这个`幂等性`来着。

当时是在一个客户现场出现的生产问题，我们的应用程序，通过`nginx`往算法服务发送一个POST请求后，在经过大概10分钟，算法突然又被调用了一次，且收到的参数和第一次一摸一样。一开始以为是应用程序的问题，在公司的测试环境模拟了一遍，没有复现，后来怀疑可能是`nginx`做的鬼，问了现场，才知道现场使用的`nginx`版本是`1.8.1`（吐槽一下版本有点老）。然后在网上查阅资料，得知**1.9.13以前版本的nginx默认会将POST等非幂等请求做超时重试处理**。虽然我们的应用程序在往算法发起请求后，就不会再做什么后续处理，但坑的是算法会保持这个请求也不返回数据，导致`nginx`认为请求超时了，又发起了一波请求，血与泪哦。

由于不能让现场升级nginx，所以我们只能让现场在`nginx`中加大了那个算法接口的超时时间。



下面摘自`nginx`[官方文档](http://nginx.org/en/docs/http/ngx_http_proxy_module.html)。

> normally, requests with a [non-idempotent](https://tools.ietf.org/html/rfc7231#section-4.2.2) method (`POST`, `LOCK`, `PATCH`) are not passed to the next server if a request has been sent to an upstream server (1.9.13); enabling this option explicitly allows retrying such requests;

