Local directory path where to mount the downloaded Linux ISO to be preseeded.

If this directory does not exist it will be created.

If you want this directory to be deleted at the end of the process, set the
**delete_iso_mount** variable to *true*.

Defaults to *~/original_iso/*.

.. substitution-code-block:: bash

 # Including from terminal.
 ansible localhost -m include_role -a name=|AUTHOR|.|PROJECT| -K -e \
     "iso_mount=/home/username/my-mount/"

 # Including on a playbook.
 - hosts: servers
   roles:
     - role: |AUTHOR|.|PROJECT|
       iso_mount: /home/username/my-mount/

 # To a playbook from terminal.
 ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
     "iso_mount=/home/username/my-mount/"
