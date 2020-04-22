Network password to use.

This variable answer to the following steps of the Debian Installer:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/di_21_wireless_pass_type.png
   :alt: di_21_wireless_pass_type

And:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/di_22_wireless_pass.png
   :alt: di_22_wireless_pass

Defaults to *12345678*.

Must use quotes (*"* or *'*) when specifying this variable via *--extra-vars*
(*-e*):

.. substitution-code-block:: bash

 # Including from terminal.
 ansible localhost -m include_role -a name=|AUTHOR|.|PROJECT| -K -e \
     "networkpass='my-password'"

 # Including on a playbook.
 - hosts: servers
   roles:
     - role: |AUTHOR|.|PROJECT|
       networkpass: "str@nge!Pass"

 # To a playbook from terminal.
 ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
     "networkpass='my-password'"
