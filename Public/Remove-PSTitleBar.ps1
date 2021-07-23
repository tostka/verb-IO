#*------v Remove-PSTitleBar.ps1 v------
Function Remove-PSTitleBar {
    <#
    .SYNOPSIS
    Remove-PSTitleBar.ps1 - Remove specified string from the Powershell console Titlebar
    .NOTES
    Version     : 1.0.1
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    AddedCredit : dsolodow
    AddedWebsite:	https://github.com/dsolodow/IndyPoSH/blob/master/Profile.ps1
    AddedTwitter:	URL
    Twitter     :	
    CreatedDate : 2014-11-12
    FileName    : 
    License     : 
    Copyright   : 
    Github      : 
    Tags        : Powershell,Console
    REVISIONS
    * 4:37 PM 2/27/2020 updated CBH
    # 8:46 AM 3/15/2017 Remove-PSTitleBar: initial version
    # 11/12/2014 - posted version
    .DESCRIPTION
    Remove-PSTitleBar.ps1 - Append specified string to the end of the powershell console Titlebar
    Inspired by dsolodow's Update-PSTitleBar code
    .PARAMETER Tag
    Tag string to be added to current powershell console Titlebar
    .EXAMPLE
    Remove-PSTitleBar 'EMS'
    Add the string 'EMS' to the powershell console Title Bar
    .LINK
    https://github.com/dsolodow/IndyPoSH/blob/master/Profile.ps1
    #>
    
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
        if($Tag -is [system.array]){ 
            foreach ($Tg in $Tag){
                #if($host.ui.RawUI.WindowTitle -like "*$($Tg)*"){
                if($host.ui.RawUI.WindowTitle  -match "\s$($Tg)\s"){
                    $host.ui.RawUI.WindowTitle = $host.ui.RawUI.WindowTitle.replace(" $Tg ","") ;
                }else{} ;
            }
        } else { 
            #if($host.ui.RawUI.WindowTitle -like "*$($Tag)*"){
            if($host.ui.RawUI.WindowTitle  -match "\s$($Tag)\s"){
                $host.ui.RawUI.WindowTitle = $host.ui.RawUI.WindowTitle.replace(" $Tag ","") ;
            }else{} ;
        } ; 
        Rebuild-PSTitleBar ;
    } ;
}

#*------^ Remove-PSTitleBar.ps1 ^------