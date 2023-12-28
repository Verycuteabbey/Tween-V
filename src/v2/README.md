
## Install

1. Releases, download the rbxm
2. Use rojo to sync source code into your project
3. Or use wally, add `harukatea/mkktween@1.0`  to your dependencies

## Example

``````lua
local tween = require(path.to.tween)

local part = Instance.new("Part", workspace)

tween:createTween(part, "Size", "Quad", "InOut", Vector3.new(40, 40, 1599), 1.599)
``````
