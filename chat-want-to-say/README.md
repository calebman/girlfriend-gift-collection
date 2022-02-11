# 这是什么东西？

> 参考来自 https://github.com/wongjohn/for-my-love 并做了部分改造
>

以聊天交互的方式向女朋友表达想说的话，支持便捷的内容配置，急速替换为自己想要的内容，点击下方链接预览效果。

- 国内用户访问：[https://sg.chenjianhui.site/girlfriend-gift-collection/chat-want-to-say/](https://sg.chenjianhui.site/girlfriend-gift-collection/chat-want-to-say/)
- Github Pages: [https://calebman.github.io/girlfriend-gift-collection/chat-want-to-say/](https://calebman.github.io/girlfriend-gift-collection/chat-want-to-say/)
# 如何修改为自己的内容

### 一. 修改配置文件

> 项目 chat-want-to-say 根目录中的 .env.* 为环境配置文件，默认打包使用 .env.production 配置，配置内容如下所示：
> 

| 配置项                 | 含义                 | 备注                                                   |
| ---------------------- | -------------------- | ------------------------------------------------------ |
| VITE_APP_TITLE         | 聊天框标题           | 可填入如“与XXX正在聊天”等内容                          |
| VITE_BASE_URL          | 网页基础路径         | 如果部署在服务器的二级路径则需要填写                   |
| VITE_CHAT_OPTIONS_PATH | 聊天内容配置（重要） | 填入内容对应的 json 文件地址，寻找 public 目录下的文件 |

参考 .env.development 一个完整的配置文件如下所示：

```properties
VITE_APP_TITLE=与XXX聊天中
VITE_BASE_URL=chat-interactive-demo/
VITE_CHAT_OPTIONS_PATH=options/demo/chat.json
```

### 二. 完善聊天内容

聊天内容配置由一个 json 数组构成，数组内每一项对应一段聊天内容，其支持的配置信息如下所示：

| 配置项                 | 含义                 | 类型               | 备注                                                   |
| ---------------------- | -------------------- | ------------------------------------------------------ | ------------------------------------------------------ |
| msgs         | 聊天内容           | 数组         |          支持**文本/图片/信件/VLog**等形式内容，文本情况下数组传入多个内容可以形成回退效果。          |
| msgInputSpeed          | 文本输入速度         | 数字       | 默认为 150，当内容为文本时，代表键入数组，单位为 ms。 |
| triggerNextAction | 触发下一段聊天的行为配置 | 对象 | 默认为空，当有内容时会暂停等待用户交互触发下一个聊天内容。 |
| author | 聊天内容的归属人 | 字符串 | 默认为空，当需要模拟对方有内容输入时，可以填入 “me” |

用户交交互的行为触发 triggerNextAction 配置信息如下所示：

| 配置项                 | 含义                 | 类型               | 备注                                                   |
| ---------------------- | -------------------- | ------------------------------------------------------ | ------------------------------------------------------ |
| type         | 触发行为的类型    | 字符串      |          目前针对不同的内容组件支持两种类型值，userInput/componentClose，具体解释见表格下方所示          |
| options          | 触发行为的配置 | 对象     |  | 根据类型不同配置表达含义不同，目前只有 userInput 支持 options 配置，具体解释见表格下方所示

> triggerNextAction.type 解释
> - userInput: 代表等待用户输入指定内容完成一轮交互，支持关键字配置
> - componentClose: 代表等待用户关闭组件完成一轮交互，常用于信件/VLog等组件，用户点击关闭回到聊天页面触发后续的内容播放
> 

> triggerNextAction.options 解释，当 triggerNextAction.type = userInput 时，该配置有效
> - resolveKeyTexts: 类型为数组，触发下一行为的关键词，只需要包含即可，比如 ["好的", "可以", "同意"]，用户只要输入如 "好的呢" 就会触发下一行为
> - rejectKeyTexts: 类型为数组，触发下一行为的黑名单关键词，只需要包含即可，优先级高，比如 ["不想"]，用户只要输入 "我不想" 就会已经卡在这一聊天内容中
> - rejectHitTexts: 类型为数组，交互提示内容，当用户输入不满足预期时，给予提示，提示会按照数组顺序进行，提示不够了会强行触发下一个聊天内容
>

下面对多种形式的内容做一些说明

#### 1. 普通文本

- 如下是一条输入速度为 80ms 的文本内容

```json
{ "msgs": ["普通消息，有输入动画"], "msgInputSpeed": 80 }
```

- 如下是带有回退效果的文本内容

```json
{
    "msgs": ["普通消息会回退", "普通消息回退后的结果，也能调整动画速度"],
    "msgInputSpeed": 120
}
```

- 如下是带有触发效果的文本内容

```json
{
    "msgs": ["有些心里话，你想听吗？"],
    "msgInputSpeed": 40,
    "triggerNextAction": {
        "type": "userInput",
        "options": {
            "resolveKeyTexts": ["好的", "可以", "同意", "愿意", "想", "想听", "是" ],
            "rejectKeyTexts": ["不想"],
            "rejectHitTexts": [
                "不听？信不信我分分钟出 bug 给你看？",
                "好吧，既然你实在不想听，那我就讲给你听吧～"
            ]
        }
    }
}
```

- 如下是自定义文本颜色的内容

```json
{
    "msgs": ["<span style=\"color: red;\">红色的span标签字体</span>"],
    "msgInputSpeed": 80
}
```

#### 2. 图片

图片内容示例如下所示，图片文件放到 public 目录下，使用相对路径引用

```json
{ "msgs": ["<img src='options/demo/imgs/test.png'/>"] }
```

#### 3. 信件

信件内容示例如下所示，信件内容文件放到 public 目录下，使用相对路径引用，当信件被用户关闭时触发下一段聊天内容

```json
{
    "msgs": ["<letter src='options/demo/letters/test.json'/>"],
    "triggerNextAction": { "type": "componentClose" }
}
```

信件的配置项如下所示：

| 配置项                 | 含义                 | 类型               | 备注                                                   |
| ---------------------- | -------------------- | ------------------------------------------------------ | ------------------------------------------------------ |
| openTip  | 信件打开提示     | 字符串      |                    |
| title     | 信件标题     | 字符串    |  |
| speed | 文本输入速度 | 数字 | 信件文字的输入速度 |
| paragraphs | 信件段落信息 | 数组 | 数组每一项为字符串，支持文本/图片，具体解释如下所示 |

比如如下的一个信件配置段落含义为，"几场梅雨" 输入完成后停顿 1000ms，然后输入 "几卷荷风".....，段落完成后放置一张图片。

```json
{
    "openTip": "Lover",
    "title": "给xx的一封信",
    "speed": 10,
    "paragraphs": [
        "几场梅雨^1000，几卷荷风^1000，江南已是烟水迷离。",
        "<img src='options/demo/imgs/test.png'/>",
        "几场梅雨^1000，几卷荷风^1000，江南已是烟水迷离。",
    ]
}

```

#### 4. VLog

VLog内容示例如下所示，视频文件放到 public 目录下，使用相对路径引用，当视频被用户关闭时触发下一段聊天内容

```json
{
    "msgs": ["<vlog src='options/demo/vlogs/test.mp4'/>"],
    "triggerNextAction": { "type": "componentClose" }
}
```

### 三. 调试&编译出静态网页

#### 1. 调试

```bash
cd chat-want-to-say
yarn dev
# see http://localhost:3000/
```

#### 2. 编译打包

```bash
sh bin/build.sh
cd dist
# 将 dist 目录的内容部署到静态服务器，通过 anywhere 可以预览效果
yarn global add anywhere
anywhere
```

### 四. 部署至静态服务器

```bash
scp -r chat-want-to-say/dist/** root@domain:/nginx-html/
```
