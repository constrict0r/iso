Wheter to apply preseed to partitioning configuration or not.

If set to *true* the *atomic* partitioning type is applied on the device
specified in the **device** variable.

On simple terms this variable allows to apply a *whole* disk partitioning or
not (*none*) partitioning at all.

Defaults to *false*.

.. substitution-code-block:: bash

 # Including from terminal.
 ansible localhost -m include_role -a name=|AUTHOR|.|PROJECT| -K -e \
     "preseed_partitioning=false"

 # Including on a playbook.
 - hosts: servers
   roles:
     - role: |AUTHOR|.|PROJECT|
       preseed_partitioning: true

 # To a playbook from terminal.
 ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
     "preseed_partitioning=false"
