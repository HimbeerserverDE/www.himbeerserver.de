default_target: himbeerserver.deb

himbeerserver.deb:
	dpkg-deb	--build	.	deb/himbeerserver.deb
