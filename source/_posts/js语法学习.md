---
title: js语法学习
date: 2018-02-08 10:50:54
tags: javascript
---

今年过年一周时间需要用来充电，目前目标就是啃一下<JavaScript Dom编程艺术>这本书。

#### 语法

1. 语句

```
	first statement
	second statement
```

```
	first statement; second statement;
```

```
	first statement;
	second statement;
```

以上三种都是可行的。

2. 注释

```
	// 这可以代表一行注释
```

```
	// 这可以代表多行注释第一行 
	// 这可代表多行注释第二行
```

```
	/* 多行注释
		第二种写法*/
```

```
	<!-- html风格注释，功能等同于//，不推荐使用，不需要使用html的-->结尾
```

3. 变量

javascript是一个弱类型语言

变量声明

```
	var mood;
	var age;
```

```
	var mood, age;
```

```
	var mood = "happy";
	var age = 33;
```

```
	var mood = "happy", age = 33;
```

```
	var mood, age;
	mood = "happy";
	age = 33;
```

以上声明都可以。js区分大小写。

变量命名不允许包含空格或者标点符号，可以在适当的地方插入下划线。美元符号也可以。
也可以使用驼峰格式

4. 数据类型

javascript是弱类型语言，可以在任何阶段改变变量的数据类型。

+ 字符串

字符串由0个或者多个字符构成，字符包括不限于字母、数字、标点符号和空格。字符必须包在引号里面，单引号或者双引号都可以。
可以随意选用引号，单最好根据字符串所包含的字符来选择，如果字符串包含双引号，就将字符放入单引号里面。

字符的转义也是和java一样的使用\符号

+ 数值

javascript允许使用带小数点的数值，并且允许任意位小数，这样的数称为浮点数。

```
	var age = 33.35;
```

+ 布尔值

```
	var sleeping = true;
```

5. 数组

可以声明带长度的数组
```
	var beatles = Array(4);
```

也可以声明不带长度的数组
```
	var beatles = Array();
```

数据填充方式如下
```
	array[index] = element;
```

也可以声明的时候赋值
```
	var beatles = Array("John", "Paul", "George", "Ringo");
```

也可以不明确声明数组
```
	var beatles = ['John', 'Paul', 'George', 'Ringo'];
```

数组使用方式较为灵活，可以使用变量添加数组，数组数据类型可以不固定，还可以数组中包含其他数组。

关联数组类似于key2value的pojo

```
	var lennon = Array();
	lennon["name"] = "John";
	lennon["year"] = 1940;
	lennon["living"] = false;
```

并不推荐使用。可以直接使用object

6. 对象

对象也是使用一个名字表示一组值。对象的每个值都是对象的一个属性。

```
	var lennon = Object();
	lennon.name = "John";
	lennon.year = 1940;
	lennon.living = false;
```

或者使用一种更简洁的“花括号语法”

```
	var lennon = {name:"John", year:1940, living:false};
```

#### 函数

需要多次使用同一段代码，可以把他们封装成一个函数，

```
	function multiply(num1, num2){
		var total = num1 * num2;
		alert(total);
	}
```

```
	function convertToCelsius(temp){
		var result = temp - 32;
		result = result/1.8;
		return result;
	}
```


#### 对象

javascript里面，属性和方法都使用“点”语法来访问

```
	var jeremy = new Person;
	alert(jeremy.age);
	alert(jeremy.mood);
```

+ 内建对象

内建对象是在new的时候就会自动创建的内在对象，比如说new出一个array，就自带了length对象。

+ 宿主对象

javascript脚本里面可以使用一些已经预先定义好的其他对象，这些对象不是由javascript语言本身而是由它的运行环境提供的。具体到web里面，这个环境就是浏览器，由浏览器提供的预定义对象被称为宿主对象。

#### DOM

+ getElementById

DOM提供了一个名为getElementById的方法，这个方法将返回一个与那个有着给定id属性值的元素节点对应的对象

+ getElementsByTagName

该方法返回一个对象数组，每个对象分别对应着文档里有着给定标签的一个元素

+ getElementsByClassName

这个方法能够通过class来访问元素，返回一个具有相同类名的元素组。但是该方法需要较新的浏览器才可以使用，否则就要自己实现。

```
	function getElementsByClassName(node, classname){
		if(node.getElementsByClassName){
			return node.getElementsByClassName(classname);
		}else{
			var results = new Array();
			var elems = node.getElementsByTagName("*");
			for (var i = 0; i < elems.length; i++){
				if(elems[i].className.indexOf(classname) != -1){
					results[results.length] = elems[i];
				}
			}
			return results;
		}
	}
```

+ getAttribute

getAttribute是一个函数，它只有一个参数，打算查询的属性的姓名，getAttribute()方法不属于document对象，所以不能通过document对象调用，只能通过元素节点对象调用。

```
	var paras = document.getElementsByTagName("p");
	for(var i = 0; i < paras.length; i++){
		alert(paras[i].getAttribute("title"));
	}
```

+ setAttribute

setAttribute允许对节点值进行修改

```
	var shopping = document.getElementById("purchases");
	shopping.setAttribute("title", "a list of goods");
```





