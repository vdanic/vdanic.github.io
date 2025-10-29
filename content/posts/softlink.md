---
title: Linux中软连接的应用
date: 2016-12-20 19:32:05
description: "Linux中软连接的使用学习"
tag: linux 
featured_image: "https://pic.danic.tech/blog/bg/bg-10.jpg"
---

linux中的软连接类似于windows中的快捷方式，可以快捷得访问目标文件或文件夹。

### 命令格式

> ln -s [源文件或目录][目标文件或目录]

#### 示例：
![Alt text](http://pic.danic.tech/softlink/view4.png)
以上创建的是一个指向idea启动脚本的一个软连接，并命名为start-idea。
![Alt text](http://pic.danic.tech/softlink/view5.png)
运行start-idea即运行idea.sh

<!-- more -->

### 软连接的应用

在编写java时，可能会遇到需要切换jdk版本的时候，一种方法是改变环境变量中的$JAVA_HOME，指向指定版本的jdk。但在每次修改中，会发现将对应版本的文件目录名复制进环境变量，然后再source一下环境变量将会是一件麻烦的事。软连接将会方便很多。
#### 示例:
![Alt text](http://pic.danic.tech/softlink/view1.png)
先建立一个指向目标jdk的一个软连接
![Alt text](http://pic.danic.tech/softlink/view2.png)
然后将环境变量中的JAVA_HOME指向先前创建的软连接
source一下环境变量后，大功告成！
接下来看看效果吧。
![Alt text](http://pic.danic.tech/softlink/view3.png)


