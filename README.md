# Tween-V // 下一代 VCA's Tween

你的下一个 Tween, 何必是 TweenService 呢？

这是一个自定义 Tween 框架, 算法来源自 Tween.js 但是优化并修改了其算法

什么？你说怎么开发进度那么慢的？那当然是精力有限，而且 remake 一年前的密集型石山非常艰难的

~~才... 才不是因为 VCA 这个时候在被社会拷打呢！~~

---

## 如何食用？

前要提醒：

（待完善类型支持）Tween-V - Library // 是负责返回所提供参数的当前插值进度的支持库，常见类型均可用（详细可见 positionType 定义）

（基础部分已完成）Tween-V - Controller // 是负责处理 Library 所返回的插值进度的控制器，使用 Heartbeat 进行自适应插值

### 单独使用 Library

如果不打算使用配套 Controller 或者说是写得没你好, 你可以使用以下函数来调用：

```lua
local library = require(path.to.library); -- 记得换成自己存放的路径

library:Lerp(easeOption: table?, A: positionType, B: positionType, schedule: number): positionType
```

---

当前缓动类型支持如下：

> 由于个人能力不足，无法提供 OutIn 方向类型

```lua
type easeStyle = "Linear" | "Quad" | "Cubic" | "Quart" | "Quint" | "Sine" | "Expo" | "Circ" | "Elastic" | "Back" | "Bounce";
type easeDirection = "In" | "Out" | "InOut";
```

其中 positionType 是给传入参数的一个定义，可以理解成当前支持插值的类型：

```lua
type positionType = CFrame | Color3 | ColorSequenceKeypoint | DateTime | number | NumberRange | NumberSequenceKeypoint | Ray | Rect | Region3 | UDim2 | Vector2 | Vector3;
```

easeOption 包含以下内容，可以填写 nil 或空表, 当出现前两个情况将会用默认值：

> 注：展示的示例为默认值

```lua
local easeOption: table = {
    style = "Linear",
    direction = "In"
};
```

A 为起始点（你跑步的起点），B 为结束点（你要到达的终点），schedule 为插值进度（0 ~ 1 区间）

但是 A 与 B 需符合 positionType 定义，提交无效或尚未支持的类型会被驳回

最终将会返回一个相同类型的插值给你

---

使用示例：

获得 Vector3 (0, 0, 0) 到 (10, 10, 10) 之间 50% 的插值进度，使用 Quad Out 来驱动

> ⚠ Library 不允许出现异类型计算，不要想着 CFrame 与 Vector3 两个之间奇奇怪怪的计算！ ⚠

```lua
local library = require(path.to.library); -- 记得换成自己存放的路径

local result = library:Lerp({style = "Quad", direction = "Out"}, Vector3.new(0, 0, 0), Vector3.new(10, 10, 10), 0.5);
print(result);
```

输出 result 将会得到 Vector3 (7.5, 7.5, 7.5) 返回值

---

### 一条龙 Controller

什么？你懒得自己写？

不慌啊，我帮你一条龙服务了，但是先说好不准说我代码水平拉哦？毕竟我都将近一年没有碰过了

---

使用下列函数即可创建缓动：

> 控制器默认 Library 路径在其之上，建议存放位置在对应

```lua
local tweenV = require(path.to.controller); -- 记得换成自己存放的路径

tweenV:Create(instance: Instance, property: string, easeOption: {style: easeStyle?, direction: easeDirection?, duration: number?}?, target: positionType): table
```

instance 就是你缓动的目标，property 是需要缓动的属性

easeOption 就不需要我介绍了吧？可有可无

target 就是你缓动最终的位置（也就是 Library:Lerp() 参数 B: positionType），同样需要满足 positionType 定义

---

当调用之后会返回一个表（专业点叫对象）给你，比如：

```lua
local object = controller:Create(...);

object:Continue(); -- 从暂停的位置开始缓动
object:Replay(); -- 重新缓动一次（会打断当前！！！）
object:Start(); -- 缓动，启动！
object:Stop(); -- 暂停缓动
```

什么？你说怎么没有回收的？不必担心，在你调用 Start() 后会启动自计时 60s

空闲会持续扣除直到进入 recycle 状态，并有 10s 缓冲，全部倒计时完毕后自动清除自己（此时再调用会直接 nil index）

**现在仅仅只是基础部分完成，多线程和回收利用还得再等等**

---

# 然后？

然后就没了，如果你有更好的想法欢迎提交 PR

我 remake 这个框架时完全是用一年前的知识来写的，像 !strict 及优化是后面有兴趣学的

然后真没了，如果你想问为什么 VCA 又突然干起关于 Roblox 的事了？只能说我在重操旧业而已，没别的意思

真没了，再见...？

MIT License @ 2023 The Mystery Team // Verycuteabbey