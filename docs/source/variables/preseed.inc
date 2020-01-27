Wheter to add preseeding to the resulting ISO or not.

If set to *false* the grub installation step is not preseeded neither.

If this variable is set to *true* the Debian Installer Variables
(listed below) are used to apply preseeding.

Defaults to *false*.

.. substitution-code-block:: bash

 # Including from terminal.
 ansible localhost -m include_role -a name=|AUTHOR|.|PROJECT| -K -e \
     "preseed=false"

 # Including on a playbook.
 - hosts: servers
   roles:
     - role: |AUTHOR|.|PROJECT|
       preseed: true

 # To a playbook from terminal.
 ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
     "preseed=false"
