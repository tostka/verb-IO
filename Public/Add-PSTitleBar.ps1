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
    Param ([parameter(Mandatory = $true,Position=0)][String]$Tag)
    #only use on console host; since ISE shares the WindowTitle across multiple tabs, this information is misleading in the ISE.
    If ($host.name -eq 'ConsoleHost') {
        # don't add if already present
        if($host.ui.RawUI.WindowTitle -like "*$($Tag)*"){}
        else{$host.ui.RawUI.WindowTitle = $host.ui.RawUI.WindowTitle+" $Tag "} ;
    } ;
}
