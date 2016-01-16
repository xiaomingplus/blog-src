+++
date = "2016-01-16T18:21:09+08:00"
title = "nodejs中exports和module.exports的区别"

+++

**用一句话来说明就是，require方能看到的只有module.exports这个对象，它是看不到exports对象的，而我们在编写模块时用到的exports对象实际上只是对module.exports的引用**


如果你能理解上面这句话，那么下面的都是废话，可以不用看了，因为是用来解释上面这句话的。

关于引用，可以用下面的例子来让你搞得请清楚楚的：


首先说一个概念：

ECMAScript的变量值类型共有两种：

基本类型 (primitive values) ： 包括Undefined, Null, Boolean, Number和String五种基本数据类型；

引用类型 (reference values) ： 保存在内存中的对象们，不能直接操作，只能通过保存在变量中的地址引用对其进行操作。

我们今天要讨论的exports和module.exports属于Object类型，属于引用类型。

看下面的例子：

	var module = {
	    exports:{
	        name:"我是module的exports属性"
	    }
	};
	var exports = module.exports;  //exports是对module.exports的引用，也就是exports现在指向的内存地址和module.exports指向的内存地址是一样的
	
	console.log(module.exports);    //  { name: '我是module的exports属性' }
	console.log(exports);   //  { name: '我是module的exports属性' }
	
	
	exports.name = "我想改一下名字";
	
	
	console.log(module.exports);    //  { name: '我想改一下名字' }
	console.log(exports);   //  { name: '我想改一下名字' }
	//看到没，引用就是a和b都操作同一内存地址下的数据
	
	
	//这个时候我在某个文件定义了一个想导出的模块
	var Circle = {
	    name:"我是一个圆",
	    func:function(x){
	        return x*x*3.14;
	    }
	};
	
	exports = Circle;  //   看清楚了，Circle这个Object在内存中指向了新的地址，所以exports也指向了这个新的地址，和原来的地址没有半毛钱关系了
	
	console.log(module.exports);    //  { name: '我想改一下名字' }
	console.log(exports);   // { name: '我是一个圆', func: [Function] }
		
		
		
		
	
	
	
回到nodejs中，module.exports初始的时候置为```{}```,exports也指向这个空对象。

那么，这样写是没问题的：

	exports.name = function(x){
	    console.log(x);
	};
	
	//和下面这个一毛一样，因为都是修改的同一内存地址里的东西
	
	
	module.exports.name = function(x){
	    console.log(x);
	};

但是这样写就有了区别了：

	exports = function(x){
	    console.log(x);
	};
	
	//上面的 function是一块新的内存地址，导致exports与module.exports不存在任何关系，而require方能看到的只有module.exports这个对象，看不到exports对象，所以这样写是导不出去的。
	
	//下面的写法是可以导出去的。说句题外话，module.exports除了导出对象，函数，还可以导出所有的类型，比如字符串、数值等。
	module.exports = function(x){
	    console.log(x);
	};

我讲清楚了吧？

