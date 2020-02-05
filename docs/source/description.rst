Description
------------------------------------------------------------------------------

Ansible role to generate a Linux installer **.iso** file with or without
`preseeding <https://wiki.debian.org/DebianInstaller/Preseed>`_.

When using preseeding on the generated iso, the questions asked by the Debian
installer during the installation process will be automatically answered and
when the installation
process ends, the `kick.sh <https://gitlab.com/constrict0r/kick>`_ script will
be runned to setup the newly installed system.

When using preseeding and on the first screen that the Debian Installer shows,
you will have to wait a couple of seconds (about 5) for the process to autostart.

