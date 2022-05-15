% Setting up OpenVPN IPv6 support

# The different kinds of IPv6 support
OpenVPN supports IPv6 in two different ways. It can listen on
an IPv6 socket so that IPv6 clients can connect to it.
This way you can run OpenVPN servers that are IPv6 only.

This does not allow connected clients to access hosts via IPv6.
In order to achieve that the server needs to assign addresses
that are routable on the internet.

# Listening on an IPv6 socket
This is quite easy to set up. Open your `/etc/openvpn/server.conf`
and append a 6 to the proto line. For example `proto udp`
becomes `proto udp6`.

# Assigning addresses from a prefix
The OpenVPN server can assign IPv6 addresses from a prefix.
I recommend a /64 subnet, but OpenVPN supports smaller prefixes
such as /112 as well. If you have a bigger subnet such as /60
you can make it a /64 by filling it up with zeros.

To enable this feature add this to your `/etc/openvpn/server.conf`:

```
server-ipv6 2001:db8:0:123::/64
```

## Static addresses
*WARNING: If you're using the client config dir to set static IPv4
addresses you have to set static IPv6 addresses as well:*

```
ifconfig-ipv6-push 2001:db8:0:123::abcd/64 2001:db8:0:123::1
```

where `abcd` is the IFID you'd like the client to get.

## Pushing routes
Now we have to route IPv6 traffic through the tunnel.
Traffic to the subnet of GUAs (2000::/3) always has to be routed
through the tunnel. If you have an ULA prefix or anything else
you'd like to go through the tunnel simply add another
line to the config and use that prefix.

Add this to `/etc/openvpn/server.conf`:

```
push "route-ipv6 2000::/3"
```

# Routing
The OpenVPN IPv6 prefix either needs to be NATed or routed.
If it's a subnet of the IPv6 prefix assigned by your ISP
everything should work right away. Otherwise you have to configure
IPv6 NAT which is a dirty solution but should work.

# Firewall
Don't forget to protect the OpenVPN IPv6 subnet with a firewall.
This is NOT a security issue of IPv6, IPv4 needs a firewall too.

You can allow certain requests to go through. This way you can
"forward" IPv6 ports from a location that supports it to another
location that doesn't support it but is connected to the OpenVPN
server.

[Return to Guide List](/cgi-bin/guides.lua)

[Return to Index Page](/cgi-bin/index.lua)
