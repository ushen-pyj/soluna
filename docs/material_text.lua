---@meta soluna.material.text

---text style 配置。
---Text style configuration.
---@class soluna.material.text.Style
---@field font integer `font.name()` 返回的字体 id / Font id returned by `font.name()`
---@field size? integer 字体像素大小，默认 24 / Font pixel size, default 24
---@field color? integer ARGB 颜色，默认 `0xff000000` / ARGB color, default `0xff000000`
---@field line_height? integer 行高；小于字体自然高度时使用自然高度 / Line height; clamped to the natural font height

---text style set。
---Text style set.
---@class soluna.material.text.Styles: userdata

---文本行信息。
---Text line information.
---
---`start` 和 `finish` 是 0-based visible position，`finish` 为 exclusive。
---`start` and `finish` are 0-based visible positions. `finish` is exclusive.
---@class soluna.material.text.Line
---@field start integer 行起始 visible position / First visible position on the line
---@field finish integer 行结束 visible position，exclusive / End visible position, exclusive
---@field x integer 行矩形 X / Line rectangle X
---@field y integer 行矩形 Y / Line rectangle Y
---@field width integer 行矩形宽度 / Line rectangle width
---@field height integer 行矩形高度 / Line rectangle height

---文本布局查询对象。
---Text layout query object.
---@class soluna.material.text.Layout
local Layout = {}

---返回文本实际高度。
---Returns text content height.
---@return integer height 文本实际高度 / Text content height
function Layout:height()
end

---返回最大行高。
---Returns maximum line height.
---@return integer height 最大行高 / Maximum line height
function Layout:line_height()
end

---返回行数。
---Returns line count.
---@return integer count 行数 / Line count
function Layout:line_count()
end

---返回 cursor position 数量。
---Returns cursor position count.
---@return integer count cursor position 数量 / Cursor position count
function Layout:cursor_count()
end

---返回 1-based 行信息。
---Returns 1-based line information.
---@param index integer 1-based 行号 / 1-based line index
---@return soluna.material.text.Line? line 行信息 / Line information
function Layout:line(index)
end

---查询 cursor 矩形。
---Queries cursor rectangle.
---@param position integer 0-based cursor position / 0-based cursor position
---@return integer x cursor X / Cursor X
---@return integer y cursor Y / Cursor Y
---@return integer width cursor 宽度 / Cursor width
---@return integer height cursor 高度 / Cursor height
---@return integer position clamp 后的 cursor position / Clamped cursor position
---@return integer decent 字体 descent / Font descent
function Layout:cursor(position)
end

---命中测试，返回 0-based cursor position。
---Hit-tests and returns a 0-based cursor position.
---@param x number 本地 X / Local X
---@param y number 本地 Y / Local Y
---@return integer position cursor position / Cursor position
---@return boolean out_of_box 是否在布局盒外 / Whether the point is outside the layout box
function Layout:hit_test(x, y)
end

---返回 visible position 使用的 0-based style id。
---Returns the 0-based style id at a visible position.
---@param position integer 0-based visible position / 0-based visible position
---@return integer? style style id；无效 position 返回 nil / Style id; nil for invalid position
function Layout:style(position)
end

---文本块创建函数。
---Text block builder function.
---@alias soluna.material.text.Block fun(text: string, width?: integer, height?: integer): string, integer

---文本布局创建函数。
---Text layout builder function.
---@alias soluna.material.text.LayoutBuilder fun(text: string, width?: integer, height?: integer): soluna.material.text.Layout

---text material 模块。
---Text material module.
---
---Tagged text stream 支持 `[i42]` icon、`[hex]` 临时颜色、`[sN]` style 切换、
---`[s]` 回到 style 0、`[wN]` / `[w]` 标记不可拆分换行组，以及 `[[`
---输出字面量 `[`。`[sN]` 中的 `N` 是 0-based style id，Lua style 数组
---第一项对应 style 0。`[wN]` 中的 `N` 是调用方自定义的正整数 group id；
---group 本身比行宽更宽时会退回普通逐字换行。
---
---Tagged text streams support `[i42]` icons, `[hex]` temporary colors, `[sN]`
---style switching, `[s]` reset to style 0, `[wN]` / `[w]` no-break wrap
---groups, and `[[` for a literal `[`. `N` in `[sN]` is a 0-based style id.
---The first Lua style entry is style 0. `N` in `[wN]` is a caller-defined
---positive group id. A group wider than the line falls back to normal
---per-character wrapping.
---@class soluna.material.text
local mattext = {}

---创建 style set。
---Creates a style set.
---@param fontcobj lightuserdata `font.cobj()` 返回的字体管理器指针 / Font manager pointer returned by `font.cobj()`
---@param styles soluna.material.text.Style[] style 数组，第一项是 style 0 / Style array; first entry is style 0
---@return soluna.material.text.Styles styles style set / Style set
function mattext.styles(fontcobj, styles)
end

---创建文本块和布局查询函数。
---Creates text block and layout query functions.
---@overload fun(styles: soluna.material.text.Styles, alignment?: string): soluna.material.text.Block, soluna.material.text.LayoutBuilder
---@param fontcobj lightuserdata `font.cobj()` 返回的字体管理器指针 / Font manager pointer returned by `font.cobj()`
---@param fontid integer `font.name()` 返回的字体 id / Font id returned by `font.name()`
---@param size? integer 字体像素大小，默认 24 / Font pixel size, default 24
---@param color? integer ARGB 颜色，默认 `0xff000000` / ARGB color, default `0xff000000`
---@param alignment? string 对齐代码，如 `"LT"`、`"CV"`、`"RB"` / Alignment code such as `"LT"`, `"CV"`, `"RB"`
---@return soluna.material.text.Block block 创建 packed text stream / Creates packed text stream
---@return soluna.material.text.LayoutBuilder layout 创建布局查询对象 / Creates layout query object
function mattext.block(fontcobj, fontid, size, color, alignment)
end

return mattext
