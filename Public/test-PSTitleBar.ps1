Function test-PSTitleBar {
    <#
    .SYNOPSIS
    test-PSTitleBar.ps1 - Test for presence of specified string(s) from the Powershell console Titlebar
    .NOTES
    Version     : 1.0.0
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
    * 10:15 AM 7/22/2021 init vers
    .DESCRIPTION
    test-PSTitleBar.ps1 - Test for presence of specified string(s) from the Powershell console Titlebar
    Inspired by dsolodow's Update-PSTitleBar code
    .PARAMETER Tag
    Tag/array-of-tags string to be tested-for in text of current powershell console Titlebar
    .EXAMPLE
    test-PSTitleBar 'EMS'
    Test for the string 'EMS' in the powershell console Title Bar
    .EXAMPLE
    test-PSTitleBar 'EMS','EXO'
    Test for the 'EMS' or 'EXO' strings in the powershell console Title Bar
    .LINK
    https://github.com/dsolodow/IndyPoSH/blob/master/Profile.ps1
    #>
    
    Param (
        #[parameter(Mandatory = $true,Position=0)][String][]$Tag
        [parameter(Mandatory = $true,Position=0)]$Tag,
        [Parameter(HelpMessage="Debugging Flag [-showDebug]")]
        [switch] $showDebug
    )
    $showDebug=$true ; 
    #only use on console host; since ISE shares the WindowTitle across multiple tabs, this information is misleading in the ISE.
    $bPresent = $false ; 
    If ( $host.name -eq 'ConsoleHost' -OR ($showDebug)) {
        if($Tag -is [system.array]){ 
            foreach ($Tg in $Tag){
                #if($host.ui.RawUI.WindowTitle -like "*$($Tg)*"){
                <# could do rebuild style parse as well:
                $consPrembl = $host.ui.rawui.windowtitle.substring(0,$host.ui.rawui.windowtitle.LastIndexOf('-')).trim() ;
                $consData = ($host.ui.rawui.windowtitle.substring(($host.ui.rawui.windowtitle.LastIndexOf('-'))+1) -split '\s\s').trim(); 
                $svcs = $consdata | ?{$_ -match $rgxsvcs} | sort | select -unique  ; 
                $Orgs = $consdata |?{$_ -match $rgxTenOrgs } | sort | select -unique  ; 
                #>
                if($host.ui.RawUI.WindowTitle  -match "\s$($Tg)\s"){
                      $bPresent = $true ;
                }else{} ;
            } ; 
        } else {
            #if($host.ui.RawUI.WindowTitle -like "*$($Tag)*"){
            if($host.ui.RawUI.WindowTitle -match "\s$($Tg)\s"){
                  $bPresent = $true ;
            }else{} ;
        }; 
    } ;
    $bPresent | write-output ;
}
