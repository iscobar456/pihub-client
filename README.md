# Pihub Linux Client
---

### Installation
1. Extract the zip file, location does not matter.
2. Make installer executable. `chmod u+x <path_to_extracted_zip>/install.sh`
3. Run installer. `sudo <path_to_extracted_zip>/install.sh`
4. Provide the installer script necessary keys.
5. Done!

### Stop updates
To stop sending updates to [pihub](http://pihub.site), run the following commands.
    systemctl stop pihub.timer
    systemctl disable pihub.timer # Prevents updates from resuming after a system restart.

To start updates again, replace `stop` and `disable` in the commands above with `start` and `enable`, respectively.

### Uninstall
To uninstall the pihub client, run `sudo /opt/pihub-client/uninstall.sh`