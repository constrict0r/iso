- To use with `Virt Manager <https://virt-manager.org>`_:

Use this role to generate a *remaster.iso* image (replace with your data):

.. code-block:: bash

 ansible localhost -m include_role -a name=constrict0r.iso -K -e \
     'username=constrict0r userpass=1234 rootpass=1234 device=sda preseed=true \
     preseed_wireless=true preseed_partitioning=true preseed_last_question=true \
     preseed_custom=/home/constrict0r/Documentos/madvillain.yml networkname="MY NETWORK" \
     networkpass="my-network-pass" hostname="latveria" domain="amanita"'

Open Virt Manager and click on the *New Virtual Machine* icon (the tiny computer):

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/vm_00_open.png
   :alt: vm_00_open

On the *new Virtual Machine* screen choose the option *Local media* and press *Next*:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/vm_01_new.png
   :alt: vm_01_new

On the *Create Virtual Machine* screen, search for the *remaster.iso* file and on the bottom input select the *Generic* OS type, then press the *Next* button:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/vm_02_remaster.png
   :alt: vm_02_remaster

On the *Memory Assign* screen type the amount of memory you need and the amount of cpus that you want to use and press *Next*:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/vm_03_memory.png
   :alt: vm_03_memory

On the *Disk Space* screen type the amount of space that you want to use and press *Next*:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/vm_04_disk.png
   :alt: vm_04_disk

On the *Final* screen put a name to your Virtual Machine, choose the network you want to use and press *Finish*:

.. image:: https://gitlab.com/constrict0r/img/raw/master/iso/vm_05_final.png
   :alt: vm_05_final
