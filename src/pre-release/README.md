[简体中文](https://github.com/Verycuteabbey/Tween-V/blob/deprecated/src/pre-release/README_CN.md)
## Warning
**This algorithm still in beta, there is no guarantee that there will be no problems during use**

**v1 has release, it is highly recommended to use v1 instead of pre-release**
### What is this?
This is a Tween Logic Algorithm for Roblox, you can require() Tween to instead TweenService (**Can't instead all!!! At efficiency, Roblox API more better**)
### Use
`Tween.Create()` is require 5 arguments:

`Instance:Instance` | `Property:string` | `EaseType:table` | `Target:CFrame|Color3|number|UDim|UDim2|Vector2|Vector3` | `Duration:number`

`Instance` —————— Is can be any instances

`Property` —————— Is require to be `Instance` any property

`EaseType` —————— This is a table, must include 3 arguments: `Style`, `Direction`, `ExtraProperties`
  - `Style` can be `Linear`, `Quad`, `Cubic`, `Quart`, `Quint`, `Sine`, `Expo`, `Circ`, `Elastic`, `Back`, `Bounce`
  - `Direction` can be `In`, `Out`, `InOut`
  - `ExtraProperties` can be empty table, see [Extra Properties](https://github.com/Verycuteabbey/Tween-V/blob/deprecated/src/pre-release#extra-properties)

`Target` —————— Is can be `CFrame`, `Color3`, `number`, `UDim`, `UDim2`, `Vector2`, `Vector3`, depend on your tween property

`Duration` —————— Tween running time

Example: Part's position (0, 0, 0) to (1, 1, 1) by using Quart Out in 1s
```lua
Tween.Create(game.Workspace.Part, "Position", {Style = "Quart", Direction = "Out", ExtraProperties = {}}, Vector3.new(1, 1, 1), 1);
```
### Extra Properties
Includes 3 arguments, they are `A`, `P`, `S`, all are number

`A` and `P` for style `Elastic`, `S` for style `Back`

`A` must be higher than `Target` argument or equals it, higher will let `Elastic` effect distance more farther

Smaller `P` will let `Elastic` effect more quickly

Higher `S` will let `Back` effect distance more farther
