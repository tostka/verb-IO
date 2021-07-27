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
    * 8:15 AM 7/27/2021 sub'd in $rgxQ for duped rgx
    * 4:37 PM 2/27/2020 updated CBH
    # 8:46 AM 3/15/2017 Remove-PSTitleBar: initial version
    # 11/12/2014 - posted version
    .DESCRIPTION
    Remove-PSTitleBar.ps1 - Append specified string to the end of the powershell console Titlebar
    Inspired by dsolodow's Update-PSTitleBar code
    .PARAMETER Tag
    Tag string to be removed to current powershell console Titlebar (supports regex syntax)
    .EXAMPLE
    Remove-PSTitleBar 'EMS'
    Add the string 'EMS' to the powershell console Title Bar
    .LINK
    https://github.com/dsolodow/IndyPoSH/blob/master/Profile.ps1
    #>
    [CmdletBinding()]
    Param (
        #[parameter(Mandatory = $true,Position=0)][String]$Tag
        [parameter(Mandatory = $true,Position=0)]$Tag,
        [Parameter(HelpMessage="Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    )
    $showDebug=$true ; 
    $verbose = ($VerbosePreference -eq "Continue") ; 
    write-verbose "`$Tag:`n$(($Tag|out-string).trim())" ; 
    $rgxRgxOps = [regex]'[\[\]\\\{\}\+\*\?\.]+' ; 
    #only use on console host; since ISE shares the WindowTitle across multiple tabs, this information is misleading in the ISE.
    If ( $host.name -eq 'ConsoleHost' -OR ($showDebug)) {
        if($Tag -is [system.array]){ 
            foreach ($Tg in $Tag){
                if($Tg -notmatch $rgxRgxOps){
                    $rgxQ = "\s$([Regex]::Escape($Tg))\s" ; 
                } else { 
                    $rgxQ = "\s$($Tg)\s" ; # assume it's already a regex, no manual escape
                }; 
                write-verbose "`$rgxQ:$($rgxQ)" ; 
                if($host.ui.RawUI.WindowTitle  -match $rgxQ){
                    if(-not($whatif)){
                        write-verbose "update:`$host.ui.RawUI.WindowTitle to`n$(($host.ui.RawUI.WindowTitle -replace $rgxQ,''|out-string).trim())" ; 
                        #$host.ui.RawUI.WindowTitle = $host.ui.RawUI.WindowTitle.replace(" $Tg ","") ;
                        $host.ui.RawUI.WindowTitle = $host.ui.RawUI.WindowTitle -replace $rgxQ,'' ;
                    } else { 
                        write-host "update:`$host.ui.RawUI.WindowTitle to`n$(($host.ui.RawUI.WindowTitle -replace $rgxQ,''|out-string).trim())" ; 
                    } ; 
                }else{
                    write-verbose "(unable to match '$($rgxQ)' to `$host.ui.RawUI.WindowTitle`n`$($host.ui.RawUI.WindowTitle)')" ;
                } ;
            }
        } else { 
            if($Tag -notmatch $rgxRgxOps){
                $rgxQ = "\s$([Regex]::Escape($Tag))\s" ; 
            } else { 
                $rgxQ = "\s$($Tag)\s" ; # assume it's already a regex, no manual escape
            }; 
            write-verbose "`$rgxQ:$($rgxQ)" ; 
            if($host.ui.RawUI.WindowTitle -match $rgxQ){
                if(-not($whatif)){
                    write-verbose "update:`$host.ui.RawUI.WindowTitle to`n$(($host.ui.RawUI.WindowTitle -replace $rgxQ,''|out-string).trim())" ; 
                    #$host.ui.RawUI.WindowTitle = $host.ui.RawUI.WindowTitle.replace(" $Tag ","") ;
                    $host.ui.RawUI.WindowTitle = $host.ui.RawUI.WindowTitle -replace $rgxQ,'' ;
                }else{
                    write-host "-whatif:update:`$host.ui.RawUI.WindowTitle to`n$(($host.ui.RawUI.WindowTitle.replace(" $Tag ",'')|out-string).trim())" ; 
                } ;
            }else{
                write-verbose "(unable to match '$($rgxQ)' to `$host.ui.RawUI.WindowTitle`n`'$($host.ui.RawUI.WindowTitle)')" ;
            } ;
        } ; 
        rebuild-PSTitleBar -verbose:$($VerbosePreference -eq "Continue") -whatif:$($whatif);
    } ;
}

#*------^ Remove-PSTitleBar.ps1 ^------