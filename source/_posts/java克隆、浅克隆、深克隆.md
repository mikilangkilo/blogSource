---
title: java克隆、浅克隆、深克隆
date: 2018-04-04 14:29:51
tags: java
---

# 克隆

当我们需要有一个当前对象的克隆体，和当前对象完全相同的属性、功能，但又不想去仅仅创建一个对象的引用时，我们就需要对对象进行克隆。

克隆clone，是创建了一个一摸一样的对象。该方法是object的方法，平时用不到是因为这个方法是protect属性的。

需要用到clone方法的时候，直接覆盖父类的方法，定义成public，然后写super.clone()。或者直接自己写一个clone方法也可以。同时不要忘了记成clonable接口。

# 浅克隆

被复制对象的所有变量都含有与原来的对象相同的值，而所有的对其他对象的引用仍然指向原来的对象。换言之，浅复制仅仅复制所考虑的对象，而不复制它所引用的对象。

继承自object的clone方法，就是浅克隆，除非对引用也使用clone的方法。

没啥大用。

# 深克隆

被复制对象的所有变量都含有与原来的对象相同的值，除去那些引用其他对象的变量。那些引用其他对象的变量将指向被复制过的新对象，而不再是原有的那些被引用的对象。换言之，深复制把要复制的对象所引用的对象都复制了一遍。

深克隆可以使用序列化的方法。

精髓主要是将对象写入流中，然后在从流中都取出来。这样就实现了一个对象的深克隆。

前提是对象都是序列化的，不论成员还是引用。

```
public Object deepClone() throws IOException,OptionalDataException,ClassNotFoundException{//将对象写到流里
ByteArrayOutoutStream bo=new ByteArrayOutputStream();
ObjectOutputStream oo=new ObjectOutputStream(bo);
oo.writeObject(this);//从流里读出来
ByteArrayInputStream bi=new ByteArrayInputStream(bo.toByteArray());
ObjectInputStream oi=new ObjectInputStream(bi);
return(oi.readObject());

```



