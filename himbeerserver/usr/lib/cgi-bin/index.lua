#!/usr/bin/env lua

local cgi = require "cgi"
local file = require "file"

cgi.content(file.process("/index.md", nil, "--toc"))
cgi.done()
