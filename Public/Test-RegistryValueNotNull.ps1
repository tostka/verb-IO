#*------v Test-RegistryValueNotNull.ps1 v------
function Test-RegistryValueNotNull {
    <#
    .SYNOPSIS
    Test-RegistryValueNotNull.ps1 - Checks specified registry key is Not Null
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    AddedCredit : Adam Bertram
    AddedWebsite:	https://adamtheautomator.com/pending-reboot-registry-windows/
    AddedTwitter:	@adambertram
    CreatedDate : 20201014-0826AM
    FileName    : Test-RegistryValueNotNull.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell,System,Reboot
    REVISIONS
    * 1:35 PM 4/25/2022 psv2 explcit param property =$true; regexpattern w single quotes.
    * 5:03 PM 1/14/2021 init, minor CBH mods
    * 7/29/19 AB's posted version
    .DESCRIPTION
    Test-RegistryValueNotNull.ps1 - Checks specified registry key is Not Null
    .PARAMETER  Key
    Full registkey to be tested [-Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending']
    .PARAMETER  Value
    Value to be compared to
    .EXAMPLE
    Test-RegistryValueNotNull -Key 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Value 'PendingFileRenameOperations2'
    Tests value of the specified key is NotNull
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [OutputType('bool')]
    [CmdletBinding()]
    #[Alias('get-ScheduledTaskReport')]
    PARAM(
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
        [string]$Key,
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
        [string]$Value
    ) ;
    $ErrorActionPreference = 'Stop'
    if (($regVal = Get-ItemProperty -Path $Key -Name $Value -ErrorAction Ignore) -and $regVal.($Value)) {
        $true| write-output  ;
    } ;
}

#*------^ Test-RegistryValueNotNull.ps1 ^------