# get-ColorNames.ps1

#*------v Function get-ColorNames v------
function get-ColorNames {
    <#
    .SYNOPSIS
    get-ColorNames - Outputs a color-chart grid of all write-host -backgroundcolor & -foregroundcolors comboos, for easy selection of suitable combos for output. 
    .NOTES
	Author      : Todd Kadrie
	Website     : http://www.toddomation.com
	Twitter     : @tostka / http://twitter.com/tostka
	CreatedDate : 2023-01-30
	FileName    : get-ColorNames.ps1
	License     : MIT License
	Copyright   : (c) 2023 Todd Kadrie
	Github      : https://github.com/tostka/verb-IO
	Tags        : Powershell
	AddedCredit : REFERENCE
	AddedWebsite: URL
	AddedTwitter: URL
    REVISIONS
    * 4:24 PM 2/1/2023 typo, trailing missing }
    * 4:24 PM 1/30/2023 flipped freeshtanding script to function in verb-io 
    .DESCRIPTION
    get-ColorNames - Outputs a color-chart grid of all write-host -backgroundcolor & -foregroundcolors comboos, for easy selection of suitable combos for output. 
    
    Simple nested loop on the default consolecolor foreground & background color combos.
    
    .INPUTS
    Does not accepted piped input
    .OUTPUTS
    None.
    .EXAMPLE
    PS> get-ColorNames ;
    
		Black|DarkBlue|DarkGreen|DarkCyan|DarkRed|DarkMagenta|DarkYellow|Gray|DarkGray|Blue|Green|Cyan|Red|Magenta|Yellow|White| on Black
		Black|DarkBlue|DarkGreen|DarkCyan|DarkRed|DarkMagenta|DarkYellow|Gray|DarkGray|Blue|Green|Cyan|Red|Magenta|Yellow|White| on DarkBlue
		Black|DarkBlue|DarkGreen|DarkCyan|DarkRed|DarkMagenta|DarkYellow|Gray|DarkGray|Blue|Green|Cyan|Red|Magenta|Yellow|White| on DarkGreen
		Black|DarkBlue|DarkGreen|DarkCyan|DarkRed|DarkMagenta|DarkYellow|Gray|DarkGray|Blue|Green|Cyan|Red|Magenta|Yellow|White| on DarkCyan
		Black|DarkBlue|DarkGreen|DarkCyan|DarkRed|DarkMagenta|DarkYellow|Gray|DarkGray|Blue|Green|Cyan|Red|Magenta|Yellow|White| on DarkRed
		Black|DarkBlue|DarkGreen|DarkCyan|DarkRed|DarkMagenta|DarkYellow|Gray|DarkGray|Blue|Green|Cyan|Red|Magenta|Yellow|White| on DarkMagenta
		Black|DarkBlue|DarkGreen|DarkCyan|DarkRed|DarkMagenta|DarkYellow|Gray|DarkGray|Blue|Green|Cyan|Red|Magenta|Yellow|White| on DarkYellow
		Black|DarkBlue|DarkGreen|DarkCyan|DarkRed|DarkMagenta|DarkYellow|Gray|DarkGray|Blue|Green|Cyan|Red|Magenta|Yellow|White| on Gray
		Black|DarkBlue|DarkGreen|DarkCyan|DarkRed|DarkMagenta|DarkYellow|Gray|DarkGray|Blue|Green|Cyan|Red|Magenta|Yellow|White| on DarkGray
		Black|DarkBlue|DarkGreen|DarkCyan|DarkRed|DarkMagenta|DarkYellow|Gray|DarkGray|Blue|Green|Cyan|Red|Magenta|Yellow|White| on Blue
		Black|DarkBlue|DarkGreen|DarkCyan|DarkRed|DarkMagenta|DarkYellow|Gray|DarkGray|Blue|Green|Cyan|Red|Magenta|Yellow|White| on Green
		Black|DarkBlue|DarkGreen|DarkCyan|DarkRed|DarkMagenta|DarkYellow|Gray|DarkGray|Blue|Green|Cyan|Red|Magenta|Yellow|White| on Cyan
		Black|DarkBlue|DarkGreen|DarkCyan|DarkRed|DarkMagenta|DarkYellow|Gray|DarkGray|Blue|Green|Cyan|Red|Magenta|Yellow|White| on Red
		Black|DarkBlue|DarkGreen|DarkCyan|DarkRed|DarkMagenta|DarkYellow|Gray|DarkGray|Blue|Green|Cyan|Red|Magenta|Yellow|White| on Magenta
		Black|DarkBlue|DarkGreen|DarkCyan|DarkRed|DarkMagenta|DarkYellow|Gray|DarkGray|Blue|Green|Cyan|Red|Magenta|Yellow|White| on Yellow
		Black|DarkBlue|DarkGreen|DarkCyan|DarkRed|DarkMagenta|DarkYellow|Gray|DarkGray|Blue|Green|Cyan|Red|Magenta|Yellow|White| on White
		
    Demo typical pass output (obviously rendered in appriate colors in actual console output).
    .LINK
    https://github.com/tostka/verb-IO
    #>
    $ConsoleColors = [enum]::GetValues([System.ConsoleColor]) ;
	Foreach ($backgroundcolor in $ConsoleColors){
		Foreach ($foregroundcolor in $ConsoleColors) {Write-Host -ForegroundColor $foregroundcolor -BackgroundColor $backgroundcolor "$($foregroundcolor)|" -NoNewLine } ;
		Write-Host " on $backgroundcolor" ;
	} ;
} ; 
#*------^ END Function get-ColorNames ^------