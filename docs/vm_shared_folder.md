# Sharing Folders with Virtual Box

If you are running Talend Studio on Windows and wish to use Job2Docker then you will need to share a folder from the host OS (Windows) with a machine running the job2docker scripts.
Shared folders are a feature of VM apps like VirtualBox or VMware that allow the host OS to share a folder with the guest OS.

A brief tutorial for sharing folders with VirtualBox between Windows and Ubuntu can be found [here](https://www.techrepublic.com/article/how-to-share-folders-between-guest-and-host-in-virtualbox/).

The first step is to [install the VM guest additions](https://www.techrepublic.com/article/how-to-install-virtualbox-guest-additions-on-a-gui-less-ubuntu-server-host/) on your VM instance.

The next step is to use the VirtualBox or VMware gui client to configure a shared folder.
* Select your VM and click on the `Settings` button in the toolbar.
* Select `Shared Folders` from the dialog navigation pane.
* Click the add folder icon and give your shared folder a logical name and then select the folder on the host OS (Windows).
* Click ok to save your changes.

![sharing folders with virtualbox](pictures/virtual_box_share_folders.png)

You will need to mount the shared folder using the logical name to a local directory in the guest OS (Linux).
You need to first create the local directory to which to mount the shared folder and then use the mount command.

    mkdir ~/shared_jobs
    sudo mount -t vboxsf my_shared_folder ~/shared_jobs

In the example above the `my_shared_folder` is the one you entered in the dialog window.  The example creates the local directory `shared_jobs` and mounts the shared folder.

You will need to run this mount command each time you start your VM.  Alternatively, you can edit the `/etc/fstab` file to make the mount permanent.

    my_shared_jobs /home/eost/shared_jobs vboxsf comment=systemd.automount,uid=eost,gid=eost,noauto 0 0

Substitute your correct path and username above and add it to the fstab.
