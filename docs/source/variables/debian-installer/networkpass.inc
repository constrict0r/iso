Network password to use.

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
