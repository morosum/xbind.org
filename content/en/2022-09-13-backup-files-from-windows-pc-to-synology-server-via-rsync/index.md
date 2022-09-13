---
title: Backup files from Windows PC to Synology server via rsync
date: '2022-09-13'
slug: backup-files-from-windows-pc-to-synology-server-via-rsync
tags:
  - rsync
  - backup
---

<!-- My laptop got a shingled magnetic recording (SMR) hard drive for storage. After years of use, it almost filled up. Weeks ago, I lost the latest changes to a MS-word file. Not sure if it was related to the SMR drive. It reminds me of backup data, as SMR drives can be fragile. I have a Synology disk server, yet it is too slow to run any backup package or docker. rsync is embedded in Synology DSM and terrific for backup.  -->

[rsync](https://rsync.samba.org/) is a Linux application that provides fast incremental file transfer between local and remote computers. "Incremental" means that it compares the source and destination so that rsync only transfers the modified pieces of files. 

rsync has been included in Synology DiskStation Manager (DSM) as well as many Linux distributions. If not, rsync can be easily installed by `apt install rsync` (debian) or `yum install rsync` (fedora). rsync works in two modes: rsync module mode and ssh mode. In rsync module mode, you set up a configuration file `/etc/rsyncd.conf` on the server and keep the rsync run in the background. On the client machine, run `rsync -[OPTIONS] source destination` and push the 'source' directory (or files) to the 'destination'. If the 'source' is a remote directory, rsync will pull all files back to your local 'destination'. The most useful options are `-a`, `-r`, `--delete`. 'a' stands for archive and the metadata (e.g. time revised and permissions) will be transferred along with the files; 'r' stands for 'recursive' and all the files in sub-directories will be transferred, and '--delete' will delete all the files that are no longer in the source directory from the destination, i.e. mirroring. A good rsync tutorial is available at [Everything Linux](https://everythinglinux.org/rsync/). 

In Synology DSM, a graphical user interface is available for the rsync service. On the client Windows PC, we can use DeltaCopy which wraps rsync, Cygwin and provides a windows-style user interface. 

### Enable rsync service on Synology

In Synology DSM, go to "Control Panel" and select "File services". Move on to the "rsync" tab, and make sure the "Enable rsync service" as well as "Enable rsync account" boxes are checked. 

If you would like to protect the rsync module with a password, open the "Edit rsync Account" window and add a user along with a password in it. Then click the "Apply" button at the bottom right corner of the "Control Panel" window. 

That's all for the settings on the Synology side. Your Synology will create a folder named "NetBackup". 

There is documentation on how to enable the rsync service at [Synology Knowledge Center](https://kb.synology.com/en-us/DSM/help/DSM/AdminCenter/file_rsync?version=6).

### DeltaCopy

Typically, you need to install and configure Cygwin on your Windows PC, as rsync is a Linux application. But with DeltaCopy, you don't need to configure Cygwin yourself. DeltaCopy is open source, provides Windows friendly interface for both rsync server and client settings and works with Windows task scheduler. The only drawback of DeltaCopy is that the latest version is over ten years old. 

DeltaCopy is freely available at [aboutmyip.com](http://www.aboutmyip.com/AboutMyXApp/DeltaCopy.jsp). Shortcuts for both DeltaCopy server and client appeared in your start menu after installation. Here, we only need the DeltaCopy client console, as we would like to transfer files from Windows PC to the Synology disk server. 

Run "DeltaCopy Client" on the Windows PC. Double click "Add New Profile", and then a new window will pop up. Add a profile name and type in the IP address of your Synology disk server. Then you can click the "Test Connection" button to check if the DeltaCopy client could connect to your Synology disk station. If successful, click the "..." button to load the directory names on your disk server and select a directory as the destination. Then click "Add Profile". 

A new profile appeared in the "Existing Profiles" panel. Select the profile and add some folders or files by clicking the "Add Folder" or "Add Files" buttons. Here, I add the database file of my Zotero library as an example. Then, move on to the "Authentication" tab, and type your user name along with its password into the dialogue box. This authentication setting should be consistent with your setting in Synology DSM. 

Now, you are ready to have a test run. Right-click on your profile name, and click "Run Now". A status window will pop up, which shows the file "zotero.sqlite" is copied to the server. The file is compressed during transfer, as approximately 105 MB is sent for a 237 MB file. If failed, you probably need manually create folders in your destination directory on your disk server to receive your files. For example, here I created a "zotero" folder in the "NetBackup". Then, I revised my Zotero library by adding a tag to one of my references and running the profile again. Only 125 KB were sent which indicates only the modified parts were transferred. 

Click the "Modify Schedule" button to configure the backup profile to run automatically. A new task schedule window popped up. Set the intervals in the "Schedule" tab and click "OK". The task scheduler may ask for the password. Please note that you should input the password to your Windows user, not the password you set in Synology and not the 4-digit pin code that logs you in to your Windows PC. 

![DeltaCopy Client configuation](https://storage.live.com/items/D70A892E0DD05FA3!2981?authkey=AKNCRUpelpMuI5U)

### Useful links
+ [rsync](https://rsync.samba.org/)
+ [rsync 用法教程 - 阮一峰](https://www.ruanyifeng.com/blog/2020/08/rsync.html)
+ [rsync tutorial by Everythin Linux](https://everythinglinux.org/rsync/)
