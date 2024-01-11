# Tween-V // 下一代 VCA's Tween

你的下一个 Tween, 何必是 TweenService 呢？

这是一个自定义 Tween 框架, 算法来源自 Tween.js 但是修改了算法

~~已经尽力去开发了，别催了别催了（可怜.jpg~~

---

**⚠ 你现在正在浏览 dev 分支，本分支不保证任何稳定性 ⚠**

---

## 如何食用？

前要提醒：

（待完善类型）Tween-V - Library // 是负责返回所提供参数的当前插值进度的支持库，常见类型均可用（详细可见 `sourceType` 定义）

（待完善功能）Tween-V - Controller // 是负责处理 Library 所返回的插值进度的控制器，使用 Heartbeat 进行自适应插值

---

### 单独使用 Library

如果不打算使用配套 Controller 或者说是写得没你好, 你可以使用以下函数来调用：

```lua
local library = require(path.to.library) -- 记得换成自己存放的路径

library:Lerp(
    easeOptions: {
        style: Enum.EasingStyle | string?,
        direction: Enum.EasingDirection | string?,
        extra: { amplitude: number?, period: number? }?
    }?,
    A: sourceType,
    B: sourceType, 
    schedule: number
): sourceType
```

---

#### 讲解

`easeOptions` 为缓动类型定义：

- `style` 为缓动类型
  - 使用自定义类型 `string`: 可选 `Linear`, `Quad`, `Cubic`, `Quart`, `Quint`, `Sine`, `Exponential`, `Circular`, `Elastic`, `Back`, `Bounce`
  - 使用兼容性类型 `Enum`: 与 `Enum.EasingStyle` 一致

- `direction` 为缓动方式
  - 使用自定义类型 `string`: 可选 `In`, `Out`, `InOut`, `OutIn`
  - 使用兼容性类型 `Enum`: 与 `Enum.EasingDirection` 一致

- `extra` 为扩展自定义，仅对 `Elastic` 类型生效
  - 当 `amplitude` 越大，弹性幅度越大，反之越小
  - 当 `period` 越大，弹性周期越长，反之越小

所有 `easeOptions` 项都可以选择留空使用 Library 的默认值，包括自身

---

`sourceType` 为类型定义：

> 可以理解成当前支持插值的类型

```lua
type sourceType =
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

---

`A` 为起始点（你跑步的起点），`B` 为结束点（你要到达的终点），`schedule` 为插值进度（0 ~ 1 区间）

但是 `A` 与 `B` 需符合 `sourceType` 定义，提交无效或尚未支持的类型会被驳回

最终将会返回一个相同类型的插值给你

---

#### 使用示例

获得 Vector3 `(0, 0, 0)` 到 `(10, 10, 10)` 之间 50% 的插值进度，`Quad Out` 作为缓动类型

> ⚠ Library 不允许出现异类型计算，不要想着 CFrame 与 Vector3 两个之间奇奇怪怪的计算！ ⚠

以自定义类型：

```lua
local library = require(path.to.library) -- 记得换成自己存放的路径

local result = library:Lerp(
    { "Quad", "Out" },
    Vector3.new(0, 0, 0),
    Vector3.new(10, 10, 10),
    0.5
)

print(result)
```

以兼容性类型:

```lua
local result = library:Lerp(
    { Enum.EasingStyle.Quad, Enum.EasingDirection.Out },
    Vector3.new(0, 0, 0),
    Vector3.new(10, 10, 10),
    0.5
)
```

输出 `result` 将会得到 Vector3 `(7.5, 7.5, 7.5)` 返回值

---

### 一条龙 Controller

什么？你懒得自己写？一条龙启动！

~~手头缺少测试工具完全是纯打，有 bug 很正常，别骂了别骂了~~

---

使用下列函数即可创建缓动：

> 控制器默认 Library 路径在其之下，建议存放位置就如刚才所说

```lua
local tweenV = require(script.library)

tweenV:Create(
    instance: Instance,
    easeOptions: {
        style: Enum.EasingStyle | string?,
        direction: Enum.EasingDirection | string?,
        duration: number?,
        extra: { amplitude: number?, period: number? }?
    }?,
    target: table,
    loop: number?,
    reverse: boolean?
): table
```

---

#### 讲解

`instance` 为你缓动的目标，并非 `instance.Name`

`easeOptions` 与 Library 的一致，只是多了个 `duration`

`target` 为对象属性最终值，可一个或多个属性同时进行

> 以下为示例

```lua
target = {
    Position = Vector3.new(114, 514, 1919),
    Size = Vector3.new(810, 114, 514),
    Transparency = 0.5
}
```

`loop` 为该对象需循环多少次，`0` 为不循环，`-1` 为一直循环直到手动 `:Kill()`，可留空使用默认值

`reverse` 为该对象是否需要往返，可留空使用默认值

---

当调用之后会返回一个对象： 

```lua
local object = controller:Create(...)

object:Kill() -- 你直接给我坐下！
object:Replay() -- one more time!
object:Resume() -- 时间再次流动......
object:Start() -- 函数，启动！
object:Yield() -- 冻住，不许走！
```

`:Kill()` 会直接结束掉当前运行，若需要可以用 `:Replay()` 重新播放

但需要注意的是，`:Replay()` 会打断当前并重新播放，在 `:Start()` 之前无法调用

---

## 然后？

然后就没了，如果你有更好的想法欢迎提交 PR

如果你想问为什么 VCA 又突然干起关于 Roblox 的事了？只能说我在~~怀旧~~重操旧业而已，没别的意思了

但说真的，比起各位开发者我其实是个 fw 来的（真）

**MIT License @ 2023 The Mystery Team // Verycuteabbey**
