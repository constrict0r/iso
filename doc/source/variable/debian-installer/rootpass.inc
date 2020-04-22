Root user password.

This variable answer to the following step of the Debian Installer:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/di_04_root.png
   :alt: di_04_root

Defaults to *debian*.

Must use quotes (*"* or *'*) when specifying this variable via *--extra-vars*
(*-e*):

.. substitution-code-block:: bash

 # Including from terminal.
 ansible localhost -m include_role -a name=|AUTHOR|.|PROJECT| -K -e \
     "rootpass='my-password'"

 # Including on a playbook.
 - hosts: servers
   roles:
     - role: |AUTHOR|.|PROJECT|
       rootpass: "str@nge!Pass"

 # To a playbook from terminal.
 ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
     "rootpass='my-password'"
