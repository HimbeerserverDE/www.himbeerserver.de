local cgi = require "cgi"
local file = require "file"

local f = io.open("/dev/random", "r")
local rand = f:read(64)
f:close()

local seed = 0
for _, v in ipairs(rand) do
	seed = seed + string.byte(v)
end
math.randomseed(seed)

local passwords = {
	strongest = {},
	strong = {},
	medium = {},
	weak = {},
}

for i = 1, 5 do
	table.insert(passwords.strongest, gen_strongest())
	table.insert(passwords.strong, gen_strong())
	table.insert(passwords.medium, gen_medium())
	table.insert(passwords.weak, gen_weak())
end

local data = {}
for k, t in pairs(passwords) do
	for i, v in ipairs(t) do
		data[k .. tostring(i)] = v
	end
end

cgi.content(file.process("/password_generator.md", data))

cgi.done()
