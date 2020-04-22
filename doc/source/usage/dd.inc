- To use a USB stick to install a physical computer:

Use this role to generate a *remaster.iso* image (replace with your data):

.. code-block:: bash

 ansible localhost -m include_role -a name=constrict0r.iso -K -e \
     'username=constrict0r userpass=1234 rootpass=1234 device=sda \
     preseed=true preseed_wireless=true preseed_partitioning=true \
     preseed_last_question=true \
     preseed_custom=/home/constrict0r/Documentos/madvillain.yml \
     networkname="MY NETWORK" networkpass="my-network-pass" \
     hostname="latveria" domain="amanita" \
     firmware_path=/home/constrict0r/Instaladores/firmware/'

- Then use `dd <http://man7.org/linux/man-pages/man1/dd.1.html>`_ to copy
  the file to your USB stick (replacing *sdx* with your drive):

.. code-block:: bash

 su -c 'dd if=/path/to/remaster.iso of=/dev/sdx'

- Some modern computer complaints about a **cdrom not detected** during the
  installation process (because they no longer include cdroms), to overpass
  this issue, rename the extension *.iso* to *.img* and use **dd** to copy
  the file:

.. code-block:: bash

 mv remaster.iso remaster.img
 su -c 'dd if=/path/to/remaster.img of=/dev/sdx'
