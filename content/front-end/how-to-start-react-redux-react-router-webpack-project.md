+++
date = "2016-04-16T02:52:18+08:00"
title = "如何使用webpack开始一个react项目?"
categories = ["前端"]
tags = ["javascript","react","react-router","webpack"]
+++

本文是讲实战操作的，会使用到react,react-router,webpack,babel,react热启动,webpack热启动等，而且本文不准备对原理等进行说明，只想让新手能迅速自己动手生成自己的第一个demo，想了解原理的朋友推荐以下两个教程，讲的非常好。

- http://survivejs.com/webpack/advanced-techniques/configuring-react/
- http://cn.redux.js.org/index.html

第一个是一个讲webpack的配置的教程，是英文版的，有国内的翻译，但是太旧了，所以推荐看英文版本的，第二个是国内翻译的redux教程文档，讲的非常好，暂时还挺新的，如果想看英文版，里面也有对应的链接。

直接开始吧，本文只讲如何配置，以及如何写一个简单的示例。

**注意！！！本文在os操作系统下保证可以运行，其他操作系统请勿跟随该示例。**

第一步：

	mkdir react-demo
	cd react-demo
	npm init -y
	npm i webpack webpack-dev-server html-webpack-plugin webpack-merge babel-loader babel-core css-loader style-loader babel-preset-react-hmre babel-preset-es2015 babel-preset-react -D
	mkdir app
	mkdir dist
	mkdir assets
	touch assets/index.tmpl.html

第二步，编辑index.tmpl.html为如下:

	<!DOCTYPE html>
	<html>
	<head>
	    <meta http-equiv="Content-type" content="text/html; charset=utf-8"/>
	    <title><%= htmlWebpackPlugin.options.title %></title>
	</head>
	<body>
	<div id="root"></div>
	</body>
	</html>

第二步，打开你的`package.json`文件,添加如下字符串:

	...
	"scripts": {	
	  "build": "webpack",
	  "start": "webpack-dev-server"
	},
	"babel":{
	  "presets": [
	    "es2015",
	    "react"
	  ],
	  "env": {
	      "start": {
	        "presets": [
	          "react-hmre"
	        ]
	      }
	    }
	}
	...
	
第三步：在根目录新建一个`webpack.config.js`的文件,写入如下配置
	
	const path = require('path');
	const HtmlWebpackPlugin = require('html-webpack-plugin');
	const webpack = require('webpack');
	const merge = require('webpack-merge');
	const TARGET = process.env.npm_lifecycle_event;
	process.env.BABEL_ENV = TARGET;
	const PATHS = {
	  app: path.join(__dirname, 'app'),
	  build: path.join(__dirname, 'dist'),
	  template: path.resolve(__dirname, 'assets', 'index.tmpl.html'),
	};
	const common = {
	  entry: {
	    app: PATHS.app,
	  },
	  output: {
	    path: PATHS.build,
	    filename: 'bundle.js',
	  },
	  plugins: [
	    new HtmlWebpackPlugin({
	      title: 'react demo',
	      template: PATHS.template,
	      inject: 'body',
	    }),
	  ],
	  module: {
	    loaders: [{
	      test: /\.jsx?$/,
	      loaders: ['babel?cacheDirectory'],
	      include: PATHS.app,
	    }, {
	      test: /\.css$/,
	      loaders: ['style', 'css'],
	      include: PATHS.app,
	    }],
	  },
	  resolve: {
	    extensions: ['', '.js', '.jsx'],
	  },
	};
	if (TARGET === 'start' || !TARGET) {
	  module.exports = merge(common, {
	    devtool: 'eval-source-map',
	    devServer: {
	      contentBase: '/dist',
	      historyApiFallback: true,
	      hot: true,
	      inline: true,
	      progress: true,
	      stats: 'errors-only',
	    },
	    plugins: [
	      new webpack.HotModuleReplacementPlugin(),
	    ],
	
	  });
	}
	if (TARGET === 'build') {
	  module.exports = merge(common, {});
	}

	
第四步：到这里，关于react的需要的webpack方面的配置就结束了，接下来我们来写一个很小的示例来生成一个真正的react文件。
	
	npm i react react-dom react-router -S
	touch app/App.jsx
	touch app/index.jsx


编辑`App.jsx`文件如下:

	import React, { Component } from 'react';
	import {
	    Router,
	    Route,
	    Link,
	    IndexLink,
	    IndexRoute,
	    hashHistory,
	} from 'react-router';
	
	const activeStyle = {
	  color: '#53acff',
	};
	const Nav = () => (
	    <div>
	        <IndexLink onlyActiveOnIndex activeStyle={activeStyle} to="/">主页</IndexLink>
	        &nbsp;
	        <IndexLink onlyActiveOnIndex activeStyle={activeStyle} to="/address">地址</IndexLink>
	        &nbsp;
	    </div>
	);
	
	const Container = (props) => <div>
	    <Nav /> { props.children }
	</div>;
	
	const Twitter = () => <div>@xiaomingplus twitter</div>;
	const Instagram = () => <div>@xiaomingplus instagram</div>;
	
	const NotFound = () => (
	    <h1>404.. 找不到该页面!</h1>
	);
	const Home = () => <h1>你好，这是主页。</h1>;
	const Address = (props) => <div>
	    <br />
	    <Link activeStyle={{ color: '#53acff' }} to="/address">这是Twitter</Link> &nbsp;
	    <Link to="/address/instagram">这是Instagram</Link>
	    <h1>欢迎互关！</h1>
	    { props.children }
	</div>;
	
	
	class App extends Component {
	  construct() {
	  }
	  render() {
	    return (
	        <Router history={hashHistory}>
	            <Route path="/" component={Container}>
	                <IndexRoute component={Home} />
	                <Route path="/address" component={Address}>
	                    <IndexRoute component={Twitter} />
	                    <Route path="instagram" component={Instagram} />
	                </Route>
	                <Route path="*" component={NotFound} />
	            </Route>
	        </Router>
	    );
	  }
	}
	
	export default App;
	
编辑`index.jsx`文件:

	import React from 'react';
	import ReactDOM from 'react-dom';
	import App from './App.jsx';
	
	ReactDOM.render(
	    <App />, document.getElementById('root'));
	    
ok,到这里你已经实用react-router构建了一个有路由的应用，接下来启动这个应用吧。

	npm start
	
用浏览器访问:`http://localhost:8080`,你将看到如下界面：

![](http://ww1.sinaimg.cn/large/d9f8fd81gw1f32ivzlj5yj20wi0j240c.jpg)
![](http://ww2.sinaimg.cn/large/d9f8fd81gw1f32iyh9nw4j20w60iuwgv.jpg)

