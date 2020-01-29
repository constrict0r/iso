Absolute path to a .yml file containing some or
all of the following configuration:

- A list of apt repositories to add (see *constrict0r.sourcez* role).

- A list of packages to purge via Apt (see *constrict0r.aptitude* role).

- A list of packages to install via Apt (see *constrict0r.aptitude* role).

- A list of packages to install via npm (see *constrict0r.jsnode* role).

- A list of packages to install via pip (see *constrict0r.pyp* role).
 
- An URL to a skeleton git repository to copy to */* (see
  *constrict0r.sysconfig* role).

- A list of services to stop and disable (see *constrict0r.servicez* role).

- A list of services to enable and restart (see *constrict0r.servicez* role).

- A list of users to create (see *constrict0r.users* role).

- A list of groups to add the created users (see *constrict0r.group* role).

- A password for each created user.

- A list of files or URLs to skeleton git repositories to copy to each */home* folder
  (see *constrict0r.userconfig* role).

- A list of files or URLs to custom Ansible tasks to run
  (see *constrict0r.task* role).

If set to *true* the
`constrictor.constructor <https://github.com/constrict0r/constructor>`_
ansible role will be included to read the specified configuration file and to
apply the configuration described on it.

When this variable is present and not empty, the **preseed_desktop** variable
is ignored (as if its value is *false*).

Defaults to *empty*.

.. substitution-code-block:: bash

 # Including from terminal.
 ansible localhost -m include_role -a name=|AUTHOR|.|PROJECT| -K -e \
     "preseed_custom=/home/username/my-config.yml"

 # Including on a playbook.
 - hosts: servers
   roles:
     - role: |AUTHOR|.|PROJECT|
       preseed_custom: /home/username/my-config.yml

 # To a playbook from terminal.
 ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
     "preseed_custom=/home/username/my-config.yml"
