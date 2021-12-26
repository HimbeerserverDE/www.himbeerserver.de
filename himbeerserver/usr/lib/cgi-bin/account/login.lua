#!/usr/bin/env lua

local cgi = require "cgi"
local config = require "config"

local client_id = config.get("client_id")
if not client_id then
	-- ToDo: show error page
	cgi.status(500)
	cgi.done()
end

-- ToDo: TLS support
local rdr_uri = "http://himbeerserver.de/cgi-bin/account/oauth/redirect.lua"

local f = io.open("/dev/random", "r")
local state = f:read(32):tohex()
f:close()

local authorize_uri = "https://github.com/login/oauth/authorize?" ..
		"client_id=" .. client_id .. "&" ..
		"redirect_uri=" .. rdr_uri .. "&" ..
		"state=" .. state

local session = cgi.get_session()
session.expires = cgi.default_session_lifetime

if not session.oauth then
	session.oauth = {}
end

session.oauth.state = state
cgi.set_session(session)

cgi.status(302)
cgi.header("Location", authorize_uri)

cgi.done()
