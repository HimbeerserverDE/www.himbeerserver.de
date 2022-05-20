% rtl8812au WiFi driver setup on RPi@5.10.103-v7l

# The Problem
WiFi drivers on Linux are already annoying enough, and it's gotten even worse
with the 5.10.103 kernel. This version is no longer compatible with the
[install-wifi script](http://downloads.fars-robotics.net/wifi-drivers/install-wifi).
On top of that some versions of the rtl8812au driver I'm using drop IPv6 Multicast,
breaking NDP and preventing you from automatically connecting to the IPv6 internet.
Fortunately aircrack-ng maintains a working version of the driver. However it has
to be compiled from source. Here's how.

# Kernel Headers
You may need to install the raspberry pi kernel headers.
The apt package name is `raspberrypi-kernel-headers`.
If you're using the 64-bit RPi OS, make sure to install
the arm64 version of the package.
Use `apt list raspberrypi-kernel-headers` to check if you have
the correct version installed.

# Installing
Run the following shell commands. If you aren't using sudo, run commands that
require root access in some other way.

```sh
sudo apt update && sudo apt install -y git dkms

git clone https://github.com/aircrack-ng/rtl8812au.git
cd rtl8812au/

sed -i 's/CONFIG_PLATFORM_I386_PC = y/CONFIG_PLATFORM_I386_PC = n/g' Makefile
sed -i 's/CONFIG_PLATFORM_ARM_RPI = n/CONFIG_PLATFORM_ARM_RPI = y/g' Makefile
export ARCH=arm
sed -i 's/^MAKE="/MAKE="ARCH=arm\ /' dkms.conf

sudo make dkms_install
```

**For 64-bit, these are the commands to run:**

```sh
sudo apt update && sudo apt install -y git dkms

git clone https://github.com/aircrack-ng/rtl8812au.git
cd rtl8812au/

sed -i 's/CONFIG_PLATFORM_I386_PC = y/CONFIG_PLATFORM_I386_PC = n/g' Makefile
sed -i 's/CONFIG_PLATFORM_ARM64_RPI = n/CONFIG_PLATFORM_ARM64_RPI = y/g' Makefile
export ARCH=arm64
sed -i 's/^MAKE="/MAKE="ARCH=arm64\ /' dkms.conf

sudo make dkms_install
```

If the last command gives an error because the DKMS module already exists,
remove any existing installations of the driver.

# Loading
The driver should now automatically be loaded. It seems to be
loaded at boot time automatically, but I haven't tested it yet.
If you can confirm or disprove this please let me know.

[Return to Guide List](/cgi-bin/guides.lua)

[Return to Index Page](/cgi-bin/index.lua)
