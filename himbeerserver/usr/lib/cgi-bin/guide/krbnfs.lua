#!/usr/bin/env lua

local cgi = require "cgi"
local file = require "file"

cgi.serve(file.process("/guide/krbnfs.md", nil, "--toc"))
