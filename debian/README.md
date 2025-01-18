# Packaging on Debian Linux

To create a [Debian](https://www.debian.org) package of the SSH Tunnel (a `sshtunnel.deb` file),
you first need to have installed the following programs:

    apt install build-essential debhelper devscripts


Run this command in the repository root folder to create the package (`-us -uc` to disable signing):

    debuild -us -uc

The package will be created in the parent directory.

Install the debian package:

    sudo dpkg -i ../sshtunnel_*.deb

