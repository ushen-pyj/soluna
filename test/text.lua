local soluna = require "soluna"
local ltask = require "ltask"
local mattext = require "soluna.material.text"
local matquad = require "soluna.material.quad"
local matclip = require "soluna.material.clip"
local font = require "soluna.font"
local file = require "soluna.file"

local function font_init()
	if soluna.platform == "wasm" then
		local bundled_path = "asset/font/SourceHanSansSC-Regular.ttf"
		local bundled_data = file.load(bundled_path)
		if bundled_data then
			font.import(bundled_data)
			local bundled_id = font.name "Source Han Sans SC Regular"
			if bundled_id then
				return bundled_id
			end
		end
	end

	local sysfont = require "soluna.font.system"
	local candidates = {
		"WenQuanYi Micro Hei",    -- Linux
		"Microsoft YaHei",        -- Windows
		"Yuanti SC",              -- macOS
		"Source Han Sans SC Regular", -- WASM
	}
	for _, name in ipairs(candidates) do
		local ok, data = pcall(sysfont.ttfdata, name)
		if ok and data then
			font.import(data)
			local fontid = font.name(name)
			if fontid then
				return fontid
			end
		end
	end
	error "No available system font for text sample"
end

soluna.set_window_title "soluna text sample"

local args = ...
local batch = args.batch
local fontid = font_init()
local fontcobj = font.cobj()

local callback = {}
local WIDTH_MIN <const> = 120
local WIDTH_MAX <const> = 300
local HEIGHT <const> = 200
local VIEWPORT_MIN <const> = 48
local VIEWPORT_MAX <const> = HEIGHT
local CLIP_BLEED <const> = 8
local screen_w = args.width
local screen_h = args.height

function callback.window_resize(w, h)
	screen_w = w
	screen_h = h
end

local TEXT <const> = [[[004000][w1]Hello[w][n], 这个句子中有[s1]大字[n]，也有[s2]小字[n]。这句话会在文本区居中
 这里追加一段 [w2]English[w] 和中文混排，[w3]no-break[w] [w4]words[w] 会随着宽度变化整体换行。
 [w5]超长不可分割分组会在比整行更宽时退回逐字换行[w]。]]
-- size 32; color 0; alignment center
-- local block, layout = mattext.block(fontcobj, fontid, 32, 0, "CV")
local function text_block()
	local styles = mattext.styles(fontcobj, {
		{ font = fontid, size = 24, color = 0 },
		{ font = fontid, size = 32, color = 0x800000 },
		{ font = fontid, size = 16, color = 0x000080 },
	})
	return mattext.block(styles, "CV")
end

local block, layout = text_block()
local label = nil
local label_layout = nil
local label_width = 0

local cursor_pos = 0
local selection_anchor = nil
local selection_focus = nil
local dragging = false

local function viewport_height(count)
	local t = (math.sin(count * 0.025) + 1) * 0.5
	return math.floor(VIEWPORT_MIN + (VIEWPORT_MAX - VIEWPORT_MIN) * t)
end

local function viewport_width(count)
	local t = (math.sin(count * 0.018 + 1.3) + 1) * 0.5
	return math.floor(WIDTH_MIN + (WIDTH_MAX - WIDTH_MIN) * t)
end

local function update_label(width)
	if width == label_width then
		return
	end
	label_width = width
	label = block(TEXT, width, HEIGHT)
	label_layout = layout(TEXT, width, HEIGHT)
end

update_label(WIDTH_MAX)

local function position(width)
	local x = (screen_w - width) / 2
	local y = (screen_h - HEIGHT) / 2
	return x, y
end

local function ordered_selection()
	if not selection_anchor or not selection_focus then
		return nil
	end
	local from = selection_anchor
	local to = selection_focus
	if to < from then
		from, to = to, from
	end
	if from == to then
		return nil
	end
	return from, to
end

local function draw_selection(x, y)
	local from, to = ordered_selection()
	if not from then
		return
	end
	for i = 1, label_layout:line_count() do
		local line = label_layout:line(i)
		if line then
			local a = math.max(from, line.start)
			local b = math.min(to, line.finish)
			if a < b then
				local sx
				if a <= line.start then
					sx = line.x
				else
					sx = label_layout:cursor(a)
				end
				local ex
				if b >= line.finish then
					ex = line.x + line.width
				else
					ex = label_layout:cursor(b)
				end
				local w = math.floor(ex - sx + 0.5)
				if w > 0 then
					batch:add(matquad.quad(w, line.height, 0x664f7dff), x + sx, y + line.y)
				end
			end
		end
	end
end

function callback.frame(count)
	local clip_h = viewport_height(count)
	local width = viewport_width(count)
	update_label(width)
	local x, y = position(width)
	batch:add(matquad.quad(width, clip_h, 0x400000ff), x, y)
	batch:add(matclip.rect(width + CLIP_BLEED * 2, clip_h), x - CLIP_BLEED, y)
	draw_selection(x, y)
	batch:add(label, x, y)
	-- cursor
	local cx, cy, cw, ch, n = label_layout:cursor(cursor_pos)
	cursor_pos = n
	batch:add(matquad.quad(cw, ch, 0xffffff), cx + x, cy + y)
	batch:add(matclip.rect())
end

function callback.key(keycode, state)
	if state == 1 then         -- press
		if keycode == 262 then -- right
			cursor_pos = cursor_pos + 1
		elseif keycode == 263 then -- left
			cursor_pos = cursor_pos - 1
		else
			print(keycode)
		end
	end
end


local mouse_x = 0
local mouse_y = 0

local function hit_text(x, y)
	local ox, oy = position(label_width)
	return label_layout:hit_test(x - ox, y - oy)
end

function callback.mouse_move(x, y)
	mouse_x = x
	mouse_y = y
	if dragging then
		selection_focus = hit_text(x, y)
		cursor_pos = selection_focus
	end
end

local MOUSE_LEFT <const> = 0
local MOUSE_RELEASE <const> = 0
local MOUSE_PRESS <const> = 1

function callback.mouse_button(button, state)
	if button ~= MOUSE_LEFT then
		return
	end
	if state == MOUSE_PRESS then
		local hit = hit_text(mouse_x, mouse_y)
		selection_anchor = hit
		selection_focus = hit
		cursor_pos = hit
		dragging = true
	elseif state == MOUSE_RELEASE then
		dragging = false
	end
end

return callback
