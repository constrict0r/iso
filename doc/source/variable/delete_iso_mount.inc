Wheter to delete or not (at the end of the process) the directory where the
original Debian iso is mounted.

Defaults to *false*.

.. substitution-code-block:: bash

 # Including from terminal.
 ansible localhost -m include_role -a name=|AUTHOR|.|PROJECT| -K -e \
     "delete_iso_mount=true"

 # Including on a playbook.
 - hosts: servers
   roles:
     - role: |AUTHOR|.|PROJECT|
       delete_iso_mount: true

 # To a playbook from terminal.
 ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
     "delete_iso_mount=true"
