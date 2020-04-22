
iso
***

.. image:: https://travis-ci.com/constrict0r/iso.svg
   :alt: travis

.. image:: https://readthedocs.org/projects/iso/badge
   :alt: readthedocs

Ansible role to generate a Linux installer **.iso** file with or
without `preseeding
<https://wiki.debian.org/DebianInstaller/Preseed>`_.

Full documentation on `Readthedocs <https://iso.readthedocs.io>`_.

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/avatar.png
   :alt: avatar

Source code on:

`Github <https://github.com/constrict0r/iso>`_.

`Gitlab <https://gitlab.com/constrict0r/iso>`_.

`Part of: <https://gitlab.com/explore/projects?tag=doombot>`_

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/doombot.png
   :alt: doombot

**Ingredients**

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/ingredient.png
   :alt: ingredient


Contents
********

* `Description <#Description>`_
* `Usage <#Usage>`_
* `Variables <#Variables>`_
   * `iso_path <#iso-path>`_
   * `iso_url <#iso-url>`_
   * `iso_destination <#iso-destination>`_
   * `iso_mount <#iso-mount>`_
   * `delete_iso_mount <#delete-iso-mount>`_
   * `remaster_mount <#remaster-mount>`_
   * `delete_remaster_mount <#delete-remaster-mount>`_
   * `remaster_destination <#remaster-destination>`_
   * `iso_architecture <#iso-architecture>`_
   * `firmware_path <#firmware-path>`_
   * `preseed <#preseed>`_
   * `preseed_wireless <#preseed-wireless>`_
   * `preseed_partitioning <#preseed-partitioning>`_
   * `preseed_desktop <#preseed-desktop>`_
   * `preseed_custom <#preseed-custom>`_
   * `preseed_last_question <#preseed-last-question>`_
* `Installer Variables <#installer-variables>`_
   * `locale <#locale>`_
   * `keyboard <#keyboard>`_
   * `networkname <#networkname>`_
   * `networkpass <#networkpass>`_
   * `hostname <#hostname>`_
   * `domain <#domain>`_
   * `rootpass <#rootpass>`_
   * `username <#username>`_
   * `userpass <#userpass>`_
   * `mirror <#mirror>`_
   * `device <#device>`_
* `Requirements <#Requirements>`_
* `Compatibility <#Compatibility>`_
* `Limitations <#Limitations>`_
* `License <#License>`_
* `Links <#Links>`_
* `UML <#UML>`_
   * `Deployment <#deployment>`_
   * `Main <#main>`_
   * `Cleanup <#cleanup>`_
   * `Initrd <#initrd>`_
   * `Initrd-Partitioning <#initrd-partitioning>`_
   * `Initrd-Set-Answer <#initrd-set-answer>`_
   * `Menu <#menu>`_
   * `Preseed <#preseed>`_
   * `Remaster <#remaster>`_
   * `Sync <#sync>`_
   * `Sync-Get-ISO <#sync-get-iso>`_
   * `Vars <#vars>`_
* `Author <#Author>`_

Description
***********

Ansible role to generate a Linux installer **.iso** file with or
without `preseeding
<https://wiki.debian.org/DebianInstaller/Preseed>`_.

When using preseeding on the generated iso, the questions asked by the
Debian installer during the installation process will be automatically
answered and when the installation process ends, the `kick.sh
<https://gitlab.com/constrict0r/kick>`_ script will be runned to setup
the newly installed system.

When using preseeding and on the first screen that the Debian
Installer shows, you will have to wait a couple of seconds (about 5)
for the process to autostart.



Usage
*****

* To install and execute:

..

   ::

      ansible-galaxy install constrict0r.iso
      ansible localhost -m include_role -a name=constrict0r.iso -K

* Passing variables:

..

   ::

      ansible localhost -m include_role -a name=constrict0r.iso -K \
          -e "{username: [mary]}"

* To include the role on a playbook:

..

   ::

      - hosts: servers
        roles:
            - {role: constrict0r.iso}

* To include the role as dependency on another role:

..

   ::

      dependencies:
        - role: constrict0r.iso
          username: [mary]

