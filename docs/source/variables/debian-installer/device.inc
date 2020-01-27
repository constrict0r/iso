Device used for partitioning and where to install
`grub <https://www.gnu.org/software/grub>`_, usually *sda* or *hda*.

This variable must not include the text */dev/* but only the device name.

Defaults to *sda*.

.. substitution-code-block:: bash

 # Including from terminal.
 ansible localhost -m include_role -a name=|AUTHOR|.|PROJECT| -K -e \
     "device=sda"

 # Including on a playbook.
 - hosts: servers
   roles:
     - role: |AUTHOR|.|PROJECT|
       device: sdb

 # To a playbook from terminal.
 ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
     "device=hda"
