Domain name to use.

This variable answer to the following step of the Debian Installer:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/di_03_domain.png
   :alt: di_03_domain

Defaults to *debian*.

.. substitution-code-block:: bash

 # Including from terminal.
 ansible localhost -m include_role -a name=|AUTHOR|.|PROJECT| -K -e \
     "domain=my-domain"

 # Including on a playbook.
 - hosts: servers
   roles:
     - role: |AUTHOR|.|PROJECT|
       domain: my-domain

 # To a playbook from terminal.
 ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
     "domain=my-domain"
