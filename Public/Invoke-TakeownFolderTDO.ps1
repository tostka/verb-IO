# Invoke-TakeownFolderTDO.ps1

# Invoke-TakeownFolderTDO.ps1 

# #*------v Invoke-TakeownFolderTDO.ps1 v------
Function Invoke-TakeownFolderTDO {
    <#
    .SYNOPSIS
    Invoke-TakeownFolderTDO.ps1 - Simple wrapper for Window's takeown.exe, reassigns Folder Ownership to the admins SID S-1-5-32-544 group (takes back damaged permissions for access)
    .NOTES
    Version     : 1.0.0
    Author      : (unknown)
    Website     : was blundled with Debloat-Windows-10 scripts.
    Twitter     : 
    CreatedDate : 2023-12-12
    FileName    : Invoke-TakeownFolderTDO.ps1
    License     : (none asserted)
    Copyright   : (none asserted)
    Github      : https://github.com/tostka/verb-IO
    Tags        : Powershell,development,filesystem,SpecialFolders
    AddedCredit : Todd Kadrie
    AddedWebsite: http://www.toddomation.com
    AddedTwitter: @tostka / http://twitter.com/tostka
    REVISION
    * 12:29 PM 3:11 PM 1/10/2024 adding to verb-io for future ref
    .DESCRIPTION
    Invoke-TakeownFolderTDO.ps1 - Simple wrapper for Window's takeown.exe, reassigns file Ownership to the admins SID S-1-5-32-544 group (takes back damaged permissions for access)
    .PARAMETER Path 
    Full path to file to have Owner reassigned to the admins SID S-1-5-32-544 group [-Path 'c:\tmp']
    .INPUTS
    Does not accept piped input.
    .OUTPUTS
    No output
    .EXAMPLE
    PS> Invoke-TakeownFolderTDO 'HKEY_CLASSES_ROOT\*\shell';
    Resolve the CLSID for 'Downloads' to the current user's folder
    .LINK
    https://github.com/tostka/verb-IO
    https://www.reddit.com/r/PowerShell/comments/12zh5uh/using_environmentgetfolderpath_to_find_downloads/
    #>
    [CmdletBinding()]
    #[Alias('expand-ISOFile')]
    #[OutputType([boolean])]
    PARAM (
        [Parameter(Mandatory = $true,Position = 0,HelpMessage = "Full path to file to have Owner reassigned to the admins SID S-1-5-32-544 group [-Path 'c:\tmp']")]
            [Alias('PsPath')]
            [ValidateScript({Test-Path $_ -PathType 'Container'})]
            [System.IO.DirectoryInfo]$Path
            #[ValidateScript({Test-Path $_})]
            #[system.io.fileinfo]$Path,
            #[string[]]$Path,
    ) ;
        Invoke-TakeownFileTDO $Path.fullname
    foreach ($item in Get-ChildItem $Path.fullname) {
        if (Test-Path $item -PathType Container) {
            Invoke-TakeownFolderTDO $item.FullName
        } else {
            Invoke-TakeownFileTDO $item.FullName
        }
    }
}
#*------^ Invoke-TakeownFolderTDO.ps1 ^------
