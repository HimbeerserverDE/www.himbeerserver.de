% rtl8812au WiFi driver setup on RPi@5.10.103-v7l

# The Problem
WiFi drivers on Linux are already annoying enough, and it's gotten even worse
with the 5.10.103 kernel. This version is no longer compatible with the
[install-wifi script](http://downloads.fars-robotics.net/wifi-drivers/install-wifi).
On top of that some versions of the rtl8812au driver I'm using drop IPv6 Multicast,
breaking NDP and preventing you from automatically connecting to the IPv6 internet.
Fortunately aircrack-ng maintains a working version of the driver. However it has
to be compiled from source. Here's how.

# Installing
Run the following shell commands. If you aren't using sudo, run commands that
require root access in some other way.

```sh
git clone https://github.com/aircrack-ng/rtl8812au.git
cd rtl8812au/

sudo apt update && sudo apt install -y dkms

sed -i 's/CONFIG_PLATFORM_I386_PC = y/CONFIG_PLATFORM_I386_PC = n/g' Makefile
sed -i 's/CONFIG_PLATFORM_ARM_RPI = n/CONFIG_PLATFORM_ARM_RPI = y/g' Makefile
export ARCH=arm
sed -i 's/^MAKE="/MAKE="ARCH=arm\ /' dkms.conf

sudo make dkms_install
```

If the last command gives an error because the DKMS module already exists,
remove any existing installations of the driver.

# Loading
The driver should now automatically be loaded. It appears that it's
loaded at boot time automatically, but I haven't tested it yet.
If you can confirm or disprove this please let me know.