#!/usr/bin/env lua

local cgi = require "cgi"
local file = require "file"

local f = io.open("/dev/random", "r")
local rand = f:read(64)
f:close()

local seed = 0
for i = 1, #rand do
	local c = rand:sub(i, i)
	seed = seed + string.byte(c)
end
math.randomseed(seed)

local chars = {
	strongest = "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_abcdefghijklmnopqrstuvwxyz{|}~",
	strong = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz",
	medium = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz",
	weak = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz",
}

-- generator function
local function gen(from, len)
	local result = ""
	for i = 1, len do
		local j = math.random(1, #from)
		result = result .. from:sub(j, j)
	end

	return result:gsub("%%", "%%%%")
end

local passwords = {}
for i = 1, 5 do
	passwords["strongest" .. tostring(i)] = gen(chars.strongest, 32)
	passwords["strong" .. tostring(i)] = gen(chars.strong, 32)
	passwords["medium" .. tostring(i)] = gen(chars.medium, 32)
	passwords["weak" .. tostring(i)] = gen(chars.weak, 16)
end

cgi.serve(file.process("/password_generator.md", passwords))
