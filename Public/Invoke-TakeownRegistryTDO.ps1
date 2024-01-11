# Invoke-TakeownRegistryTDO.ps1

# Invoke-TakeownRegistryTDO.ps1 

# #*------v Invoke-TakeownRegistryTDO.ps1 v------
Function Invoke-TakeownRegistryTDO {
    <#
    .SYNOPSIS
    Invoke-TakeownRegistryTDO.ps1 - Reassigns a target Registry Key Ownership to the admins SID S-1-5-32-544 group (takes back damaged key permissions for access)
    .NOTES
    Version     : 1.0.0
    Author      : (unknown)
    Website     : was blundled with Debloat-Windows-10 scripts.
    Twitter     : 
    CreatedDate : 2023-12-12
    FileName    : Invoke-TakeownRegistryTDO.ps1
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
    Invoke-TakeownRegistryTDO.ps1 - Reassigns a target Registry Key Ownership to the admins SID S-1-5-32-544 group (takes back damaged key permissions for access)
    .PARAMETER Key 
    Registry Key to have Owner reassigned to the admins SID S-1-5-32-544 group [-Key 'HKEY_CURRENT_USER\Software\Microsoft\Office\16.0\Outlook']
    .INPUTS
    Does not accept piped input.
    .OUTPUTS
    No output
    .EXAMPLE
    PS> Invoke-TakeownRegistryTDO 'HKEY_CLASSES_ROOT\*\shell';
    Resolve the CLSID for 'Downloads' to the current user's folder
    .LINK
    https://github.com/tostka/verb-IO
    https://www.reddit.com/r/PowerShell/comments/12zh5uh/using_environmentgetfolderpath_to_find_downloads/
    #>
    [CmdletBinding()]
    #[Alias('expand-ISOFile')]
    #[OutputType([boolean])]
    PARAM (
        [Parameter(Mandatory = $true,HelpMessage = "Registry Key to have Owner reassigned to the admins SID S-1-5-32-544 group [-Key 'HKEY_CURRENT_USER\Software\Microsoft\Office\16.0\Outlook']")]
            #[Alias('PsPath')]
            [string]$key        
    ) ;
    # TODO does not work for all root keys yet
    switch ($key.split('\')[0]) {
        "HKEY_CLASSES_ROOT" {
            $reg = [Microsoft.Win32.Registry]::ClassesRoot
            $key = $key.substring(18)
        }
        "HKEY_CURRENT_USER" {
            $reg = [Microsoft.Win32.Registry]::CurrentUser
            $key = $key.substring(18)
        }
        "HKEY_LOCAL_MACHINE" {
            $reg = [Microsoft.Win32.Registry]::LocalMachine
            $key = $key.substring(19)
        }
    }

    # get administraor group
    $admins = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-544")
    $admins = $admins.Translate([System.Security.Principal.NTAccount])

    # set owner
    $key = $reg.OpenSubKey($key, "ReadWriteSubTree", "TakeOwnership")
    $acl = $key.GetAccessControl()
    $acl.SetOwner($admins)
    $key.SetAccessControl($acl)

    # set FullControl
    $acl = $key.GetAccessControl()
    $rule = New-Object System.Security.AccessControl.RegistryAccessRule($admins, "FullControl", "Allow")
    $acl.SetAccessRule($rule)
    $key.SetAccessControl($acl)
}
#*------^ Invoke-TakeownRegistryTDO.ps1 ^------
