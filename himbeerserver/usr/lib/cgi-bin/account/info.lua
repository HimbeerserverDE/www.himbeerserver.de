#!/usr/bin/env lua

local cgi = require "cgi"
local auth = require "auth"
local json = require "lunajson"

auth.require_login()

cgi.content_type("application/json")
cgi.content(json.encode(auth.user_info()))

cgi.done()
