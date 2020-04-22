Network name to use.

This variable answer to the following steps of the Debian Installer:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/di_20_wireless_name.png
   :alt: di_20_wireless_name

Defaults to *mynetwork*.

Must use quotes (*"* or *'*) when specifying this variable via *--extra-vars*
(*-e*):

.. substitution-code-block:: bash

 # Including from terminal.
 ansible localhost -m include_role -a name=|AUTHOR|.|PROJECT| -K -e \
     "networkname='mynetwork'"

 # Including on a playbook.
 - hosts: servers
   roles:
     - role: |AUTHOR|.|PROJECT|
       networkname: 'my network with spaces'

 # To a playbook from terminal.
 ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
     "networkname='mynetwork'"
