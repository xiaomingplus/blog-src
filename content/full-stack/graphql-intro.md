+++
title = "如何为老板节省几个亿之graphql介绍"
date =  2017-10-28T12:54:46+08:00
draft = true
categories = ["全栈"]
tags = ["javascript","graphql","restful"]
+++

写过接口和联调过接口的人想必都对接口的约定，文档维护和联调等问题经常头痛不已，因为我们的业务里有大量不同的应用和系统共同使用着许许多多的服务api，而随着业务的变化和发展，不同的应用对相同资源的不同使用方法最终会导致需要维护的服务api数量呈现爆炸式的增长，比如我试着跑了下我们自己业务里的接口数量，线上正在运行的就有超过1000多个接口，非常不利于维护。而另一方面，创建一个大而全的通用性接口又非常不利于移动端使用（流量损耗），而且后端数据的无意义聚合也对整个系统带来了很大的资源浪费。

总结一下，我们目前接口的开发遇到的主要痛点如下：

## 痛点

### 字段冗余

比如用户接口，刚开始时，返回的信息会比较少，例如只有 id,name，后来用户的信息增加了，就在用户接口中返回更多的信息，例如 id,name,age,city,addr,email,headimage,nick，但可能很多客户端只是想获取其中少部分信息，如name,headimage，却必须得到所有的用户信息，然后从中提取自己想要的，这个情况会增加网络传输量，并且也不利于客户端处理数据（为老板增加了很多不必要的开支:smile:。

### 参数类型校验

