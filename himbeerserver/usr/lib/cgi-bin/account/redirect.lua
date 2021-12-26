#!/usr/bin/env lua

local cgi = require "cgi"
local auth = require "auth"

auth.require_auth()

cgi.status(302)
cgi.header("Location", "/account")

cgi.done()