* To use the role from tasks:

..

   ::

      - name: Execute role task.
        import_role:
          name: constrict0r.iso
        vars:
          username: [mary]

* To use a USB stick to install a physical computer:

Use this role to generate a *remaster.iso* image (replace with your
data):

::

   ansible localhost -m include_role -a name=constrict0r.iso -K -e \
       'username=constrict0r userpass=1234 rootpass=1234 device=sda \
       preseed=true preseed_wireless=true preseed_partitioning=true \
       preseed_last_question=true \
       preseed_custom=/home/constrict0r/Documentos/madvillain.yml \
       networkname="MY NETWORK" networkpass="my-network-pass" \
       hostname="latveria" domain="amanita" \
       firmware_path=/home/constrict0r/Instaladores/firmware/'

* Then use `dd <http://man7.org/linux/man-pages/man1/dd.1.html>`_ to
   copy the file to your USB stick (replacing *sdx* with your drive):

::

   su -c 'dd if=/path/to/remaster.iso of=/dev/sdx'

* Some modern computer complaints about a **cdrom not detected**
   during the installation process (because they no longer include
   cdroms), to overpass this issue, rename the extension *.iso* to
   *.img* and use **dd** to copy the file:

::

   mv remaster.iso remaster.img
   su -c 'dd if=/path/to/remaster.img of=/dev/sdx'

To run tests:

::

   cd iso
   chmod +x testme.sh
   ./testme.sh

On some tests you may need to use *sudo* to succeed.

* To use with `Virt Manager <https://virt-manager.org>`_:

Use this role to generate a *remaster.iso* image (replace with your
data):

::

   ansible localhost -m include_role -a name=constrict0r.iso -K -e \
       'username=constrict0r userpass=1234 rootpass=1234 device=sda preseed=true \
       preseed_wireless=true preseed_partitioning=true preseed_last_question=true \
       preseed_custom=/home/constrict0r/Documentos/madvillain.yml networkname="MY NETWORK" \
       networkpass="my-network-pass" hostname="latveria" domain="amanita"'

Open Virt Manager and click on the *New Virtual Machine* icon (the
tiny computer):

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/vm_00_open.png
   :alt: vm_00_open

On the *new Virtual Machine* screen choose the option *Local media*
and press *Next*:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/vm_01_new.png
   :alt: vm_01_new

On the *Create Virtual Machine* screen, search for the *remaster.iso*
file and on the bottom input select the *Generic* OS type, then press
the *Next* button:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/vm_02_remaster.png
   :alt: vm_02_remaster

On the *Memory Assign* screen type the amount of memory you need and
the amount of cpus that you want to use and press *Next*:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/vm_03_memory.png
   :alt: vm_03_memory

On the *Disk Space* screen type the amount of space that you want to
use and press *Next*:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/vm_04_disk.png
   :alt: vm_04_disk

On the *Final* screen put a name to your Virtual Machine, choose the
network you want to use and press *Finish*:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/vm_05_final.png
   :alt: vm_05_final



Variables
*********

The following variables are supported:


iso_path
========

Absolute file path to an ISO file to use as base for preseeding.

If this variable is not especified, a Debian netinstall iso will be
downloaded from internet.

This variable is empty by default.

::

   # Including from terminal.
   ansible localhost -m include_role -a name=constrict0r.iso -K -e \
       "iso_path=/home/username/my-image.iso"

   # Including on a playbook.
   - hosts: servers
     roles:
       - role: constrict0r.iso
         iso_path: /home/username/my-image.iso

   # To a playbook from terminal.
   ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
       "iso_path=/home/username/my-image.iso"


iso_url
=======

Url to obtain a Linux ISO image.

