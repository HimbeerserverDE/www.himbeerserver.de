% Kerberized NFS: access denied by server while mounting

# Introduction
Protecting a NFS share with Kerberos is not very easy to do but definitely
doable with a good setup manual. A very helpful website is
https://wiki.ubuntuusers.de although some of the pages
have since been archived.

# Setup
The hostnames are different in my actual setup and will certainly be
different for you.

There are two machines involved. The first one is the server.
It's running a krb5 KDC and admin server as well as a NFS server.
The NFS export is configured to allow any source address
but requires krb5i or krb5p security.

The client computer is running a krb5 client and a NFS client with
the necessary rpc daemons.

#### Kerberos principals
* admin/admin, has full access to kadmin
* himbeerserverde, a regular user
* host/srv.himbeerserver.de, server host key
* host/clt.himbeerserver.de, client host key
* nfs/srv.himbeerserver.de, server NFS key
* nfs/clt.himbeerserver.de, client NFS key

The users are synced across other clients and the server using LDAP.
The clients use SSSD to cache credentials. This way they can operate
without a permanent connection to the LDAP server. They also keep working
in case of a server failure.
The server uses local auth for the actual accounts. The other accounts
are not intended to be logged into. A LDAP failure will only result
in a broken NFS.

I'm aware this isn't the best solution. I'm probably going to come up
with a better one in about half a decade.

# The Error
This is the command I use to mount the NFS share:

```sh
sudo mount -t nfs4 -o sec=krb5i,async,soft srv.himbeerserver.de:/media/ssd /mnt/himbeerserverde/nfs
```

This suddenly resulted in the above error. I couldn't really figure out
what was going on. This has happened several times and could sometimes be
fixed by rebooting both machines. Unfortunately rebooting didn't help
most of the time.

# Debugging
The logs are not very helpful for debugging this error.
Adding `-vvvv` to the mount command outputs more but still only shows
that permission was denied, not why it's happening.
Looking at the traffic with wireshark I didn't see any Kerberos packets.

The syslog eventually lead me to the systemd service `auth-rpcgss-module`.
It failed to start. The reason was a kernel update that had been installed
but not yet activated. Rebooting fixed this by restoring synchronization
of the kernel version and the modules' required kernel version.

I'm not sure if that module is required but given its name it seems to be.
Reading the krb5 logs (using `journalctl -xeu krb5-kdc.service`) I could
see that the KDC refused to issue service tickets to the server.
There were attempts from the client to get a service ticket earlier that
day that were also denied. In both cases the reason was failing authentication.

The fact that the server was experiencing the issue made me think that it
was a host authentication issue that had nothing to do with the user.
This later turned out to be correct.

# The Solution
After spending days googling for a solution and trying different things
I decided to completely reconfigure host-related principals.
Here's exactly what I did:

Server:
```sh
srv# rm /etc/krb5.keytab
srv# kadmin -p admin/admin
kadmin:  purgekeys host/srv.himbeerserver.de
kadmin:  purgekeys nfs/srv.himbeerserver.de
kadmin:  delprinc host/srv.himbeerserver.de
kadmin:  delprinc nfs/srv.himbeerserver.de
kadmin:  addprinc -randkey host/srv.himbeerserver.de
kadmin:  addprinc -randkey nfs/srv.himbeerserver.de
kadmin:  ktadd host/srv.himbeerserver.de
kadmin:  ktadd nfs/srv.himbeerserver.de
kadmin:  quit
srv# systemctl restart nfs-kernel-server rpc-gssd rpc-svcgssd
```

It's important to restart rpc-gssd to make it reload the keytab.
I'm not sure if restarting rpc-svcgssd is necessary.
Purging the user keys is *probably* not needed either but you can
do it if the above steps didn't work.

Client (repeat for all affected clients with the corresponding keys):
```sh
clt# rm /etc/krb5.keytab
clt# kadmin -p admin/admin
kadmin:  purgekeys host/clt.himbeerserver.de
kadmin:  purgekeys nfs/clt.himbeerserver.de
kadmin:  delprinc host/clt.himbeerserver.de
kadmin:  delprinc nfs/clt.himbeerserver.de
kadmin:  addprinc -randkey host/clt.himbeerserver.de
kadmin:  addprinc -randkey nfs/clt.himbeerserver.de
kadmin:  ktadd host/clt.himbeerserver.de
kadmin:  ktadd nfs/clt.himbeerserver.de
kadmin:  quit
clt# systemctl restart rpc-gssd
```

Once again purging the user keys is *probably* not needed but you
can do it if the above steps didn't work.

Now mount the NFS share again. If it still doesn't work, reboot
the server and the client. If that doesn't fix it unfortunately
I can't help you.

[Return to Guide List](/cgi-bin/guides.lua)

[Return to Index Page](/cgi-bin/index.lua)
