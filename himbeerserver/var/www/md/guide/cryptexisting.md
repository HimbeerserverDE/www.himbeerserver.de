% Encrypting existing drives

# Disclaimer
**It is not easily possible to use most of the methods described here
to encrypt existing drives without having to make and restore a backup.**

# Preparation: Making a backup
It is necessary to create a backup of your drive as encrypting will
erase your data.

## SquashFS
I like to use SquashFS as I don't have much backup
space:

```sh
apt update
apt install squashfs-tools

mksquashfs /media/drive/mountpoint /media/backup/mountpoint/drive.sqsh
```

The above commands all need to be run as root.

A major disadvantage of SquashFS is its slowness. It uses all CPU cores
but still takes a long time to complete depending on how much data is
being squashed.

## tar
If you can afford to store a raw copy, you can create it with `tar`.
The `tar` command is faster than `cp` or `rsync` for copying many
large files. Here's how to use it:

```sh
tar -c -C /media/drive/mountpoint . | \
tar --same-owner -xp -C /media/backup/location
```

Make sure you run this as root.

This is much faster compared to squashing but it requires much more
storage space.

# Wiping
This is optional but it's highly recommended to do if unencrypted data
used to be stored on the drive.
Some encryption tools such as OS installers do this automatically, but
pure cryptsetup does not. To be safe, wipe manually:

```sh
dd bs=1M if=/dev/urandom of=/dev/sdX
```

Once again only root can do this.

Replace `/dev/sdX` with the device file of the drive you want to encrypt.
You can specify a partition number if you only want to wipe a single
partition.

If you're still using an old kernel (<4.8) this is going to be slow.
Replace `/dev/urandom` with `/dev/zero` to counter this.

# Encrypting
There are three methods I have used.

## LVM + LUKS
This is recommended for drives with an operating system.

Do a complete reinstall and select the "encrypted LVM" option when
partitioning. Make sure to use a secure passphrase that you can still
remember.

This sets up LVM and LUKS.

## LUKS
Use this for external drives that are always connected to the same
machine.

Run the following commands as root:

```sh
cryptsetup luksFormat -c aes-xts-plain64 -s 512 -h sha512 -y /dev/sdXY
cryptsetup luksOpen /dev/sdXY sdXY-crypt
mkfs.ext4 /dev/mapper/sdXY-crypt
cryptsetup luksClose sdXY-crypt
```

where sdXY is the name of the device file of the partition.

## VeraCrypt volume
This is useful if you want to use your drive in other places or on
other platforms. Follow the VeraCrypt instructions for this.

# Restoring the backup
No matter how you made your backup, `tar` is the way to restore it.
Before you do that you have to take care of some other things.

## SquashFS
Mount the SquashFS image:

```sh
mount /media/squashfs/location/drive.sqsh /media/backup/mountpoint
```

You now need to mount the encrypted device. This is quite easy to do
with VeraCrypt volumes. When you mount one the mountpoint is usually
`/media/veracryptX`. For LUKS it works like this:

```sh
cryptsetup luksOpen /dev/sdXY sdXY-crypt
mount /dev/mapper/sdXY-crypt /media/drive/mountpoint
```

LVM + LUKS is slightly different:

```sh
cryptsetup luksOpen /dev/sdXY sdXY-crypt
lvchange -ay hostname-vg/partitionname
mount /dev/hostname-vg/partitionname /media/drive/mountpoint
```

Now restore the backup:

```sh
tar -c -C /media/backup/mountpoint . | \
tar --same-owner -xp -C /media/drive/mountpoint
```

# Cleaning up
Now unmount the encrypted volume (if you don't want to use it yet)
and delete the SquashFS. Unmounting VeraCrypt volumes is easy
enough to not be documented here.

## Unmounting LUKS
```sh
umount /media/drive/mountpoint
cryptsetup luksClose sdXY-crypt
```

## Unmounting LVM + LUKS
```sh
umount /media/drive/mountpoint
lvchange -an hostname-vg/partitionname
cryptsetup luksClose sdXY-crypt
```

***WARNING: Store the SquashFS image on an encrypted drive
or wipe it securely! A simple `rm` won't do, especially with
solid state storage!***

[Return to Guide List](/cgi-bin/guides.lua)

[Return to Index Page](/cgi-bin/index.lua)
