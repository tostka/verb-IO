#*------v Add-PSTitleBar.ps1 v------
Function Add-PSTitleBar {
    <#
    .SYNOPSIS
    Add-PSTitleBar.ps1 - Append specified identifying Tag string to the end of the powershell console Titlebar
    .NOTES
    Version     : 1.0.1
    Author      : dsolodow
    Website     :	https://github.com/dsolodow/IndyPoSH/blob/master/Profile.ps1
    Twitter     :	
    CreatedDate : 2014-11-12
    FileName    : 
    License     : 
    Copyright   : 
    Github      : 
    Tags        : Powershell,Console
    REVISIONS
    * 3:11 PM 4/19/2021 added cmdletbinding/verbose supp & alias add-PSTitle
    * 4:37 PM 2/27/2020 updated CBH
    # 8:44 AM 3/15/2017 ren Update-PSTitleBar => Add-PSTitleBar, so that we can have a Remove-PSTitleBar, to subtract
    # 8:42 AM 3/15/2017 Add-PSTitleBar for addition, before adding
    # 11/12/2014 - posted version
    .DESCRIPTION
    Add-PSTitleBar.ps1 - Append specified identifying Tag string to the end of the powershell console Titlebar
    Inspired by dsolodow's Update-PSTitleBar code
    .PARAMETER Tag
    Tag string to be added to current powershell console Titlebar
    .EXAMPLE
    Add-PSTitleBar 'EMS'
    Add the string 'EMS' to the powershell console Title Bar
    .LINK
    https://github.com/dsolodow/IndyPoSH/blob/master/Profile.ps1
    #>
    [CmdletBinding()]
    [Alias('add-PSTitle')]
    Param (
        #[parameter(Mandatory = $true,Position=0)][String]$Tag
        [parameter(Mandatory = $true,Position=0)]$Tag,
        [Parameter(HelpMessage="Debugging Flag [-showDebug]")]
        [switch] $showDebug
    )
    $showDebug=$true ; 
    #only use on console host; since ISE shares the WindowTitle across multiple tabs, this information is misleading in the ISE.
    #If ($host.name -eq 'ConsoleHost') {
    If ( $host.name -eq 'ConsoleHost' -OR ($showDebug)) {
        #if($host.ui.rawui.windowtitle -match '(PS|PSc)\s(ADMIN|Console)\s-\s(.*)\s-(.*)'){
        #    $conshost = $matches[1] ; $consrole = $matches[2] ; $consdom = $matches[3] ; $consData = ($matches[4] -split '\s\s').trim() ;
        # alt, take everything after last '-':
        if($Tag -is [system.array]){ 
            foreach ($Tg in $Tag){
                # don't add if already present
                #if($host.ui.RawUI.WindowTitle -like "*$($Tg)*"){}
                # search space delimited, mebbe regex, $env:userdomain is overlapping the TenOrg (which is a substring of the domain), plus side always has trailing \s
                if($host.ui.RawUI.WindowTitle  -match "\s$($Tg)\s"){}
                else{$host.ui.RawUI.WindowTitle += " $Tg "} ;
            } ; 
        } else { 
            # don't add if already present
            #if($host.ui.RawUI.WindowTitle -like "*$($Tag)*"){}
            if($host.ui.RawUI.WindowTitle  -match "\s$($Tag)\s"){}
            else{$host.ui.RawUI.WindowTitle += " $Tag "} ;
        } ;
    } ;
    Rebuild-PSTitleBar ;
}
#*------^ Add-PSTitleBar.ps1 ^------