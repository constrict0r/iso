Local directory path to a folder containing firmware files to be added to the
resulting ISO file.

This files must have *.deb* extension.

This variable is empty by default.

.. substitution-code-block:: bash

 # Including from terminal.
 ansible localhost -m include_role -a name=|AUTHOR|.|PROJECT| -K -e \
     "firmware_path=/home/username/my-firmware/"

 # Including on a playbook.
 - hosts: servers
   roles:
     - role: |AUTHOR|.|PROJECT|
       firmware_path: /home/username/my-firmware/

 # To a playbook from terminal.
 ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
     "firmware_path=/home/username/my-firmware/"
