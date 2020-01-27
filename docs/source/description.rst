Description
------------------------------------------------------------------------------

Ansible role to generate a Linux installer **.iso** file with or without
`preseeding <https://wiki.debian.org/DebianInstaller/Preseed>`_.

When using preseeding on the generated iso, the questions asked by the Debian
installer during the installation process will be automatically answered and
when the installation
process ends, the `kick.sh <https://github.com/constrict0r/kick>`_ script will
be runned to setup the newly installed system.
