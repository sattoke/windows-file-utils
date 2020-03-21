#Requires -Version 7

Param(
    [string] $Path,
    [switch] $Install,
    [switch] $Uninstall
)

if ($Install) {
    $script = $MyInvocation.MyCommand.Path

    $installKey = 'HKCU:\Software\Classes\*\Shell\RealPath\Command'
    New-Item -Path $installKey -Force
    Set-ItemProperty -LiteralPath $installKey -Name "(default)" -Value "pwsh ""$script"" ""%1"""

    $installKey = 'HKCU:\Software\Classes\Folder\Shell\RealPath\Command'
    New-Item -Path $installKey -Force
    Set-ItemProperty -LiteralPath $installKey -Name "(default)" -Value "pwsh ""$script"" ""%1"""

    exit 0
}

if ($Uninstall) {
    $uninstallKey = 'HKCU:\Software\Classes\*\Shell\RealPath'
    Remove-Item -LiteralPath $uninstallKey -Recurse -Force -ErrorAction SilentlyContinue

    $uninstallKey = 'HKCU:\Software\Classes\Folder\Shell\RealPath'
    Remove-Item -LiteralPath $uninstallKey -Recurse -Force -ErrorAction SilentlyContinue

    exit 0
}

try {
    $letter = ($Path | Split-Path -Qualifier -ErrorAction Stop)[0]
}
catch [System.FormatException] {
    # if the specified path is UNC
    $Path | Set-Clipboard
    exit 0
}

try {
    $pathRoot = (Get-PSDrive -Name $letter -PSProvider FileSystem -ErrorAction Stop).DisplayRoot
}
catch [System.Management.Automation.DriveNotFoundException] {
    # if the specified drive is not found
    exit 1
}

if ($null -eq $pathRoot) {
    # if the specified drive is a local drive
    $Path | Set-Clipboard
    # Note: Even if the specified drive is a local drive made by subst, 
    #       Get-PSDrive executed on another session 
    #       may not be able to distinguish with the normal local drive.
}
else {
    # if the spefified drive is a mounted network drive
    $pathRest = $Path | Split-Path -NoQualifier
    join-path $pathRoot $pathRest | Set-Clipboard
}