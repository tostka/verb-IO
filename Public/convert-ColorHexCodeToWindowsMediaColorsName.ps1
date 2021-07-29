#*------v Function convert-ColorHexCodeToWindowsMediaColorsName v------
Function convert-ColorHexCodeToWindowsMediaColorsName {
    <#
    .SYNOPSIS
    convert-ColorHexCodeToWindowsMediaColorsName.ps1 - Convert color hexcodes into equiv [windows.media.colors] name value (if exists)
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-04-19
    FileName    : convert-ColorHexCodeToWindowsMediaColorsName.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    Tags        : PowershellConsole
    AddedCredit : mdjxkln
    AddedWebsite:	https://xkln.net/blog/putting-the-powershell-window-title-to-better-use/
    REVISIONS
       * 11:36 AM 7/29/2021 completely unfinished, added (borked) code to populate $colors, but need to debug further. Looks like an abandoned concept that must have not been needed (likely around fact that ISE/VSC & winhost each implement colors differently, and aren't cross-compatible. 
       * 3:14 PM 4/19/2021 init vers
    .DESCRIPTION
    convert-ColorHexCodeToWindowsMediaColorsName.ps1 - Convert color hexcodes into equiv [windows.media.colors] name value (if exists)
    Issues: 1)Powershell ISE $psise supports a much wider range of colors than the native windows Console
    2) The ISE colors are accessible as: 
    $psise.Options.ConsolePaneBackgroundColor 
    $psISE.Options.ConsolePaneTextBackgroundColor
    $psISE.Options.ConsolePaneForegroundColor 
    ... but the values are RGB, or if .tostring() output as hex codes #FF9ACD32
    Neither of which are compatible with the windows console's color 'names'. 
    So I want a simple function to build an indexed hash of the [windows.media.colors] colors, and permit quick lookups of the hex value to return the matching [windows.media.colors] name value
    .PARAMETER ColorCode
    Colorhex code to be converted to [windows.media.colors] name value [-colorcode '#FF9ACD32'
    .OUTPUT
    Returns either a system.string containing the resolved WMC Color, or `$false, where no match was found for the specified ColorCode
    .EXAMPLE
    convert-ColorHexCodeToWindowsMediaColorsName 'EMS'
    Set the string 'EMS' as the powershell console Title Bar
    .EXAMPLE
    if ((Get-History).Count -gt 0) {
        convert-ColorHexCodeToWindowsMediaColorsName ((Get-History)[-1].CommandLine[0..25] -join '')
    }
    mdjxkln's example to set the title to the last entered command
    .EXAMPLE
    $ColorName = convert-ColorHexCodeToWindowsMediaColorsName -colorcode $psISE.Options.ConsolePaneTextBackgroundColor.tostring() 
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    Param ([parameter(Mandatory = $true,Position=0,HelpMessage="Colorhex code to be converted to [windows.media.colors] name value [-colorcode '#FF9ACD32'")][String]$ColorCode)
    BEGIN{
        # build indexed hash of media colors keyed on hexcodes
        Add-Type –assemblyName PresentationFramework
        $colors = [windows.media.colors] | Get-Member -static -Type Property |  Select -Expand Name ;
        $ISEColors = @{} ;
        $colors| foreach {
            $hexcolor = ([windows.media.colors]::$($_.name)).tostring() ; 
            $ISEColors[$hexcolor] = $_.name  ; 
        } ;
    } 
    PROCESS{
        # try for a lookup of specified $colorcode against the hash
        if($Colorname = $isecolors[$colorcode]){
            $Colorname | write-output ; 
        } else { 
            write-verbose "Unable to convert specified -ColorCode ($($ColorCode)) to a matching [windows.media.colors] color." ; 
            $false | write-output ; 
        } 
    } ; 
    END {} ;
} ; 
#*------^ END Function convert-ColorHexCodeToWindowsMediaColorsName ^------