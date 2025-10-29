---
title: 新姿势！Redis中调用Lua脚本以实现原子性操作
description: "学习使用Redis中的Lua脚本实现原子性操作"
date: 2019-06-07 23:07:41
tag: ["Redis", "Lua"]
featured_image: "https://pic.danic.tech/blog/bg/bg-09.jpg"
---

背景：有一服务提供者Leader，有多个消息订阅者Workers。Leader是一个排队程序，维护了一个用户队列，当某个资源空闲下来并被分配至队列中的用户时，Leader会向订阅者推送消息（消息带有唯一标识**ID**），订阅者在接收到消息后会进行特殊处理并再次推往前端。

问题：前端只需要接收到一条由Worker推送的消息即可，但是如果Workers不做消息重复推送判断的话，会导致前端收到多条消息推送，从而影响正常业务逻辑。



<!-- more -->

### 方案一（未通过）

在Worker接收到消息时，尝试先从redis缓存中根据消息的**ID**获取值，有以下两种情况：

- 如果值不存在，则表示当前这条消息是第一次被推送，可以执行继续执行推送程序，当然，不要忘了将当前消息**ID**作为键插入缓存中，并设置一个过期时间，标记这条消息已经被推送过了。
- 如果值存在，则表示当前这条消息是被推送过的，跳过推送程序。

代码可以这么写：

```java
public void waitingForMsg() {
    // Message Received.
    String value = redisTemplate.opsForValue().get("msg_pushed_" + msgId);
    if (!StringUtils.hasText(value)) {
        // 当不能从缓存中读取到数据时，表示消息是第一次被推送
        // 赶紧往缓存中插入一个标识，表示当前消息已经被推送过了
        redisTemplate.opsForValue().set("msg_pushed_" + msgId, "1");
        // 再设置一个过期时间，防止数据无限制保留
        redisTemplate.expire("msg_pushed_" + msgId, 20, TimeUnit.SECONDS);
        // 接下来就可以执行推送操作啦
        this.pushMsgToFrontEnd();
    }
}
```

看起来似乎是没啥问题，但是我们从redis的角度分析一下请求，看看是不是真的没问题。

```shell
> get msg_pushed_1		# 此时Worker1尝试获取值
> get msg_pushed_1		# Worker2也没闲着，执行了这句话，并且时间找得刚刚好，就在Worker1准备插入值之前
> set msg_pushed_1 "1"  # Worker1觉得消息没有被推送，插入了一个值
> set msg_pushed_1 "1"  # Worker2也这么觉得，做了同样的一件事
```

你看，还是有可能会往前端推送多次消息，所以这个方案不通过。

再仔细想一想，出现这个问题的原因是啥？———— 就是在执行get和set命令时，没有保持**原子性**操作，导致其他命令有机可趁，那是不是可以把get和set命令当成一整个部分执行，不让其他命令插入执行呢？

有很多方案可以实现，例如给键加锁或者添加事务可能可以完成这个操作。但是我们今天讨论一下另外一种方案，在Redis中执行Lua脚本。



### 方案二

