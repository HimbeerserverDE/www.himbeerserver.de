file = {}

function file.read(path)
	local f = io.open(path, "r")
	if not f then
		return nil
	end

	local contents = f:read("*a")
	f:close()

	return contents
end

function file.write(path, contents)
	local f = io.open(path, "w")
	if not f then
		return false
	end

	f:write(contents)
	f:close()

	return true
end

function file.process(uri, templates)
	local tmp = "/var/tmp/himbeerserver" .. uri
	path = "/var/www/md" .. uri

	local contents = file.read(path)
	if not contents then
		return nil
	end

	for template, value in pairs(templates) do
		contents = contents:gsub("${" .. template .. "}", value)
	end

	local lines = contents:split("\n")
	local title = lines[1]:gsub("# ", "")
	table.remove(lines, 1)

	contents = table.concat(lines, "\n"):gsub("'", "\\'")

	local cmd = 'echo -n \'' .. contents .. '\' | pandoc --standalone --metadata title="'
			.. title .. '" '
	local handle = io.popen(cmd)
	local html = handle:read("*a")
	handle:close()

	return html
end

return file
