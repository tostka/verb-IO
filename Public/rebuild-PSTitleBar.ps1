Function rebuild-PSTitleBar {
    <#
    .SYNOPSIS
    rebuild-PSTitleBar.ps1 - reconstruct Powershell console Titlebar in '[consHost] [role] - [domain] - [org] [svcs]' sorted format
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    AddedCredit : 
    AddedWebsite:	
    AddedTwitter:	
    Twitter     :	
    CreatedDate : 2021-07-22
    FileName    : rebuild-PSTitleBar.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    Tags        : Powershell,Console
    REVISIONS
    * 10:15 AM 7/22/2021 init vers
    .DESCRIPTION
    rebuild-PSTitleBar.ps1 - reconstruct Powershell console Titlebar in '[consHost] [role] - [domain] - [org] [svcs]' sorted format
    .EXAMPLE
    rebuild-PSTitleBar 
    Test for the string 'EMS' in the powershell console Title Bar
    .EXAMPLE
    rebuild-PSTitleBar -showdebug
    run with flag to permit code to run in ISE/VSCode (normally suppressed, they don't have consistent window titles)
    .LINK
    https://github.com/dsolodow/IndyPoSH/blob/master/Profile.ps1
    #>
    Param (
        [Parameter(HelpMessage="Debugging Flag [-showDebug]")]
        [switch] $showDebug
    )
    $showDebug=$true ; 
    #only use on console host; since ISE shares the WindowTitle across multiple tabs, this information is misleading in the ISE.
    If ( $host.name -eq 'ConsoleHost' -OR ($showDebug)) {
        # doing it with rgx
        #if($host.ui.rawui.windowtitle -match '(PS|PSc)\s(ADMIN|Console)\s-\s(.*)\s-(.*)'){
        #     $conshost,$consrole,$consdom=$matches[1..3]; 
        #     $conssvcs = $matches[4] -split ' '|?{$_}|%{"'$($_)'"}
        # }
        # simpler alt, take everything after last '-':
        [regex]$rgxsvcs = ('(' + (((Get-Variable  -name "TorMeta").value.OrgSvcs |foreach-object{[regex]::escape($_)}) -join '|') + ')') ;
        $Metas=(get-variable *meta|?{$_.name -match '^\w{3}Meta$'}) ; 
        if(!$rgxTenOrgs){ [regex]$rgxTenOrgs = ('(' + (($metas.name.substring(0,3) |foreach-object{[regex]::escape($_)}) -join '|') + ')') } ; 
        $consPrembl = $host.ui.rawui.windowtitle.substring(0,$host.ui.rawui.windowtitle.LastIndexOf('-')).trim() ;
        $consData = ($host.ui.rawui.windowtitle.substring(($host.ui.rawui.windowtitle.LastIndexOf('-'))+1) -split '\s\s').trim(); 
        $svcs = $consdata | ?{$_ -match $rgxsvcs} | sort | select -unique  ; 
        $Orgs = $consdata |?{$_ -match $rgxTenOrgs } | sort | select -unique  ; 
        [array]$titElems = @($consPrembl) ; 
        $titElems += (([array]$orgs + $svcs) -join ' ') ; 
        $host.ui.RawUI.WindowTitle = "$($titElems -join ' - ') " ; # manually add trailing space, to keep consistent for parsing.
    } ;
} ;
