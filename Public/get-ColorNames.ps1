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
    * 8:42 AM 2/16/2023 hybrided in new -narrow support (for psv2/ISE); added PARAM() block; -Narrow & -MaxColumns to support, stdized the vari names across both (shorter names , as this also winds up in psb-pscolors.cbp, unwrapped); updated CBH to include; added bnr support to both.
    * 4:24 PM 2/1/2023 typo, trailing missing }
    * 4:24 PM 1/30/2023 flipped freeshtanding script to function in verb-io 
    .DESCRIPTION
    get-ColorNames - Outputs a color-chart grid of all write-host -backgroundcolor & -foregroundcolors comboos, for easy selection of suitable combos for output. 
    
    Simple nested loop on the default consolecolor foreground & background color combos.
    .PARAMETER Narrow
    Optional Parameter to use a narrower layout, grouped by foreground color [-Narrow]
    .PARAMETER MaxColumns
    Optional Parameter to specify the number of columns of colors to display per line, in the -Narrow layout (defaults to 4)[-MaxColumns 5]
    .INPUTS
    Does not accepted piped input
    .OUTPUTS
    None.
    .EXAMPLE
    PS> get-ColorNames ;
    
          #*------v PS WIDE CONSOLE COLOR TABLE v------
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
          08:34:49:
          #*------^ PS WIDE CONSOLE COLOR TABLE ^------
		
    Demo typical pass output (obviously rendered in appriate colors in actual console output).
    .EXAMPLE
    PS>  get-ColorNames -Narrow ;
     
          11:55:11:
          #*------v PS NARROW/ADJ-WIDTH CONSOLE COLOR TABLE v------
          Black on Black|Black on DarkBlue|Black on DarkGreen|Black on DarkCyan|
          Black on DarkRed|Black on DarkMagenta|Black on DarkYellow|Black on Gray|
          Black on DarkGray|Black on Blue|Black on Green|Black on Cyan|
          Black on Red|Black on Magenta|Black on Yellow|Black on White|

          DarkBlue on Black|DarkBlue on DarkBlue|DarkBlue on DarkGreen|DarkBlue on DarkCyan|
          DarkBlue on DarkRed|DarkBlue on DarkMagenta|DarkBlue on DarkYellow|DarkBlue on Gray|
          DarkBlue on DarkGray|DarkBlue on Blue|DarkBlue on Green|DarkBlue on Cyan|
          DarkBlue on Red|DarkBlue on Magenta|DarkBlue on Yellow|DarkBlue on White|

          DarkGreen on Black|DarkGreen on DarkBlue|DarkGreen on DarkGreen|DarkGreen on DarkCyan|
          DarkGreen on DarkRed|DarkGreen on DarkMagenta|DarkGreen on DarkYellow|DarkGreen on Gray|
          DarkGreen on DarkGray|DarkGreen on Blue|DarkGreen on Green|DarkGreen on Cyan|
          DarkGreen on Red|DarkGreen on Magenta|DarkGreen on Yellow|DarkGreen on White|

          DarkCyan on Black|DarkCyan on DarkBlue|DarkCyan on DarkGreen|DarkCyan on DarkCyan|
          DarkCyan on DarkRed|DarkCyan on DarkMagenta|DarkCyan on DarkYellow|DarkCyan on Gray|
          DarkCyan on DarkGray|DarkCyan on Blue|DarkCyan on Green|DarkCyan on Cyan|
          DarkCyan on Red|DarkCyan on Magenta|DarkCyan on Yellow|DarkCyan on White|

          DarkRed on Black|DarkRed on DarkBlue|DarkRed on DarkGreen|DarkRed on DarkCyan|
          DarkRed on DarkRed|DarkRed on DarkMagenta|DarkRed on DarkYellow|DarkRed on Gray|
          DarkRed on DarkGray|DarkRed on Blue|DarkRed on Green|DarkRed on Cyan|
          DarkRed on Red|DarkRed on Magenta|DarkRed on Yellow|DarkRed on White|

          DarkMagenta on Black|DarkMagenta on DarkBlue|DarkMagenta on DarkGreen|DarkMagenta on DarkCyan|
          DarkMagenta on DarkRed|DarkMagenta on DarkMagenta|DarkMagenta on DarkYellow|DarkMagenta on Gray|
          DarkMagenta on DarkGray|DarkMagenta on Blue|DarkMagenta on Green|DarkMagenta on Cyan|
          DarkMagenta on Red|DarkMagenta on Magenta|DarkMagenta on Yellow|DarkMagenta on White|

          DarkYellow on Black|DarkYellow on DarkBlue|DarkYellow on DarkGreen|DarkYellow on DarkCyan|
          DarkYellow on DarkRed|DarkYellow on DarkMagenta|DarkYellow on DarkYellow|DarkYellow on Gray|
          DarkYellow on DarkGray|DarkYellow on Blue|DarkYellow on Green|DarkYellow on Cyan|
          DarkYellow on Red|DarkYellow on Magenta|DarkYellow on Yellow|DarkYellow on White|

          Gray on Black|Gray on DarkBlue|Gray on DarkGreen|Gray on DarkCyan|
          Gray on DarkRed|Gray on DarkMagenta|Gray on DarkYellow|Gray on Gray|
          Gray on DarkGray|Gray on Blue|Gray on Green|Gray on Cyan|
          Gray on Red|Gray on Magenta|Gray on Yellow|Gray on White|

          DarkGray on Black|DarkGray on DarkBlue|DarkGray on DarkGreen|DarkGray on DarkCyan|
          DarkGray on DarkRed|DarkGray on DarkMagenta|DarkGray on DarkYellow|DarkGray on Gray|
          DarkGray on DarkGray|DarkGray on Blue|DarkGray on Green|DarkGray on Cyan|
          DarkGray on Red|DarkGray on Magenta|DarkGray on Yellow|DarkGray on White|

          Blue on Black|Blue on DarkBlue|Blue on DarkGreen|Blue on DarkCyan|
          Blue on DarkRed|Blue on DarkMagenta|Blue on DarkYellow|Blue on Gray|
          Blue on DarkGray|Blue on Blue|Blue on Green|Blue on Cyan|
          Blue on Red|Blue on Magenta|Blue on Yellow|Blue on White|

          Green on Black|Green on DarkBlue|Green on DarkGreen|Green on DarkCyan|
          Green on DarkRed|Green on DarkMagenta|Green on DarkYellow|Green on Gray|
          Green on DarkGray|Green on Blue|Green on Green|Green on Cyan|
          Green on Red|Green on Magenta|Green on Yellow|Green on White|

          Cyan on Black|Cyan on DarkBlue|Cyan on DarkGreen|Cyan on DarkCyan|
          Cyan on DarkRed|Cyan on DarkMagenta|Cyan on DarkYellow|Cyan on Gray|
          Cyan on DarkGray|Cyan on Blue|Cyan on Green|Cyan on Cyan|
          Cyan on Red|Cyan on Magenta|Cyan on Yellow|Cyan on White|

          Red on Black|Red on DarkBlue|Red on DarkGreen|Red on DarkCyan|
          Red on DarkRed|Red on DarkMagenta|Red on DarkYellow|Red on Gray|
          Red on DarkGray|Red on Blue|Red on Green|Red on Cyan|
          Red on Red|Red on Magenta|Red on Yellow|Red on White|

          Magenta on Black|Magenta on DarkBlue|Magenta on DarkGreen|Magenta on DarkCyan|
          Magenta on DarkRed|Magenta on DarkMagenta|Magenta on DarkYellow|Magenta on Gray|
          Magenta on DarkGray|Magenta on Blue|Magenta on Green|Magenta on Cyan|
          Magenta on Red|Magenta on Magenta|Magenta on Yellow|Magenta on White|

          Yellow on Black|Yellow on DarkBlue|Yellow on DarkGreen|Yellow on DarkCyan|
          Yellow on DarkRed|Yellow on DarkMagenta|Yellow on DarkYellow|Yellow on Gray|
          Yellow on DarkGray|Yellow on Blue|Yellow on Green|Yellow on Cyan|
          Yellow on Red|Yellow on Magenta|Yellow on Yellow|Yellow on White|

          White on Black|White on DarkBlue|White on DarkGreen|White on DarkCyan|
          White on DarkRed|White on DarkMagenta|White on DarkYellow|White on Gray|
          White on DarkGray|White on Blue|White on Green|White on Cyan|
          White on Red|White on Magenta|White on Yellow|White on White|

          11:55:17:
          #*------^ PS NARROW/ADJ-WIDTH CONSOLE COLOR TABLE ^------      
          
    Demo -narrow output. 
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    ###[Alias('Alias','Alias2')]
    PARAM(
        [Parameter(HelpMessage="Optional Parameter to use a narrower layout, grouped by foreground color [-Narrow]")]
        [int]$Narrow,
        [Parameter(HelpMessage="Optional Parameter to specify the number of columns of colors to display per line, in the -Narrow layout (defaults to 4)[-MaxColumns 5]")]
        [int]$MaxColumns = 4
    ) ;
    $colors = [enum]::GetValues([System.ConsoleColor]) ;
    if(-not $Narrow){
        $sBnrS="`n#*------v PS WIDE CONSOLE COLOR TABLE v------" ; 
        write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($sBnrS)" ;
        Foreach ($back in $colors){
            Foreach ($fore in $colors) {Write-Host -ForegroundColor $fore -BackgroundColor $back "$($fore)|" -NoNewLine } ;
            Write-Host " on $back" ;
        } ;
        write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($sBnrS.replace('-v','-^').replace('v-','^-'))" ;
    } else { 
        $sBnrS="`n#*------v PS NARROW/ADJ-WIDTH CONSOLE COLOR TABLE v------" ; 
        write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($sBnrS)" ;
        if(-not $colors){$colors=[enum]::GetValues([System.ConsoleColor]);} ; # (to clip out usable block for non-module use)
        $prcd = 0 ;
        foreach($back in $colors){
            foreach($fore in $colors){
                $prcd++ ;
                if($prcd -lt $MaxColumns){
                    write-host -ForegroundColor $fore -BackgroundColor $back -nonewline ("{0} on {1}|" -f $fore,$back ) ;
                } else {
                    write-host -ForegroundColor $fore -BackgroundColor $back ("{0} on {1}|" -f $fore,$back ) ;
                    $prcd = 0 ;
                } ;
            } ;
            write-host "`n" ;
        } ;
        write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($sBnrS.replace('-v','-^').replace('v-','^-'))" ;
    } ; 
} ; 
#*------^ END Function get-ColorNames ^------