It can be the a full url to an ISO (i.e.:
*https://mirrors.ucr.ac.cr/debian-cd/current/amd64/iso-cd/debian-10.1.0-amd64-netinst.iso*)
to fetch a specific Debian version or it can be the base url of that
ISO (i.e.: *https://mirrors.ucr.ac.cr/debian-cd/current/amd64/iso-cd*)
to fetch the latest Debian version.

If this url does not refers to an .iso file, then is assumed to be a
base ISO URL and the md5 file will be used to obtain the ISO name.

This variable points to
*https://mirrors.ucr.ac.cr/debian-cd/current/amd64/iso-cd* by default.

::

   # Including from terminal.
   ansible localhost -m include_role -a name=constrict0r.iso -K -e \
       "iso_url=https://is.gd/TFzT71"

   # Including on a playbook.
   - hosts: servers
     roles:
       - role: constrict0r.iso
         iso_url: https://is.gd/TFzT71

   # To a playbook from terminal.
   ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
       "iso_url=https://is.gd/TFzT71"


iso_destination
===============

Local directory path where to store the downloaded Linux ISO file.

Defaults to *~/*.

::

   # Including from terminal.
   ansible localhost -m include_role -a name=constrict0r.iso -K -e \
       "iso_destination=/home/username/my-downloaded-iso/"

   # Including on a playbook.
   - hosts: servers
     roles:
       - role: constrict0r.iso
         iso_destination: /home/username/my-downloaded-iso/

   # To a playbook from terminal.
   ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
       "iso_destination=/home/username/my-downloaded-iso/"


iso_mount
=========

Local directory path where to mount the downloaded Linux ISO to be
preseeded.

If this directory does not exist it will be created.

If you want this directory to be deleted at the end of the process,
set the **delete_iso_mount** variable to *true*.

Defaults to *~/original_iso/*.

::

   # Including from terminal.
   ansible localhost -m include_role -a name=constrict0r.iso -K -e \
       "iso_mount=/home/username/my-mount/"

   # Including on a playbook.
   - hosts: servers
     roles:
       - role: constrict0r.iso
         iso_mount: /home/username/my-mount/

   # To a playbook from terminal.
   ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
       "iso_mount=/home/username/my-mount/"


delete_iso_mount
================

Wheter to delete or not (at the end of the process) the directory
where the original Debian iso is mounted.

Defaults to *false*.

::

   # Including from terminal.
   ansible localhost -m include_role -a name=constrict0r.iso -K -e \
       "delete_iso_mount=true"

   # Including on a playbook.
   - hosts: servers
     roles:
       - role: constrict0r.iso
         delete_iso_mount: true

   # To a playbook from terminal.
   ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
       "delete_iso_mount=true"


remaster_mount
==============

Local directory path where to copy the Linux ISO files to be modified
to include preseeding.

If you want this directory to be deleted at the end of the process,
set the **delete_remaster_mount** variable to *true*.

Defaults to *~/remaster_iso/*.

::

   # Including from terminal.
   ansible localhost -m include_role -a name=constrict0r.iso -K -e \
       "remaster_mount=/home/username/my-remaster/"

   # Including on a playbook.
   - hosts: servers
     roles:
       - role: constrict0r.iso
         remaster_mount: /home/username/my-remaster/

   # To a playbook from terminal.
   ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
       "remaster_mount=/home/username/my-remaster/"


delete_remaster_mount
=====================

Wheter to delete or not (at the end of the process) the directory
where the Linux files to be modified are copied.

Defaults to *false*.

::

   # Including from terminal.
   ansible localhost -m include_role -a name=constrict0r.iso -K -e \
       "delete_remaster_mount=true"

   # Including on a playbook.
   - hosts: servers
     roles:
       - role: constrict0r.iso
         delete_remaster_mount: true

   # To a playbook from terminal.
   ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
       "delete_remaster_mount=true"


remaster_destination
====================

Local file path where to save the resulting remastered ISO.

Defaults to *~/remaster.iso*.

::

   # Including from terminal.
   ansible localhost -m include_role -a name=constrict0r.iso -K -e \
       "remaster_destination=/home/username/my-remaster.iso"

   # Including on a playbook.
   - hosts: servers
     roles:
       - role: constrict0r.iso
         remaster_destination: /home/username/my-remaster.iso

   # To a playbook from terminal.
   ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
       "remaster_destination=/home/username/my-remaster.iso"


iso_architecture
================

The iso architecture, this variable is used to set the path where to
copy and modify the *preseed.cfg* file. Valid values are:

* **amd64**: To install *x86_64* machines.

* **386**: To install *x86* machines.

* **a64**: To install *arm* machines.

Defaults to *amd64*.

::

   # Including from terminal.
   ansible localhost -m include_role -a name=constrict0r.iso -K -e \
       "iso_architecture=amd64"

   # Including on a playbook.
   - hosts: servers
     roles:
       - role: constrict0r.iso
         iso_architecture: 386

   # To a playbook from terminal.
   ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
       "iso_architecture=a64"


firmware_path
=============

Local directory path to a folder containing firmware files to be added
to the resulting ISO file.

This files must have *.deb* extension.

This variable answer to the following steps of the Debian Installer:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/di_18_add_firmware.png
   :alt: di_18_add_firmware

This variable is empty by default.

::

   # Including from terminal.
   ansible localhost -m include_role -a name=constrict0r.iso -K -e \
       "firmware_path=/home/username/my-firmware/"

   # Including on a playbook.
   - hosts: servers
     roles:
       - role: constrict0r.iso
         firmware_path: /home/username/my-firmware/

   # To a playbook from terminal.
   ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
       "firmware_path=/home/username/my-firmware/"


preseed
=======

Wheter to add preseeding to the resulting ISO or not.

If set to *false* the grub installation step is not preseeded neither.

If this variable is set to *true* the Debian Installer Variables
(listed below) are used to apply preseeding.

This variable answer to the following step of the Debian Installer:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/di_11_another_dvd.png
   :alt: di_11_another_dvd

And:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/di_13_popularity_contest.png
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

::

   # Including from terminal.
   ansible localhost -m include_role -a name=constrict0r.iso -K -e \
       "preseed=false"

   # Including on a playbook.
   - hosts: servers
     roles:
       - role: constrict0r.iso
         preseed: true

   # To a playbook from terminal.
   ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
       "preseed=false"


preseed_wireless
================

Wheter to preseed wireless network configuration or not.

You can disable wireless network preseeding when using wired
connections or for another particular case.

Defaults to *false*.

::

   # Including from terminal.
   ansible localhost -m include_role -a name=constrict0r.iso -K -e \
       "preseed_wireless=false"

   # Including on a playbook.
   - hosts: servers
     roles:
       - role: constrict0r.iso
         preseed_wireless: true

   # To a playbook from terminal.
   ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
       "preseed_wireless=false"


preseed_partitioning
====================

Wheter to apply preseed to partitioning configuration or not.

If set to *true* the *atomic* partitioning type is applied on the
device specified in the **device** variable.

On simple terms this variable allows to apply a *whole* disk
partitioning or not (*none*) partitioning at all.

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

::

   # Including from terminal.
   ansible localhost -m include_role -a name=constrict0r.iso -K -e \
       "preseed_partitioning=false"

   # Including on a playbook.
   - hosts: servers
     roles:
       - role: constrict0r.iso
         preseed_partitioning: true

   # To a playbook from terminal.
   ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
       "preseed_partitioning=false"


preseed_desktop
===============

Wheter to apply desktop configuration to the new system or not.

If set to *true* the `gnome <https://www.gnome.org>`_ desktop
enviroment is installed by including the `constrictor.desktop
<https://gitlab.com/constrict0r/desktop>`_ ansible role.

When the **preseed_custom** variable is present and not empty, this
variable is ignored.

Defaults to *false*.

::

   # Including from terminal.
   ansible localhost -m include_role -a name=constrict0r.iso -K -e \
       "preseed_desktop=false"

   # Including on a playbook.
   - hosts: servers
     roles:
       - role: constrict0r.iso
         preseed_desktop: true

   # To a playbook from terminal.
   ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
       "preseed_desktop=false"


preseed_custom
==============

Absolute path to a .yml file containing some or all of the following
configuration:

* A list of apt repositories to add (see *constrict0r.sourcez* role).

* A list of packages to purge via Apt (see *constrict0r.aptitude*
   role).

* A list of packages to install via Apt (see *constrict0r.aptitude*
   role).

* A list of packages to install via yarn (see *constrict0r.jsnode*
   role).

* A list of packages to install via pip (see *constrict0r.pyp* role).

* An URL to a skeleton git repository to copy to */* (see
   *constrict0r.sysconfig* role).

* A list of services to stop and disable (see *constrict0r.servicez*
   role).

* A list of services to enable and restart (see
   *constrict0r.servicez* role).

* A list of users to create (see *constrict0r.users* role).

* A list of groups to add the created users (see *constrict0r.group*
   role).

* A password for each created user.

* A list of files or URLs to skeleton git repositories to copy to
   each */home* folder (see *constrict0r.userconfig* role).

* A list of files or URLs to custom Ansible tasks to run (see
   *constrict0r.task* role).

If set to *true* the `constrictor.constructor
<https://gitlab.com/constrict0r/constructor>`_ ansible role will be
included to read the specified configuration file and to apply the
configuration described on it.

When this variable is present and not empty, the **preseed_desktop**
variable is ignored (as if its value is *false*).

Defaults to *empty*.

::

   # Including from terminal.
   ansible localhost -m include_role -a name=constrict0r.iso -K -e \
       "preseed_custom=/home/username/my-config.yml"

   # Including on a playbook.
   - hosts: servers
     roles:
       - role: constrict0r.iso
         preseed_custom: /home/username/my-config.yml

   # To a playbook from terminal.
   ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
       "preseed_custom=/home/username/my-config.yml"


preseed_last_question
=====================

Wheter to preseed or not the last question.

This is useful to prevent multiple installations if the machine keeps
booting from an usb drive or similar.

This variable answer to the following steps of the Debian Installer:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/di_17_end_installation.png
   :alt: di_17_end_installation

Defaults to *false*.

::

   # Including from terminal.
   ansible localhost -m include_role -a name=constrict0r.iso -K -e \
       "preseed_last_question=false"

   # Including on a playbook.
   - hosts: servers
     roles:
       - role: constrict0r.iso
         preseed_last_question: true

   # To a playbook from terminal.
   ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
       "preseed_last_question=false"


Installer Variables
*******************


locale
======

Language and country to use.

This variable answer to the following step of the Debian Installer:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/di_00_language.png
   :alt: di_00_language

Defaults to *es_CR*.

::

   # Including from terminal.
   ansible localhost -m include_role -a name=constrict0r.iso -K -e \
       "locale=us_US"

   # Including on a playbook.
   - hosts: servers
     roles:
       - role: constrict0r.iso
         locale: us_US

   # To a playbook from terminal.
   ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
       "locale=us_US"


keyboard
========

Keyboard distribution to use.

This variable answer to the following step of the Debian Installer:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/di_01_keyboard.png
   :alt: di_01_keyboard

Defaults to *latam*.

::

   # Including from terminal.
   ansible localhost -m include_role -a name=constrict0r.iso -K -e \
       "keyboard=en_US"

   # Including on a playbook.
   - hosts: servers
     roles:
       - role: constrict0r.iso
         keyboard: en_US

   # To a playbook from terminal.
   ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
       "keyboard=en_US"


networkname
===========

Network name to use.

This variable answer to the following steps of the Debian Installer:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/di_20_wireless_name.png
   :alt: di_20_wireless_name

Defaults to *mynetwork*.

Must use quotes (*“* or *‘*) when specifying this variable via
*–extra-vars* (*-e*):

::

   # Including from terminal.
   ansible localhost -m include_role -a name=constrict0r.iso -K -e \
       "networkname='mynetwork'"

   # Including on a playbook.
   - hosts: servers
     roles:
       - role: constrict0r.iso
         networkname: 'my network with spaces'

   # To a playbook from terminal.
   ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
       "networkname='mynetwork'"


networkpass
===========

Network password to use.

This variable answer to the following steps of the Debian Installer:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/di_21_wireless_pass_type.png
   :alt: di_21_wireless_pass_type

And:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/di_22_wireless_pass.png
   :alt: di_22_wireless_pass

Defaults to *12345678*.

Must use quotes (*“* or *‘*) when specifying this variable via
*–extra-vars* (*-e*):

::

   # Including from terminal.
   ansible localhost -m include_role -a name=constrict0r.iso -K -e \
       "networkpass='my-password'"

   # Including on a playbook.
   - hosts: servers
     roles:
       - role: constrict0r.iso
         networkpass: "str@nge!Pass"

   # To a playbook from terminal.
   ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
       "networkpass='my-password'"


hostname
========

Hostname to use.

This variable answer to the following step of the Debian Installer:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/di_02_hostname.png
   :alt: di_02_hostname

Defaults to *debian*.

::

   # Including from terminal.
   ansible localhost -m include_role -a name=constrict0r.iso -K -e \
       "hostname=my-hostname"

   # Including on a playbook.
   - hosts: servers
     roles:
       - role: constrict0r.iso
         hostname: my-hostname

   # To a playbook from terminal.
   ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
       "hostname=my-hostname"


domain
======

Domain name to use.

This variable answer to the following step of the Debian Installer:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/di_03_domain.png
   :alt: di_03_domain

Defaults to *debian*.

::

   # Including from terminal.
   ansible localhost -m include_role -a name=constrict0r.iso -K -e \
       "domain=my-domain"

   # Including on a playbook.
   - hosts: servers
     roles:
       - role: constrict0r.iso
         domain: my-domain

   # To a playbook from terminal.
   ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
       "domain=my-domain"


rootpass
========

Root user password.

This variable answer to the following step of the Debian Installer:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/di_04_root.png
   :alt: di_04_root

Defaults to *debian*.

Must use quotes (*“* or *‘*) when specifying this variable via
*–extra-vars* (*-e*):

::

   # Including from terminal.
   ansible localhost -m include_role -a name=constrict0r.iso -K -e \
       "rootpass='my-password'"

   # Including on a playbook.
   - hosts: servers
     roles:
       - role: constrict0r.iso
         rootpass: "str@nge!Pass"

   # To a playbook from terminal.
   ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
       "rootpass='my-password'"


username
========

Non-root username.

This variable answer to the following step of the Debian Installer:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/di_05_username.png
   :alt: di_05_username

Defaults to *debian*.

::

   # Including from terminal.
   ansible localhost -m include_role -a name=constrict0r.iso -K -e \
       "username=mary"

   # Including on a playbook.
   - hosts: servers
     roles:
       - role: constrict0r.iso
         username: jhon

   # To a playbook from terminal.
   ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
       "username=mary"


userpass
========

Non-root user password.

This variable answer to the following step of the Debian Installer:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/di_06_pass.png
   :alt: di_06_pass

Defaults to *debian*.

Must use quotes (*“* or *‘*) when specifying this variable via
*–extra-vars* (*-e*):

::

   # Including from terminal.
   ansible localhost -m include_role -a name=constrict0r.iso -K -e \
       "userpass='my-password'"

   # Including on a playbook.
   - hosts: servers
     roles:
       - role: constrict0r.iso
         userpass: "str@nge!Pass"

   # To a playbook from terminal.
   ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
       "userpass='my-password'"


mirror
======

Debian mirror url added to `sources
<https://wiki.debian.org/SourcesList>`_.

This variable answer to the following steps of the Debian Installer:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/di_12_mirror.png
   :alt: di_12_mirror

Defaults to *`https://mirrors.ucr.ac.cr
<https://mirrors.ucr.ac.cr>`_*.

::

   # Including from terminal.
   ansible localhost -m include_role -a name=constrict0r.iso -K -e \
       "mirror=https://mirrors.ucr.ac.cr"

   # Including on a playbook.
   - hosts: servers
     roles:
       - role: constrict0r.iso
         mirror: http://ftp.us.debian.org/debian

   # To a playbook from terminal.
   ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
       "mirror=https://mirrors.ucr.ac.cr"


device
======

Device used for partitioning and where to install `grub
<https://www.gnu.org/software/grub>`_, usually *sda* or *hda*.

This variable must not include the text */dev/* but only the device
name.

This variable answer to the following step of the Debian Installer:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/di_16_grub_device.png
   :alt: di_16_grub_device

Defaults to *sda*.

::

   # Including from terminal.
   ansible localhost -m include_role -a name=constrict0r.iso -K -e \
       "device=sda"

   # Including on a playbook.
   - hosts: servers
     roles:
       - role: constrict0r.iso
         device: sdb

   # To a playbook from terminal.
   ansible-playbook -i tests/inventory tests/test-playbook.yml -K -e \
       "device=hda"



Requirements
************

* `Ansible <https://www.ansible.com>`_ >= 2.8.

* `Jinja2 <https://palletsprojects.com/p/jinja/>`_.

* `Pip <https://pypi.org/project/pip/>`_.

* `Python <https://www.python.org/>`_.

* `PyYAML <https://pyyaml.org/>`_.

* `Requests <https://2.python-requests.org/en/master/>`_.

If you want to run the tests, you will also need:

* `Docker <https://www.docker.com/>`_.

* `Molecule <https://molecule.readthedocs.io/>`_.

* `Setuptools <https://pypi.org/project/setuptools/>`_.



Compatibility
*************

* `Debian Buster <https://wiki.debian.org/DebianBuster>`_.

* `Debian Raspbian <https://raspbian.org/>`_.

* `Debian Stretch <https://wiki.debian.org/DebianStretch>`_.



Limitations
***********

* This role uses the **username** variable to set both the non-root
   username and its full user name.

* Only support two types of partitioning: no partitioning or whole
   disk partitioning.

* If you use the **whole** partitioning type it does not allow to
   handle encrypted partitioning.

* Does not allows to handle partman recipes.

* When using preseeding to specify packages to install via *apt*
   there could be some problematic packages that needs a full Linux
   system enviroment to get installed and configured properly. Example
   of such packages are:

   * bridge-utils

   * libvirt-system-daemon

   If you include any of those packages on a preseeding setup it
   **will fail**.

   To prevent such failure it is recommended to setup a basic system
   first and when the system has started, call the **kick.sh** script
   again passing to it a configuration file.

* Uses the same device to install the operating system and grub.

* When using a wireless network there is one step not preseeded:

..

   The option *Enter ESSID Manually* must be choosed automatically but
   it does not, the installer highlights the option correctly but does
   not continue with the process as if the *Enter* key is not preseed,
   and because of this is necessary to hit the *Enter* key one time
   during this step.

   Once the *Enter* key has been preseed, all the other steps continue
   without any problem.

   Luckily this step occurs at the beggining of the installation
   process, affects only wireless setups and does not affect virtual
   machines or containers.

* This role does not support vault values.



License
*******

MIT. See the LICENSE file for more details.



Links
*****

* `Github <https://github.com/constrict0r/iso>`_.

* `Gitlab <https://gitlab.com/constrict0r/iso>`_.

* `Readthedocs <https://iso.readthedocs.io>`_.

* `Travis CI <https://travis-ci.com/constrict0r/iso>`_.



UML
***


Deployment
==========

The full project structure is shown below:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/deploy.png
   :alt: deploy


Main
====

The project data flow is shown below:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/main.png
   :alt: main


Cleanup
=======

The cleanup process data flow is shown below:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/cleanup.png
   :alt: cleanup


Initrd
======

The process to modify the *initrd.gz* file is shown below:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/initrd.png
   :alt: initrd


Initrd-Partitioning
===================

The process to modify the *initrd.gz* file is shown below:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/initrd_partitioning.png
   :alt: initrd_partitioning


Initrd-Set-Answer
=================

The process to preseed the answers for the Installer is shown below:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/initrd_set_answer.png
   :alt: initrd_set_answer


Menu
====

The process to modify the *boot* menu is shown below:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/menu.png
   :alt: menu


Preseed
=======

The preseeding process is shown below:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/preseed.png
   :alt: preseed


Remaster
========

The remastering process is shown below:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/remaster.png
   :alt: remaster


Sync
====

The files sync process is shown below:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/sync.png
   :alt: sync


Sync-Get-ISO
============

The process of obtaining the ISO to sync is shown below:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/sync_get_iso.png
   :alt: sync_get_iso


Vars
====

The process of variable copying is shown below:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/variables.png
   :alt: variables



Author
******

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/author.png
   :alt: author

The Travelling Vaudeville Villain.

Enjoy!!!

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/enjoy.png
   :alt: enjoy


