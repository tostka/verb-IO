#*------v replace-PSTitleBarText.ps1 v------
Function replace-PSTitleBarText {
    <#
    .SYNOPSIS
    replace-PSTitleBarText.ps1 - replaced specified text string in powershell console Titlebar with updated text
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-04-19
    FileName    : replace-PSTitleBarText.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    Tags        : PowershellConsole
    AddedCredit : mdjxkln
    AddedWebsite:	https://xkln.net/blog/putting-the-powershell-window-title-to-better-use/
    REVISIONS
   * 7:47 AM 7/26/2021init vers
    .DESCRIPTION
    replace-PSTitleBarText.ps1 - replace-PSTitleBarText.ps1 - replaced specified text string in powershell console Titlebar with updated text
    .PARAMETER Title
    Title string to be set on current powershell console Titlebar
    .EXAMPLE
    replace-PSTitleBarText -text ([Environment]::UserDomainName) -replace "$([Environment]::UserDomainName)-EMS" -whatif
    Replace title previously set with: ("PS ADMIN - " + [Environment]::UserDomainName), to "Domain-EMS - "
    .EXAMPLE
    replace-PSTitleBarText -text 'PS ADMIN' -replace 'PS ADMIN-EMS' -whatif -verbose
    replace title PS ADMIN string with PS ADMIN-EMS
    .LINK
    https://xkln.net/blog/putting-the-powershell-window-title-to-better-use/
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    #[Alias('set-PSTitle')]
    Param (
        [parameter(Mandatory = $true,Position=0,HelpMessage="Title substring to be replaced on current powershell console Titlebar (supports regex syntax)[-title 'Domain'")]
        [String]$Text,
        [parameter(Mandatory = $true,Position=0,HelpMessage="Title substring replace the -Text string with, on current powershell console Titlebar[-Replacement 'Domain-EMS'")]
        [String]$Replacement,
        #[Parameter(HelpMessage="switch to indicate that $Text is a regular expression [-regex]")]
        #[switch] $regex, # not needed -replace seamlessly supports both string & regex (tho' capture grpneed $1, $2 etc, unsupported in this simple variant
        [Parameter(HelpMessage="Whatif Flag  [-whatIf]")]
        [switch] $whatIf,
        [Parameter(HelpMessage="Debugging Flag [-showDebug]")]
        [switch] $showDebug
    )
    $showDebug=$true ; 
    $verbose = ($VerbosePreference -eq "Continue") ; 
    write-verbose "`$Text:$($Text)" ; 
    write-verbose "`$Replacement:$($Replacement)" ; 
    If ( $host.name -eq 'ConsoleHost' -OR ($showDebug)) {
        #only use on console host; since ISE shares the WindowTitle across multiple tabs
        #$bPresent = $true ;
        if(-not($whatif)){
            write-verbose "update:`$host.ui.RawUI.WindowTitle to`n$(($host.ui.RawUI.WindowTitle -replace $Text,$Replacement|out-string).trim())" ; 
            $host.ui.RawUI.WindowTitle = $host.ui.RawUI.WindowTitle -replace $Text,$Replacement ;
        } else { 
            write-host "update:`$host.ui.RawUI.WindowTitle to`n$(($host.ui.RawUI.WindowTitle -replace $Text,$Replacement|out-string).trim())" ;
        } 
        rebuild-PSTitleBar  -verbose:$($VerbosePreference -eq "Continue") -whatif:$($whatif);
    } ;
}

#*------^ replace-PSTitleBarText.ps1 ^------