---
title: 对JAVA内部类的一些认知
date: 2017-05-14 12:13:48
tags: Java
description: "学习一下JAVA内部类的知识"
featured_image: "https://pic.danic.tech/blog/bg/bg-05.jpg"
---

 这是我今天在牛客网做的一道练习题
```java
class Person {
    String name = "No name";
    public Person(String nm) {
        name = nm;
    }
}
class Employee extends Person {
    String empID = "0000";
    public Employee(String id) {
        empID = id;
    }
}
public class Test {
    public static void main(String args[]) {
        Employee e = new Employee("123");
        System.out.println(e.empID);
    }
}
 
```
 当时虽然是做对了，但是一看解答，咦，为何与我预想的不一样。

 **我的想法**：`Employee`作为一个成员内部类，外部类应该不能直接访问其中的成员变量，需要通过内部类才能访问。

 然鹅，你们应该也看出来了，`Employee`类并非什么内部类，当时对这一块概念并非特别了解，真的是瞎猫碰上死耗子。

 **正解**： 子类构造方法总是先调用父类的构造方法，如果子类的构造方法没有显式地调用父类的某个构造方法，子类就调用父类不带参的构造方法，但是`Person`类并没有无参构造函数，所以会报错。

 **解决方法一**：在`Employee`的构造函数里调用父类的构造函数，如下所示
```java
public Employee(String id) {
    super("nnn"); // 这里调用父类的构造函数
	empID = id;
}
```
 **解决方法二**：在`Person` 类中添加一个无参的构造函数

 顺便做了一下java内部类的功课，且听我细细道来。。

### 知识点：内部类
 内部类大致可分为四种
<!--more-->
**1 .  成员内部类**
```java
public class Outer{
	class Inner{} // 成员内部类
	public static void main(String args[]) {
	}
}
```
 成员内部类即外部类的一个成员。

 作为外部类的一个成员，它有一个特殊的地方，即它**可以访问外部类的所有属性**，即使这个属性是`private`的，但是外部类不能直接访问他的成员内部类，需通过内部类的对象获取。

 并且成员内部类不能有static的变量和方法，因为**成员内部类的创建是在外部类创建之后的**。图中是样例代码编译所产生的文件

 ![java inner class](http://pic.danic.tech/javaclass/outer&inner.png)

 当需要创建一个成员内部类对象的时候，则可以通过外部类对象创建，例：`Inner inner = new Outer().new Inner();`

 插播一曲～～因为`java`中非静态内部类对象的创建依赖其外部类对象，而在静态方法中，例如主函数，没有`this`，也就是说没有所谓的外部类对象，所以需先创建一个外部类对象，然后才能通过这个外部类对象创建一个内部类对象

**2 . 局部内部类**
```java
interface Demo{}
public class Outer{

    public Demo func() {
        class Inner implements Demo{} // 局部内部类
        return new Inner();
    }

    public static void main(String args[]) {
    }
}
```
 局部内部类，是指内部类定义在方法或作用域内。

 局部内部类的作用域，只在该方法或者条件内，超出这些作用域，便无法再被引用。

**3 .嵌套内部类**
```java
public class Outer{
    static class Inner{ // 嵌套内部类
        public static int a = 1;
    }

    public static void main(String args[]) {
        System.out.println(Outer.Inner.a);
    }
}
```

嵌套内部类，修饰为static的内部类，可直接通过Outer.Inner调用方法，无需创建外部类对象或内部类对象。

 需要注意的一点是，嵌套内部类一般声明为public，方便调用。

 **4 .匿名内部类**
```java
interface Inner{ // 一定要有这个接口的定义，不然编译会报错
    void func(); // java中默认接口的方法是public和abstract的
}

public class Outer{
    
    public Inner getInner() {
        return new Inner() { // 匿名内部类
            @Override
            public void func() {
                System.out.println("I am Inner Class");
            }
        };
    }
    
    public static void main(String args[]) {
    }
}
```
 匿名内部类，是指没有名字的内部类，只能被利用一次，通常用来简化代码。

 例如`java` 中Thread类的匿名内部类实现
```java
public class Outer{

    public static void main(String args[]) {
        Thread t = new Thread() {
            @Override
            public void run() {
                for(int i = 0; i < 5; i++) {
                    System.out.println(i);
                }
            }
        };
        t.start(); // 输出0,1,2,3,4
    }
} 
```



 
