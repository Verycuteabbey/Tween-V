# Tween-V // 下一代 VCA's Tween

你的下一个 Tween, 何必是 TweenService 呢？

这是一个自定义 Tween 框架, 算法来源自 Tween.js 但是优化并修改了其算法

什么？你说怎么开发进度那么慢的？那当然是精力有限，而且 remake 一年前的密集型石山非常艰难的

~~才... 才不是因为 VCA 这个时候在被社会拷打呢！~~

---

**⚠ 你现在正在浏览 dev 分支，本分支并不保证任何稳定性！⚠**

---

## 如何食用？

前要提醒：

（待完善类型支持）Tween-V - Library // 是负责返回所提供参数的当前插值进度的支持库，常见类型均可用（详细可见 `sourceType` 定义）

（待逻辑优化）Tween-V - Controller // 是负责处理 Library 所返回的插值进度的控制器，使用 Heartbeat 进行自适应插值

---

### 单独使用 Library

如果不打算使用配套 Controller 或者说是写得没你好, 你可以使用以下函数来调用：

```lua
local library = require(path.to.library) -- 记得换成自己存放的路径

library:Lerp(
    easeOptions: { style: Enum.EasingStyle | string?, direction: Enum.EasingDirection | string? }?,
    A: sourceType,
    B: sourceType, 
    schedule: number
): sourceType
```

---

`easeOptions` 为缓动类型定义，支持 Roblox 所支持的所有类型且向 Roblox 兼容

其中 `sourceType` 是给传入参数的一个定义，可以理解成当前支持插值的类型：

```lua
type positionType =
	CFrame
	| Color3
	| ColorSequenceKeypoint
	| DateTime
	| number
	| NumberRange
	| NumberSequenceKeypoint
	| Ray
	| Rect
	| Region3
	| UDim2
	| Vector2
	| Vector3
```

`A` 为起始点（你跑步的起点），`B` 为结束点（你要到达的终点），`schedule` 为插值进度（0 ~ 1 区间）

但是 `A` 与 `B` 需符合 sourceType 定义，提交无效或尚未支持的类型会被驳回

最终将会返回一个相同类型的插值给你

---

使用示例：

获得 Vector3 `(0, 0, 0)` 到 `(10, 10, 10)` 之间 50% 的插值进度，`Quad Out` 作为缓动类型

> ⚠ Library 不允许出现异类型计算，不要想着 CFrame 与 Vector3 两个之间奇奇怪怪的计算！ ⚠

以 `Enum` 为传参类型：

```lua
local library = require(path.to.library) -- 记得换成自己存放的路径

local result = library:Lerp(
    { Enum.EasingStyle.Quad, Enum.EasingDirection.Out },
    Vector3.new(0, 0, 0),
    Vector3.new(10, 10, 10),
    0.5
)

print(result)
```

以 `string` 为传参类型:

```lua
local result = library:Lerp(
    { "Quad", "Out" },
    Vector3.new(0, 0, 0),
    Vector3.new(10, 10, 10),
    0.5
)
```

输出 `result` 将会得到 Vector3 `(7.5, 7.5, 7.5)` 返回值

---

### 一条龙 Controller

什么？你懒得自己写？

不要慌张，我帮你一条龙服务了，但是先说好不准说我代码水平拉哦？毕竟我都将近一年没有碰过了

而且手头缺少测试工具完全是纯打，别骂了别骂了

---

使用下列函数即可创建缓动：

> 控制器默认 Library 路径在其之下，建议存放位置就如刚才所说

```lua
local tweenV = require(script.library)

tweenV:Create(
    instance: Instance,
    easeOption: { style: Enum.EasingStyle | string?, direction: Enum.EasingDirection | string?, duration: number? }?,
    target: table
): table
```

`instance` 就是你缓动的目标（不是 `Instance.Name`）

`easeOption` 就不需要我介绍了吧？可有可无

`target` 就是你缓动最终的位置（也就是 Library:Lerp() 的参数 `B`），但是与 `TweenService` 类似为一个 table:

```lua
target = {
    Position = Vector3.new(114, 514, 1919),
    Size = Vector3.new(810, 114, 514),
    Transparency = 0.5
}
```

可一个或多个属性同时进行

---

当调用之后会返回一个对象给你，可参考如下： 

```lua
local object = controller:Create(...)

object:Replay() -- one more time!（位置会被重置且会打断当前）
object:Resume() -- 时间再次流动......（不会重置位置也不会打断，因为本身就是解除冻结）
object:Start() -- 函数，启动！（指启动 tween）
object:Yield() -- 冻住，不许走！
```

---

## 然后？

然后就没了，如果你有更好的想法欢迎提交 PR

我 remake 这个框架时完全是用一年前的知识来写的，像 !strict 及优化是后面有兴趣学的

然后没了，如果你想问为什么 VCA 又突然干起关于 Roblox 的事了？只能说我在~~怀旧~~重操旧业而已，没别的意思了

但说真的，比起各位开发者我其实是个 fw 来的（真），甚至不如一个新手

**MIT License @ 2023 The Mystery Team // Verycuteabbey**
