Local file path where to save the resulting remastered ISO.

Defaults to *~/remaster.iso*.

.. substitution-code-block:: bash

 # Including from terminal.
 ansible localhost -m include_role -a name=|AUTHOR|.|PROJECT| -K -e \
     "remaster_destination=/home/username/my-remaster.iso"

 # Including on a playbook.
 - hosts: servers
   roles:
     - role: |AUTHOR|.|PROJECT|
       remaster_destination: /home/username/my-remaster.iso

 # To a playbook from terminal.
 ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
     "remaster_destination=/home/username/my-remaster.iso"
