Keyboard distribution to use.

This variable answer to the following step of the Debian Installer:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/di_01_keyboard.png
   :alt: di_01_keyboard

Defaults to *latam*.

.. substitution-code-block:: bash

 # Including from terminal.
 ansible localhost -m include_role -a name=|AUTHOR|.|PROJECT| -K -e \
     "keyboard=en_US"

 # Including on a playbook.
 - hosts: servers
   roles:
     - role: |AUTHOR|.|PROJECT|
       keyboard: en_US

 # To a playbook from terminal.
 ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
     "keyboard=en_US"
