Url to obtain a Linux ISO image.

It can be the a full url to an ISO
(i.e.: *https://mirrors.ucr.ac.cr/debian-cd/current/amd64/iso-cd/debian-10.1.0-amd64-netinst.iso*)
to fetch a specific Debian version or it can be the base url of that ISO
(i.e.: *https://mirrors.ucr.ac.cr/debian-cd/current/amd64/iso-cd*) to fetch the
latest Debian version.

If this url does not refers to an .iso file, then is assumed to be a base ISO
URL and the md5 file will be used to obtain the ISO name.

This variable points to
*https://mirrors.ucr.ac.cr/debian-cd/current/amd64/iso-cd* by default.

.. substitution-code-block:: bash

 # Including from terminal.
 ansible localhost -m include_role -a name=|AUTHOR|.|PROJECT| -K -e \
     "iso_url=https://is.gd/TFzT71"

 # Including on a playbook.
 - hosts: servers
   roles:
     - role: |AUTHOR|.|PROJECT|
       iso_url: https://is.gd/TFzT71

 # To a playbook from terminal.
 ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
     "iso_url=https://is.gd/TFzT71"
