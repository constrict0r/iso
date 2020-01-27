Wheter to preseed wireless network configuration or not.

You can disable wireless network preseeding when using wired connections or
for another particular case.

Defaults to *false*.

.. substitution-code-block:: bash

 # Including from terminal.
 ansible localhost -m include_role -a name=|AUTHOR|.|PROJECT| -K -e \
     "preseed_wireless=false"

 # Including on a playbook.
 - hosts: servers
   roles:
     - role: |AUTHOR|.|PROJECT|
       preseed_wireless: true

 # To a playbook from terminal.
 ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
     "preseed_wireless=false"
