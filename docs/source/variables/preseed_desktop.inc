Wheter to apply desktop configuration to the new system or not.

If set to *true* the `gnome <https://www.gnome.org>`_ desktop enviroment is
installed by including the
`constrictor.desktop <https://github.com/constrict0r/desktop>`_ ansible role.

When the **preseed_custom** variable is present and not empty, this variable
is ignored.

Defaults to *false*.

.. substitution-code-block:: bash

 # Including from terminal.
 ansible localhost -m include_role -a name=|AUTHOR|.|PROJECT| -K -e \
     "preseed_desktop=false"

 # Including on a playbook.
 - hosts: servers
   roles:
     - role: |AUTHOR|.|PROJECT|
       preseed_desktop: true

 # To a playbook from terminal.
 ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
     "preseed_desktop=false"
