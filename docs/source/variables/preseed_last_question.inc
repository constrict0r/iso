Wheter to preseed or not the last question.

This is useful to prevent multiple installations if the machine keeps booting
from an usb drive or similar.

Defaults to *false*.

.. substitution-code-block:: bash

 # Including from terminal.
 ansible localhost -m include_role -a name=|AUTHOR|.|PROJECT| -K -e \
     "preseed_last_question=false"

 # Including on a playbook.
 - hosts: servers
   roles:
     - role: |AUTHOR|.|PROJECT|
       preseed_last_question: true

 # To a playbook from terminal.
 ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
     "preseed_last_question=false"
