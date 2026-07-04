local clipmat = require "soluna.material.clip"

local ctx = ...
local state = ctx.state
clipmat.set_material_id(ctx.id)

state.material_clip = clipmat.new {
	uniform = state.uniform,
}

local material = {}

function material.reset()
	state.material_clip:reset()
end

function material.submit(ptr, n)
	state.material_clip:submit(ptr, n)
end

function material.draw(ptr, n)
	state.material_clip:draw(ptr, n)
end

return material
