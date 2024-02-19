# Tween-V-RS // 下一代 VCA's Tween, 但是RS兼容版本

你的下一个 Tween, 何必是 TweenService 呢？

这是一个自定义 Tween 框架, 算法来源自 Tween.js 但是修改了算法

~~已经尽力去开发了，别催了别催了（可怜.jpg~~

---

## 如何食用？

使用下列函数即可创建`Tween`：

```lua
local tweenV = require(path.to.tweenv)

tweenV:Create(
    instance: Instance,
    tweenInfo: TweenInfo,
    target: { [string]: any }
)

--// For exmaple
tweenV:Create(workspace.Part, TweenInfo.new(), { Size = Vector3.new(4,4,4) })
```
由于是兼容版，所以你会觉得：这不就是`TweenService`？

但是，别急，当调用之后会返回一个对象给你，可参考如下： 

```lua
local object = tweenV:Create()

object:Start() -- Tween，启动！
object:Cancel() -- 溜了溜了

--// Recommended
tweenV:Create(...):Start() --// 这可快多了好吧，链式结构YYDS
```
*这更像`TweenService`了好吧*

---

## 然后？

然后就没了，如果你有更好的想法欢迎提交 PR

我 remake 这个框架时完全是用一年前的知识来写的，像 !strict 及优化是后面有兴趣学的

然后没了，如果你想问为什么 VCA 又突然干起关于 Roblox 的事了？只能说我在~~怀旧~~重操旧业而已，没别的意思了

但说真的，比起各位开发者我其实是个 fw 来的（真），甚至不如一个新手

**MIT License @ 2024 The Mystery Team // Verycuteabbey**