我们可以看一下Redis官方文档对Lua脚本原子性的[解释](https://redis.io/commands/eval)。

> ## Atomicity of scripts
>
> Redis uses the same Lua interpreter to run all the commands. Also Redis guarantees that a script is executed in an atomic way: no other script or Redis command will be executed while a script is being executed. This semantic is similar to the one of [MULTI](https://redis.io/commands/multi) / [EXEC](https://redis.io/commands/exec). From the point of view of all the other clients the effects of a script are either still not visible or already completed.

大致意思是说：我们Redis采用相同的Lua解释器去运行所有命令，我们可以保证，脚本的执行是原子性的。作用就类似于加了MULTI/EXEC。



好，原子性有保证了，那么我们再看看编写语法。

```shell
> eval "return {KEYS[1],KEYS[2],ARGV[1],ARGV[2]}" 2 key1 key2 first second
1) "key1"
2) "key2"
3) "first"
4) "second"
```

由前至后的命令解释(Arg 表示参数的意思 argument)：

​    eval: Redis执行Lua脚本的命令，后接脚本内容及各参数。这个命令是从**2.6.0**版本才开始支持的。

​    1st. Arg : Lua脚本，其中的KEYS[]和ARGV[]是传入script的参数 。

​    2nd. Arg: 后面跟着的KEY个数n，从第三个参数开始的总共n个参数会被作为KEYS传入script中，在script中可以通过KEYS[1], KEYS[2]…格式读取，下标从1开始 。

​    Remain Arg: 剩余的参数可以在脚本中通过ARGV[1], ARGV[2]…格式读取 ，下标从1开始 。

我们执行脚本内容是`return {KEYS[1],KEYS[2],ARGV[1],ARGV[2]}`表示返回传入的参数，所以我们可以看到参数被原封不动的返回了。



接着，我们再来实战一下，在Lua脚本中调用Redis方法吧。

我们可以在Lua脚本中通过以下两个命令调用redis的命令程序 

- redis.call() 
- redis.pcall() 

两者的作用是一样的，但是程序出错时的返回结果略有不同。 

![img](http://pic.danic.tech/call_and_pcall.png)

使用方法，命令和在Redis中执行一模一样：

```shell
> eval "return redis.call('set', KEYS[1], ARGV[1])" 1 foo bar
OK
> eval "return redis.call('get', KEYS[1])" 1 foo
"bar"
```



是不是很简单，说了这么多，我们赶紧来现学现卖，写一个脚本应用在我们的场景中吧。

```shell
> eval "if redis.call('get', KEYS[1]) == false then redis.call('set', KEYS[1], ARGV[1]) redis.call('expire', KEYS[1], ARGV[2]) return 0 else return 1 end" 1 msg_push_1 "1" 10
```

脚本的意思和我们之前在**方案一**中写的程序逻辑一样，先判断缓存中是否存在键，如果不存在则存入键和其值，并且设置失效时间，最后返回0；如果存在则返回1。PS: 如果对`if redis.call('get', KEYS[1]) == false`这里为什么得到的结果要与false比较有疑问的话，可以看最后的Tip。

- 执行第一次：我们发现返回值0，并且我们看到缓存中插入了一条数据，键为`msg_push_1`、值为`"1"`

- 在失效前，执行多次：我们发现返回值一直为1。并且在执行第一次后的10秒，该键被自动删除。



将以上逻辑迁入我们java代码后，就是下面这个样子啦

```java
public boolean isMessagePushed(String messageId) {
    Assert.hasText(messageId, "消息ID不能为空");

    // 使用lua脚本检测值是否存在
    String script = "if redis.call('get', KEYS[1]) == false then redis.call('set', KEYS[1], ARGV[1]) redis.call('expire', KEYS[1], ARGV[2]) return 0 else return 1 end";

    // 这里使用Long类型，查看源码可知脚本返回值类型只支持Long, Boolean, List, or deserialized value type.
    DefaultRedisScript<Long> redisScript = new DefaultRedisScript<>();
    redisScript.setScriptText(script);
    redisScript.setResultType(Long.class);

    // 设置key
    List<String> keyList = new ArrayList<>();
    // key为消息ID
    keyList.add(messageId);

    // 每个键的失效时间为20秒
    Long result = redisTemplate.execute(redisScript, keyList, 1, 20);

    // 返回true: 已读、false: 未读
    return result != null && result != 0L;
}

public void waitingForMsg() {
    // Message Received.
    if (!this.isMessagePushed(msgId)) {
        // 返回false表示未读，接下来就可以执行推送操作啦
        this.pushMsgToFrontEnd();
    }
}
```



### Tip

这里只是简单的Redis中使用Lua脚本介绍，详细的使用方法可以参考官方文档，而且还有其他很多用法介绍。

对了，上面还有一个**坑**需要注意一下，就是关于Redis和Lua中变量的相互转换，因为说起来啰哩啰嗦的，所以没放在上文中，最后可以简单说一下。

> **Redis to Lua** conversion table.
>
> - Redis integer reply -> Lua number
> - Redis bulk reply -> Lua string
> - Redis multi bulk reply -> Lua table (may have other Redis data types nested)
> - Redis status reply -> Lua table with a single ok field containing the status
> - Redis error reply -> Lua table with a single err field containing the error
> - Redis Nil bulk reply and Nil multi bulk reply -> Lua false boolean type    // 这里就是上面我们在脚本中做是否为空判断的时候`if redis.call('get', KEYS[1]) == false`，采用与false比较的原因。Redis的nil(类似null)会被转换为Lua的false
>
> **Lua to Redis** conversion table.
>
> - Lua number -> Redis integer reply (the number is converted into an integer)
> - Lua string -> Redis bulk reply
> - Lua table (array) -> Redis multi bulk reply (truncated to the first nil inside the Lua array if any)
> - Lua table with a single ok field -> Redis status reply
> - Lua table with a single err field -> Redis error reply
> - Lua boolean false -> Redis Nil bulk reply.

注意点： 

​    Lua的Number类型会被转为Redis的Integer类型，因此如果希望得到小数时，需要由Lua返回String类型的数字。 