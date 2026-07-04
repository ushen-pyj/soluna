---@meta soluna.material.clip

---clip material 模块。
---Clip material module.
---
---`rect(width, height)` 打开一个矩形裁剪范围，`rect()` 关闭最近一次打开的裁剪范围。
---裁剪矩形位于屏幕空间，是轴对齐矩形；它不是 layer-local clip，也不为旋转 layer
---提供精确裁剪。
---
---`rect(width, height)` opens a rectangular clipping region, and `rect()`
---closes the latest opened clipping region. The clipping rectangle is
---screen-space and axis-aligned. It is not a layer-local clip and does not
---provide exact clipping for rotated layers.
---@class soluna.material.clip
local matclip = {}

---打开或关闭矩形裁剪范围。
---Opens or closes a rectangular clipping region.
---@overload fun(): string
---@overload fun(width: number, height: number): string
---@param width number 逻辑像素宽度 / Width in logical pixels.
---@param height number 逻辑像素高度 / Height in logical pixels.
---@return string stream 打包后的 clip 命令流 / Packed clip command stream.
function matclip.rect(width, height)
end

return matclip
