The iso architecture, this variable is used to set the path where to copy and
modify the *preseed.cfg* file. Valid values are:

- **amd64**: To install *x86_64* machines.

- **386**: To install *x86* machines.

- **a64**: To install *arm* machines.

Defaults to *amd64*.

.. substitution-code-block:: bash

 # Including from terminal.
 ansible localhost -m include_role -a name=|AUTHOR|.|PROJECT| -K -e \
     "iso_architecture=amd64"

 # Including on a playbook.
 - hosts: servers
   roles:
     - role: |AUTHOR|.|PROJECT|
       iso_architecture: 386

 # To a playbook from terminal.
 ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
     "iso_architecture=a64"
