#!/bin/bash

dpkg-deb -b himbeerserver/
if [ $? != 0 ]; then
	echo -e " [\e[31m✗\e[0m] Error building deb package, see above"
else
	echo -e " [\e[32m✓\e[0m] Building done, run 'apt install ./himbeerserver.deb' as root to install"
fi
