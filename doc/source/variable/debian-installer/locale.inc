Language and country to use.

This variable answer to the following step of the Debian Installer:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/di_00_language.png
   :alt: di_00_language

Defaults to *es_CR*.

.. substitution-code-block:: bash

 # Including from terminal.
 ansible localhost -m include_role -a name=|AUTHOR|.|PROJECT| -K -e \
     "locale=us_US"

 # Including on a playbook.
 - hosts: servers
   roles:
     - role: |AUTHOR|.|PROJECT|
       locale: us_US

 # To a playbook from terminal.
 ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
     "locale=us_US"
