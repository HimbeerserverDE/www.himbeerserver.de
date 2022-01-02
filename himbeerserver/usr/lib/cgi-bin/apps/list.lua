#!/usr/bin/env lua

local cgi = require "cgi"
local json = require "lunajson"

local cmd = 'find /var/www/html/apps/* -type "d" | ' ..
		'sed "s/\\/var\\/www\\/html//"'
local handle = io.popen(cmd)
local paths_str = handle:read("*a")
handle:close()

local apps = {}
local paths = paths_str:split("\n")
for _, path in ipairs(paths) do
	local f = io.open(path .. "/.project_name", "r")
	local app = f:read("*a")
	f:close()

	apps[app] = path
end

cgi.header("Content-Type", "application/json")
cgi.content(json.encode(apps))

cgi.done()
