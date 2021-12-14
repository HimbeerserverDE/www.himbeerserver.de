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

cgi.method = os.getenv("REQUEST_METHOD")

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

local headers_complete = false
function cgi.header(key, value)
	if not headers_complete then
		print(key .. ": " .. value)
	end

	return not headers_complete
end

function cgi.content(data)
	if not headers_complete then
		print()
		headers_complete = true
	end

	if data then
		print(data)
	end

	return not not data
end

function cgi.done()
	if not headers_complete then
		cgi.content()
	end
end

function cgi.content_type(type)
	return cgi.header("Content-type", type)
end

function cgi.status(code)
	return cgi.header("Status", tostring(code))
end

return cgi
