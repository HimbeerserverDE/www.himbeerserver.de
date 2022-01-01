local json = require "lunajson"

cgi = {}

-- constants
cgi.default_session_lifetime = os.time() + 3153600

cgi.none = "None"
cgi.lax = "Lax"
cgi.strict = "Strict"

-- global helpers
function string.split(self, sep)
	if not sep then sep = "%s" end

	local t = {}
	for str in self:gmatch("([^" .. sep .. "]+)") do
		table.insert(t, str)
	end

	return t
end

function string.fromhex(self)
	return (self:gsub("..", function(cc)
		return string.char(tonumber(cc, 16))
	end))
end

function string.tohex(self)
	return (self:gsub(".", function(c)
		return string.format("%02x", string.byte(c))
	end))
end

function cgi.encode_uri(str)
	if str then
		str = str:gsub("\n", "\r\n")
		str = str:gsub("([^%w _ %- . ~])",
			function(c) return string.format("%%%02X", string.byte(c)) end)
		str = str:gsub(" ", "+")
	end

	return str
end

function cgi.decode_uri(str)
	if str then
		str = str:gsub("+", " ")
		str = str:gsub("%%(%x%x)",
			function(hex) return string.char(tonumber(hex, 16)) end)
	end

	return str
end

local function parse_params(dst, src)
	for _, pair in ipairs(src:split("&")) do
		local kv = pair:split("=")
		local key = kv[1]
		local value = kv[2]

		dst[key] = cgi.decode_uri(value)
	end
end

local function params_tostring(src)
	local dst = ""
	for k, v in pairs(src) do
		local kv = k .. "=" .. cgi.encode_uri(v)
		dst = dst .. kv .. "&"
	end

	return dst:sub(1, #dst - 1)
end

local function parse_cookies(dst, src)
	for _, pair in ipairs(src:split("; ")) do
		local kv = pair:split("=")
		local key = kv[1]
		local value = kv[2]

		dst[key] = cgi.decode_uri(value)
	end
end

-- method
cgi.method = os.getenv("REQUEST_METHOD")

-- GET/POST params
cgi.get = {}
cgi.post = {}

if cgi.method == "GET" then
	local get_params = os.getenv("QUERY_STRING")
	if get_params then
		parse_params(cgi.get, get_params)
	end
elseif cgi.method == "POST" then
	local post_params = io.read("*a")
	if post_params then
		parse_params(cgi.post, post_params)
	end
end

-- cookies
local cookies = {}

local cookie = os.getenv("HTTP_COOKIE")
if cookie then
	local c = {}
	parse_cookies(c, cookie)

	for k, v in pairs(c) do
		cookies[k] = {value = v}
	end
end

function cgi.get_cookie(name)
	if not cookies[name] then return nil end
	return cookies[name].value
end

function cgi.set_cookie(name, cookie)
	cookie._modified = true
	cookies[name] = cookie
end

-- custom headers
function cgi.request_header(name)
	return os.getenv("HTTP_" .. name:upper())
end

local resp_headers = {}
local headers_complete = false
function cgi.header(key, value)
	if not value then
		return false
	end

	if not headers_complete then
		resp_headers[key] = value
		print(key .. ": " .. value)
	end

	return not headers_complete
end

-- set cookies on exit
local function set_cookies()
	for name, c in pairs(cookies) do
		if c._modified then
			local cookie = name .. "=" .. cgi.encode_uri(c.value or "")

			if c.domain then
				cookie = cookie .. "; Domain=" .. c.domain
			end
			if c.path then
				cookie = cookie .. "; Path=" .. c.path
			end
			if c.expires then
				cookie = cookie .. "; Expires=" .. c.expires
			end
			if c.http_only then
				cookie = cookie .. "; HttpOnly"
			end
			if c.https_only then
				cookie = cookie .. "; Secure"
			end
			if c.same_site then
				cookie = cookie .. "; SameSite=" .. c.same_site
			end

			cgi.header("Set-Cookie", cookie)
		end
	end
end

-- sessions
local f = io.open("/var/lib/himbeerserver/sessions.json", "r")
local sessions = json.decode(f:read("*a"))
f:close()

for himbeer_session, session in pairs(sessions) do
	if expires and os.time() >= session.expires then
		sessions[himbeer_session] = nil
	end
end

local function save_session_map()
	local f = io.open("/var/lib/himbeerserver/sessions.json", "w")
	f:write(json.encode(sessions))
	f:close()
end

function cgi.get_session()
	local himbeer_session = cgi.get_cookie("HimbeerSession")
	if not himbeer_session then return {} end

	return sessions[himbeer_session] or {}
end

function cgi.set_session(data)
	local himbeer_session = cgi.get_cookie("HimbeerSession")
	if not himbeer_session then
		-- if session does not exist, create it
		local f = io.open("/dev/random", "r")
		himbeer_session = f:read(32):tohex()
		f:close()

		cgi.set_cookie("HimbeerSession", {
			path = "/",
			expires = cgi.date(data.expires),
			http_only = true,
			https_only = true,
			same_site = cgi.strict,
			value = himbeer_session,
		})
	end

	sessions[himbeer_session] = data
end

-- special date format
function cgi.date(t)
	return os.date("!%a, %d %b %Y %H:%M:%S GMT", t)
end

-- (custom) content
function cgi.content(data)
	if not headers_complete then
		set_cookies()
		print()
		headers_complete = true
	end

	if data then
		print(data)
	end

	return not not data
end

-- finish response
function cgi.done()
	if not headers_complete then
		local body

		local status = tonumber(resp_headers["Status"])
		if status and status >= 400 and status < 600 then
			-- error but no content: display error page
			local f = io.open("/var/www/html/error/" .. tostring(status) .. ".html")
			if f then
				body = f:read("*a")
				f:close()
			end
		end

		cgi.content(body)
	end

	save_session_map()
	os.exit(0)
end

-- frequently used header utilities
function cgi.content_type(type)
	return cgi.header("Content-Type", type)
end

function cgi.status(code)
	return cgi.header("Status", tostring(code))
end

return cgi
