file = {}

function file.read(path)
	path = "/var/www/html" .. path

	local f = io.open(path, "r")
	if not f then
		return nil
	end

	local contents = f:read("*a")
	f:close()

	return contents
end

function file.write(path, contents)
	path = "/var/www/html" .. path

	local f = io.open(path, "w")
	if not f then
		return false
	end

	f:write(contents)
	f:close()

	return true
end

function file.process(path, templates)
	local contents = file.read(path)
	if not contents then
		return nil
	end

	for template, value in pairs(templates) do
		contents = contents:gsub("${" .. template .. "}", value)
	end

	return contents
end

return file
