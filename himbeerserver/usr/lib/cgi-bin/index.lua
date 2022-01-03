#!/usr/bin/env lua

local cgi = require "cgi"
local file = require "file"

cgi.content(file.process("/index.md", {
	name = "test",
}))

cgi.done()
