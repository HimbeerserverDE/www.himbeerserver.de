#!/bin/bash

dpkg-deb -b himbeerserver/
echo -e " [\e[32m✓\e[0m] Building done, run 'dpkg -i himbeerserver.deb' as root to install"
