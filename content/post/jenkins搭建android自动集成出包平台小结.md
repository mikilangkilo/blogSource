---
title: "Jenkins搭建android自动集成出包平台小结"
date: 2019-06-25T13:40:24+08:00
---

平台 ： centos

## 1 安装jenkins环境

```
wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo

rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key

yum install -y jenkins
```

yum失败则

```
wget http://pkg.jenkins-ci.org/redhat-stable/jenkins-2.7.3-1.1.noarch.rpm

rpm -ivh jenkins-2.7.3-1.1.noarch.rpm
```

## 2 启动

```
service jenkins start/stop/restart
```

## 3 网页输入ip:8080

进服务器找到对应的密码，然后输入让jenkins启动

## 4 安装git，gradle

选择安装性的

