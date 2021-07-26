#*------v set-PSTitleBar.ps1 v------
Function set-PSTitleBar {
    <#
    .SYNOPSIS
    set-PSTitleBar.ps1 - Set specified powershell console Titlebar
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-04-19
    FileName    : set-PSTitleBar.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    Tags        : PowershellConsole
    AddedCredit : mdjxkln
    AddedWebsite:	https://xkln.net/blog/putting-the-powershell-window-title-to-better-use/
    REVISIONS
    * 12:12 PM 7/26/2021 rework for verbose & whatif
    * 4:26 PM 7/23/2021 added rebuild-pstitlebar to post cleanup
       * 3:14 PM 4/19/2021 init vers
    .DESCRIPTION
    set-PSTitleBar.ps1 - Set specified powershell console Titlebar
    Added some examples posted by mdjxkln
    .PARAMETER Title
    Title string to be set on current powershell console Titlebar
    .EXAMPLE
    set-PSTitleBar 'EMS'
    Set the string 'EMS' as the powershell console Title Bar
    .EXAMPLE
    if ((Get-History).Count -gt 0) {
        set-PsTitleBar ((Get-History)[-1].CommandLine[0..25] -join '')
    }
    mdjxkln's example to set the title to the last entered command
    .EXAMPLE
    $ExampleArray = @(1..200) ; 
    $ExampleArray | % {
        Write-Host "Processing $_" # Doing some stuff...
        $PercentProcessed = [Math]::Round(($ExampleArray.indexOf($_) + 1) / $ExampleArray.Count * 100,0) ; 
        $Host.UI.RawUI.WindowTitle = "$PercentProcessed% Completed" ; 
        Start-Sleep -Milliseconds 50 ; 
    } ; 
    mdjxkln's example to display script progress
    .LINK
    https://xkln.net/blog/putting-the-powershell-window-title-to-better-use/
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    [Alias('set-PSTitle')]
    Param (
        [parameter(Mandatory = $true,Position=0,HelpMessage="Title string to be set on current powershell console Titlebar[-title 'PS Window'")]
        [String]$Title,
        [Parameter(HelpMessage="Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    )
    $verbose = ($VerbosePreference -eq "Continue") ; 
    If ( $host.name -eq 'ConsoleHost' -OR ($showDebug)) {
        #only use on console host; since ISE shares the WindowTitle across multiple tabs
        if(-not($whatif)){
            write-verbose "update:`$host.ui.RawUI.WindowTitle to`n$($Title|out-string).trim())" ; 
            $host.ui.RawUI.WindowTitle = $Title ;
        } else { 
            write-host "whatif:update:`$host.ui.RawUI.WindowTitle to`n$($Title|out-string).trim())" ; 
        } 
        Rebuild-PSTitleBar -verbose:$($VerbosePreference -eq "Continue") -whatif:$($whatif);
    } ;
}

#*------^ set-PSTitleBar.ps1 ^------