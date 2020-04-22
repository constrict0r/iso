Local directory path where to copy the Linux ISO files to be modified to
include preseeding.

If you want this directory to be deleted at the end of the process, set the
**delete_remaster_mount** variable to *true*.

Defaults to *~/remaster_iso/*.

.. substitution-code-block:: bash

 # Including from terminal.
 ansible localhost -m include_role -a name=|AUTHOR|.|PROJECT| -K -e \
     "remaster_mount=/home/username/my-remaster/"

 # Including on a playbook.
 - hosts: servers
   roles:
     - role: |AUTHOR|.|PROJECT|
       remaster_mount: /home/username/my-remaster/

 # To a playbook from terminal.
 ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
     "remaster_mount=/home/username/my-remaster/"
