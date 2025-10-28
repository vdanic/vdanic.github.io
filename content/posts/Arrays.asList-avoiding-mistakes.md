---
title: Arrays.asList避坑
date: 2018-07-20 15:07:41
tag: ["Java"]
featured_image: "https://pic.danic.tech/blog/bg/bg-01.jpg"
---

​	今天在开开心心写代码的时候，对一个List进行add操作时突然提示 **UnsupportedOperationException** 错误，一开始还以为是我add的参数不对，调试了半天，后来想想，这报错和参数类型没有半毛钱关系啊，该错误翻译过来是__不支持的操作类型__，真想抽自己俩巴掌，没仔细审题。然后去网上查了下这个错误，搞明白了这个错误产生的原因。

​	产生这个错误主要是因为List中的`add()`方法没有被重写，然后查看代码发现，我调用的List是通过 `Arrays.asList(String [])` 方法生成的，这个方法的作用主要是根据传入的数组，生存对应的List集合，生成的集合是Arrays类中的一个内部类，并没有重写继承自父类`AbstractList`的`add()`和`remove()`方法，而在没有重写`add()`的情况下，`AbstractList`中的`add()`方法是默认抛出一个__UnsupportedOperationException__。

​	解决方案：将其转换成`java.util.ArrayList`，这个`ArrayList`是重写了`add()`方法的，我们可以放心大胆使用。

```java
	List<String> foo = new ArrayList<String>(Arrays.asList(String []));
```

<!-- more -->

​	接下来我们看一下`ArrayList`的构造方法

```java
    public ArrayList(Collection<? extends E> c) {
        elementData = c.toArray();
        if ((size = elementData.length) != 0) {
            // c.toArray might (incorrectly) not return Object[] (see 6260652)
            if (elementData.getClass() != Object[].class)
                elementData = Arrays.copyOf(elementData, size, Object[].class);
        } else {
            // replace with empty array.
            this.elementData = EMPTY_ELEMENTDATA;
        }
    }
```

​	我们可以发现，该构造方法会调用`toArray()`方法将传入的集合转换成`Object[]`类型，并存入__elementData__变量中，如果转换后的数据类型不是`Object[]`类型，则会将其拷贝成`Object[]`类型并存入__elementData__变量中。

​	所以说，有问题，第一时间看看源码，说不定就懂了。