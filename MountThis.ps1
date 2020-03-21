#Requires -Version 7

Param(
    [string] $Path,
    [switch] $Unmount,
    [switch] $Install,
    [switch] $Uninstall
)

if ($Install) {
    $script = $MyInvocation.MyCommand.Path

    $installKey = 'HKCU:\Software\Classes\Folder\Shell\MountThis\Command'
    New-Item -Path $installKey -Force
    Set-ItemProperty -LiteralPath $installKey -Name "(default)" -Value "pwsh ""$script"" ""%1"""
    exit 0
}

if ($Uninstall) {
    $uninstallKey = 'HKCU:\Software\Classes\Folder\Shell\MountThis'
    Remove-Item -LiteralPath $uninstallKey -Recurse -Force -ErrorAction SilentlyContinue
    exit 0
}

if ($Unmount) {
    try {
        $letter = ($Path | Split-Path -Qualifier -ErrorAction Stop)[0]
    }
    catch [System.FormatException] {
        # if the specified path is UNC
        exit 1
    }

    try {
        $pathRoot = (Get-PSDrive -Name $letter -PSProvider FileSystem -ErrorAction Stop).DisplayRoot
    }
    catch [System.Management.Automation.DriveNotFoundException] {
        # if the specified drive is not found
        exit 1
    }

    if ($null -eq $pathRoot) {
        # if the spefified drive is a local drive
        exit 1
        # Note: Even if the specified drive is a local drive made by subst, 
        #       Get-PSDrive executed on another session 
        #       may not be able to distinguish with the normal local drive.
    }
    else {
        # if the spefified drive is a mounted network drive
        Remove-PSDrive -Name $letter -Scope Global -Force
        # Note: This does NOT work well, even if Powershell 7.0.0
        #       https://github.com/PowerShell/PowerShell/issues/7829
    }

    exit 0
}

# Search for an unassigned drive letter.
$letters = "ZYXWVUTSRQPONMLKJIHGFEDCBA"
for ($i = 0; $i -lt $letters.Length; $i++) {
    try {
        Get-PSDrive -Name $letters[$i] -ErrorAction Stop > $null
    }
    catch [System.Management.Automation.DriveNotFoundException] {
        $letter = $letters[$i]
        break
    }
}

New-PSDrive -Name $letter -PSProvider FileSystem -Root $Path -Persist -Scope Global