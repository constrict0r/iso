- To use with `Virt Manager <https://virt-manager.org>`_:

  - Use this role to generate an ISO image (replace with your data):

    .. substitution-code-block:: bash

      ansible localhost -m include_role -a name=constrict0r.iso -K -e \
          'username=constrict0r userpass=1234 rootpass=1234 device=sda preseed=true \
          preseed_wireless=true preseed_partitioning=true preseed_last_question=true \
          preseed_custom=/home/constrict0r/Documentos/madvillain.yml networkname="MY NETWORK" \
          networkpass="my-network-pass" hostname="latveria" domain="amanita"'

  - Open Virt Manager:

    .. image:: https://gitlab.com/constrict0r/img/raw/master/iso/virt_manager/00_open.png
       :alt: 00_open