Debian mirror url added to `sources <https://wiki.debian.org/SourcesList>`_.

Defaults to *`https://mirrors.ucr.ac.cr <https://mirrors.ucr.ac.cr>`_*.

.. substitution-code-block:: bash

 # Including from terminal.
 ansible localhost -m include_role -a name=|AUTHOR|.|PROJECT| -K -e \
     "mirror=https://mirrors.ucr.ac.cr"

 # Including on a playbook.
 - hosts: servers
   roles:
     - role: |AUTHOR|.|PROJECT|
       mirror: http://ftp.us.debian.org/debian

 # To a playbook from terminal.
 ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
     "mirror=https://mirrors.ucr.ac.cr"
