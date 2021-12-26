#!/usr/bin/env lua

local cgi = require "cgi"

local session = cgi.get_session()
session.oauth = nil
cgi.set_session(session)

cgi.status(302)
cgi.header("Location", "/")
cgi.done()
