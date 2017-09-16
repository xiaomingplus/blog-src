+++
date = "2016-07-04T09:52:18+08:00"
title = "使用流的思维方式来构建cycle.js前端应用"
categories = ["前端"]
tags = ["javascript","cyclejs","xStream"]
+++

流是在时间流逝的过程中产生的一系列事件的集合，和数组的概念类似，只不过流的索引是时间，它的值是事件。一个流或者一系列流可以作为另一个流的输入， 流在rxjs,xstream,most等库中是一等公民，而学习流最难的地方就在于思维方式的转变：**一切皆流！**

### 使用流来构建应用的优点主要有：

- 容易书写 
- 进一步抽象
- 容易阅读 
- 容易测试 
- 写起来爽

### 适用的场景主要有：

- 比较复杂的异步场景 
- 有大量基于异步数据流的操作
- 有大量交互
- 有很多回调深渊
- 实时响应

### 什么是流？

流主要用于异步数据流，我们平常所用的事件，比如click事件，input事件,http请求等这些都是异步数据流,不只是这些，我们可以为任何东西创建一个流,比如变量, 用户的输入, 属性, 缓存, 数据结构，所有的东西都可以创建为流来使用。比如说我们的朋友圈的时间轴的数据就可以是一个数据流,各个业务都可以订阅这个流做出相应的自己的逻辑。

用来创建和使用流的工具比如rxJs,xstream,most（按从重到轻排序）等流行的库均提供了一系列创建、合并、过滤、组合流的方法，并且这些方法都是函数式的！

一个流可以作为另一个流的输入，流是流世界里的一等公民，他可以emit出3种类型的信号，```next```,```error```,```complete```，订阅者可以在这些回调的方法里做对应的处理。

流是一个被观察者，观察者可以通过定义回调函数来监听它，流有点像是一个增强版的promise，区别在于promise是定义之后就执行，但是对于流来讲，必须有人订阅它，才会执行。promise的then只会被回调一次，而流的next可以被无限次回调，流可以实现promise能实现的所有的功能。

我们一般用$符结尾的变量名来命名流，表示其是一个可观测对象。 

接下来我们从几个小例子中开始学习一下流吧：

    //从dom事件中创建流
    import fromEvent from 'xstream/extra/fromEvent'

    const domInput$ = fromEvent(document.querySelector("#input"), 'input');

    //value流，这个流的输出是input的value,输入是domInput事件流
    const value$ = domInput$.map((event) => {
        console.log('event', event);
        return event.target.value;
    });

    //test流，这个流的输入是value流，输出是当value流里的值是'test'的时候
    const test$ = value$.filter((data) => {
        console.log('data',data);
        return data === "test"
    })

    //每个返回都是一个新的流，流是immutability的

    //订阅test流
    test$.subscribe({
         next:(data)=>{
             console.log('after filter',data);
         }
     }) 

    //我们也可以从promise中创建流
    const fromPromise$ = xs.fromPromise(new Promise((resolve, reject) => {
        resolve("test");
    }))

    //我们可以合并test流和promise流
    const allTest$ = xs.merge(fromPromise$, test$);

    /*
    //合并流方法执行的原理：

    stream A: ---a--------e-----o----->
    stream B: -----B---C-----D-------->
            vvvvvvvvv merge vvvvvvvvv
            ---a-B---C--e--D--o----->
    */

    //订阅合并流
    allTest$.subscribe({
        next:(data)=>{
            console.log('test',data);
        }
    })

    //下面是最原始的创建流的方法

    const stream$ = xs.create({
        start: function (listener) {
            let i = 1;
            this.id = setInterval(() => {
                listener.next(i++)
            }, 1000);
        }, //当有订阅者订阅的时候才开始执行,懒执行的
        stop: function (listener) {
            clearInterval(this.id);
        }, //当订阅者取消订阅时，会回调这个stop
        id: 0
    })
cycle.js是一个基于函数式和适用于处理异步数据流的js框架.

比如点击事件，http请求事件这些都是异步的数据流，在cycle.js里开发者可以观测这些数据流，并用特定的逻辑对它们进行处理。cycle.js默认使用```xstream```作为流的基础库，基于xstream你可以创建任意流。基于流的概念，xstream赋予了一系列对流进行操作的函数工具集，使用这些函数可以合并、创建、过滤这些流。 一个流或者一系列流可以作为另一个流的输入。你可以合并两个流，从一堆流中过滤你真正感兴趣的那一些，或者将值从一个流*映射*到另一个流。

cycle.js提出了Model-View-Intent模型
![](http://ww1.sinaimg.cn/large/d9f8fd81gy1fh9ap5dlsuj20f703aaa8.jpg)

它遵循的理念：

- 一切都是事件源
- 使用流的概念来构建整个应用的模型
- 使用driver来隔离有副作用的行为（如网络请求、DOM渲染、URL变化）

基于这套理念，我们的代码就像下面这样：

- 从driver流映射成action流
- 把action映射成数据流
- 把数据流映射成界面流

用通俗的话来讲就是，这个模型是无副作用的，dom或其他的输入作为入参，它给你输入啥，你对应的做处理，最后输出一个相应的dom就可以了。用代码里表示就是：
    
    /**
    @source里可以有DOM,HTTP等外界的事件来源
    @最终根据DOM的变化处理成一个虚拟dom返回就ok
    */
    function main(sources) {
        const actions = intent(sources.DOM);
        const state = model(actions);
        const vDom = view(state);
        return {DOM: vDom};
    }
