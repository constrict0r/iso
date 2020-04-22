Non-root username.

This variable answer to the following step of the Debian Installer:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/di_05_username.png
   :alt: di_05_username

Defaults to *debian*.

.. substitution-code-block:: bash

 # Including from terminal.
 ansible localhost -m include_role -a name=|AUTHOR|.|PROJECT| -K -e \
     "username=mary"

 # Including on a playbook.
 - hosts: servers
   roles:
     - role: |AUTHOR|.|PROJECT|
       username: jhon

 # To a playbook from terminal.
 ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
     "username=mary"
