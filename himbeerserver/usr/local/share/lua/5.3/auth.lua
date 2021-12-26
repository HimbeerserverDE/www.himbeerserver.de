local cgi = require "cgi"
local http_request = require "http.request"
local json = require "lunajson"

auth = {}

function auth.log_in()
	cgi.set_cookie("LoginRedirect", {
		path = "/",
		expires = nil, -- session cookie
		http_only = false,
		https_only = false, -- ToDo: TLS support
		same_site = cgi.strict,
		value = os.getenv("SCRIPT_NAME"),
	})

	cgi.status(302)
	cgi.header("Location", "/cgi-bin/account/login.lua")

	cgi.done()
end

function auth.user_info()
	local session = cgi.get_session()
	if not session.oauth or not session.oauth.access_token then
		return nil
	end

	local api_uri = "https://api.github.com/user"
	local request = http_request.new_from_uri(api_uri)
	if not request then
		return nil
	end

	local token = session.oauth.access_token
	request.headers:append("accept", "application/vnd.github.v3+json", false)
	request.headers:append("authorization", "token " .. token)

	-- send oauth request
	local headers, stream = request:go()
	if not headers or not stream then
		return nil
	end

	local body = stream:get_body_as_string()
	if not body then
		return nil
	end

	if headers:get ":status" ~= "200" then
		return nil
	end

	return json.decode(body)
end

function auth.logged_in()
	local user = auth.user_info()
	return not not user
end

function auth.require_login()
	if not auth.logged_in() then
		cgi.status(401)
		cgi.done()
	end
end

function auth.require_auth()
	if not auth.logged_in() then
		auth.log_in()
	end
end

return auth
