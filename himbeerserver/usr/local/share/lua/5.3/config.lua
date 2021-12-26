config = {}

local function split(self, sep)
	if not sep then sep = "%s" end

	local t = {}
	for str in self:gmatch("([^" .. sep .. "]+)") do
		table.insert(t, str)
	end

	return t
end

function config.get(question)
	-- input could be malicious
	if not question:match("^([%a_]*)$") then
		return nil
	end

	local cmd = "echo 'GET himbeerserver/" .. question .. "' | " ..
			"sudo debconf-communicate himbeerserver"

	local handle = io.popen(cmd)
	local ret = split(handle:read("*a"), "\n")
	handle:close()

	return split(ret[#ret], " ")[2]
end

return config
