+++
date = "2017-09-16T23:38:54+08:00"
title = "解决IFTT同步微博不能区分文字微博、图片微博、转发微博的问题"
tags = ["技术应用"]
categories = ["笔记"]
+++

如何只让你的原创文字微博，原创图片微博自动同步到其他平台？

很多人（包括我）都会使用IFTTT的同步服务来把自己的微博同步到其他第三方平台，目前来讲运行的还不错，但是其中有一个问题很困扰我：IFTTT并不能区分文字微博、图片微博、转发微博这几种类型的帖子从而同步对应类型的帖子到twitter/facebook（其实IFTTT付费用户是可以实现这一点的，但是这个需求付费199$有点不值得，所以我们可以寻求其他服务来解决这个问题），我的方法里还是以IFTTT为核心，以另一个类IFTTT工具[integromat](https://www.integromat.com)为过滤器来实现的。

其实国外有很多类似IFTTT的工具，比如Zapier,integromat,Microsoft,他们都提供了比IFTTT更加强大、自定义的功能，但是使用起来门槛相对高一点，但是非程序员一定能学会并使用，因为这些平台的目标群体本来就是非程序员群体。不过，这些工具基本都是收费的，免费用户只提供一点额度，所以说IFTTT还是非常良心的。我在这个教程里面使用的是[integromat](https://www.integromat.com)的服务来配合IFTTT，[integromat](https://www.integromat.com)提供的免费额度大概每个月能同步300+条微博，如果你不是话痨的话，应该够了吧。

需要说明的是：
这个方法适合所有人，并不复杂。 该方法可以过滤掉转发微博（直接转发（不带转发理由）/转发别人的转发微博)，并且区分出图片微博，原创微博（会把你直接带转发理由转发原创微博的转发微博（有点绕，我称为一级带文字转发），也当做原创微博），从而同步对应类型到其他平台。

## 原理

![](http://ww1.sinaimg.cn/large/006tV6Vmgy1fjlj3j4vcdj30p30o6q4j.jpg)

## 操作步骤

以同步到twitter为例（你可以参照这个同步到其他任何IFTTT支持的平台

1. 先在[IFTTT](https://ifttt.com/create)创建2个Applet，分别用于同步原创文字微博到twitter和同步原创图片微博到twitter. 
    - 同步原创文字微博到twitter
        - this:搜索webhook，并选择```webhook```->```Connect```->```Receive a web request```,Event Name填写```originalWeibo```,点击```Create trigger```
        - that:搜索twitter,并选择```twitter```->```Post a tweet```,Tweet text填写```{{Value1}}```,点击Create action
        - finish
    - 同步原创图片微博到twitter图片tweet
        - this:搜索webhook，并选择```webhook```->```Receive a web request```,Event Name填写```imageWeibo```,点击```Create trigger```
        - that:搜索twitter,并选择```twitter```->```Post a tweet with image```,Tweet text填写```{{Value1}}```,Image URL填写```{{Value2}}```,点击Create action
        - finish
    - 获取webhook的触发地址：ifttt的网站右上角，点击```Services```,搜索```Webhooks```,点击```Documentation```,不要关闭这个网页，这里的Key，待会要用到。

1. 登录[integromat](https://www.integromat.com/en/login),点击Create a new scenario,作用是接收ifttt请求，并过滤之后，再分别触发上面1中的2个ifttt的webhook规则，ifttt去处理接下来的事情。
    1. webhook步骤（图片见下）：点击?:搜索webhook，并选择```webhooks```->```Custom Webhook```,点击Webhooks图标，看到Webhook的下拉框，点击右侧的```Add```,```Webhook name```填写```IFTTT weibo webhook```,```Data structure```右侧点击```Add```,Data Structure name填写```Weibo data structure```,点击Generator,Content type选择```Query String```,Sample data填写:```text=text&image=imageUrl```,点击```Save```,Add data structure表单也点击```Save```,Add a hook也点击```Save```,你会在Webhooks看到一串如(https://hook.integromat.com/xxx)的url,把这个url记下来，待会儿用于ifttt触发微博后通知integromat
    ![](http://ww1.sinaimg.cn/large/006tV6Vmgy1fjlm9af9taj31g60pddj7.jpg)
    1. 点击webhook图标右边的半圆，选择```Router```,我们要在Router里做过滤:
        - 点击第一条分支的虚线中间部分，点击```set up a filter```,Lable填```image weibo```,点击```Condition```输入框，选左边的```image```,下拉框选择```exists```，点击OK，点击这条分支的末端？号，搜索```HTTP```,选择HTTP,选择```Make a request```,```https://maker.ifttt.com/trigger/imageWeibo/with/key/xxxxxx```,这里的xxxxxx要换成刚刚IFTTT步骤里最后一步获取到的Key,Method选择```POST```,Body Type选择```application/x-www-form-urlencode```,点击```Add item```,Key填```value1```,点击value的输入框，选择```text```,点击```Add item```,key填写```value2```,点击value的输入框，选择```image```,点击OK;
        - 点击第二条分支的虚线中间部分，点击```set up a filter```,Lable填```original weibo```,点击```Condition```输入框，选左边的```image```,下拉框选择```Does not exist```，点击右下角```Add and rule```,点击输入框，选择```text```,下拉框选择```Dose not matches Pattern(case insensitive)```,下面的输入框输入```(Repost)|(转发微博)|(\/\/)|(轉發微博)```,点击OK，点击这条分支的末端？号，搜索```HTTP```,选择HTTP,选择```Make a request```,```https://maker.ifttt.com/trigger/originalWeibo/with/key/xxxxxx```,这里的xxxxxx要换成刚刚IFTTT步骤里最后一步获取到的Key,Method选择```POST```,Body Type选择```Application/x-www-form-urlencode```,点击```Add item```,Key填```value1```,点击value的输入框，选择```text```,点击OK;
        - 点击左下角最后一个按钮，保存。点击[右上角Scenarios](https://www.integromat.com/scenarios)，在列表里找到你刚刚添加的scenarios，点击右侧的OFF/ON,打开这个任务。

1. 回到[IFTTT](https://ifttt.com/create),创建同步微博内容到integromat的webhook的触发器。

    - this:搜索weibo,选择```New post by you```
    - that:搜索webhook,选择```Make a web request```,URL填写刚刚第2步里面拿到的```https://hook.integromat.com/xxx```这样的一个url，Method选择```POST```,Content Type选择```application/x-www-form-urlencode```,Body填写```text={{Text}}&image={{PhotoURL}}```，点击```Create Action```，点击Finish

ok,到这里就全部搞定了！其实花费这些时间去搞这些，归根结底还是因为国内的这些服务接口做的太烂，用户不得不绕一个大圈去实现一些很简单的东西。这些厂商去看看telegram,stack,github的API估计会找个洞钻下去吧。

本篇文章只介绍了关于同步微博这一个应用，其实IFTTT,Zapier,integromat这些服务还可以实现更多，更牛逼的应用，比如当你回到家，自动开灯开空调，当你在微信、微博、浏览器中看到好文章准备稍后阅读时，自动在pocket里添加这篇文章并在todolist里创建一个待办任务，甚至当xxx发生的时候，自动往数据库添加一条记录。等等等等。而这一切都不需要你编程实现。