---
title: ios-stanford-1
date: 2017-12-31 21:44:56
tags:
---

# what‘s in iOS？

## Core OS:

iOS基本就是一个基于Unix的操作系统，它大量借鉴了Mac OS X的内核部分。
所以Core OS部分，包含了Sockets,Security,BSD,Mach 3.0,OSX Kernal, Power Management, Keychain Access, Certifications, File System Bonjour.这些实现一个操作系统的部分。

## Core Services:

这是一个能够让开发者使用大量的面向对象编程技术，但这层不包括ui，而是更多用于通过面向对象编程的方式访问硬件或者访问网络等等。我们需要耗费很多的时间，因为我们需要这些原始组件来建立更高的层。
包括了Collections,Address Book,Networking,FileAccess, SQLite, CoreLocation,Net Services, Threading, Preferences, URL Utilities.

## Media

Core Audio, OpenAL, Audio Mixing, Audio Mixing, Audio Recording, Video Playback, JPEG/PNG/TIFF, PDF, Quartz(2D), Core Animation, OpenGL ES.

## Cocoa Touch

Multi-Touch, Alerts, Core Motion, Web View, View Hierarchy, Map kit, Localization, Image Picker, Controls, Camera
使用这些与用户互动

# MVC

MVC是一种设计模式，更有利于阅读代码。而iOS从一开始就使用MVC设计，这是构建iOS的一种方法。

# Demo

