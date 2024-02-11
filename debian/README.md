# Packaging on Debian Linux

To create a [Debian](https://www.debian.org) package of the SSH Tunnel (a `sshtunnel.deb` file),
you first need to have installed the following programs:

    apt install build-essential debhelper devscripts


Run this command in the repository root folder to create the package:

    debuild

The package will be created in the parent directory.

Install the debian package:

    sudo dpkg -i ../sshtunnel_*.deb

Publish to Ubuntu PPA

    git remote add ppa git+ssh://stokito@git.launchpad.net/~stokito/+git/sshtunnel
    git push --set-upstream ppa master

Go to https://code.launchpad.net/~stokito/+git/sshtunnel

Create packaging recipe

Use an existing PPA: utils
Default distribution series: select first two-four
Run build by clicking on "Request build(s)"
