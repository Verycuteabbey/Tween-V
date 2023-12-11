# Tween-V // 下一代 VCA's Tween

你的下一个 Tween, 何必是 TweenService 呢？

这是一个自定义 Tween 框架, 算法来源自 Tween.js 但是优化并修改了其算法

什么？你说怎么开发进度那么慢的？那当然是精力有限，而且 remake 一年前的密集型石山非常艰难的

~~才... 才不是因为 VCA 这个时候在被社会拷打呢！~~

---

## 如何食用？

前要提醒：

（待完善）Tween-V - Library // 是负责返回所提供参数的当前插值进度，支持常用类型（详细可见 positionType 定义）

（开发中）Tween-V - Controller // 是负责处理 Library 所返回的插值进度，使用 Heartbeat 进行自适应插值

### 单独使用 Library

如果不打算使用配套 Controller, 你可以使用以下函数来调用：

```lua
local library = require(path.to.library);

library:Lerp(easeOption: table?, A: positionType, B: positionType, schedule: number): positionType
```

其中 positionType 是一个定义：

```lua
type positionType = CFrame | Color3 | ColorSequenceKeypoint | DateTime | number | NumberRange | NumberSequenceKeypoint | Ray | Rect | Region3 | UDim2 | Vector2 | Vector3;
```

easeOption 包含以下内容，当然如果为空将会用默认值，子项也是如此：

> 注：展示的示例就是默认值

```lua
local easeOption: table = {
    style = "Linear",
    direction = "In"
};
```

A 为起始点，B 为终点，schedule 为当前进度（0 ~ 1 表示，可转化为百分比显示）

最终 Lerp 函数会返回一个相同类型的插值进度

---

使用示例：

获得 part 从 0, 0, 0 到 10, 10, 10 之间 50% 的插值进度，使用 Quad Out 来驱动 Vector3 类型

> ⚠ 注意：Library 不允许出现异类型之间的计算，不要想着 CFrame 与 Vector3 两个奇奇怪怪的计算！ ⚠

```lua
local library = require(path.to.library);

local part = Instance.new("Part");
part.Position = Vector3.new(0, 0, 0);

local result = library:Lerp({style = "Quad", direction = "Out"}, part.Position, Vector3.new(10, 10, 10), 0.5);
print(result);
```

此时输出 result 会得到 7.5, 7.5, 7.5 的返回值

---

### 一条龙 Controller

还没写完呢，什... 什么？！你说我太慢了！

还不是工作上的缘故！要不是因为我有兴趣...？你... 你别想太多！才不是为了你而去开发的！~~（小傲娇.jpg）~~
