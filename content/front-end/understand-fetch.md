+++
date = "2016-09-24T02:52:18+08:00"
title = "学会fetch的用法"
categories = ["前端"]
tags = ["javascript","fetch"]
+++

fetch是web提供的一个可以获取异步资源的api，目前还没有被所有浏览器支持，它提供的api返回的是Promise对象，所以你在了解这个api前首先得了解Promise的用法。参考[阮老师的文章](http://javascript.ruanyifeng.com/advanced/promise.html)

那我们首先讲讲在没有fetch的时候，我们是如何获取异步资源的：

```
//发送一个get请求是这样的:

//首先实例化一个XMLHttpRequest对象
var httpRequest = new XMLHttpRequest();

//注册httpRequest.readyState改变时会回调的函数,httpRequest.
//readyState共有5个可能的值,
//0	UNSENT (未打开)	open()方法还未被调用;
//1	OPENED  (未发送)	send()方法还未被调用;
//2	HEADERS_RECEIVED (已获取响应头)	send()方法已经被调用, 响应头和响应状态已经返回;
//3	LOADING (正在下载响应体)	响应体下载中; responseText中已经获取了部分数据;
//4	DONE (请求完成)	整个请求过程已经完毕.
httpRequest.onreadystatechange = function(){
 //该回调函数会被依次调用4次
 console.log(httpRequest.readyState);

 if(httpRequest.readyState===4){
   //请求已完成
   if(httpRequest.status===200){
     //http状态为200
     console.log(httpRequest.response);

     var data = JSON.parse(httpRequest.response);
     console.log(data);
   }
 }

}

//请求的网址
var url = "http://127.0.0.1:7777/list";
//该方法为初始化请求,第一个参数是请求的方法,比如GET,POST,PUT,第二个参数是请求的url
httpRequest.open('GET',url,true);

//设置http请求头
httpRequest.setRequestHeader("Content-Type","application/json");

//发出请求,参数为要发送的body体,如果是GET方法的话，一般无需发送body,设为空就可以
httpRequest.send(null);

```
关于XMLHttpRequest的更多用法请参照:[https://developer.mozilla.org/zh-CN/docs/Web/API/XMLHttpRequest#open()](https://developer.mozilla.org/zh-CN/docs/Web/API/XMLHttpRequest#open())

如果用了fetch之后，发送一个get请求是这样的：

```
//请求的网址
var url = "http://127.0.0.1:7777/list";
//发起get请求
var promise = fetch(url).then(function(response) {

   //response.status表示响应的http状态码
   if(response.status === 200){
     //json是返回的response提供的一个方法,会把返回的json字符串反序列化成对象,也被包装成一个Promise了
     return response.json();
   }else{
     return {}
   }

});
    
promise = promise.then(function(data){
  //响应的内容
	console.log(data);
}).catch(function(err){
	console.log(err);
})
```

接下来介绍下fetch的语法:

```
/**
参数:
input:定义要获取的资源。可能的值是：一个URL或者一个Request对象。
init:可选,是一个对象，参数有：
	method: 请求使用的方法，如 GET、POST。
	headers: 请求的头信息，形式为 Headers 对象或 ByteString。
	body: 请求的 body 信息：可能是一个 Blob、BufferSource、FormData、URLSearchParams 或者 USVString 对象。注意 GET 或 HEAD 方法的请求不能包含 body 信息。
	mode: 请求的模式，如 cors、 no-cors 或者 same-origin,默认为no-cors,该模式允许来自 CDN 的脚本、其他域的图片和其他一些跨域资源，但是首先有个前提条件，就是请求的 method 只能是HEAD、GET 或 POST。此外，如果 ServiceWorkers 拦截了这些请求，它不能随意添加或者修改除这些之外 Header 属性。第三，JS 不能访问 Response 对象中的任何属性，这确保了跨域时 ServiceWorkers 的安全和隐私信息泄漏问题。cors模式允许跨域请求,same-origin模式对于跨域的请求，将返回一个 error，这样确保所有的请求遵守同源策略。
	credentials: 请求的 credentials，如 omit、same-origin 或者 include。
	cache:  请求的 cache 模式: default, no-store, reload, no-cache, force-cache, or only-if-cached.
返回值：一个 Promise，resolve 时回传 Response 对象。
*/
fetch(input, init).then(function(response) {  });
```

一个发送post请求的示例:

```
fetch("http://127.0.0.1:7777/postContent", {
  method: "POST",
  headers: {
      "Content-Type": "application/json",
  },
  mode: "cors",
  body: JSON.stringify({
      content: "留言内容"
  })
}).then(function(res) {
  if (res.status === 200) {
      return res.json()
  } else {
      return Promise.reject(res.json())
  }
}).then(function(data) {
  console.log(data);
}).catch(function(err) {
  console.log(err);
});
```
如果考虑低版本浏览器的问题的话，引入https://github.com/github/fetch/blob/master/fetch.js 即可兼容。

参考：http://bubkoo.com/2015/05/08/introduction-to-fetch/