我们几乎每个接口都需要做基本的字段校验，比如某个参数是否必需，是不是数字，是不是数组，是不是布尔型，是不是字符串等等，而除了服务端要校验客户端传来的参数，客户端自己也需要去校验服务端返回的参数，比如客户端要的是数组，你有没有返回数组，试问有哪个前端想整天去写出```var x = data?(data.obj?data.obj.name:null):null;```这样的代码？我们业务自己线上出的很多问题也是因为客户端没有严格的校验服务端返回的数据是否符合预期造成的。比如下图是我们业务某天的js error错误日志上报：
![](http://ww1.sinaimg.cn/large/d9f8fd81gy1fkxvdoc6kmj20kf06nt9e.jpg)

### 文档与维护

这个可能是和接口打交道的人员感触最深的环节了，联调基本靠猜，维护历史遗留代码更是一种高深的猜一猜游戏。正常理论上来讲，写接口就要写对应的文档，接口一旦有变动，文档也一定要及时更新。但是，有不少团队因为种种原因，没有能及时维护文档甚至有不少连文档都没有，全部依赖口口相传和读源码。这个问题其实是困扰我个人在开发过程中最大的一个问题。

### 请求多个接口

我们经常会在某个需求中需要调用多个独立的API接口才能获取到足够的数据，例如客户端要去显示一篇文章的内容，同时也要显示评论、作者信息，那么就可能需要调用文章接口、评论接口、用户接口。这种方式非常的不灵活。另一个case是很多项目都会去拉一些不同的配置文件来决定展示什么，比如我们业务里的app，一打开就有10多个请求，非常不合理，不仅多个请求浪费了带宽，而且速度慢，客户端处理的请求也复杂。

## 如何解决？

对于上面的问题，我们来逐一攻破：

- **字段冗余？**那我可不可以客户端要什么字段，服务端就给什么字段的值？
- **参数类型校验？**那我可不可以定义一个返回数据格式与请求的数据格式的一个强类型的约束？
- **文档与维护？**这里的核心问题我觉的是因为我们写不写文档对于我们的代码没有约束力，所以我们写不写文档对代码的正常运行是没有任何影响的。所以我们能不能考虑和代码结合起来，我代码里怎么写的，文档就怎么生成的？
- **请求多个接口？**那我能不能客户端可以问服务端要1、2、3这些数据，服务端一次给我返回就行？

## graphql方案介绍

graphql的方案完美的解决了以上所有问题，连大名鼎鼎GitHub也抛弃了自己非常优秀的REST API接口，全面拥抱graphql了。

GraphQL是Facebook 在2012年开发的，2015年开源，2016年下半年Facebook宣布可以在生产环境使用，而其内部早就已经广泛应用了，用于替代 REST API。facebook的解决方案和简单：用一个“聪明”的节点来进行复杂的查询，将数据按照客户端的要求传回去，后端根据GraphQL机制提供一个具有强大功能的接口，用以满足前端数据的个性化需求，既保证了多样性，又控制了接口数量。

GraphQL并不是一门程序语言或者框架，它是描述你的请求数据的一种规范，是协议而非存储，GraphQL本身并不直接提供后端存储的能力，它不绑定任何的数据库或者存储引擎，它可以利用已有的代码和技术来进行数据源管理。

一个GraphQL查询是一个被发往服务端的字符串，该查询在服务端被解释和执行后返回JSON数据给客户端。

### 和Rest Api的对比

- **RESTful**：服务端决定有哪些数据获取方式，客户端只能挑选使用，如果数据过于冗余也只能默默接收再对数据进行处理；而数据不能满足需求则需要请求更多的接口。
- **GraphQL**：给客户端自主选择数据内容的能力，客户端完全自主决定获取信息的内容，服务端负责精确的返回目标数据。

## 为什么推荐用GraphQL方案

说人话就是：减少工作量

专业一点：**提供一种更严格、可扩展、可维护的数据查询方式**

### 优点

- 能为老板节省几个亿的流量（由前端定义需要哪些字段
- 再也不需要对接口的文档进行维护了（自动生成文档，代码里定义的结构就是文档
- 再也不用加班了（真正做到一个接口适用多个场景
- 再也不用改bug了（强类型，自动校验入参出参类型
- 新人再也不用培训了（所有的接口都在一颗数下，一目了然
- 再也不用前端去写假数据了（代码里定义好结构之后自动生成mock接口
- 再不用痛苦的联调了（代码里定义好结构之后，自动生成接口在线调试工具，直接在界面里写请求语句来调试返回，而且调试的时候各种自动补全
- react/vue/express/koa无缝接入（relay方案/apollo方案
- 更容易写底层的工具去监控每个接口的请求统计信息（都在同一个端点的请求下
- 不限语言，除了官方提供的js实现，其他所有的语言都有社区的实现
- 生态是真的好啊，有各种方便易用的开发者工具

## 怎么用？

![](http://ww1.sinaimg.cn/large/d9f8fd81gy1fkxve9z48pj21yk0hcthf.jpg)
其实graphql的理念还算简单，总的来说，就如图中所示：

1. 接口提供方定义好强类型的数据入参和返回的数据结构
1. 客户端发送一个带有查询语句（graphql的查询协议）的请求，请求里定义了需要哪些数据。
1. 服务端返回给客户端符合客户端预期的json字符串结果

github官方提供了github的graph api的在线调试工具，地址是<https://developer.github.com/v4/explorer/>,实际上这个工具是社区提供的，我们在写好graph服务的时候，也可以自动一键生成这样一个服务。你可以在github提供的这个调试工具里多试试查询语句。

在REST的API中，给哪些数据是服务端决定的，客户端只能从中挑选，如果A接口中的数据不够，再请求B接口，然后从他们返回的数据中挑出自己需要的，而在GraphQL 中，客户端直接对服务端说想要什么数据，服务端就负责精确的返回目标数据。

可以把GraphQL看成一棵树，GraphQL对外提供的其实就只有一个接口，所有的请求都通过这个接口去处理，相当于在graph服务内部做了针对不同请求的路由处理。

根节点下分为2大类，一类是Query类（主要是查询相关的，相当于get），一类是Mutation类（主要是非幂等操作，post,put,delete)。

下图是我写的一个微博类应用的demo，图是写完服务后用工具[voyager](https://github.com/APIs-guru/graphql-voyager)生成的这个graph服务的数据结构图：
![](http://ww1.sinaimg.cn/large/d9f8fd81gy1fkxverr6jcj20zy05sq5n.jpg)
注：其中类型后面的感叹号表示这个属性必须提供。

GraphQL是一个**强类型**的协议，服务端在定义数据的时候必须指定每一个入参，出参的类型以及是否可选，这样的话，框架就可以自动帮我们去处理参数类型校验的问题了。GraphQL 的类型系统分为标量类型（Scalar Types，标量类型，也称为简单类型）和其他高级数据类型（复合类型），标量类型即可以表示最细粒度数据结构的数据类型，可以和 JavaScript的原始类型对应。
GraphQL 规范目前官方规定支持的标量类型有：
Int : 整数，对应JavaScript的Number
Float：浮点数，对应JavaScript的Number
String：字符串，对应Javascript的String
Boolean： 布尔值，对应JavaScript的Boolean
ID：序列化后唯一的字符串，对应JavaScript的Symbol
高级数据类型包括：Object（对象）、Interface（接口，定义的时候继承这个接口的结构必须实现这个接口所有属性）、Union(联合类型，可以既是某个类型又是某个类型)、Enum(枚举类型)、Input Object（输入对象）、List（列表，对应js的数组）、Non-Null(不能为null) 这里不做详述，请参考官方指引 Schemas and Types。

## 查询示例
下面是对上面的graph服务的查询示例：

```
// 获取单个用户信息的同时获取该位用户的文章列表，以及每篇文章对应的tag列表

{
  user(id: 1) { # 括号里的是参数，表示请求id为1的用户信息
    id
    username:nickname # 这里可以给服务返回的字段设置别名，比如我们把服务返回的nickname设置为username
    gender
    avatar
    posts{
      id
      source
      tagIds
      tags{
        name
      } # tags也是一个数组，我们这里只需要数组里的tag里的name属性
    } # posts的返回是一个数组，我们这里只需要定义数组里的项目对应的数据结构就可以
    createdAt
    updatedAt
  }
}

//返回示例

{
  "data": {
    "user": {
      "id": "1c5c160c-b666-4728-b745-81c723e3e722",
      "username": "hello",
      "gender": "UNKNOW",
      "avatar": "http://qq.com",
      "posts": [
        {
          "id": "ab9d26b9-23b8-4ca6-97e7-bb5f9091133e",
          "source": "黑队7首映归来！全程被卡黄发糖砸到懵逼！好不容易回过神了！被彩蛋砸了一顿玻璃渣！！！编剧我要给你寄刀片！！！！！！！！ ",
          "tagIds": [
            "a7475f18-4132-4155-be78-9d942de9fa89",
            "875d592a-a0f2-483f-b680-93c0db27b173"
          ],
          "tags": [
            {
              "name": "任务1"
            },
            {
              "name": "任务1"
            }
          ]
        },
        {
          "id": "d96f7717-cd20-4ef5-b62e-01fbeb2e3b06",
          "source": "你好，世界",
          "tagIds": [
            "14698f1e-2610-4d9c-baa0-8a94b3d8597a",
            "97557a0b-0bc5-48db-9338-3e864aa6b1c5"
          ],
          "tags": [
            {
              "name": "任务1"
            },
            {
              "name": "任务1"
            }
          ]
        }
      ],
      "createdAt": "2017-10-18T16:33:27.620Z",
      "updatedAt": "2017-10-18T16:33:27.620Z"
    }
  }
}


//下面是一个典型的创建文章示例
//需要指定为mutation类型，如果不写的话，默认是query类型
mutation  {
  createPost(input:{source:"hello",sourceType:MARKDOWN,authorId:1,score:1}){
    id,# 创建后返回id属性
    createdAt # 创建后返回createdAt属性
  }
}

//返回示例

{
  "data": {
    "createPost": {
      "id": "bcb1eafa-6440-4336-a4f0-5cafb334581f",
      "createdAt": "2017-10-18T16:35:48.297Z"
    }
  }
}
```
除此之外，你还可以进行批量的请求，query类型的请求是并行的，mutation类的请求是顺序执行的。


### 服务端的数据结构定义

```
// 对应上面的GraphQL查询，GraphQL 服务需要建立以下自定义类型

type Query {
    # 单个用户 #号表示对这个字段的注释，感叹号表示必须传这个字段
    user(id:ID!): User # User表示这个的返回类型的User
}

# 用户类
type User {
    # 用户uuid
    id: ID!
    # 昵称
    nickname: String!
    # 性别
    gender:Gender!
    # 头像地址
    avatar:Url!
    # 注册时间
    createdAt:DateTime!
    # 最后更新时间
    updatedAt:DateTime!
    # 帖子列表
    posts:[Post!]!
}

# 帖子
type Post {
    id: ID!
    # 帖子内容
    source: String!
    # 作者ID
    authorId:ID!
    # 作者
    author:User!
    # 帖子标签id数组
    tagIds:[ID!]!
    # 帖子标签
    tags:[Tag!]!
    # 创建时间
    createdAt:DateTime!
    # 更新时间
    updatedAt:DateTime!
}
# 标签
type Tag {
    # 标签uuid
    id: ID!
    # 标签名字
    name:String!
    # 作者ID
    authorId:ID!
    # 作者
    author:User!
    # 创建时间
    createdAt:DateTime!
    # 最后更新时间
    updatedAt:DateTime!
}
# 性别
enum Gender {
    # 男
    MALE
    # 女
    FEMALE
    # 未知
    UNKNOW
}
```

##  GraphQL存在的问题

graphQl也不是没有缺点，主要有以下几个缺点：

### 改造成本

要使用GraphQL对数据源进行管理，相当于要对整个服务端进行一次换血。你需要考虑的不仅仅是需要针对现有数据源建立一套GraphQL的类型系统，同时需要改造服务端暴露数据的方式，这对业务久远的产品无疑是一场灾难，让人望而却步。

### 查询性能

GraphQL查询的每个字段如果都有自己的resolve方法，可能导致一次查询操作对数据库跑了大量了query，数据库里一趟select+join就能完成的事情在这里看来会产生大量的数据库查询操作，虽然网络层面的请求数被优化了，但是数据库查询可能会成为性能瓶颈。但是这个其实是可以优化，反正就算是用rest api，同时处理多个请求的时候，也总要运行那些数据库语句的。

## 一些有用的链接：

- facebook/graphql的github项目 — <https://github.com/facebook/graphql>
- GraphQl定义 — <https://facebook.github.io/graphql/>
- GraphQ介绍网站，把graph讲的挺清楚的 <http://graphql.org/>
- 谁在用 <http://graphql.org/users/>

## 参考

<http://imweb.io/topic/58499c299be501ba17b10a9e>
<https://juejin.im/post/58fd6d121b69e600589ec740>
<https://segmentfault.com/a/1190000005766732>
<http://blog.kazaff.me/2016/01/01/GraphQL%E4%BB%80%E4%B9%88%E9%AC%BC/>
<https://neighborhood999.github.io/2017/01/12/Learning-GraphQL/>