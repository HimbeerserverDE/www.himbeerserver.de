#!/usr/bin/env lua

local cgi = require "cgi"
local config = require "config"
local http_request = require "http.request"
local json = require "lunajson"

if cgi.method ~= "GET" or not cgi.get.code or not cgi.get.state then
	if cgi.get.error == "access_denied" then
		-- ToDo: show error page
		cgi.status(403)
	else
		cgi.status(400)
	end

	cgi.done()
end

-- weird: SameSite=Strict cookies aren't sent
-- after HTTP header redirect
-- fix: refresh
local session = cgi.get_session()
if not session.oauth then
	cgi.content("<meta http-equiv='refresh' content='0'>")
	cgi.done()
end
-- end fix

local client_id = config.get("client_id")
local client_secret = config.get("client_secret")

if not client_id or not client_secret then
	-- ToDo: show error page
	cgi.status(500)
	cgi.done()
end

local token_uri = "https://github.com/login/oauth/access_token?" ..
		"client_id=" .. client_id .. "&" ..
		"client_secret=" .. client_secret .. "&" ..
		"code=" .. cgi.get.code
local request = assert(http_request.new_from_uri(token_uri))
request.headers:append("accept", "application/json", false)

local headers, stream = assert(request:go())
local body = assert(stream:get_body_as_string())
if headers:get ":status" ~= "200" then
	cgi.status(401)
	cgi.done()
end

local oauth_resp = json.decode(body)
if not oauth_resp.access_token then
	cgi.status(401)
	cgi.done()
end

session.expires = cgi.default_session_lifetime

if session.oauth.state ~= cgi.get.state then
	cgi.status(403)
	cgi.done()
end

if not session.oauth then
	session.oauth = {}
end

session.oauth.state = nil
session.oauth.access_token = oauth_resp.access_token
cgi.set_session(session)

cgi.status(302)

local rdr = cgi.get_cookie("LoginRedirect") or "/"
cgi.header("Location", rdr)

cgi.done()
