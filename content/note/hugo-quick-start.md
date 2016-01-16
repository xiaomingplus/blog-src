+++
date = "2016-01-06T02:52:18+08:00"
title = "hugo博客从创建到托管到github教程"
categories = ["笔记"]
tags = ["教程"]
+++

通过本教程，你可以拥有一个使用hugo生成的github静态博客。
### 1.安装hugo

mac os：`brew install hugo`

(如果没有brew，参考官方教程 https://gohugo.io/tutorials/installing-on-mac/)

windows:直接下载最新版的exe文件安装即可，下载地址https://github.com/spf13/hugo/releases ，可参考https://gohugo.io/tutorials/installing-on-windows/ 来配置环境变量

[注意]以下内容以mac os为准，其他系统请举一反三，或者换一个mac ^_^

### 2.生成静态博客

		hugo new site /path/to/site
		cd /path/to/site
	
		//安装一款主题，比如我写的主题
	   git remote add -f we https://github.com/xiaomingplus/hugo-theme-we.git
	   git subtree add --prefix=themes/we we master --squash

		//开始写文章吧
		hugo new about.md
		//用你喜欢的markdown编辑器开始写文章吧。
	 	//编辑好并保存之后
	 	hugo server -t=we -D
到这里，你的博客就可以在本地跑起来了，访问`http://127.0.0.1:1313/`你可以看到下图的内容：
![](http://ww1.sinaimg.cn/large/d9f8fd81gw1ezzpv460rnj21gp0setab.jpg)
其中`content`文件夹存放你的原始文档，`public`存放生成的html静态文档，你可以把public的静态文档放在任何可以存放静态文档的地方来供别人访问。

### 3.利用github进行托管


	//登录github账户，直接创建分支username.github.io
	//(username为你在github的用户名，下同)，不需要初始化
	//进入本地的blog主目录
	cd /path/to/site

	//配置博客,把`baseurl`的值设置为http://username.github.io/"，保存
	vi config.toml

	//重新生成静态博客
	hugo -t=we -D

	//上传public内的文件到username.github.io项目
	cd public
	git init
	git add .
	git commit -m 'for init blog'
	git remote add origin git@github.com:username/username.github.io.git
	git push -u origin master
到这里，你自己的博客在github上的托管已全部完成，一般来说，过一会儿（不超过10分钟），你就可以用：http://username.github.io 来访问你的博客了。

### 4.使用脚本一键部署

每次输入那么多命令，烦不烦啊，所以有了这个一键部署的脚本，这样，写完文章后，只需执行一个命令即可发布在2个博客了。复制以下内容到`/path/to/site`目录下的`deploy.sh`

	#!/bin/bash

	echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"
	msg="rebuilding site `date`"
	if [ $# -eq 1 ]
	then msg="$1"
	fi

	hugo -t=we -D

	cd public
	git add -A
	git commit -m "$msg"
	git push --force -u origin master

	cd ../
继续：

	//复制以上脚本内容到deploy.sh
	vi deploy.sh

	//给脚本文件可执行权限
	chmod +x deploy.sh

	//再写一篇文章呗
	hugo new doc/hugo-quick-start.md

	//写完保存后，执行一键部署
	./deploy.sh

至此，你的博文已经发布在你的个人博客了。（可能会有一点点延迟）

demo参见我的博客与团队博客：

- http://xiaomingplus.com

