cgi = {}

function string.split(self, sep)
	if not sep then sep = "%s" end

	local t = {}
	for str in self:gmatch("([^" .. sep .. "]+)") do
		table.insert(t, str)
	end

	return t
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

-- constants for SameSite attribute
cgi.none = "None"
cgi.lax = "Lax"
cgi.strict = "Strict"

-- cookies
local cookies = {}

local cookie = os.getenv("HTTP_COOKIE")
if cookie then
	local c = {}
	parse_params(c, cookie)

	for k, v in pairs(c) do
		cookies[k] = {
			value = v,
			_recv = true,
		}
	end
end

function cgi.get_cookie(name)
	if not cookies[name] then return nil end
	return cookies[name].value
end

function cgi.set_cookie(name, cookie)
	cookies[name] = cookie
end

-- custom headers
function cgi.request_header(name)
	return os.getenv("HTTP_" .. name:upper())
end

local headers_complete = false
function cgi.header(key, value)
	if not headers_complete then
		print(key .. ": " .. value)
	end

	return not headers_complete
end

-- set cookies on exit
local function set_cookies()
	local cookie = ""
	for name, c in pairs(cookies) do
		cookie = cookie .. name .. "="
		cookie = cookie .. cgi.encode_uri(c.value or "")

		if c.domain then
			cookie = cookie .. "; Domain=" .. c.domain
		end
		if c.path then
			cookie = cookie .. "; Path=" .. c.path
		end
		if c.max_age then
			cookie = cookie .. "; MaxAge=" .. tostring(c.max_age)
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
	end

	if #cookie > 0 then
		cgi.header("Set-Cookie", cookie)
	end
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
		cgi.content()
	end

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
