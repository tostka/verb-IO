#*------v Function set-PSTitleBar v------
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
    Param ([parameter(Mandatory = $true,Position=0,HelpMessage="Title string to be set on current powershell console Titlebar[-title 'PS Window'")][String]$Title)
    If ($host.name -eq 'ConsoleHost') {
        #only use on console host; since ISE shares the WindowTitle across multiple tabs
        $host.ui.RawUI.WindowTitle = $Title ;
    } ;
} ; 
#*------^ END Function set-PSTitleBar ^------