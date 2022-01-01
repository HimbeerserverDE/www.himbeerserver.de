#!/usr/bin/env lua

local cgi = require "cgi"
local config = require "config"
local http_request = require "http.request"
local json = require "lunajson"

if cgi.method ~= "GET" then
	cgi.status(405)
	cgi.done()
end

if not cgi.get.code or not cgi.get.state then
	if cgi.get.error == "access_denied" then
		cgi.status(401)
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

if not session.oauth.provider then
	cgi.status(400)
	cgi.done()
end

local client_id = config.get(session.oauth.provider .. "_client_id")
local client_secret = config.get(session.oauth.provider .. "_client_secret")

if not client_id or not client_secret then
	cgi.status(500)
	cgi.done()
end

local domain = config.get("domain")
local rdr_uri = "https://" .. domain .. "/cgi-bin/account/oauth/redirect.lua"

local token_uri, post_params
if session.oauth.provider == "github" then
	token_uri = "https://github.com/login/oauth/access_token?" ..
			"client_id=" .. client_id .. "&" ..
			"client_secret=" .. client_secret .. "&" ..
			"code=" .. cgi.get.code
elseif session.oauth.provider == "discord" then
	token_uri = "https://discord.com/api/oauth2/token"
	post_params = "client_id=" .. client_id .. "&" ..
			"client_secret=" .. client_secret .. "&" ..
			"code=" .. cgi.get.code .. "&" ..
			"redirect_uri=" .. rdr_uri .. "&" ..
			"grant_type=authorization_code"
end

local request = assert(http_request.new_from_uri(token_uri))
if session.oauth.provider == "discord" then
	request.headers:upsert(":method", "POST")
	request.headers:append("content-type", "application/x-www-form-urlencoded")
	request:set_body(post_params)
end

request.headers:append("accept", "application/json", false)

local headers, stream = assert(request:go())
local body = assert(stream:get_body_as_string())
if headers:get ":status" ~= "200" then
	-- cgi.status(401)
	cgi.status(tonumber(headers:get ":status"))
	cgi.content(body)
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
