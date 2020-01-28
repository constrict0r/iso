Wheter to apply preseed to partitioning configuration or not.

If set to *true* the *atomic* partitioning type is applied on the device
specified in the **device** variable.

On simple terms this variable allows to apply a *whole* disk partitioning or
not (*none*) partitioning at all.

This variable answer to the following step of the Debian Installer:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/di_07_partitioning_guided_manual_whole.png
   :alt: di_07_partitioning_guided_manual_whole

And:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/di_08_partitioning_whole.png
   :alt: di_08_partitioning_whole

And:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/di_23_partitioning_biggest_free.png
   :alt: di_23_partitioning_biggest_free

And:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/di_09_partitioning_end_partitioning.png
   :alt: di_09_partitioning_end_partitioning

And:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/di_10_partitioning_write_changes.png
   :alt: di_10_partitioning_write_changes

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
