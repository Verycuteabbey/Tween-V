## 定义：

```lua
type easeStyle = "Linear" | "Quad" | "Cubic" | "Quart" | "Quint" | "Sine" | "Expo" | "Circ" | "Elastic" | "Back" | "Bounce";
type easeDirection = "In" | "Out" | "InOut";
type positionType = CFrame | Color3 | ColorSequenceKeypoint | DateTime | number | NumberRange | NumberSequenceKeypoint | Ray | Rect | Region3 | UDim2 | Vector2 | Vector3;
```

---

## Library 逻辑构思

### 公有函数：

```lua
library:Lerp(easeOption: {style: easeStyle?, direction: easeDirection?}?, A: positionType, B: positionType, schedule: number): positionType
```

### 私有函数：

```lua
__getAlpha(style: easeStyle, direction: easeDirection, schedule: number): number
__getLerp(variant: string, A: positionType, B: PositionType, alpha: number): positionType
```

1. 为了保证整体性能，将采用分体逻辑；即一个人只能做一个工作，不得一心二用
2. 在用户调用公有函数 Lerp() 后，先检查其 easeOption 参数是否存在或子项是否合规，其一不符合将会对其针对性采用默认值
3. 待检查完毕后，将调用私有函数 __getAlpha() 并传入公有函数 Lerp() 提供的 easeOption 设置及 schedule 进度；__getAlpha() 采用 map 导航寻址，固定返回 number 数值
4. 最后再调用另一个私有函数 __getLerp() 并传入点类型、A 点、B 点及 __getAlpha() 的返回值；同样采用 map 导航寻址，固定返回与点类型相同的数值将直接作为公有函数 Lerp() 的返回值

---

## Controller 逻辑构思

### 公有函数

```lua
controller:Create(instance: Instance, property: string, easeOption: {style: easeStyle?, direction: easeDirection?, duration: number?}?, target: positionType): table
controller:Find(instance: Instance, property: string): table?
```

### 私有函数

```lua
__collector();
__insert(target: table, value: any);
```

### 对象函数

```lua
object:Replay();
object:Resume();
object:Start();
object:Yield();
```

1. 整体为面向对象，对象函数将存入其中，内容将会作为一个独立元表与对象绑定
2. 在调用公有函数 Create() 时，与 library:Lerp() 一致，都会先检查 easeOption 参数是否存在或子项是否合规
3. 待检查完毕后，再使用公有函数 Find() 检查 tweens 对象池中是否有相同目标的对象；若存在将会翻新老旧的对象并覆盖原内容重新启用，若不存在将会建立一个新的并使用私有函数 __insert() 存入对象池
4. 每隔 60s 为一次周期，私有函数 __collector() 将会回收非 running 中的对象，使用 task.defer() 持久运行
