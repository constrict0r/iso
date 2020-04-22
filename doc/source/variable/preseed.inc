Wheter to add preseeding to the resulting ISO or not.

If set to *false* the grub installation step is not preseeded neither.

If this variable is set to *true* the Debian Installer Variables
(listed below) are used to apply preseeding.

This variable answer to the following step of the Debian Installer:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/di_11_another_dvd.png
   :alt: di_11_another_dvd

And:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/di_13_contest.png
   :alt: di_13_popularity_contest

And:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/di_14_tasksel.png
   :alt: di_14_tasksel

And:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/di_15_grub_install.png
   :alt: di_15_grub_install

And:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/di_19_network_interface.png
   :alt: di_19_network_interface

Defaults to *false*.

.. substitution-code-block:: bash

 # Including from terminal.
 ansible localhost -m include_role -a name=|AUTHOR|.|PROJECT| -K -e \
     "preseed=false"

 # Including on a playbook.
 - hosts: servers
   roles:
     - role: |AUTHOR|.|PROJECT|
       preseed: true

 # To a playbook from terminal.
 ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
     "preseed=false"
