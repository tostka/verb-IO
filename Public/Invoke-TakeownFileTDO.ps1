# Invoke-TakeownFileTDO.ps1

# Invoke-TakeownFileTDO.ps1 

# #*------v Invoke-TakeownFileTDO.ps1 v------
Function Invoke-TakeownFileTDO {
    <#
    .SYNOPSIS
    Invoke-TakeownFileTDO.ps1 - Simple wrapper for Window's takeown.exe, reassigns file Ownership to the admins SID S-1-5-32-544 group (takes back damaged permissions for access)
    .NOTES
    Version     : 1.0.0
    Author      : (unknown)
    Website     : was blundled with Debloat-Windows-10 scripts.
    Twitter     : 
    CreatedDate : 2023-12-12
    FileName    : Invoke-TakeownFileTDO.ps1
    License     : (none asserted)
    Copyright   : (none asserted)
    Github      : https://github.com/tostka/verb-IO
    Tags        : Powershell,development,filesystem,SpecialFolders
    AddedCredit : Todd Kadrie
    AddedWebsite: http://www.toddomation.com
    AddedTwitter: @tostka / http://twitter.com/tostka
    REVISION
    * 9:39 AM 1/16/2024 fix typo trailing comma in param; flip param hlpmsg quote type
    * 12:29 PM 3:11 PM 1/10/2024 adding to verb-io for future ref
    .DESCRIPTION
    Invoke-TakeownFileTDO.ps1 - Simple wrapper for Window's takeown.exe, reassigns file Ownership to the admins SID S-1-5-32-544 group (takes back damaged permissions for access)
    .PARAMETER Path 
    Full path to file to have Owner reassigned to the admins SID S-1-5-32-544 group [-Key 'HKEY_CURRENT_USER\Software\Microsoft\Office\16.0\Outlook']
    .INPUTS
    Does not accept piped input.
    .OUTPUTS
    No output
    .EXAMPLE
    PS> Invoke-TakeownFileTDO 'HKEY_CLASSES_ROOT\*\shell';
    Resolve the CLSID for 'Downloads' to the current user's folder
    .LINK
    https://github.com/tostka/verb-IO
    https://www.reddit.com/r/PowerShell/comments/12zh5uh/using_environmentgetfolderpath_to_find_downloads/
    #>
    [CmdletBinding()]
    #[Alias('expand-ISOFile')]
    #[OutputType([boolean])]
    PARAM (
        [Parameter(Mandatory = $true,Position = 0,HelpMessage = "Full path to file to have Owner reassigned to the admins SID S-1-5-32-544 group [-Path 'c:\tmp\tmp.txt']")]
            [Alias('PsPath')]
            #[ValidateScript({Test-Path $_ -PathType 'Container'})]
            #[System.IO.DirectoryInfo[]]$Path,
            [ValidateScript({Test-Path $_})]
            [system.io.fileinfo]$Path
            #[string[]]$Path,
    ) ;
    takeown.exe /A /F $Path.fullname
    $acl = Get-Acl $Path.fullname

    # get administraor group
    $admins = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-544")
    $admins = $admins.Translate([System.Security.Principal.NTAccount])

    # add NT Authority\SYSTEM
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($admins, "FullControl", "None", "None", "Allow")
    $acl.AddAccessRule($rule)

    Set-Acl -Path $Path.fullname -AclObject $acl
}
#*------^ Invoke-TakeownFileTDO.ps1 ^------
