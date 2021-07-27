#*------v parse-PSTitleBar.ps1 v------
Function parse-PSTitleBar {
    <#
    .SYNOPSIS
    parse-PSTitleBar.ps1 - parse Powershell console Titlebar into components '[consHost] [role] - [domain] - [org] [svcs]' sorted format
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    AddedCredit : 
    AddedWebsite:	
    AddedTwitter:	
    Twitter     :	
    CreatedDate : 2021-07-23
    FileName    : parse-PSTitleBar.ps1
    License     : MIT License
    Copyright   : (c) 2021 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    Tags        : Powershell,Console
    REVISIONS
    * 8:15 AM 7/27/2021 sub'd in $rgxQ for duped rgx
    * 11:42 AM 7/26/2021 added verbose echo support
    * 3:15 PM 7/23/2021 init vers
    .DESCRIPTION
    parse-PSTitleBar.ps1 - parse Powershell console Titlebar into components '[consHost] [role] - [domain] - [org] [svcs]' sorted format
    .EXAMPLE
    $consParts = parse-PSTitleBar 
    Parse the current powershell console Title Bar and return components
    .LINK
    https://github.com/dsolodow/IndyPoSH/blob/master/Profile.ps1
    #>
    [CmdletBinding()]
    Param (
        [Parameter(HelpMessage="Debugging Flag [-showDebug]")]
        [switch] $showDebug
    )
    BEGIN {
        $showDebug=$true ; 
        $verbose = ($VerbosePreference -eq "Continue") ; 
        # simpler alt, take everything after last '-':
        [regex]$rgxsvcs = ('^(' + (((Get-Variable  -name "TorMeta").value.OrgSvcs |foreach-object{[regex]::escape($_)}) -join '|') + ')$') ;
        write-verbose "using `$rgxsvcs:$($rgxsvcs)" ; 
        $Metas=(get-variable *meta|?{$_.name -match '^\w{3}Meta$'}).name ; 
        if(!$rgxTenOrgs){ [regex]$rgxTenOrgs = ('^(' + (($metas.substring(0,3) |foreach-object{[regex]::escape($_)}) -join '|') + ')$') } ; 
        write-verbose "`$rgxTenOrgs:$($rgxTenOrgs)" ; 
    } 
    PROCESS {
        #only use on console host; since ISE shares the WindowTitle across multiple tabs, this information is misleading in the ISE.
        If ( $host.name -eq 'ConsoleHost' -OR ($showDebug)) {
            $hshCons=[ordered]@{
                Host=$null ; 
                Role = $null ; 
                Domain = $null ; 
                Info = $null ; 
                Orgs = $null ; 
                Services = $null ; 
            } ; 
            # doing it with rgx
            #$rgxTitleBarTemplate = '(PS|PSc)\s(ADMIN|Console)\s-\s(.*)\s-(.*)' ; 
            $rgxTitleBarTemplate = '^(PS|PSc)\s(.*)\s-\s(.*)\s-(.*)$' ; 
            if($host.ui.rawui.windowtitle -match $rgxTitleBarTemplate){
                $hshCons.host,$hshCons.role,$hshCons.domain=$matches[1..3]; 
                if($hshCons.role.indexof('-')){
                    $xs = $hshCons.role ; 
                    $hshCons.role=$xs.tostring().split('-')[0] ; 
                    $hshCons.add('TermTag',($xs.tostring().split('-'))[1] ) ; 
                    remove-variable xs
                } ;
                $hshCons.Info = $matches[4] ;
                $hshCons.Orgs = $hshCons.Info -split ' '| ?{$_} | ?{$_ -match $rgxTenOrgs} | sort | select -unique  ; 
                $hshCons.Services = $hshCons.Info -split ' '| ?{$_} | ?{$_ -match $rgxsvcs} | sort | select -unique  ; 
            }
            <# simple parser        
            $consPrembl = $host.ui.rawui.windowtitle.substring(0,$host.ui.rawui.windowtitle.LastIndexOf('-')).trim() ;
            $consData = ($host.ui.rawui.windowtitle.substring(($host.ui.rawui.windowtitle.LastIndexOf('-'))+1) -split '\s\s').trim(); 
            $svcs = $consdata | ?{$_ -match $rgxsvcs} | sort | select -unique  ; 
            $Orgs = $consdata |?{$_ -match $rgxTenOrgs } | sort | select -unique  ; 
            [array]$titElems = @($consPrembl) ; 
            $titElems += (([array]$orgs + $svcs) -join ' ') ; 
            $host.ui.RawUI.WindowTitle = "$($titElems -join ' - ') " ; # manually add trailing space, to keep consistent for parsing.
            #>
        }
    }
    END {
        write-verbose "Returning values:`n$(($hshCons|out-string).trim())" ; 
        [pscustomobject]$hshCons | write-output ;  
    } ;
}

#*------^ parse-PSTitleBar.ps1 ^------