+++
date = "2016-07-24T18:50:34+08:00"
title = "理解javascript中的原型"
categories = ["前端"]
tags = ["javascript","prototype","原型"]

+++

## 概述

javascript的灵魂应该就是原型了吧，可以说在js里一切皆有原型的影子，js中用原型实现继承，使得我们在实例对象中除了可以访问实例对象自己的属性外，还可以访问到它的原型的属性，以及它的原型的原型的属性，只要在它的原型链里面我们就都能访问到。不过如果实例对象自身就有某个属性或方法，它就不会再去原型对象寻找这个属性或方法。JavaScript的每个对象都继承自另一个对象，后者称为“原型”（prototype）对象。只有null除外，它没有自己的原型对象。比如说我们定义一个简单的对象：

```
var o = {
  a:1,
  b:2
}
// 这里，我们不仅可以访问o自己的属性o.a，我们还可以访问的o的原型Object.prototype的所有属性，比如o.toString(),toString就是Object.prototype里的属性，Object.prototype也有自己的原型:null，null没有原型。
```
js提供了一个获取某个对象原型的方法```Object.getPrototypeOf()```，我们可以用这个方法来查看```o```的原型：

```
var oPrototype = Object.getPrototypeOf(o);
//我们会发现o的原型就等于下面的这个东西：
oPrototype === Object.prototype;

//而Object.prototype的原型等于null这个鬼东西
Object.getPrototypeOf(Object.prototype) === null;
```
## js中创建对象的方法
js中有至少3种方法来创建对象（同时会生成所创建对象的原型链）：

### 使用普通语法创建对象

```
var obj1 = {};

//这个时候obj1的原型链:
Object.getPrototypeOf(obj1) === Object.prototype;
Object.getPrototypeOf(Object.prototype) === null;
```

### 使用```Object.create```创建对象

```
var obj2 = Object.create(Object.prototype);

//这里的obj2其实和obj1是一毛一样的，{}其实相当于Object.create的语法糖，obj2的原型链也和obj1的一样，Object.create方法的第一个参数就是显式的指定要创建的对象的原型。
```

### 使用函数创建对象
```
//Object其实是一个函数

var obj3 = new Object();

//这里的obj3其实和obj1和2是一样的，用new来创建对象时，会把函数的prototype属性（这个示例中就是Object.prototype）作为创建对象的原型，也就是
Object.getPrototypeOf(obj3) === Object.prototype;

//事实上所有的函数都拥有一个prototype属性(事实上也只有函数才拥有这个属性)，所有使用new来创建的对象，他们的原型均是该函数的prototype,比如：

var F = function(){

};
var a = new F();

//这是a的原型
Object.getPrototypeOf(a) === F.prototype;

//我们可以a被创建后或创建之前给F.prototype增加一些属性，由于a的原型是F.prototype，所以在a上就能访问到F.prototype的所有属性

F.prototype.test = function(){
  return 1;
}
F.prototype.value = 2;

console.log(a.test()); // 1
console.log(a.value); //2


//所有继承F的对象，都拥有F.prototype的所有属性
var b = new F();

b.test();// 1  
b.value; //2
```

## 理解js中常见类型的原型链
这个时候，我们可以看看js中常见的一些类型比如数组、函数的原型链。

```
var arr1 = [];
//上面这个定义与下面的这个等价：
var arr2 = new Array(); //Array其实就是个函数，js环境默认给Array函数的prototype添加了一些属性，比如join,push等，所以数组其实就是Array函数的一个实例化对象，所以我们可以在数组中使用Array.prototype中所有的属性

//arr1和arr2的原型链均如下：
Object.getPrototypeOf(arr1) === Array.prototype;
Object.getPrototypeOf(Array.prototype) === Object.prototype;
Object.getPrototypeOf(Object.prototype) === null;
//null其实是所有对象原型的老祖宗
```
我们再来看看函数：
```
var fun1 = function(arg){return 1;}
var fun2 = new Function("arg","return 1;");
//fun1和fun2是全等的（但对于js引擎来讲fun1的效率更高，所以不推荐用fun2这种来定义函数
// fun1和fun2的原型链均如下：
Object.getPrototypeOf(fun1) === Function.prototype;
Object.getPrototypeOf(Function.prototype) === Object.prototype;
Object.getPrototypeOf(Object.prototype) === null;

```

在这里，我们不能用```Object.create()```来创建函数对象和数组,为什么呢？

```
//Object.create这个方法的定义其实就是下面这个：
Object.create = function (o) {
    function F() {}
    F.prototype = o;
    return new F();
  };

//所以我们只能说只要能用create来创建的对象就一定能用new来创建，反之则不然。因为使用new的话F这个函数里面可能要做一些处理，但是Object.create就无法做任何处理。
```
