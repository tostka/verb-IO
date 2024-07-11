#*------v rebuild-PSTitleBar.ps1 v------
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
    * 9:24 AM 7/11/2024 yanked $showdebug exemption; ISE won't work at all, just throws an error, only run in console host
    * 11:53 AM 7/26/2021 refactor for verbose/begin/proc/whatif etc
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
    [CmdletBinding()]
    Param (
        [Parameter(HelpMessage="Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    )
    BEGIN{
        $showDebug=$true ; 
        $verbose = ($VerbosePreference -eq "Continue") ; 
    } 
    PROCESS{
        #only use on console host; since ISE shares the WindowTitle across multiple tabs, this information is misleading in the ISE.
        #If ( $host.name -eq 'ConsoleHost' -OR ($showDebug)) {
        If ( $host.name -eq 'ConsoleHost') { # no point in running in ISE even w $showdebug; just creates an error
            # doing it with rgx
            #if($host.ui.rawui.windowtitle -match '(PS|PSc)\s(ADMIN|Console)\s-\s(.*)\s-(.*)'){
            #     $conshost,$consrole,$consdom=$matches[1..3]; 
            #     $conssvcs = $matches[4] -split ' '|?{$_}|%{"'$($_)'"}
            # }
            # simpler alt, take everything after last '-':
            #[regex]$rgxsvcs = ('(' + (((Get-Variable  -name "TorMeta").value.OrgSvcs |foreach-object{[regex]::escape($_)}) -join '|') + ')') ;
            # make it ^$ restrictive, no substring matches
            [regex]$rgxsvcs = ('^(' + (((Get-Variable  -name "TorMeta").value.OrgSvcs |foreach-object{[regex]::escape($_)}) -join '|') + ')$') ;
            write-verbose "`$rgxsvcs:$($rgxsvcs)" ; 
            $Metas=(get-variable *meta|?{$_.name -match '^\w{3}Meta$'}).name ; 
            if(!$rgxTenOrgs){ [regex]$rgxTenOrgs = ('^(' + (($metas.substring(0,3) |foreach-object{[regex]::escape($_)}) -join '|') + ')$') } ; 
            write-verbose "`$rgxTenOrgs:$($rgxTenOrgs)" ; 
            $consPrembl = $host.ui.rawui.windowtitle.substring(0,$host.ui.rawui.windowtitle.LastIndexOf('-')).trim() ;
            write-verbose "`$consPrembl:$($consPrembl)" ; 
            #$consData = ($host.ui.rawui.windowtitle.substring(($host.ui.rawui.windowtitle.LastIndexOf('-'))+1) -split '\s\s').trim(); 
            # split to an array, not space-dcelimtied
            $consData = ($host.ui.rawui.windowtitle.substring(($host.ui.rawui.windowtitle.LastIndexOf('-'))+1) -split '\s').trim(); 
            write-verbose "`$consData:`n$(($consData|out-string).trim())" ; 
            $svcs = $consdata | ?{$_ -match $rgxsvcs} | sort | select -unique  ; 
            write-verbose "`$svcs:`n$(($svcs|out-string).trim())" ; 
            $Orgs = $consdata |?{$_ -match $rgxTenOrgs } | sort | select -unique  ; 
            write-verbose "`$Orgs:`n$(($Orgs|out-string).trim())" ; 
            [array]$titElems = @($consPrembl) ; 
            write-verbose "`$titElems:`n$(($titElems|out-string).trim())" ; 
            $titElems += (([array]$orgs + $svcs) -join ' ') ; 
            write-verbose "`$titElems:`n$(($titElems|out-string).trim())" ; 
            if(-not($whatif)){
                write-verbose "update:`$host.ui.RawUI.WindowTitle to :`n'$($titElems -join ' - ') '" ; 
                $host.ui.RawUI.WindowTitle = "$($titElems -join ' - ') " ; # manually add trailing space, to keep consistent for parsing.
            } else { 
                write-host "update:`$host.ui.RawUI.WindowTitle to :`n'$($titElems -join ' - ') '" ;  
            } ;
        } ;
    }
    END{} ;
}

#*------^ rebuild-PSTitleBar.ps1 ^------