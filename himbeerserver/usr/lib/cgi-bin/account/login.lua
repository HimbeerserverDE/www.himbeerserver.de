#!/usr/bin/env lua

local cgi = require "cgi"
local config = require "config"

if cgi.method ~= "GET" then
	cgi.status(400)
	cgi.done()
end

if cgi.get.provider ~= "github" and cgi.get.provider ~= "discord" then
	-- ToDo: show error page
	cgi.status(400)
	cgi.done()
end

local client_id = config.get(cgi.get.provider .. "_client_id")
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

local authorize_uri
if cgi.get.provider == "github" then
	authorize_uri = "https://github.com/login/oauth/authorize?" ..
			"client_id=" .. client_id .. "&" ..
			"redirect_uri=" .. rdr_uri .. "&" ..
			"state=" .. state
elseif cgi.get.provider == "discord" then
	authorize_uri = "https://discord.com/api/oauth2/authorize?" ..
			"client_id=" .. client_id .. "&" ..
			"redirect_uri=" .. rdr_uri .. "&" ..
			"state=" .. state .. "&" ..
			"response_type=code&" ..
			"scope=identify&" ..
			"prompt=none"
end

local session = cgi.get_session()
session.expires = cgi.default_session_lifetime

if not session.oauth then
	session.oauth = {}
end

session.oauth.provider = cgi.get.provider
session.oauth.state = state
cgi.set_session(session)

cgi.status(302)
cgi.header("Location", authorize_uri)

cgi.done()
