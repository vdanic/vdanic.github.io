---
title: Ubuntu软件支持和系统配置
date: 2016-11-20 23:07:31
tag: Linux
featured_image: "https://pic.danic.tech/blog/bg/bg-11.jpg"
---

在使用Ubuntu的时候，会经常出现一些问题，找了好久才能找到解决方法，再次列出一些平时安装时的问题和解决办法，不定时更新，吼吼。


## Ubuntu Android Studio 安装不了

 更新默认jdk

```
 # update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk1.8.0_05/bin/java 300
 # update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/jdk1.8.0_05/bin/javac 300
 # update-alternatives --config java
```
 安装32位支持

<!-- more -->

## Ubuntu indicator-sysmonitor

替换图标

```
 sudo gedit /usr/bin/indicator-sysmonitor
```

将 724 行的 sysmonitor 改为 application-community

开机自起

终端执行：
```
sudo mkdir ~/.config/autostart 
```

## Ubuntu sublime Text 3

Package Control

```javascript
 import urllib.request,os,hashlib; h = '2915d1851351e5ee549c20394736b442' + '8bc59f460fa1548d1514676163dafc88';
 pf = 'Package Control.sublime-package'; ipp = sublime.installed_packages_path();
 urllib.request.install_opener( urllib.request.build_opener( urllib.request.ProxyHandler()) );
 by = urllib.request.urlopen( 'http://packagecontrol.io/' + pf.replace(' ', '%20')).read();
 dh = hashlib.sha256(by).hexdigest();
 print('Error validating download (got %s instead of %s), please try manual install' % (dh, h)) if dh != h else open(os.path.join( ipp, pf), 'wb' ).write(by)
```

## Ubuntu wifi打不开

```
 sudo gedit /etc/modprobe.d/blacklist.conf
```

在最后一行加上

```
 blacklist acer-wmi
```
 
