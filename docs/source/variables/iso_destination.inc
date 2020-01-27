Local directory path where to store the downloaded Linux ISO file.

Defaults to *~/*.

.. substitution-code-block:: bash

 # Including from terminal.
 ansible localhost -m include_role -a name=|AUTHOR|.|PROJECT| -K -e \
     "iso_destination=/home/username/my-downloaded-iso/"

 # Including on a playbook.
 - hosts: servers
   roles:
     - role: |AUTHOR|.|PROJECT|
       iso_destination: /home/username/my-downloaded-iso/

 # To a playbook from terminal.
 ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
     "iso_destination=/home/username/my-downloaded-iso/"
