# windows-file-utils
Tool for file handling with Windows Explorer.

## Prerequisite
- PowerShell 7
- Execution Polity of PowerShell is laxer than or equal to `RemoteSigned`.
- Set execution policy of PowerShell to `RemoteSigned` and remove the ZoneId of *.ps1 scripts.
  To remove the ZoneId, for example, check the unblock checkbox of the file properties using Windows Explorer.

## Install
- Double-click `InstallAll.cmd`

## Uninstall
- Double-click `UninstallAll.cmd`

## Usage
### MountThis
Click `MountThis`, which is displayed by right-clicking on a folder on the explorer, and the folder is mounted on a free drive letter.

### RealPath
Click `RealPath`, which is displayed by right-clicking on a file or folder on the explorer, and the name of file or folder is copied to the clipboard. If the file or folder is on the network-mounted drive, the name of file or folder is converted to UNC.