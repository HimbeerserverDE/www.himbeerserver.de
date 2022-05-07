#!/usr/bin/env lua

local cgi = require "cgi"
local file = require "file"

cgi.serve(file.process("/guides.md"))
