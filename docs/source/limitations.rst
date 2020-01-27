Limitations
------------------------------------------------------------------------------

- This role uses the **username** variable to set both the non-root username
  and its full user name.

- Only support two types of partitioning: no partitioning or whole disk
  partitioning.

- If you use the **whole** partitioning type it does not allow to handle
  encrypted partitioning.

- Does not allows to handle partman recipes.

- When using preseeding to specify packages to install via *apt* there could
  be some problematic packages that needs a full Linux system enviroment to
  get installed and configured properly. Example of such packages are:

  - bridge-utils

  - libvirt-system-daemon

  If you include any of those packages on a preseeding setup it **will fail**.

  To prevent such failure it is recommended to setup a basic system first and when
  the system has started, call the **kick.sh** script again passing to it a
  configuration file.

- Uses the same device to install the operating system and grub.

- When using a wireless network there is one step not preseeded:

 The option *Enter ESSID Manually* must be choosed automatically but it does
 not, the installer highlights the option correctly but does not continue with
 the process as if the *Enter* key is not preseed, and because of this is
 necessary to hit the *Enter* key one time during this step.

 Once the *Enter* key has been preseed, all the other steps continue without
 any problem.

 Luckily this step occurs at the beggining of the installation process, affects
 only wireless setups and does not affect virtual machines or containers.

.. include:: parts/limitations/vault.inc
