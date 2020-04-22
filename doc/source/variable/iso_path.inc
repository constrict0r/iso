Absolute file path to an ISO file to use as base for preseeding.

If this variable is not especified, a Debian netinstall iso will be downloaded
from internet.

This variable is empty by default.

.. substitution-code-block:: bash

 # Including from terminal.
 ansible localhost -m include_role -a name=|AUTHOR|.|PROJECT| -K -e \
     "iso_path=/home/username/my-image.iso"

 # Including on a playbook.
 - hosts: servers
   roles:
     - role: |AUTHOR|.|PROJECT|
       iso_path: /home/username/my-image.iso

 # To a playbook from terminal.
 ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
     "iso_path=/home/username/my-image.iso"
