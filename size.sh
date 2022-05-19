#!/bin/bash

du --apparent-size -sc $1/etc $1/usr $1/var | tail -n 1 | awk '{print $1}'
du --apparent-size -sc $1/../himbeerserver.deb | tail -n 1 | awk '{print $1}'
