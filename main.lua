local sti   = require("lib.sti")
local Input = require("lib.input")

local Player   = require("player")
local Bridge   = require("bridge")
local Trapdoor = require("trapdoor")

-- Constants
WIDTH  = love.graphics.getWidth()
HEIGHT = love.graphics.getHeight()

-- Locals
local debug = false
local player_drop  = false

local meter = 8
local multiplier = 10
local scale = 3

local entities = {
	bridges   = {},
	trapdoors = {}
}

local shaders = {}


function load_keybindings()
	input = Input()

	-- General bindings
	input:bind('q',      "quit")	
	input:bind('escape', "quit")	
	input:bind('r',		 "restart")
	input:bind('tab',	 "debug")

	-- Player controls
	input:bind('w', "up")
	input:bind('s', "down")
	input:bind('d', "right")
	input:bind('a', "left")
	input:bind('k', "fly")

	-- Debug
	input:bind('space', "toggle shader")
	input:bind('j',		"toggle jetpack")
end

function update_keybindings(dt)
	if input:pressed("quit") then
		love.event.quit()
	elseif input:pressed("restart") then
		love.event.quit("restart")
	end

	if input:pressed("debug") then
		debug = not debug
	end
	if input:pressed("down") then
		player_drop = true
	end
	if input:pressed("toggle shader") then
		shader_id = shader_id + 1

		if shader_id > #shaders then
			shader_id = 0
		end
	end
end

function load_shaders()
	shaders = {
		{ love.graphics.newShader("shaders/gray_scale.glsl"),	"gray scale" },
		{ love.graphics.newShader("shaders/weird_shader.glsl"), "weird shader" },
		{ love.graphics.newShader("shaders/glow_shader.glsl"),  "glow shader" }
	}

	shader_id = 0
end

function cycle_shaders()
	if shader_id == 0 then
		love.graphics.setShader()
	else
		love.graphics.setShader(shaders[shader_id][1])
	end
end


-- MAIN FUNCTIONS
function love.load()
	load_keybindings()
	load_shaders()

	world = love.physics.newWorld(0, 9.807*meter*multiplier, true)
	world:setCallbacks(begin_contact, end_contact, presolve, postsolve)

	map = sti("assets/maps/map.lua", { "box2d" })
	map:box2d_init(world)

	local sprite_layer = map.layers["sprite layer"]
	sprite_layer.sprites = {
		player = {
			image = love.graphics.newImage("assets/sprites/player.png"),
			tags = { "player" }
		}
	}

	local spawn_layer = map.layers["spawn"]
	for _, object in pairs(spawn_layer.objects) do
		if object.name == "player_spawn" then
			player = Player.new(world, object.x, object.y)
			player:load()
		elseif object.name == "bridge_spawn" then
			table.insert(entities.bridges, Bridge.new(world, object.x + meter/2, object.y + meter/2-0.5))
		elseif object.name == "trapdoor_spawn" then
			table.insert(entities.trapdoors, Trapdoor.new(world, object.x + meter/2, object.y + meter/2-0.5))
		end
	end

	function sprite_layer:draw()
		for _, sprite in pairs(self.sprites) do
			for _, tag in pairs(sprite.tags) do
				if tag == "player" then
					self.sprites.player.x = player.body:getX() - meter/2
					self.sprites.player.y = player.body:getY() - meter/2
				end
			end

			local vel_x, vel_y = player.body:getLinearVelocity()
			if vel_x >= -5 then
				love.graphics.draw(sprite.image, math.floor(sprite.x + 9), math.floor(sprite.y + 1), 0, -1, 1)
				--love.graphics.draw(sprite.image, sprite.x + 9, sprite.y, 0, -1, 1)
			else
				love.graphics.draw(sprite.image, math.floor(sprite.x), math.floor(sprite.y + 1), 0, 1, 1)
				--love.graphics.draw(sprite.image, sprite.x, sprite.y, 0, 1, 1)
			end

			--if player.has_jetpack and player.is_flying then
				--love.graphics.draw(player.jetpack.psystem, player.body:getX(), player.body:getY() + meter)	
				player.jetpack:draw()
			--end
		end
	end
end

function love.update(dt)
	world:update(dt)
	player:update(dt, input)

	update_keybindings(dt)
end

function love.draw()
	cycle_shaders()

	love.graphics.setDefaultFilter("nearest", "nearest")
	map:draw(-player.body:getX() + WIDTH/2/scale, -player.body:getY() + HEIGHT/2/scale, scale, scale)

	local vel_x, vel_y = player.body:getLinearVelocity()
	love.graphics.print("Velocity X: " .. math.floor(vel_x) .. ", Velocity Y: " .. math.floor(vel_y), 10, 10)

	love.graphics.print("Jetpack: " .. tostring(player.has_jetpack), 10, 30)
	love.graphics.print("Is flying: " .. tostring(player.is_flying), 10, 50)

	if player.is_flying then
		love.graphics.print("PSYSTEM ON!", 10, 70)
	end

	if debug then
		map:box2d_draw(-player.body:getX() + WIDTH/2/scale, -player.body:getY() + HEIGHT/2/scale, scale, scale)
		player:draw_debug(-player.body:getX() + WIDTH/2/scale, -player.body:getY() + HEIGHT/2/scale, scale)

		love.graphics.print("Is flying: " .. tostring(player.is_flying), 10, 50)

		for _, bridge in ipairs(entities.bridges) do
			bridge:draw_debug(-player.body:getX() + WIDTH/2/scale, -player.body:getY() + HEIGHT/2/scale, scale)
		end
		for _, trapdoor in ipairs(entities.trapdoors) do
			trapdoor:draw_debug(-player.body:getX() + WIDTH/2/scale, -player.body:getY() + HEIGHT/2/scale, scale)
		end

		if player.is_flying then
			love.graphics.print("PSYSTEM ON!", 10, 70)
		end
	end
end

function begin_contact(a, b, contact)
end

function end_contact(a, b, contact)
end

function presolve(a, b, contact)
	local vel_x, vel_y = player.body:getLinearVelocity()
	
	if a:getUserData() == "player" then
		topleft_x, topleft_y, bottomright_x, bottomright_y = b:getBoundingBox()	
	elseif b:getUserData() == "player" then
		topleft_x, topleft_y, bottomright_x, bottomright_y = a:getBoundingBox()	
	end

	if (a:getUserData() == "player" or b:getUserData() == "player") and bottomright_y > player.body:getY() then
		player.can_jump = true
	end

	if a:getUserData() == "player" and b:getUserData() == "bridge" then
		if player_drop then
			contact:setEnabled(false)
		elseif vel_y < -3 then
			contact:setEnabled(false)
		end	
	elseif a:getUserData() == "player" and b:getUserData() == "trapdoor" then
		if player_drop then
			contact:setEnabled(false)
		elseif vel_y < -3 then
			contact:setEnabled(false)
		end	
	end
end

function postsolve(a, b, contact, normalimpulse, tangentimpulse)
	player_drop = false
end

