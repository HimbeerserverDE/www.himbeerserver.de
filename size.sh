#!/bin/bash

du --apparent-size -sc $1/etc $1/usr | tail -n 1 | awk '{print $1}'
