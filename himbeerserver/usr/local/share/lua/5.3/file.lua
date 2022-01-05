file = {}

function string.split(self, sep)
	if not sep then sep = "%s" end

	local t = {}
	for match in (self .. sep):gmatch("(.-)" .. sep) do
		table.insert(t, match)
	end

	return t
end

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

function file.process(uri, templates, params)
	local tmp = "/var/tmp/himbeerserver" .. uri
	path = "/var/www/md" .. uri

	local contents = file.read(path)
	if not contents then
		return nil
	end

	if templates then
		for template, value in pairs(templates) do
			contents = contents:gsub("%${" .. template .. "}", value)
		end
	end

	local lines = contents:split("\n")
	local title, num = lines[1]:gsub("^(# )", "")
	if num ~= 1 then
		return nil
	end

	table.remove(lines, 1)
	contents = table.concat(lines, "\n")

	local filename = os.tmpname()
	file.write(filename, contents)

	params = (params or ""):match("^([%a%d=]*)$") or ""

	local cmd = 'pandoc ' .. params .. ' --standalone --metadata title="'
			.. title .. '" ' .. filename
	local handle = io.popen(cmd)
	local html = handle:read("*a")
	handle:close()

	return html
end

return file
