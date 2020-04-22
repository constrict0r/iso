Hostname to use.

This variable answer to the following step of the Debian Installer:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/di_02_hostname.png
   :alt: di_02_hostname

Defaults to *debian*.

.. substitution-code-block:: bash

 # Including from terminal.
 ansible localhost -m include_role -a name=|AUTHOR|.|PROJECT| -K -e \
     "hostname=my-hostname"

 # Including on a playbook.
 - hosts: servers
   roles:
     - role: |AUTHOR|.|PROJECT|
       hostname: my-hostname

 # To a playbook from terminal.
 ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
     "hostname=my-hostname"
