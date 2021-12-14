#!/usr/bin/env lua
require "cgi"

cgi.content_type("application/json")
cgi.content("{}")
cgi.done()
